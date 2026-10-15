# See module.prop.
SECSETTINGS="system/priv-app/SecSettings/SecSettings.apk"
DECODE_APK "system" "$SECSETTINGS" || ABORT "Failed to decode $SECSETTINGS"
LOG "- Showing battery cycle count and dates without a battery authentication IC"
python3 - "$APKTOOL_DIR/system/${SECSETTINGS//system\//}" << 'PYEOF' || ABORT "Failed to patch isAvailableBatteryRegulatory"
import glob, re, sys
hits = glob.glob(sys.argv[1] + "/smali*/com/samsung/android/settings/deviceinfo/batteryinfo/BatteryInfoUtils.smali")
assert len(hits) == 1, hits
s = open(hits[0]).read()
m = re.search(r"\.method public static isAvailableBatteryRegulatory\(Landroid/content/Context;\)Z\n.*?\.end method", s, re.S)
assert m, "isAvailableBatteryRegulatory not found"
body = m.group(0)
if "k4: no battery authentication IC" in body:
    print("  - already patched"); sys.exit(0)
old = re.compile(r"(invoke-virtual \{(p0|v\d+), (v\d+)\}, Landroid/os/BatteryManager;->semGetValueAsBoolean\(I\)Z\n\n    move-result )(p0|v\d+)")
found = old.findall(body)
assert len(found) == 1, "semGetValueAsBoolean in isAvailableBatteryRegulatory: %d" % len(found)
reg = found[0][3]
# keep the call (it may log), then overwrite its result: the A52s has no battery authentication IC
new_body = old.sub(lambda k: k.group(0) + "\n\n    # k4: no battery authentication IC on the A52s; the rows read /efs/FactoryApp\n    const/4 %s, 0x1" % reg, body, count=1)
open(hits[0], "w").write(s.replace(body, new_body))
print("  - authentication result forced true in isAvailableBatteryRegulatory")
PYEOF
unset SECSETTINGS
