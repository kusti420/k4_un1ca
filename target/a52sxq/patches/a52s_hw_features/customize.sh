LOG_STEP_IN "- Disabling LE Audio / Auracast Bluetooth profiles (as stock A52s)"
for p in bap.broadcast.assist bap.broadcast.source bap.unicast.client bas.client csip.set_coordinator hap.client \
    mcp.server ccp.server vcp.controller; do
    SET_PROP "product" "bluetooth.profile.$p.enabled" "false"
done
SET_PROP "product" "persist.bluetooth.samsung.leaudio.livecast" "false"
LOG_STEP_OUT

# Gemini Nano / AICore: the SM8850 hardware config makes AICore pick SM8850 NPU models that can't run on SM7325
DELETE_FROM_WORK_DIR "product" "etc/sysconfig/google_aicore_QC_SM8850.xml"

# Adaptive color tone: backend app needs a colour-temperature (TYPE_LIGHT_CCT) light sensor
DELETE_FROM_WORK_DIR "system" "system/priv-app/EnvironmentAdaptiveDisplay"
DECODE_APK "system" "system/priv-app/SecSettings/SecSettings.apk"
DECODE_APK "system_ext" "priv-app/SystemUI/SystemUI.apk"
python3 - "$APKTOOL_DIR" << 'PYEOF' || ABORT "Failed to hide the Fold8-only settings"
import glob, sys
A = sys.argv[1]
# SecSettings > Display > Adaptive color tone -> UNSUPPORTED_ON_DEVICE (3)
f = glob.glob(A + "/**/SecSettings.apk/smali*/com/samsung/android/settings/display/controller/SecEADPreferenceController.smali", recursive=True)
assert len(f) == 1, "SecEADPreferenceController"; f = f[0]
s = open(f).read()
start = s.index(".method public getAvailabilityStatus()I")
end = s.index(".end method", start)
s = s[:start] + ".method public getAvailabilityStatus()I\n    .locals 1\n\n    const/4 p0, 0x3\n\n    return p0\n" + s[end:]
open(f, "w").write(s)

# SystemUI: Wireless DeX tile is offered unconditionally when the launcher exports DesktopModeTile
f = [x for x in glob.glob(A + "/**/SystemUI.apk/smali*/com/android/systemui/qs/TileFeatureChecker.smali", recursive=True)]
assert len(f) == 1, "TileFeatureChecker"; f = f[0]
s = open(f).read()
old = ('    const-string p0, "com.sec.android.app.launcher/com.honeyspace.dexservice.DesktopModeTile"\n\n'
       '    invoke-virtual {p0, v0}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z\n\n'
       '    move-result p0\n\n'
       '    if-eqz p0, :cond_1b\n\n'
       '    goto :goto_4\n')
assert s.count(old) == 1, "DesktopModeTile branch"
s = s.replace(old, old.replace("    goto :goto_4\n", "    const/4 p0, 0x0\n\n    return p0\n"))
open(f, "w").write(s)

# Default tile list (new setups): drop DeX and Auracast
f = [x for x in glob.glob(A + "/**/SystemUI.apk/res/values/strings.xml", recursive=True)]
assert len(f) == 1, "SystemUI strings"; f = f[0]
s = open(f).read()
key = '<string name="sec_quick_settings_tiles_default">'
i = s.index(key) + len(key); j = s.index("</string>", i)
tiles = [t for t in s[i:j].split(",") if t not in ("DesktopMode", "Auracast")]
s = s[:i] + ",".join(tiles) + s[j:]
open(f, "w").write(s)
PYEOF
LOG "- Hid Wireless DeX tile, Adaptive color tone, LE Audio/Auracast and the SM8850 AICore config"
