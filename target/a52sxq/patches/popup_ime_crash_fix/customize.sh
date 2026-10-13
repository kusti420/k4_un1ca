# SystemUI dies (FATAL EXCEPTION: wmshell.main, NullPointerException in
# FreeformImeController.showImeStartPositioning) every time the keyboard opens while a pop-up view (freeform) task has
# focus, then again after each restart while that pop-up task still exists.
#
# Cause: FreeformImeController.freeformImeCallbackFinder is a lateinit that only
# DesktopModeWindowDecorViewModel.onInit() assigns. WMShellModule.provideDesktopModeWindowDecorViewModel() returns
# Optional.empty() when DesktopState.canEnterDesktopModeOrShowAppHandle() is false, which is the case on this port
# (sff.sh SEC_FLOATING_FEATURE_COMMON_SUPPORT_DESKTOP_WINDOWING=FALSE + overlay config_isDesktopModeSupported=false),
# so the field stays null while FreeformImeController itself is still created and still tracks freeform tasks.
# R8 compiled the lateinit check to "if null use null", so the next invoke() is the NPE.
#
# Fix: when the finder is null, leave the two entry points early. The pop-up window is then simply not moved out of
# the keyboard's way (it never was on this port: it crashed instead).
DECODE_APK "system_ext" "priv-app/SystemUI/SystemUI.apk"
python3 - "$APKTOOL_DIR/system_ext/priv-app/SystemUI/SystemUI.apk" << 'PYEOF' || ABORT "Failed to apply the pop-up view keyboard crash fix"
import glob, re, sys
f = glob.glob(sys.argv[1] + "/smali*/com/android/wm/shell/freeform/ime/FreeformImeController.smali")
assert len(f) == 1, "FreeformImeController: %d" % len(f)
s = open(f[0]).read()
if "    if-nez v0, :cond_1\n\n    return-void\n" in s[s.index(".method public final showImeStartPositioning(ILjava/lang/String;)V"):]:
    print("FreeformImeController: already guarded")
    sys.exit(0)
FIELD = r"Lcom/android/wm/shell/freeform/ime/FreeformImeController;->freeformImeCallbackFinder:[^\n]+\n"

def method(sig):
    start = s.index(sig)
    return start, s.index(".end method", start)

# 1. showImeStartPositioning(ILjava/lang/String;)V - first read of the finder
start, end = method(".method public final showImeStartPositioning(ILjava/lang/String;)V")
body = s[start:end]
pat = re.compile(r"(iget-object (v\d+), p0, " + FIELD + r"\n(?:    const/4 v\d+, 0x0\n\n)?    if-nez \2, (:cond_\w+)\n\n)    move-object \2, v\d+\n")
assert len(pat.findall(body)) == 1, "showImeStartPositioning guard site: %d" % len(pat.findall(body))
body = pat.sub(lambda m: m.group(1) + "    return-void\n", body)
s = s[:start] + body + s[end:]

# 2. removeImeTarget(ILjava/lang/String;)...FreeformImeTargetImpl; - returns the removed target (v0) at its end
start, end = method(".method public final removeImeTarget(ILjava/lang/String;)Lcom/android/wm/shell/freeform/ime/FreeformImeTargetImpl;")
body = s[start:end]
assert body.rstrip().endswith("return-object v1"), "removeImeTarget tail changed"
assert re.search(r":cond_\w+\n(?:    \.line \d+\n)?    return-object v0\n", body), "removeImeTarget no longer returns v0"
pat = re.compile(r"(iget-object p0, p0, " + FIELD + r"\n    if-nez p0, (:cond_\w+)\n\n)    move-object p0, v1\n")
assert len(pat.findall(body)) == 1, "removeImeTarget guard site: %d" % len(pat.findall(body))
body = pat.sub(lambda m: m.group(1) + "    return-object v0\n", body)
s = s[:start] + body + s[end:]

open(f[0], "w").write(s)
PYEOF
LOG "- SystemUI: pop-up view no longer crashes when the keyboard opens (FreeformImeController null finder guard)"
