# One UI 9 SystemUI picks the quick-panel mode from SecQsUiDisplayModeInteractor.DeviceFormFactor:
# PHONE -> NORMAL (edge-to-edge, no pop-over), FOLD -> NARROW when folded / WIDE (pop-over card) when unfolded.
# The Fold8 build compiles getDeviceFormFactor() to the FOLD constant; this device reports a single DEFAULT
# device state that the interactor counts as "unfolded", so the quick panel came up as the foldable pop-over card.
DECODE_APK "system_ext" "priv-app/SystemUI/SystemUI.apk"
python3 - "$APKTOOL_DIR/system_ext/priv-app/SystemUI/SystemUI.apk" << 'PYEOF' || ABORT "Failed to apply the phone-style quick panel patch"
import glob, re, sys
f = glob.glob(sys.argv[1] + "/smali*/com/android/systemui/util/SecQsUiDisplayModeInteractor.smali")
assert len(f) == 1, "SecQsUiDisplayModeInteractor"
s = open(f[0]).read()
s, n = re.subn(r"(\.method private final getDeviceFormFactor\(\)Lcom/android/systemui/util/SecQsUiDisplayModeInteractor\$DeviceFormFactor;\n(?:.*\n)*?\s+sget-object p0, Lcom/android/systemui/util/SecQsUiDisplayModeInteractor\$DeviceFormFactor;->)FOLD(:)", r"\1PHONE\2", s)
assert n == 1, "getDeviceFormFactor"
open(f[0], "w").write(s)
PYEOF
LOG "- Quick panel form factor forced to PHONE"
