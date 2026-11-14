# See module.prop.
SECSETTINGS="system/priv-app/SecSettings/SecSettings.apk"
DECODE_APK "system" "$SECSETTINGS" || ABORT "Failed to decode $SECSETTINGS"
LOG "- Hiding the Super HDR switch (no effect on this panel)"
python3 - "$APKTOOL_DIR/system/${SECSETTINGS//system\//}" << 'PYEOF' || ABORT "Failed to hide the Super HDR switch"
import glob, re, sys
root = sys.argv[1]
hits = glob.glob(root + "/smali*/com/samsung/android/settings/usefulfeature/superhdr/SuperHdrPreferenceController.smali")
assert len(hits) == 1, "SuperHdrPreferenceController: %d copies" % len(hits)
f = hits[0]
s = open(f).read()
pat = re.compile(r"(^\.method public getAvailabilityStatus\(\)I\n)(.*?)(^\.end method\n)", re.M | re.S)
m = pat.search(s)
assert m, "getAvailabilityStatus() not found"
NEW = "    .locals 1\n\n    # a52sxq superhdr_switch_hide: UNSUPPORTED_ON_DEVICE\n    const/4 v0, 0x3\n\n    return v0\n"
if m.group(2) == NEW:
    print("already patched")
    sys.exit(0)
assert '"SEC_FLOATING_FEATURE_MMFW_SUPPORT_PHOTOHDR"' in m.group(2), "unexpected availability logic"
s = s[:m.start(2)] + NEW + s[m.end(2):]
open(f, "w").write(s)
PYEOF
