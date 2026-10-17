# AOD <-> lock screen: shorter clock morph / light reveal (see module.prop).
#
# On wake from AOD, NotificationPanelViewController.setDozing -> StatusBarStateControllerImpl.createDarkAnimator runs
# dozeAmount 0.99 -> 0 over 500 ms (LINEAR in time, TOUCH_RESPONSE_REVERSE applied in setDozeAmountInternal); every
# step is pushed to the AOD/FaceWidget plugin clock (FaceWidgetClockPage.updateFontDozeAnimFraction -> variable font
# HEGT axis = the clock "size change"), the LockStar plugin and the lock-screen widgets. The matching light reveal
# (LightRevealScrimInteractor, every keyguard transition except GONE -> AOD with full-screen AOD) is also 500 ms.
# 9.3.48 log 2026-10-17 10:24:54-55: the animator started 290 ms after the key (54.967), the first ~200 ms of it fell
# into the AOD plugin teardown on the main thread (first drawn step 0.75 at 55.216), and the rest ran at ~30 fps
# (30-60 ms per frame: typeface rebuild per digit, 3-4 semGetWallpaperColors binder calls per frame) until 55.549.
# Both 500 ms constants -> 350 ms (two const-wide edits, no new methods; classes3 stays at its method count).
# The KeyguardTransition DOZING -> LOCKSCREEN duration (FromDozingTransitionInteractor.TO_LOCKSCREEN_DURATION, 500 ms)
# is deliberately left alone: DozingToLockscreenTransitionViewModel builds sub-animation flows inside it and a
# shorter total could fail their startTime + duration <= transition duration checks.
SYSTEMUI="priv-app/SystemUI/SystemUI.apk"
MORPH_MS=350
LOG "- AOD <-> lock screen clock morph and light reveal: 500 -> $MORPH_MS ms"
DECODE_APK "system_ext" "$SYSTEMUI" || ABORT "Failed to decode $SYSTEMUI"
python3 - "$APKTOOL_DIR/system_ext/$SYSTEMUI" "$MORPH_MS" << 'PYEOF' || ABORT "Failed to apply aod_lockscreen_morph_speed"
import glob, re, sys
root, ms = sys.argv[1], int(sys.argv[2])
assert 200 <= ms < 500
NEW = "0x%x" % ms

def one(rel):
    hits = glob.glob(root + "/smali*/" + rel)
    assert len(hits) == 1, (rel, hits)
    return hits[0]

def edit(rel, method_re, old, new, what):
    f = one(rel)
    s = open(f).read()
    m = list(re.finditer(method_re, s, re.M | re.S))
    assert len(m) == 1, "%s: method %d" % (what, len(m))
    body = m[0].group(0)
    if new in body and old not in body:
        print("  - %s already %d ms" % (what, ms))
        return
    assert body.count(old) == 1, "%s: %d x %r" % (what, body.count(old), old)
    open(f, "w").write(s[:m[0].start()] + body.replace(old, new) + s[m[0].end():])
    print("  - %s: 500 -> %d ms" % (what, ms))

# dozeAmount animator (both directions: AOD -> lock screen and lock screen -> AOD)
edit("com/android/systemui/statusbar/StatusBarStateControllerImpl.smali",
     r"^\.method public createDarkAnimator\(\)Landroid/animation/ObjectAnimator;\n.*?^\.end method\n",
     "    const-wide/16 v0, 0x1f4\n\n    invoke-virtual {p0, v0, v1}, Landroid/animation/ObjectAnimator;->setDuration(J)Landroid/animation/ObjectAnimator;\n",
     "    const-wide/16 v0, %s\n\n    invoke-virtual {p0, v0, v1}, Landroid/animation/ObjectAnimator;->setDuration(J)Landroid/animation/ObjectAnimator;\n" % NEW,
     "StatusBarStateControllerImpl.createDarkAnimator")

# light reveal for keyguard transitions (the 650 ms GONE -> AOD full-screen reveal and the 0 ms cases stay)
edit("com/android/systemui/keyguard/domain/interactor/LightRevealScrimInteractor$listenForStartedKeyguardTransitionStep$1$1.smali",
     r"^\.method public final emit\(.*?^\.end method\n",
     "    :cond_2\n    const-wide/16 v5, 0x1f4\n",
     "    :cond_2\n    const-wide/16 v5, %s\n" % NEW,
     "LightRevealScrimInteractor reveal duration")
PYEOF
unset SYSTEMUI MORPH_MS
