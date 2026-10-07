# The Fold8 SecSettings compiles FlexModePanelPreferenceController.getAvailabilityStatus() (and the details page
# controller) to a constant AVAILABLE, so Settings > Advanced features offers "Flex mode panel" on this flat phone.
# Flex mode only runs in the hinge's half-folded posture, which the single DEFAULT device state never reports.
# Return UNSUPPORTED_ON_DEVICE (3): the entry and its search index row disappear.
SECSETTINGS="system/priv-app/SecSettings/SecSettings.apk"
for c in FlexModePanelPreferenceController FlexModePanelDetailsPreferenceController; do
    SMALI_PATCH "system" "$SECSETTINGS" \
        "smali_classes3/com/samsung/android/settings/usefulfeature/labs/flexmodepanel/$c.smali" "return" \
        'getAvailabilityStatus()I' '3' \
        || ABORT "fold_flex_mode_settings: failed to patch $c"
done
LOG "- Flex mode panel setting hidden (no hinge)"
unset SECSETTINGS c
