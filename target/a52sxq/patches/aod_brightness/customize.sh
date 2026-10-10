# Automatic AOD brightness with wallpaper AOD (sff.sh LCD_CONFIG_AOD_FULLSCREEN=1).
#
# AODService (S26 Ultra) has two brightness modes, chosen by BrightnessManager.isPlatformBrightness() (obfuscated i()):
#   g6.p && bj1.S(), where g6.p = ha6.K0 = (LCD_CONFIG_AOD_FULLSCREEN > 0) and bj1.S() = (AOD_FULLSCREEN == 1).
# - fullscreen "platform brightness" mode (true since wallpaper AOD was enabled): the sensor hub is registered with
#   CarryingDetectionAttribute(9, low, high) ("registerInner isHysteresis: true") and reports lux; updateLux() turns lux
#   into nits with a Spline over config_autoBrightnessLevels_doze / config_autoBrightnessDisplayValuesNits_doze, then
#   DisplayManager.convertToBrightness(nits) -> platform brightness, min()'d with the lock screen brightness, and sends
#   onUpdateDozeBrightness(mode, -1, brightness) to SystemUI. Those two arrays are empty in framework-res and only the
#   S26 Ultra's product overlay fills them, so here the spline is null, every lux gives 0 nits -> brightness 0 ->
#   AODScreenBrightness float 0.0 -> the panel's HLPM 2 nit level in any light ("mCurrentPlatformBrightness : 0").
# - index mode (stock A52s, AOD_FULLSCREEN=0): the hub is registered with CarryingDetectionAttribute(11, ...) and sends
#   status 101-104 (reason 12) = AOD brightness index 0-3 with its own lux thresholds and hysteresis; while charging the
#   light sensor picks the index (<=2 / <=50 / <=100 / >100 lux). The index is capped by the lock screen brightness and
#   SystemUI maps it through config_aodBrightnessValues (0, 12, 32, 55 from the A52s overlay) onto the S6E3FC3
#   samsung,aod_candela_map_table (bl 0-11 = 2 nit, 12-31 = 10, 32-54 = 30, 55-255 = 60 nit HLPM).
# g6.p is read only by the brightness code (BrightnessManager.i(), the charging light sensor model, the SemContext lux
# handler and threshold sender, and a lux debug view); the wallpaper AOD UI keys off ha6.K0 / bj1.S() directly. So
# clearing g6.p keeps wallpaper AOD and restores the stock A52s index brightness (g6.r stays true through the
# config_aodBrightnessValues fallback, so dozeMode stays 0x10002).
DECODE_APK "system" "system/priv-app/AODService_v80/AODService_v80.apk"
python3 - "$APKTOOL_DIR/system/priv-app/AODService_v80/AODService_v80.apk" << 'PYEOF' || ABORT "Failed to apply the AOD brightness patch"
import glob, re, sys
d = sys.argv[1]
bm = glob.glob(d + "/smali*/com/samsung/android/app/aodservice/manager/brightness/BrightnessManager.smali")
assert len(bm) == 1, "BrightnessManager.smali: %d" % len(bm)
s = open(bm[0]).read()
# the static ()Z method whose body is "flag && <static>()Z" (isPlatformBrightness)
cands = []
for m in re.finditer(r"\.method public static (\w+)\(\)Z\n(?:.*\n)*?\.end method", s):
    f = re.findall(r"sget-boolean v\d+, (L[\w/$]+;)->(\w+):Z", m.group(0))
    if len(f) == 1 and m.group(0).count("invoke-static") == 1:
        cands.append(f[0])
assert len(cands) == 1, "isPlatformBrightness candidates: %s" % cands
cls, fld = cands[0]
path = glob.glob(d + "/smali*/" + cls[1:-1] + ".smali")
assert len(path) == 1, cls
t = open(path[0]).read()
assert "cameralightsensor" in t and "SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_REFRESH_RATE" in t, "unexpected class " + cls
put = re.escape(cls + "->" + fld + ":Z")
# <clinit>: sget-boolean vN, <features>;->K0:Z (AOD_FULLSCREEN > 0) / sput-boolean vN, <cls>;-><fld>:Z
done = re.findall(r"const/4 (v\d+), 0x0\n\n    sput-boolean \1, " + put, t)
new, n = re.subn(r"sget-boolean (v\d+), L[\w/$]+;->\w+:Z\n\n    sput-boolean \1, " + put,
                 lambda k: "const/4 %s, 0x0\n\n    sput-boolean %s, %s->%s:Z" % (k.group(1), k.group(1), cls, fld), t)
assert n + len(done) == 1, "%s->%s initialiser: %d patched, %d already" % (cls, fld, n, len(done))
if n:
    open(path[0], "w").write(new)
print("%s->%s = false" % (cls, fld))
PYEOF
LOG "- AOD brightness follows the sensor hub index (2/10/30/60 nit HLPM) with wallpaper AOD"
