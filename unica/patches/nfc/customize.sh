# SecSettings compares its compiled SEC_PRODUCT_FEATURE_NFC_CONFIG_ANTENNA_POSITION with ro.vendor.nfc.info.antpos and
# throws (Settings > NFC crashes) when they differ. The literal changes per source (S25 27, S26 Ultra 29) and only has to
# match: NfcAntennaInfo has a single DEFAULT entry and the drawing uses antposX/Y. Read it from the source SecSettings.
DECODE_APK "system" "system/priv-app/SecSettings/SecSettings.apk"
ANTPOS="$(python3 - "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk" << 'PYEOF'
import glob, re, sys
vals = set()
for f in glob.glob(sys.argv[1] + "/smali*/com/samsung/android/settings/nfc/*.smali"):
    s = open(f).read()
    vals.update(re.findall(
        r'const-string v\d+, "(-?\d+)"\n\n    invoke-static \{v\d+\}, Ljava/lang/Integer;->parseInt\(Ljava/lang/String;\)I\n'
        r'\n    move-result v\d+\n\n    const-string v\d+, "ro\.vendor\.nfc\.info\.antpos"', s))
print(vals.pop() if len(vals) == 1 else "")
PYEOF
)"
if [ ! "$ANTPOS" ]; then
    ABORT "Could not read SEC_PRODUCT_FEATURE_NFC_CONFIG_ANTENNA_POSITION from SecSettings"
fi
SET_PROP "vendor" "ro.vendor.nfc.info.antpos" "$ANTPOS"
unset ANTPOS
