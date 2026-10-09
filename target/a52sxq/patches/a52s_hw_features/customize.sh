LOG_STEP_IN "- Disabling LE Audio / Auracast Bluetooth profiles (as stock A52s)"
for p in bap.broadcast.assist bap.broadcast.source bap.unicast.client bas.client csip.set_coordinator hap.client \
    mcp.server ccp.server vcp.controller; do
    SET_PROP "product" "bluetooth.profile.$p.enabled" "false"
done
SET_PROP "product" "persist.bluetooth.samsung.leaudio.livecast" "false"
LOG_STEP_OUT

# Gemini Nano / AICore: the source SoC hardware configs (Fold8: SM8850; S25: SM8750 + SM8850) make AICore pick
# flagship NPU models that can't run on SM7325
while IFS= read -r f; do
    DELETE_FROM_WORK_DIR "product" "etc/sysconfig/$(basename "$f")"
done < <(find "$WORK_DIR/product/etc/sysconfig" -maxdepth 1 -name "google_aicore_QC_*.xml" 2> /dev/null | LC_ALL=C sort)
unset f

# Adaptive color tone: backend app needs a colour-temperature (TYPE_LIGHT_CCT) light sensor
DELETE_FROM_WORK_DIR "system" "system/priv-app/EnvironmentAdaptiveDisplay"
DECODE_APK "system" "system/priv-app/SecSettings/SecSettings.apk"
DECODE_APK "system_ext" "priv-app/SystemUI/SystemUI.apk"
python3 - "$APKTOOL_DIR" << 'PYEOF' || ABORT "Failed to hide the source-only settings"
import glob, re, sys
A = sys.argv[1]
UNSUPPORTED = ".method public getAvailabilityStatus()I\n    .locals 1\n\n    const/4 p0, 0x3\n\n    return p0\n"

def method_span(s, sig):
    start = s.index(sig)
    return start, s.index(".end method", start)

# SecSettings > Display > Adaptive color tone -> UNSUPPORTED_ON_DEVICE (3)
f = glob.glob(A + "/**/SecSettings.apk/smali*/com/samsung/android/settings/display/controller/SecEADPreferenceController.smali", recursive=True)
assert len(f) == 1, "SecEADPreferenceController"; f = f[0]
s = open(f).read()
start, end = method_span(s, ".method public getAvailabilityStatus()I")
s = s[:start] + UNSUPPORTED + s[end:]
open(f, "w").write(s)

# SecSettings > Display > Privacy display: S26 Ultra sets config_pd_enable, which gates the page, its search entry, the
# Pd*SettingsActivity components and the Routines action (the panel feature itself is 0); the S25 ships it false
f = glob.glob(A + "/**/SecSettings.apk/res/values/bools.xml", recursive=True)
assert len(f) == 1, "SecSettings bools"; f = f[0]
s = open(f).read()
s = s.replace('<bool name="config_pd_enable">true</bool>', '<bool name="config_pd_enable">false</bool>')
open(f, "w").write(s)

# SecSettings > Display > Continue apps on cover screen: fold sources only hide it on multi-fold models; flat
# sources (S25) already compile it to a constant UNSUPPORTED_ON_DEVICE
f = glob.glob(A + "/**/SecSettings.apk/smali*/com/samsung/android/settings/display/controller/FrontScreenAppsPreferenceController.smali", recursive=True)
assert len(f) <= 1, "FrontScreenAppsPreferenceController"
if f:
    f = f[0]
    s = open(f).read()
    start, end = method_span(s, ".method public getAvailabilityStatus()I")
    body = s[start:end]
    insns = [l.strip() for l in body.split("\n")[1:] if l.strip() and not l.strip().startswith((".", "#"))]
    if re.fullmatch(r"(sget-object p0, \S+\n)?const/4 p0, 0x3\nreturn p0", "\n".join(insns)):
        print("FrontScreenApps: already UNSUPPORTED_ON_DEVICE")
    else:
        assert "isMultiFoldModel" in body, "unexpected FrontScreenApps availability"
        s = s[:start] + UNSUPPORTED + s[end:]
        open(f, "w").write(s)

# SystemUI: Wireless DeX tile is offered unconditionally when the launcher exports DesktopModeTile.
# Match the spec comparison generically (registers/labels are build specific) and return false right after it.
f = glob.glob(A + "/**/SystemUI.apk/smali*/com/android/systemui/qs/TileFeatureChecker.smali", recursive=True)
assert len(f) == 1, "TileFeatureChecker"; f = f[0]
s = open(f).read()
pat = re.compile(r'( +)const-string (\w+), "com\.sec\.android\.app\.launcher/com\.honeyspace\.dexservice\.DesktopModeTile"\n\n'
                 r' +invoke-virtual \{\2, \w+\}, Ljava/lang/Object;->equals\(Ljava/lang/Object;\)Z\n\n'
                 r' +move-result (\w+)\n\n'
                 r' +if-eqz \3, :\w+\n\n')
hits = list(pat.finditer(s))
assert len(hits) == 1, "DesktopModeTile branch: %d" % len(hits)
m = hits[0]
mstart = s.rindex("\n.method ", 0, m.start())
assert s[mstart:s.index("\n", mstart + 1)].endswith(")Z"), "DesktopModeTile check is not in a boolean method"
ind, reg = m.group(1), m.group(3)
ret = "%sconst/4 %s, 0x0\n\n%sreturn %s\n" % (ind, reg, ind, reg)
rest = s[m.end():]
g = re.match(r" +goto(?:/16|/32)? :\w+\n", rest)
if g:  # the match branch only jumps to the shared "return true" tail
    s = s[:m.end()] + ret + rest[g.end():]
else:  # anything else (inline checks): return false before it, the old code stays unreachable
    s = s[:m.end()] + ret + "\n" + rest
open(f, "w").write(s)

# Default tile list (new setups): drop DeX and Auracast
f = glob.glob(A + "/**/SystemUI.apk/res/values/strings.xml", recursive=True)
assert len(f) == 1, "SystemUI strings"; f = f[0]
s = open(f).read()
key = '<string name="sec_quick_settings_tiles_default">'
i = s.index(key) + len(key); j = s.index("</string>", i)
tiles = [t for t in s[i:j].split(",") if t not in ("DesktopMode", "Auracast")]
s = s[:i] + ",".join(tiles) + s[j:]
open(f, "w").write(s)
PYEOF
LOG "- Hid Wireless DeX tile, Adaptive color tone, Continue apps on cover screen, LE Audio/Auracast and the source AICore SoC configs"
