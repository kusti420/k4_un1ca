# See module.prop. Flip Rune.getSupportSearchInAppAssist() from "510" >= 400 to "0" >= 400 (false). Only that method
# is touched: Utils.isNPUVersion()/getSemanticSearchVersion() keep their own "510" literal.
SSI="system/priv-app/SecSettingsIntelligence/SecSettingsIntelligence.apk"
DECODE_APK "system" "$SSI" || ABORT "Failed to decode $SSI"
LOG "- Settings search: on-device semantic indexing (in-app assist) off"
SSI_DIR="$APKTOOL_DIR/system/${SSI//system\//}"
python3 - "$SSI_DIR" << 'PYEOF' || ABORT "Failed to patch Rune.getSupportSearchInAppAssist"
import glob, re, sys
root = sys.argv[1]
hits = glob.glob(root + "/smali*/com/samsung/android/settings/intelligence/Rune.smali")
assert len(hits) == 1, "Rune.smali: %d" % len(hits)
f = hits[0]; s = open(f).read()
m = re.search(r"^\.method public static getSupportSearchInAppAssist\(\)Z\n.*?^\.end method\n", s, re.M | re.S)
assert m, "getSupportSearchInAppAssist not found"
body = m.group(0)
if 'const-string v1, "0"' in body:
    print("  - already patched")
else:
    assert body.count('const-string v1, "510"') == 1, "expected one \"510\" literal in getSupportSearchInAppAssist"
    body = body.replace('const-string v1, "510"', 'const-string v1, "0"')
    open(f, "w").write(s[:m.start()] + body + s[m.end():])
PYEOF
