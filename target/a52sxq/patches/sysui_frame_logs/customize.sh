# Per-frame debug logging in SystemUI animations (see module.prop). Every Log.d/Log.v that reaches logd costs a string
# build plus a liblog socket write (~15-40 us on the A78/A55 cores), and these run once or several times per frame.
#
# 1. R8 outline SecQpBlurController$1$1$2$$ExternalSyntheticOutline0.m(F, prefix, tag) = Log.d(tag, prefix + f).
#    24 callers, all debug traces of a float: QsOpenAnimator "panelExpandedFraction", QsExpandAnimator
#    "setQsExpansionPosition", SecQpBlurController / NotificationPanelView "setTransitionToFullShadeAmount",
#    LockscreenShadeTransitionController "overDragDownAmount", ImmersiveScrollAnimator "setPosition",
#    SecPanelBackgroundBinder "setAlpha", SecNowBarOccludeAnimationController progress, ... Body emptied: the float boxing
#    and string concatenation happen inside the outline, so they go too. The return value of Log.d was never used.
# 2. WMShell ProtoLog groups that Samsung ships with logcat output on, on the wmshell main thread (it also drives the
#    transition animations): WM_SHELL_RECENT_TASKS ("Added fullscreen task: N" per task on every generateList, 1,834
#    lines in the 2026-10-16 log, ~400/s while Recents is open), WM_SHELL_DRAG_AND_DROP ("Drag event: ACTION_DRAG_LOCATION"
#    per touch move during any drag) and WM_SHELL_TASK_ORG. Their default mLogToLogcat is set false in the enum
#    constructor, so PerfettoProtoLogImpl.log skips logToLogcat (and the message formatting). Perfetto ProtoLog tracing
#    is unchanged, and `wm shell protolog enable-text WM_SHELL_RECENT_TASKS` (or `dumpsys activity service SystemUIService
#    WMShell protolog enable-text ...`) still turns them back on at runtime.
# 3. log.tag props (liblog drops the write; native ALOGD skips the formatting too), all D-level traces seen per frame
#    while pulling the shade on the lock screen (2026-10-16 blur_clock run): SurfaceComposerClient "setBlurRegions" +
#    one "BlurRegion #n" line per region on the RenderThread (600 lines), PluginLockMediatorImpl "setQsExpansion",
#    SecPanelWindowBlurInteractor "Window Blur", SecPanelWindowBlurBinder "setBlurInfo". `adb shell setprop log.tag.<TAG> D`
#    brings any of them back for a debugging session.
DECODE_APK "system_ext" "priv-app/SystemUI/SystemUI.apk"
python3 - "$APKTOOL_DIR/system_ext/priv-app/SystemUI/SystemUI.apk" << 'PYEOF' || ABORT "Failed to remove SystemUI per-frame logs"
import glob, re, sys
A = sys.argv[1]
MARK = "# k4 sysui_frame_logs"

# 1. float-log outline
f = glob.glob(A + "/smali*/com/android/systemui/blur/SecQpBlurController$1$1$2$$ExternalSyntheticOutline0.smali")
assert len(f) == 1, f
f = f[0]
s = open(f).read()
if MARK in s:
    print("  - float debug-log outline already emptied")
else:
    m = list(re.finditer(r"^\.method public static m\(FLjava/lang/String;Ljava/lang/String;\)V\n.*?^\.end method\n", s, re.M | re.S))
    assert len(m) == 1, "outline m(FLString;String;)V: %d" % len(m)
    body = m[0].group(0)
    # must be exactly: StringBuilder(prefix).append(f).toString() -> Log.d(tag, msg); nothing else
    calls = re.findall(r"invoke-\w+ \{[^}]*\}, (\S+)", body)
    assert calls == ["Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V",
                     "Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;",
                     "Ljava/lang/StringBuilder;->toString()Ljava/lang/String;",
                     "Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I"], calls
    new = (".method public static m(FLjava/lang/String;Ljava/lang/String;)V\n"
           "    .locals 0\n\n"
           "    %s: per-frame float Log.d traces (Log.d(tag, prefix + f)) dropped\n"
           "    return-void\n"
           ".end method\n") % MARK
    s = s[:m[0].start()] + new + s[m[0].end():]
    open(f, "w").write(s)
    print("  - float debug-log outline emptied")

# 2. ShellProtoLogGroup: logcat off by default for the chatty groups
G = "Lcom/android/wm/shell/protolog/ShellProtoLogGroup;"
NOISY = ["WM_SHELL_RECENT_TASKS", "WM_SHELL_DRAG_AND_DROP", "WM_SHELL_TASK_ORG"]
f = glob.glob(A + "/smali*/com/android/wm/shell/protolog/ShellProtoLogGroup.smali")
assert len(f) == 1, f
f = f[0]
s = open(f).read()
if MARK in s:
    print("  - ShellProtoLogGroup already patched")
    sys.exit(0)
for n in NOISY:
    assert len(re.findall(r'const-string(?:/jumbo)? \w+, "%s"\n' % n, s)) == 1, "group %s" % n
    assert s.count("\n.field public static final enum %s:%s\n" % (n, G)) == 1, "field %s" % n
m = list(re.finditer(r"^\.method private constructor <init>\(Ljava/lang/String;IZZLjava/lang/String;\)V\n.*?^\.end method\n", s, re.M | re.S))
assert len(m) == 1, "constructor: %d" % len(m)
body = m[0].group(0)
assert body.count("    .locals 0\n") == 1, "constructor locals"
iput = "    iput-boolean p4, p0, %s->mLogToLogcat:Z\n" % G
assert body.count(iput) == 1, "mLogToLogcat store"
chk = "".join("""    const-string v0, "%s"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :k4_no_logcat

""" % n for n in NOISY)
ins = ("    %s: no logcat copy for %s (perfetto ProtoLog unchanged)\n" % (MARK, ", ".join(NOISY)) + chk +
       "    goto :k4_logcat_keep\n\n    :k4_no_logcat\n    const/4 p4, 0x0\n\n    :k4_logcat_keep\n")
nb = body.replace("    .locals 0\n", "    .locals 1\n", 1).replace(iput, ins + iput, 1)
s = s[:m[0].start()] + nb + s[m[0].end():]
open(f, "w").write(s)
print("  - ShellProtoLogGroup: logcat off for " + ", ".join(NOISY))
PYEOF

SET_PROP "system" "log.tag.SurfaceComposerClient" "I"
SET_PROP "system" "log.tag.PluginLockMediatorImpl" "I"
SET_PROP "system" "log.tag.SecPanelWindowBlurInteractor" "I"
SET_PROP "system" "log.tag.SecPanelWindowBlurBinder" "I"
