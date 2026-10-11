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

# Battery health ("Unknown" through 9.3.20). The row (BatteryHealthPreferenceController) shows
# BatteryManager.semGetValuesAsLong(107 = SEM_BATTERY_PROPERTY_BSOH); on single-battery phones the framework
# answers it with BattUtils.readNodeAsDouble() = /efs/FactoryApp/bsoh, -1 when the file is missing, and -1 is
# displayed as "Unknown". That file is written by Samsung's SohService (a per-cell neural model fed with charge
# curves). The S26 Ultra SohService in this image carries the S26 Ultra cells' model, not the A52s cell's, so even
# when it eventually writes a value it is not a measurement of this battery; on the test phone it never wrote one.
# What the A52s does measure is the fuel gauge's ASOC (sm5714 fg_asoc, full capacity vs design capacity in
# percent), which BatteryService already curates into /efs/FactoryApp/asoc (AsocData) - and Samsung's own
# BatteryManagerInternal.getBatteryStateOfHealth() already falls back to exactly that file when bsoh is missing.
# Use the same source for the property: /efs/FactoryApp/asoc, else the live fg_asoc node, else -1 (Unknown).
# Side effect, intended: the "battery deteriorated" broadcast (sendDeteriorationIntentLocked, value below 55)
# follows ASOC too.
SERVICES="system/framework/services.jar"
DECODE_APK "system" "$SERVICES" || ABORT "Failed to decode $SERVICES"
LOG "- Battery health comes from the fuel gauge's ASOC (no S26 Ultra cell model on the A52s battery)"
python3 - "$APKTOOL_DIR/system/${SERVICES//system\//}" << 'PYEOF' || ABORT "Failed to patch BattUtils.readNodeAsDouble"
import glob, re, sys
hits = glob.glob(sys.argv[1] + "/smali*/com/android/server/battery/BattUtils.smali")
assert len(hits) == 1, hits
f = hits[0]
s = open(f).read()
B = "Lcom/android/server/battery/BattUtils;"
m = re.search(r"^\.method public static readNodeAsDouble\(\)D\n.*?^\.end method\n", s, re.M | re.S)
assert m, "readNodeAsDouble()D not found"
body = m.group(0)
if "k4: state of health = ASOC" in body:
    print("  - already patched"); sys.exit(0)
# the method must still be the plain /efs/FactoryApp/bsoh reader, and the silent long reader must exist
assert '"/efs/FactoryApp/bsoh"' in body and "Ljava/lang/Double;->parseDouble(Ljava/lang/String;)D" in body, \
    "readNodeAsDouble() no longer reads /efs/FactoryApp/bsoh"
assert re.search(r"^\.method public static readNodeAsLong\$1\(Ljava/lang/String;\)J$", s, re.M), "readNodeAsLong$1(String)J"
# every caller treats the result as a percentage (or negative = unknown)
callers = [c for c in glob.glob(sys.argv[1] + "/smali*/com/android/server/**/*.smali", recursive=True)
           if (B + "->readNodeAsDouble()D") in open(c).read()]
assert 1 <= len(callers) <= 4, "readNodeAsDouble() callers: %s" % callers
new = """.method public static readNodeAsDouble()D
    .locals 5

    # k4: state of health = ASOC on the A52s (see target/a52sxq/patches/battery_info_rows). v0/v1 hold the long
    # result on every path into :cond_k4_have; v2-v4 are scratch.
    const-string v0, "/efs/FactoryApp/asoc"

    invoke-static {v0}, %(B)s->readNodeAsLong$1(Ljava/lang/String;)J

    move-result-wide v0

    const-wide/16 v2, 0x0

    cmp-long v4, v0, v2

    if-gtz v4, :cond_k4_have

    const-string v0, "/sys/class/power_supply/battery/fg_asoc"

    invoke-static {v0}, %(B)s->readNodeAsLong$1(Ljava/lang/String;)J

    move-result-wide v0

    :cond_k4_have
    const-wide/16 v2, 0x0

    cmp-long v4, v0, v2

    if-gtz v4, :cond_k4_ok

    const-wide/high16 v0, -0x4010000000000000L    # -1.0

    return-wide v0

    :cond_k4_ok
    long-to-double v0, v0

    return-wide v0
.end method
""" % dict(B=B)
open(f, "w").write(s[:m.start()] + new + s[m.end():])
print("  - BattUtils.readNodeAsDouble(): /efs/FactoryApp/asoc, then fg_asoc (%d callers)" % len(callers))
PYEOF
unset SERVICES
