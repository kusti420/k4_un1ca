# See module.prop.
#
# Boot sequence that leaves the lock wallpaper hidden (9.3.53 log, 2026-10-18; S948B services.jar decompiled):
#   06.926  FallbackHome START -> fallback OPEN transition #2 (no shell player yet; it stays unfinished until the flush)
#   06.999  SystemUI process starts ("added application": no ImageWallpaper bind started it earlier, both wallpapers
#           are SpriteWallpaper's LayeredWallpaperService)
#   08.012  ShellTaskOrganizer.registerOrganizer -> TaskOrganizerController.registerTaskOrganizer ->
#           TransitionController.mRunningLock.runWhenIdle(): waits the 2 s timeout behind #2 ("took 2002ms")
#   08.116  config change -> fallback CHANGE transition #3 (collecting)
#   08.764  lock WallpaperWindowToken hidden (keyguard not shown yet, FallbackHome is the wallpaper target)
#   09.451  KeyguardViewMediator.setLockScreenShown (early, background thread) combined into #3: adjustWallpaperWindows
#           -> lock token setVisibility(true): collected (ChangeInfo.mVisible=false), commitVisibility(true) sets the
#           client visible, WindowAnimator skips the surface update because the token is collecting
#   09.455  adjustWallpaperWindows again (FallbackHome hidden by the keyguard sleep token, no visible target yet):
#           lock token requested false, not committed inside the transition -> requested false, client true
#   10.031  SystemUI registers its transition player -> flushRunningTransitions -> #3 aborted. The abort branch of
#           Transition.onTransactionReady only queues surface updates for changes whose requested visibility differs
#           from ChangeInfo.mVisible (false == false for the lock token)
#   later   NotificationShade becomes the wallpaper target -> lock token setVisibility(true) -> commitVisibility(true)
#           returns early (client already visible) and setVisible$1 queues nothing -> the token's SurfaceControl stays
#           hidden until the keyguard-going-away transition shows it (09:49:58.990)
# The hook: right before cleanUpInternal() in the abort branch, K4WallpaperAbort.onAborted(this) walks the aborted
# transition's participants. For every wallpaper token that no other transition holds, it commits a not-requested
# token to hidden (what finishTransition does after a played transition) and queues a surface visibility update
# (WindowAnimator applies it when requested == client). The next adjustWallpaperWindows then changes the client
# visibility for real and WindowAnimator shows the token.
SERVICES="system/framework/services.jar"
DECODE_APK "system" "$SERVICES" || ABORT "Failed to decode $SERVICES"
LOG "- Lock screen wallpaper after boot: resync wallpaper tokens of an aborted transition"
python3 - "$APKTOOL_DIR/system/${SERVICES//system\//}" << 'PYEOF' || ABORT "Failed to apply wallpaper_boot_transition"
import glob, os, re, sys
root = sys.argv[1]
WM = "Lcom/android/server/wm/"
K4 = WM + "K4WallpaperAbort;"
CALL = "invoke-static {%s}, " + K4 + "->onAborted(" + WM + "Transition;)V"

def one(rel):
    hits = glob.glob(root + "/smali*/" + rel)
    assert len(hits) == 1, "%s: %s" % (rel, hits)
    return hits[0]

def need(rel, decls):
    s = open(one(rel)).read()
    for d in decls:
        assert re.search(r"^" + re.escape(d) + r"$", s, re.M), "%s: %s" % (rel, d)

# everything the helper touches, with the types and access it assumes
need("com/android/server/wm/Transition.smali", (
    ".field public final mParticipants:Landroid/util/ArraySet;",
    ".field public final mWmService:" + WM + "WindowManagerService;",
    ".field public final mController:" + WM + "TransitionController;",
    ".method public final cleanUpInternal()V"))
need("com/android/server/wm/WindowManagerService.smali", (".field public final mAnimator:" + WM + "WindowAnimator;",))
need("com/android/server/wm/WindowAnimator.smali", (".method public final addSurfaceVisibilityUpdate(" + WM + "WindowContainer;)V",))
need("com/android/server/wm/TransitionController.smali", (".method public final inTransition(" + WM + "WindowContainer;)Z",))
need("com/android/server/wm/WindowContainer.smali", (".method public isVisibleRequested()Z",
                                                     ".method public asWallpaperToken()" + WM + "WallpaperWindowToken;"))
need("com/android/server/wm/WindowToken.smali", (".field public mClientVisible:Z",))
need("com/android/server/wm/WallpaperWindowToken.smali", (".method public final commitVisibility(Z)V",))
wwt = open(one("com/android/server/wm/WallpaperWindowToken.smali")).read()
assert ".super " + WM + "WindowToken;" in wwt, "WallpaperWindowToken no longer extends WindowToken"
# commitVisibility(Z) must still be "if (z == mClientVisible) return; setVisibleRequested(z); setVisible(z)": the
# early return is why the lost surface update is never repeated, and the fix relies on it changing the client state
cm = re.search(r"^\.method public final commitVisibility\(Z\)V\n.*?^\.end method\n", wwt, re.M | re.S).group(0)
assert "->mClientVisible:Z" in cm and "->setVisibleRequested(Z)Z" in cm, "WallpaperWindowToken.commitVisibility changed"

f = one("com/android/server/wm/Transition.smali")
s = open(f).read()
m = re.search(r"^\.method public final onTransactionReady\(Landroid/view/SurfaceControl\$Transaction;I\)V\n.*?^\.end method\n",
              s, re.M | re.S)
assert m, "Transition.onTransactionReady"
body = m.group(0)
this = re.match(r".*\n    \.locals \d+\n\n    move-object/from16 (v\d+), p0\n", body)
assert this and int(this.group(1)[1:]) < 16, "onTransactionReady: 'this' register changed"
this = this.group(1)
clean = "    invoke-virtual {%s}, %sTransition;->cleanUpInternal()V\n" % (this, WM)
assert body.count(clean) == 1, "onTransactionReady: cleanUpInternal calls: %d" % body.count(clean)
# the call must be the abort branch's: after the AbortTransition debug name and the ChangeInfo.mVisible resync loop
at = body.index(clean)
abort = body.rfind('"AbortTransition_SyncId<"', 0, at)
assert abort >= 0, "onTransactionReady: abort branch not found before cleanUpInternal"
tail = body[abort:at]
assert "->mVisible:Z" in tail and "->addSurfaceVisibilityUpdate(" in tail and "->scheduleAnimation()V" in tail, \
       "onTransactionReady: abort branch changed"
hook = "    " + (CALL % this) + "\n\n"
if hook + clean in body:
    print("  - Transition.onTransactionReady already hooked")
else:
    assert K4 not in body, "different K4WallpaperAbort hook present"
    s = s[:m.start()] + body.replace(clean, hook + clean, 1) + s[m.end():]
    open(f, "w").write(s)
    print("  - Transition.onTransactionReady: aborted transition -> K4WallpaperAbort.onAborted()")

dst = os.path.join(os.path.dirname(f), "K4WallpaperAbort.smali")
stale = [p for p in glob.glob(root + "/smali*/com/android/server/wm/K4WallpaperAbort.smali") if p != dst]
assert not stale, "stale helper copies: %s" % stale
open(dst, "w").write("""\
.class public final %(K4)s
.super Ljava/lang/Object;
.source "K4WallpaperAbort.java"


# a52sxq wallpaper_boot_transition patch. Called (WindowManager lock held) from the aborted branch of
# Transition.onTransactionReady, before cleanUpInternal(). A wallpaper token collected into a transition gets its
# client visibility committed while WindowAnimator skips its surface update (the token is collecting); the played
# transition shows/hides the SurfaceControl, an aborted one does not. Without this the token can end up client
# visible with a hidden surface, and commitVisibility(true) never touches it again (lock screen black from boot to
# the first unlock).

# direct methods
.method private constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static onAborted(%(WM)sTransition;)V
    .locals 9

    :try_start_0
    iget-object v0, p0, %(WM)sTransition;->mParticipants:Landroid/util/ArraySet;

    iget-object v1, p0, %(WM)sTransition;->mWmService:%(WM)sWindowManagerService;

    iget-object v1, v1, %(WM)sWindowManagerService;->mAnimator:%(WM)sWindowAnimator;

    iget-object v2, p0, %(WM)sTransition;->mController:%(WM)sTransitionController;

    invoke-virtual {v0}, Landroid/util/ArraySet;->size()I

    move-result v3

    add-int/lit8 v3, v3, -0x1

    :goto_0
    if-ltz v3, :cond_done

    invoke-virtual {v0, v3}, Landroid/util/ArraySet;->valueAt(I)Ljava/lang/Object;

    move-result-object v4

    check-cast v4, %(WM)sWindowContainer;

    invoke-virtual {v4}, %(WM)sWindowContainer;->asWallpaperToken()%(WM)sWallpaperWindowToken;

    move-result-object v4

    if-eqz v4, :cond_next

    # another (collecting or playing) transition owns its visibility now
    invoke-virtual {v2, v4}, %(WM)sTransitionController;->inTransition(%(WM)sWindowContainer;)Z

    move-result v5

    if-nez v5, :cond_next

    invoke-virtual {v4}, %(WM)sWindowContainer;->isVisibleRequested()Z

    move-result v5

    iget-boolean v6, v4, %(WM)sWindowToken;->mClientVisible:Z

    if-nez v5, :cond_queue

    if-eqz v6, :cond_queue

    const/4 v7, 0x0

    invoke-virtual {v4, v7}, %(WM)sWallpaperWindowToken;->commitVisibility(Z)V

    :cond_queue
    invoke-virtual {v1, v4}, %(WM)sWindowAnimator;->addSurfaceVisibilityUpdate(%(WM)sWindowContainer;)V

    new-instance v7, Ljava/lang/StringBuilder;

    const-string v8, "aborted transition: resync "

    invoke-direct {v7, v8}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v7, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    const-string v8, " requested="

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v7, v5}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    const-string v8, " clientVisible="

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v7, v6}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    const-string v8, "K4WallpaperAbort"

    invoke-static {v8, v7}, Landroid/util/Slog;->i(Ljava/lang/String;Ljava/lang/String;)I

    :cond_next
    add-int/lit8 v3, v3, -0x1

    goto :goto_0

    :cond_done
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0

    const-string v1, "K4WallpaperAbort"

    const-string v2, "resync failed"

    invoke-static {v1, v2, v0}, Landroid/util/Slog;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    return-void
.end method
""" % {"K4": K4, "WM": WM})
print("  - helper %s" % os.path.relpath(dst, root))
PYEOF

unset SERVICES
