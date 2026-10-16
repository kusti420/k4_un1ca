# See module.prop.
DECODE_APK "system" "system/priv-app/SettingsProvider/SettingsProvider.apk"
python3 - "$APKTOOL_DIR/system/priv-app/SettingsProvider/SettingsProvider.apk/res/values/arrays.xml" << 'PYEOF' || ABORT "Failed to patch the default autofill service"
import re, sys
p = sys.argv[1]
s = open(p).read()
m = re.search(r'<string-array name="config_defaultAutofillService">.*?</string-array>', s, re.S)
assert m, "config_defaultAutofillService not found"
old = "<item>com.google.android.gms/com.google.android.gms.auth.api.credentials.credman.service.PasswordAndPasskeyService</item>"
new = "<item>com.google.android.gms/com.google.android.gms.autofill.service.AutofillService</item>"
block = m.group(0)
if new in block:
    print("  - config_defaultAutofillService already falls back to GMS AutofillService")
    sys.exit(0)
assert block.count(old) == 1, "config_defaultAutofillService: credman item not found"
s = s[:m.start()] + block.replace(old, new) + s[m.end():]
open(p, "w").write(s)
print("  - config_defaultAutofillService: credman PasswordAndPasskeyService -> GMS AutofillService")
PYEOF
LOG "- Default autofill service falls back to Google autofill (Samsung Pass is debloated)"
