# One UI 9 media player wave: WaveTuning's default stepX 2 -> 8 (see module.prop).
# Idea: com.samsung.music.qs.lagfix by DanGLVK (Apache-2.0), which does the same for the older audiovisseekbar
# renderer (already 10 in the S26U SystemUI). colorfulwave clamps stepX to 1..8 in MultiWaveAreaTrackRenderer.onDraw.
DECODE_APK "system_ext" "priv-app/SystemUI/SystemUI.apk"
python3 - "$APKTOOL_DIR/system_ext/priv-app/SystemUI/SystemUI.apk" << 'PYEOF' || ABORT "Failed to raise the media wave step"
import glob, re, sys
A = sys.argv[1]
f = glob.glob(A + "/smali*/com/android/systemui/media/colorfulwave/config/WaveTuning.smali")
assert len(f) == 1, "WaveTuning.smali: %d" % len(f)
f = f[0]
s = open(f).read()
# default for the 7th constructor argument (stepX, mask bit 0x40) in the synthetic default-args constructor
pat = re.compile(r"(and-int/lit8 (v\d+), v\d+, 0x40\n\s*\n?\s*if-eqz \2, :cond_\w+\n\s*\n?\s*)const/4 \2, 0x2\n")
if "const/16 v2, 0x8  # k4 stepX" in s:
    print("  - WaveTuning stepX default already 8")
else:
    n = len(pat.findall(s))
    assert n == 1, "stepX default: %d matches" % n
    s = pat.sub(lambda m: m.group(1) + "const/16 %s, 0x8  # k4 stepX\n" % m.group(2), s)
    open(f, "w").write(s)
    print("  - WaveTuning stepX default 2 -> 8")
PYEOF
