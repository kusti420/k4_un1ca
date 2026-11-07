# See module.prop. Both edits are anchored on the exact stock instruction sequence, abort on mismatch and are skipped
# when already applied.
DECODE_APK "system" "system/framework/framework.jar"
DECODE_APK "system_ext" "priv-app/SystemUI/SystemUI.apk"
python3 - "$APKTOOL_DIR/system/framework/framework.jar" "$APKTOOL_DIR/system_ext/priv-app/SystemUI/SystemUI.apk" << 'PYEOF' || ABORT "Failed to remove the per-frame Debug.getCallers calls"
import glob, re, sys
FW, SUI = sys.argv[1], sys.argv[2]
MARK = "# k4 frame_debug_callers"

def one(pattern):
    f = glob.glob(pattern)
    assert len(f) == 1, pattern
    return f[0]

def method(s, sig):
    assert s.count(sig) == 1, sig
    a = s.index(sig)
    return a, s.index(".end method", a)

# 1. View.setRequestedFrameRate(F): drop the Log.i(... Debug.getCallers(5)) block, keep the iput
f = one(FW + "/smali*/android/view/View.smali")
s = open(f).read()
a, b = method(s, "setRequestedFrameRate(F)V\n")
a = s.rindex(".method", 0, a)
body = s[a:b]
if MARK in body:
    print("  - View.setRequestedFrameRate: already patched")
else:
    m = re.search(r"\n(    new-instance v0, Ljava/lang/StringBuilder;\n.*?    invoke-static \{v1, v0\}, Landroid/util/Log;->i\(Ljava/lang/String;Ljava/lang/String;\)I\n)", body, re.S)
    assert m, "setRequestedFrameRate log block"
    blk = m.group(1)
    assert blk.count("Landroid/os/Debug;->getCallers(I)Ljava/lang/String;") == 1 and '"setRequestedFrameRate frameRate="' in blk, "log block shape"
    assert "iput" not in blk and "return" not in blk and ":cond" not in blk and ":goto" not in blk, "log block has control flow"
    after = body[m.end():]
    assert after.lstrip("\n ").startswith(".line") or after.lstrip("\n ").startswith("iput p1, p0, Landroid/view/View;->mPreferredFrameRate:F"), "iput must follow the log"
    body = body[:m.start(1)] + "    " + MARK + ": per-call Log.i with Debug.getCallers(5) removed\n" + body[m.end(1):]
    s = s[:a] + body + s[b:]
    open(f, "w").write(s)
    print("  - View.setRequestedFrameRate: per-call caller log removed")

# 2. QSAnimView.nowWithDebugCallers(I): timestamp only
f = one(SUI + "/smali*/com/android/systemui/qs/animator/QSAnimView.smali")
s = open(f).read()
a, b = method(s, ".method private final nowWithDebugCallers(I)Ljava/lang/String;\n")
body = s[a:b]
if MARK in body:
    print("  - QSAnimView.nowWithDebugCallers: already patched")
else:
    old = ("    const/4 v0, 0x3\n\n"
           "    invoke-static {v0, p1}, Landroid/os/Debug;->getCallers(II)Ljava/lang/String;\n\n"
           "    move-result-object p1\n")
    if body.count(old) != 1:
        old = old.replace("\n\n", "\n")
    assert body.count(old) == 1, "nowWithDebugCallers getCallers sequence"
    body = body.replace(old, "    " + MARK + ": no Debug.getCallers, timestamp only\n    const-string p1, \"\"\n")
    s = s[:a] + body + s[b:]
    open(f, "w").write(s)
    print("  - QSAnimView.nowWithDebugCallers: timestamp only")

# 3. per-frame Log.i of the blur pipeline (framework): ViewRootImpl.dispatchBlurRegionsEx ("dispatchBlurRegionsEx <n>",
#    tag = the window's VRI[...]@hash, so no log.tag prop can silence it) and BackgroundBlurDrawable$Aggregator
#    .getBlurRegionsCopyForRT ("getBlurRegionsCopyForRT, size : <n>", RenderThread). ~160 lines per shade pull each.
def strip_log(pattern, sig, text):
    f = one(pattern)
    s = open(f).read()
    a, b = method(s, sig)
    body = s[a:b]
    if MARK in body:
        print("  - %s: already patched" % text)
        return
    m = re.search(r"\n(    new-instance (v\d+), Ljava/lang/StringBuilder;\n(?:(?!    new-instance ).)*?    const-string v\d+, \"" + re.escape(text) + r"\"\n.*?    invoke-static \{v\d+, v\d+\}, Landroid/util/Log;->i\(Ljava/lang/String;Ljava/lang/String;\)I\n)", body, re.S)
    assert m, text
    blk = m.group(1)
    assert not re.search(r"^\s*(:|goto|if-|return|iput|sput|throw)", blk, re.M), "%s: control flow or stores in the log block" % text
    body = body[:m.start(1)] + "    " + MARK + ": per-frame Log.i \"" + text + "\" removed\n" + body[m.end(1):]
    open(f, "w").write(s[:a] + body + s[b:])
    print("  - %s: removed" % text)

strip_log(FW + "/smali*/android/view/ViewRootImpl.smali", ".method public blacklist dispatchBlurRegionsEx([Landroid/view/SemBlurRegionData;J)V\n", "dispatchBlurRegionsEx ")
strip_log(FW + "/smali*/com/android/internal/graphics/drawable/BackgroundBlurDrawable$Aggregator.smali", ".method public blacklist getBlurRegionsCopyForRT()[Lcom/android/internal/graphics/drawable/BackgroundBlurDrawable$BlurRegion;\n", "getBlurRegionsCopyForRT, size : ")

# 4. SystemUI QuickPanelLoggerHelper$PanelStateLogger.log: Debug.getCallers(n, " - ") appended to every new panel state
#    line (QuickPanelLog, ~180 lines per shade pull). The line is kept, without the caller list.
f = one(SUI + "/smali*/com/android/systemui/log/QuickPanelLoggerHelper$PanelStateLogger.smali")
s = open(f).read()
a, b = method(s, ".method public final log(ILjava/lang/String;Ljava/lang/String;)V\n")
body = s[a:b]
if MARK in body:
    print("  - PanelStateLogger.log: already patched")
else:
    m = re.search(r"    invoke-static \{p1, p2\}, Landroid/os/Debug;->getCallers\(ILjava/lang/String;\)Ljava/lang/String;\n\s*move-result-object p1\n", body)
    assert m and body.count("getCallers") == 1, "PanelStateLogger.log getCallers"
    body = body[:m.start()] + "    " + MARK + ": no caller list\n    const-string p1, \"\"\n" + body[m.end():]
    open(f, "w").write(s[:a] + body + s[b:])
    print("  - PanelStateLogger.log: caller list dropped")

# 5. SystemUI KeyguardSecUpdateMonitorImpl.isUserUnlocked$1(): LogUtil.d("isUserUnlocked userId:%s, unlocked:%s") with
#    boxing + String.format on every call; the Now Bar (NowBarCardViewModel via FaceWidgetKeyguardUpdateMonitorWrapper)
#    calls it on every shade frame (~80 lines and 0.4 % of the main thread per pull). The UserManager query stays.
f = one(SUI + "/smali*/com/android/keyguard/KeyguardSecUpdateMonitorImpl.smali")
s = open(f).read()
a, b = method(s, ".method public final isUserUnlocked$1()Z\n")
body = s[a:b]
if MARK in body:
    print("  - KeyguardSecUpdateMonitorImpl.isUserUnlocked: already patched")
else:
    m = re.search(r"\n(    invoke-static \{v0\}, Ljava/lang/Integer;->valueOf\(I\)Ljava/lang/Integer;\n.*?    invoke-static \{v1, v2, v0\}, Lcom/android/systemui/util/LogUtil;->d\(Ljava/lang/String;Ljava/lang/String;\[Ljava/lang/Object;\)V\n)", body, re.S)
    assert m and '"isUserUnlocked userId:%s, unlocked:%s"' in m.group(1), "isUserUnlocked log block"
    assert not re.search(r"^\s*(:|goto|if-|return|iput|sput)", m.group(1), re.M), "isUserUnlocked log block shape"
    after = body[m.end():].strip()
    assert after.startswith("return p0") or after.startswith(".line"), "return must follow the log"
    body = body[:m.start(1)] + "    " + MARK + ": per-call LogUtil.d removed\n" + body[m.end(1):]
    open(f, "w").write(s[:a] + body + s[b:])
    print("  - KeyguardSecUpdateMonitorImpl.isUserUnlocked: per-call log removed")
PYEOF
