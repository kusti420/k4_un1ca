# Home -> lock -> AOD: start Good Lock LockStar's process before AODService needs it (see module.prop).
#
# Every AOD session creates a new PluginAODImpl inside SystemUI (DozeService.onCreate -> PLUGIN_AOD connected), and
# its AOD_BRIGHTNESS BrightnessManager reads aod_brightness_level_main / aod_auto_brightness_enabled_main through
# RemoteLockStarRepositoryImpl -> LockEditorDataProvider (com.samsung.systemui.lockstar), synchronously, on SystemUI's
# main thread. LockStar is a cached "empty" process that ActivityManager kills ~30-60 s after use (am_kill "empty #27"
# on the 6/8 GB A52s), so nearly every screen-off from an unlocked phone cold-starts it while SystemUI's main thread
# waits: 9.3.48 log 2026-10-17 10:24:51, main thread silent 51.830 -> 52.370 (am_proc_start lockstar 51.850), the
# home-screen frame that should start the screen-off animation is a 1029 ms Davey, DOZE INITIALIZED 800 ms after
# goToSleep; 10:23:32 the same with 258 ms. AODService cannot be patched (Samsung signature, Store updates), so the
# provider is warmed instead:
#   - system_server: PhoneWindowManager.interceptPowerKeyDown(event, interactive, ...) with interactive = true, i.e.
#     ~300 ms before goToSleep (key hold + the 170 ms double-press window of the side key);
#   - SystemUI: KeyguardService$2.onStartedGoingToSleep (binder thread) for every other sleep reason (timeout,
#     double tap to sleep), ~230 ms before the read.
# Both call K4LockStarPrewarm.prewarm(Context, String), which spawns one background thread (never more than one in
# flight per process) that acquires and closes an unstable client for that authority if aod_mode != 0. With LockStar
# running already the acquire is a single binder call; without LockStar (or before first unlock) it returns null.
# SystemUI smali_classes3 is untouched (the hook is in classes2, the helper in the last dex).
SYSTEMUI="priv-app/SystemUI/SystemUI.apk"
SERVICES="system/framework/services.jar"
HELPER="$SRC_DIR/target/a52sxq/patches/lockstar_aod_prewarm/K4LockStarPrewarm.smali"

LOG "- AOD start: warm Good Lock LockStar's provider at power key / sleep start"

DECODE_APK "system_ext" "$SYSTEMUI" || ABORT "Failed to decode $SYSTEMUI"
DECODE_APK "system" "$SERVICES" || ABORT "Failed to decode $SERVICES"

python3 - "$APKTOOL_DIR/system_ext/$SYSTEMUI" "$APKTOOL_DIR/system/${SERVICES//system\//}" "$HELPER" << 'PYEOF' || ABORT "Failed to apply lockstar_aod_prewarm"
import glob, os, re, sys
sysui, services, helper_src = sys.argv[1:4]
MARK = "# k4 lockstar_aod_prewarm"
CALL = "Lcom/k4/lockstar/K4LockStarPrewarm;->prewarm(Landroid/content/Context;Ljava/lang/String;)V"
helper = open(helper_src).read()
assert "\n.class public final Lcom/k4/lockstar/K4LockStarPrewarm;\n" in helper

def one(root, rel):
    hits = glob.glob(root + "/smali*/" + rel)
    assert len(hits) == 1, (rel, hits)
    return hits[0]

def install_helper(root):
    dirs = sorted((d for d in glob.glob(root + "/smali_classes*") if re.fullmatch(r"smali_classes\d+", os.path.basename(d))),
                  key=lambda d: int(os.path.basename(d)[len("smali_classes"):]))
    assert dirs, "no smali_classesN in " + root
    dst = dirs[-1] + "/com/k4/lockstar/K4LockStarPrewarm.smali"
    stale = [f for f in glob.glob(root + "/smali*/com/k4/lockstar/K4LockStarPrewarm.smali") if f != dst]
    assert not stale, stale
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    open(dst, "w").write(helper)
    print("  - helper in %s/%s" % (os.path.basename(root), os.path.basename(dirs[-1])))

def hook(path, sig, locals_, inject, what):
    s = open(path).read()
    m = list(re.finditer(r"^" + re.escape(sig) + r"\n.*?^\.end method\n", s, re.M | re.S))
    assert len(m) == 1, "%s: %d" % (sig, len(m))
    body = m[0].group(0)
    if MARK in body:
        print("  - %s already hooked" % what)
        return
    head = sig + "\n" + locals_ + "\n"
    assert body.startswith(head), "%s: unexpected .locals" % what
    assert body.count(CALL) == 0
    new = head + "\n    " + MARK + "\n" + inject + body[len(head):]
    open(path, "w").write(s[:m[0].start()] + new + s[m[0].end():])
    print("  - hooked %s" % what)

# SystemUI: KeyguardService$2 (the IKeyguardService binder stub). v0 is written before it is read in the stock body.
f = one(sysui, "com/android/systemui/keyguard/KeyguardService$2.smali")
body = open(f).read()
assert "->this$0:Lcom/android/systemui/keyguard/KeyguardService;" in body
hook(f, ".method public final onStartedGoingToSleep(I)V", "    .locals 8",
     "    iget-object v0, p0, Lcom/android/systemui/keyguard/KeyguardService$2;->this$0:Lcom/android/systemui/keyguard/KeyguardService;\n\n"
     "    const-string v1, \"sysui sleep\"\n\n"
     "    invoke-static {v0, v1}, " + CALL + "\n",
     "SystemUI KeyguardService$2.onStartedGoingToSleep")
install_helper(sysui)

# system_server: power key down while interactive (p2). The stock body starts with
# "iget-object v0, p0, ...->mPowerKeyWakeLock", so v0/v1 are free here.
f = one(services, "com/android/server/policy/PhoneWindowManager.smali")
s = open(f).read()
sig = ".method public final interceptPowerKeyDown(Landroid/view/KeyEvent;ZZZ)V"
pm = list(re.finditer(r"^" + re.escape(sig) + r"\n.*?^\.end method\n", s, re.M | re.S))
assert len(pm) == 1, "interceptPowerKeyDown: %d" % len(pm)
if MARK not in pm[0].group(0):
    assert pm[0].group(0).startswith(sig + "\n    .locals 8\n\n    iget-object v0, p0, Lcom/android/server/policy/PhoneWindowManager;->mPowerKeyWakeLock:"), \
           "interceptPowerKeyDown: stock entry changed"
    assert "invoke-virtual {v0, p2}, Lcom/android/server/wm/WindowManagerService;->onPowerKeyDown(Z)V" in pm[0].group(0), \
           "p2 is no longer the interactive flag passed to onPowerKeyDown"
hook(f, sig, "    .locals 8",
     "    if-eqz p2, :k4_prewarm_skip\n\n"
     "    iget-object v0, p0, Lcom/android/server/policy/PhoneWindowManager;->mContext:Landroid/content/Context;\n\n"
     "    const-string v1, \"power key\"\n\n"
     "    invoke-static {v0, v1}, " + CALL + "\n\n"
     "    :k4_prewarm_skip\n",
     "services PhoneWindowManager.interceptPowerKeyDown")
install_helper(services)
PYEOF

unset SYSTEMUI SERVICES HELPER
