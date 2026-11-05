# See module.prop.
#
# BatteryInfoUtils.isAvailableBatteryRegulatory(Context) in SecSettings:
#     if (Rune.FEATURE_BATTERY_INFO_EU_REGULATORY_WITHOUT_BATTERY_IC && Rune.isDomesticModel()) return true;
#     if (!BatteryManager.semGetValueAsBoolean(SEM_BATTERY_PROPERTY_IC_AUTHENTICATION_RESULT)) return false;
#     ... EU regulatory region checks (already satisfied: SETTINGS_ENABLE_EU_BATTERY_REGULATORY=TRUE from unica/mods/settings)
# The first line is Samsung's switch for models without a battery auth IC, limited to KR. Set the floating feature and
# replace the isDomesticModel() result with true; the IC check (always false on the A52s, type 0 in BattInfoManager) is
# then never reached. The per-row controllers read /efs/FactoryApp/* files and tolerate missing ones ("Unknown").
SECSETTINGS="system/priv-app/SecSettings/SecSettings.apk"
DECODE_APK "system" "$SECSETTINGS" || ABORT "Failed to decode $SECSETTINGS"

BIU="$(cd "$APKTOOL_DIR/system/${SECSETTINGS//system\//}" && \
    find . -path "./smali*/com/samsung/android/settings/deviceinfo/batteryinfo/BatteryInfoUtils.smali" | sed "s|^\./||")"
[ "$BIU" ] && [ "$(wc -l <<< "$BIU")" -eq 1 ] || ABORT "BatteryInfoUtils.smali not found in SecSettings"
# The method must still gate on isDomesticModel() right after the WITHOUT_IC feature, with its result in v0
if ! sed -n '/^\.method public static isAvailableBatteryRegulatory(Landroid\/content\/Context;)Z$/,/^\.end method$/p' \
        "$APKTOOL_DIR/system/${SECSETTINGS//system\//}/$BIU" | \
        grep -A2 -F 'invoke-static {}, Lcom/samsung/android/settings/Rune;->isDomesticModel()Z' | \
        grep -q '^    move-result v0$'; then
    ABORT "BatteryInfoUtils.isAvailableBatteryRegulatory() no longer has the isDomesticModel() gate this patch expects"
fi

LOG "- Showing the regulatory Battery information rows without a battery auth IC"
# The floating feature itself is set from target/a52sxq/sff.sh (unica/patches/__floating_feature validates the xml and
# rejects the comment SET_FLOATING_FEATURE_CONFIG adds for a new key from a target patch).
SMALI_PATCH "system" "$SECSETTINGS" \
    "$BIU" "replace" \
    'isAvailableBatteryRegulatory(Landroid/content/Context;)Z' \
    'move-result v0' \
    'const/4 v0, 0x1' \
    || ABORT "Failed to patch BatteryInfoUtils.isAvailableBatteryRegulatory()"
unset SECSETTINGS BIU
