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
PYEOF
