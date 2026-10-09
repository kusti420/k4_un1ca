# The Fold8 SecSettings compiles FlexModePanelPreferenceController.getAvailabilityStatus() (and the details page
# controller) to a constant AVAILABLE, so Settings > Advanced features offers "Flex mode panel" on this flat phone.
# Flex mode only runs in the hinge's half-folded posture, which the single DEFAULT device state never reports.
# Return UNSUPPORTED_ON_DEVICE (3): the entry and its search index row disappear.
# Fold sources only: flat sources (S25) already compile FlexModePanelPreferenceController to UNSUPPORTED_ON_DEVICE
if [[ "$(GET_FLOATING_FEATURE_CONFIG "$FW_DIR/$SOURCE_FIRMWARE_PATH/system/system/etc/floating_feature.xml" \
        "SEC_FLOATING_FEATURE_FRAMEWORK_SUPPORT_FOLDABLE_TYPE_FOLD")" != "TRUE" ]]; then
    LOG "- Source is not a foldable, nothing to do"
    return 0
fi
SECSETTINGS="system/priv-app/SecSettings/SecSettings.apk"
for c in FlexModePanelPreferenceController FlexModePanelDetailsPreferenceController; do
    SMALI_PATCH "system" "$SECSETTINGS" \
        "smali_classes3/com/samsung/android/settings/usefulfeature/labs/flexmodepanel/$c.smali" "return" \
        'getAvailabilityStatus()I' '3' \
        || ABORT "fold_flex_mode_settings: failed to patch $c"
done
LOG "- Flex mode panel setting hidden (no hinge)"
unset SECSETTINGS c
