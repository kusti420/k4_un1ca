SMALI_PATCH "system_ext" "priv-app/SystemUI/SystemUI.apk" \
    "smali_classes4/com/android/systemui/util/DeviceState.smali" "replaceall" \
    '"/sys/class/fingerprint/fingerprint/position"' \
    '"/sys/devices/virtual/fingerprint/fingerprint/position"'
