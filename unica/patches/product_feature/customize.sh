# shellcheck disable=SC2016 # Literal smali descriptors contain '$'.
# [
GET_FINGERPRINT_SENSOR_TYPE()
{
    if [[ "$1" == *"ultrasonic"* ]]; then
        echo "ultrasonic"
    elif [[ "$1" == *"optical"* ]]; then
        echo "optical"
    elif [[ "$1" == *"side"* ]]; then
        echo "side"
    else
        ABORT "Unknown fingerprint sensor type: \"$1\". Aborting"
    fi
}

LOG_MISSING_PATCHES()
{
    local MESSAGE="Missing SPF patches for condition ($1: [${!1}], $2: [${!2}])"

    if $DEBUG; then
        LOGW "$MESSAGE"
    else
        ABORT "${MESSAGE}. Aborting"
    fi
}

REQUIRE_FIXED_COUNT()
{
    local FILE="$1"
    local VALUE="$2"
    local EXPECTED="$3"
    local DESCRIPTION="$4"
    local ACTUAL

    if [ ! -f "$FILE" ]; then
        ABORT "Android 17 product-feature gate is missing: ${FILE//$APKTOOL_DIR\//}"
        return 1
    fi

    ACTUAL="$(grep -F -c -- "$VALUE" "$FILE" || true)"
    if [ "$ACTUAL" -ne "$EXPECTED" ]; then
        ABORT "Unexpected Android 17 $DESCRIPTION shape (expected $EXPECTED exact match(es), found $ACTUAL)"
        return 1
    fi
}

REQUIRE_METHOD_FIXED_COUNT()
{
    local FILE="$1"
    local METHOD="$2"
    local VALUE="$3"
    local EXPECTED="$4"
    local DESCRIPTION="$5"
    local ACTUAL

    if [ ! -f "$FILE" ]; then
        ABORT "Android 17 product-feature gate is missing: ${FILE//$APKTOOL_DIR\//}"
        return 1
    fi

    ACTUAL="$(awk -v FN="$METHOD" -v STR="$VALUE" '
        /^\.method/ { inside = index($0, FN) > 0 }
        inside && index($0, STR) { count++ }
        inside && /^\.end method/ { inside = 0 }
        END { print count + 0 }
    ' "$FILE")"
    if [ "$ACTUAL" -ne "$EXPECTED" ]; then
        ABORT "Unexpected Android 17 $DESCRIPTION shape in $METHOD (expected $EXPECTED exact match(es), found $ACTUAL)"
        return 1
    fi
}

REPLACE_SMALI_METHOD()
{
    local FILE="$1"
    local METHOD="$2"
    local BODY="$3"
    local COUNT
    local BEFORE
    local AFTER

    if [ ! -f "$FILE" ]; then
        ABORT "Android 17 product-feature method file is missing: ${FILE//$APKTOOL_DIR\//}"
        return 1
    fi

    COUNT="$(awk -v FN="$METHOD" '/^\.method/ && index($0, FN) { count++ } END { print count + 0 }' "$FILE")"
    if [ "$COUNT" -ne "1" ]; then
        ABORT "Unexpected Android 17 method shape for $METHOD (found $COUNT declarations)"
        return 1
    fi

    BEFORE="$(sha1sum "$FILE")"
    awk -v FN="$METHOD" -v BODY="$BODY" '
        /^\.method/ && index($0, FN) {
            print BODY
            inside = 1
            next
        }
        inside && /^\.end method/ {
            inside = 0
            next
        }
        inside { next }
        { print }
    ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
    AFTER="$(sha1sum "$FILE")"

    if [ "$BEFORE" = "$AFTER" ]; then
        ABORT "Failed to replace Android 17 method $METHOD"
        return 1
    fi
    LOG "- Replacing Android 17 method \"$METHOD\" in ${FILE//$APKTOOL_DIR\//}"
}
# ]

# SEC_PRODUCT_FEATURE_BUILD_MAINLINE_API_LEVEL
if [[ "$SOURCE_PRODUCT_SHIPPING_API_LEVEL" != "$TARGET_PRODUCT_SHIPPING_API_LEVEL" ]]; then
    SMALI_PATCH "system" "system/framework/esecomm.jar" \
        "smali/com/sec/esecomm/EsecommAdapter.smali" "replace" \
        "<clinit>()V" \
        "$SOURCE_PRODUCT_SHIPPING_API_LEVEL" \
        "$TARGET_PRODUCT_SHIPPING_API_LEVEL"
    SMALI_PATCH "system" "system/framework/services.jar" \
        "smali/com/android/server/enterprise/hdm/HdmSakManager.smali" "replace" \
        "isSupported(Landroid/content/Context;)Z" \
        "$SOURCE_PRODUCT_SHIPPING_API_LEVEL" \
        "$TARGET_PRODUCT_SHIPPING_API_LEVEL"
    if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
        # One UI 9 removed HdmVendorController's shipping-API constructor
        # branch. Verify that exact API37 shape instead of replaying the old
        # patch or accepting a silently changed implementation.
        HDM_VENDOR_SMALI="$APKTOOL_DIR/system/framework/services.jar/smali/com/android/server/enterprise/hdm/HdmVendorController.smali"
        if grep -q '^\.method.*<init>()V' "$HDM_VENDOR_SMALI" ||
                grep -q -F "\"$SOURCE_PRODUCT_SHIPPING_API_LEVEL\"" "$HDM_VENDOR_SMALI"; then
            ABORT "Unexpected Android 17 HdmVendorController API-level branch"
        fi
        unset HDM_VENDOR_SMALI
    else
        SMALI_PATCH "system" "system/framework/services.jar" \
            "smali/com/android/server/enterprise/hdm/HdmVendorController.smali" "replace" \
            "<init>()V" \
            "$SOURCE_PRODUCT_SHIPPING_API_LEVEL" \
            "$TARGET_PRODUCT_SHIPPING_API_LEVEL"
    fi
    SMALI_PATCH "system" "system/framework/services.jar" \
        "smali/com/android/server/knox/dar/ddar/ta/TAProxy.smali" "replace" \
        "updateServiceHolder(Z)V" \
        "$SOURCE_PRODUCT_SHIPPING_API_LEVEL" \
        "$TARGET_PRODUCT_SHIPPING_API_LEVEL"
    SMALI_PATCH "system" "system/framework/services.jar" \
        "smali/com/android/server/SystemServer.smali" "replace" \
        "startOtherServices(Lcom/android/server/utils/TimingsTraceAndSlog;)V" \
        "MAINLINE_API_LEVEL: $SOURCE_PRODUCT_SHIPPING_API_LEVEL" \
        "MAINLINE_API_LEVEL: $TARGET_PRODUCT_SHIPPING_API_LEVEL"
    SMALI_PATCH "system" "system/framework/services.jar" \
        "smali/com/android/server/SystemServer.smali" "replace" \
        "startOtherServices(Lcom/android/server/utils/TimingsTraceAndSlog;)V" \
        "$SOURCE_PRODUCT_SHIPPING_API_LEVEL" \
        "$TARGET_PRODUCT_SHIPPING_API_LEVEL"
    SMALI_PATCH "system" "system/framework/services.jar" \
        "smali_classes2/com/android/server/power/PowerManagerUtil.smali" "replace" \
        "<clinit>()V" \
        "$SOURCE_PRODUCT_SHIPPING_API_LEVEL" \
        "$TARGET_PRODUCT_SHIPPING_API_LEVEL"
    SMALI_PATCH "system" "system/framework/services.jar" \
        "smali_classes2/com/android/server/sepunion/EngmodeService\$EngmodeTimeThread.smali" "replace" \
        "<clinit>()V" \
        "$SOURCE_PRODUCT_SHIPPING_API_LEVEL" \
        "$TARGET_PRODUCT_SHIPPING_API_LEVEL"
fi

# SEC_PRODUCT_FEATURE_AUDIO_CONFIG_RECORDALIVE_LIB_VERSION
if [[ "$SOURCE_AUDIO_CONFIG_RECORDALIVE_LIB_VERSION" != "$TARGET_AUDIO_CONFIG_RECORDALIVE_LIB_VERSION" ]]; then
    if [[ "$SOURCE_AUDIO_CONFIG_RECORDALIVE_LIB_VERSION" != "none" ]]; then
        SMALI_PATCH "system" "system/framework/framework.jar" \
            "smali_classes6/com/samsung/android/camera/mic/SemMultiMicManager.smali" "replace" \
            "isSupported()Z" \
            "$SOURCE_AUDIO_CONFIG_RECORDALIVE_LIB_VERSION" \
            "${TARGET_AUDIO_CONFIG_RECORDALIVE_LIB_VERSION//none/}"
        SMALI_PATCH "system" "system/framework/framework.jar" \
            "smali_classes6/com/samsung/android/camera/mic/SemMultiMicManager.smali" "replace" \
            "isSupported(I)Z" \
            "$SOURCE_AUDIO_CONFIG_RECORDALIVE_LIB_VERSION" \
            "${TARGET_AUDIO_CONFIG_RECORDALIVE_LIB_VERSION//none/}"
    else
        # TODO handle this condition
        LOG_MISSING_PATCHES "SOURCE_AUDIO_CONFIG_RECORDALIVE_LIB_VERSION" "TARGET_AUDIO_CONFIG_RECORDALIVE_LIB_VERSION"
    fi
fi

# SEC_PRODUCT_FEATURE_AUDIO_CONFIG_HAPTIC
if $SOURCE_AUDIO_SUPPORT_ACH_RINGTONE; then
    if ! $TARGET_AUDIO_SUPPORT_ACH_RINGTONE; then
        if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
            SMALI_PATCH "system" "system/framework/framework.jar" \
                "smali_classes6/com/samsung/android/audio/Rune.smali" "replace" \
                "<clinit>()V" \
                'sput-boolean v2, Lcom/samsung/android/audio/Rune;->SEC_AUDIO_SUPPORT_ACH_RINGTONE:Z' \
                'sput-boolean v1, Lcom/samsung/android/audio/Rune;->SEC_AUDIO_SUPPORT_ACH_RINGTONE:Z'
            SMALI_PATCH "system" "system/framework/framework.jar" \
                "smali_classes6/com/samsung/android/vibrator/VibRune.smali" "replaceall" \
                '.field public static final blacklist SUPPORT_ACH:Z = true' \
                '.field public static final blacklist SUPPORT_ACH:Z = false'
        else
            APPLY_PATCH "system" "system/framework/framework.jar" \
                "$MODPATH/audio/ach/framework.jar/0001-Disable-ACH-ringtone-support.patch"
        fi
    fi
else
    if $TARGET_AUDIO_SUPPORT_ACH_RINGTONE; then
        # TODO handle this condition
        LOG_MISSING_PATCHES "SOURCE_AUDIO_SUPPORT_ACH_RINGTONE" "TARGET_AUDIO_SUPPORT_ACH_RINGTONE"
    fi
fi

# SEC_PRODUCT_FEATURE_AUDIO_SUPPORT_DUAL_SPEAKER
if $SOURCE_AUDIO_SUPPORT_DUAL_SPEAKER; then
    if ! $TARGET_AUDIO_SUPPORT_DUAL_SPEAKER; then
        SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_AUDIO_SUPPORT_DUAL_SPEAKER" --delete

        APPLY_PATCH "system" "system/framework/framework.jar" \
            "$MODPATH/audio/dual_speaker/framework.jar/0001-Disable-dual-speaker-support.patch"
        APPLY_PATCH "system" "system/framework/services.jar" \
            "$MODPATH/audio/dual_speaker/services.jar/0001-Disable-dual-speaker-support.patch"
    fi
else
    if $TARGET_AUDIO_SUPPORT_DUAL_SPEAKER; then
        # TODO handle this condition
        LOG_MISSING_PATCHES "SOURCE_AUDIO_SUPPORT_DUAL_SPEAKER" "TARGET_AUDIO_SUPPORT_DUAL_SPEAKER"
    fi
fi

# SEC_PRODUCT_FEATURE_AUDIO_SUPPORT_VIRTUAL_VIBRATION_SOUND
if $SOURCE_AUDIO_SUPPORT_VIRTUAL_VIBRATION_SOUND; then
    if ! $TARGET_AUDIO_SUPPORT_VIRTUAL_VIBRATION_SOUND; then
        if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
            # Android 17 has a rewritten vibrator service. Keep that native
            # implementation intact, but make its two playback entry points
            # inert and hide the inlined Settings controller. This avoids the
            # API36 patch's broad register/label rewrite while guaranteeing
            # the source-only speaker fallback can never run on the target.
            SMALI_PATCH "system" "system/framework/framework.jar" \
                "smali_classes6/com/samsung/android/audio/Rune.smali" "replaceall" \
                '.field public static final blacklist SEC_AUDIO_SUPPORT_VIRTUAL_VIBRATION_SOUND:Z = true' \
                '.field public static final blacklist SEC_AUDIO_SUPPORT_VIRTUAL_VIBRATION_SOUND:Z = false'
            SMALI_PATCH "system" "system/framework/framework.jar" \
                "smali_classes6/com/samsung/android/vibrator/VibRune.smali" "replaceall" \
                '.field public static final blacklist SUPPORT_VIRTUAL_VIBRATION_SOUND:Z = true' \
                '.field public static final blacklist SUPPORT_VIRTUAL_VIBRATION_SOUND:Z = false'
            SMALI_PATCH "system" "system/framework/services.jar" \
                "smali_classes2/com/android/server/vibrator/VirtualVibSoundHelper.smali" "null" \
                "playVirtualSoundIfNeeded(Ljava/lang/String;Landroid/os/VibrationAttributes;Z)V"
            SMALI_PATCH "system" "system/framework/services.jar" \
                "smali_classes2/com/android/server/vibrator/VirtualVibSoundHelper.smali" "null" \
                "stopVirtualSound(Ljava/lang/String;)V"
            SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
                "smali_classes3/com/samsung/android/settings/asbase/vibration/VirtualVibrationSoundPreferenceController.smali" "return" \
                "getAvailabilityStatus()I" \
                "3"
            SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
                "smali_classes3/com/samsung/android/settings/asbase/vibration/VirtualVibrationSoundPreferenceController.smali" "replace" \
                "displayPreference(Landroidx/preference/PreferenceScreen;)V" \
                "const/4 p1, 0x1" \
                "const/4 p1, 0x0"
            # One UI 9 dropped the updateState() override; getAvailabilityStatus() already hides it
            if grep -q "^\.method.* updateState(Landroidx/preference/Preference;)V" \
                    "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/smali_classes3/com/samsung/android/settings/asbase/vibration/VirtualVibrationSoundPreferenceController.smali"; then
                SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
                    "smali_classes3/com/samsung/android/settings/asbase/vibration/VirtualVibrationSoundPreferenceController.smali" "replace" \
                    "updateState(Landroidx/preference/Preference;)V" \
                    "const/4 p1, 0x1" \
                    "const/4 p1, 0x0"
            fi

            DECODE_APK "system" "system/priv-app/SettingsProvider/SettingsProvider.apk"
            SETTINGS_PROVIDER_SMALI="$APKTOOL_DIR/system/priv-app/SettingsProvider/SettingsProvider.apk/smali/com/android/providers/settings/DatabaseHelper\$1.smali"
            REQUIRE_FIXED_COUNT "$SETTINGS_PROVIDER_SMALI" \
                'const-string v1, "vibration_sound_enabled"' 1 \
                "SettingsProvider virtual-vibration default"
            REQUIRE_FIXED_COUNT "$SETTINGS_PROVIDER_SMALI" \
                'const/4 v8, 0x0' 1 \
                "SettingsProvider disabled default register"
            unset SETTINGS_PROVIDER_SMALI
        else
            APPLY_PATCH "system" "system/framework/framework.jar" \
                "$MODPATH/audio/virtual_vib/framework.jar/0001-Disable-virtual-vibration-support.patch"
            APPLY_PATCH "system" "system/framework/services.jar" \
                "$MODPATH/audio/virtual_vib/services.jar/0001-Disable-virtual-vibration-support.patch"
            SMALI_PATCH "system" "system/framework/services.jar" \
                "smali/com/android/server/audio/BtHelper\$\$ExternalSyntheticLambda0.smali" "remove"
            EVAL "sed -i \"/.source/q\" \"$APKTOOL_DIR/system/framework/services.jar/smali_classes2/com/android/server/vibrator/VibratorManagerInternal.smali\""
            SMALI_PATCH "system" "system/framework/services.jar" \
                "smali_classes2/com/android/server/vibrator/VibratorManagerService\$SamsungBroadcastReceiver\$\$ExternalSyntheticLambda1.smali" "remove"
            SMALI_PATCH "system" "system/framework/services.jar" \
                "smali_classes2/com/android/server/vibrator/VirtualVibSoundHelper.smali" "remove"
            APPLY_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
                "$MODPATH/audio/virtual_vib/SecSettings.apk/0001-Disable-virtual-vibration-support.patch"
            APPLY_PATCH "system" "system/priv-app/SettingsProvider/SettingsProvider.apk" \
                "$MODPATH/audio/virtual_vib/SettingsProvider.apk/0001-Disable-virtual-vibration-support.patch"
        fi
    fi
else
    if $TARGET_AUDIO_SUPPORT_VIRTUAL_VIBRATION_SOUND; then
        # TODO handle this condition
        LOG_MISSING_PATCHES "SOURCE_AUDIO_SUPPORT_VIRTUAL_VIBRATION_SOUND" "TARGET_AUDIO_SUPPORT_VIRTUAL_VIBRATION_SOUND"
    fi
fi

# SEC_PRODUCT_FEATURE_COMMON_CONFIG_MDNIE_MODE
if [[ "$SOURCE_COMMON_CONFIG_MDNIE_MODE" != "$TARGET_COMMON_CONFIG_MDNIE_MODE" ]]; then
    SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_COMMON_CONFIG_MDNIE_MODE" "$TARGET_COMMON_CONFIG_MDNIE_MODE"

    SMALI_PATCH "system" "system/framework/services.jar" \
        "smali_classes2/com/samsung/android/hardware/display/SemMdnieManagerService.smali" "replace" \
        "<init>(Landroid/content/Context;)V" \
        "$SOURCE_COMMON_CONFIG_MDNIE_MODE" \
        "$TARGET_COMMON_CONFIG_MDNIE_MODE"
fi

# SEC_PRODUCT_FEATURE_COMMON_CONFIG_DYN_RESOLUTION_CONTROL
if ! $SOURCE_COMMON_SUPPORT_DYN_RESOLUTION_CONTROL; then
    if $TARGET_COMMON_SUPPORT_DYN_RESOLUTION_CONTROL; then
        if [[ "$(GET_FINGERPRINT_SENSOR_TYPE "$TARGET_FINGERPRINT_CONFIG_SENSOR")" == "optical" ]]; then
            ABORT "TARGET_COMMON_SUPPORT_DYN_RESOLUTION_CONTROL is not supported on targets with an optical fingerprint sensor"
        fi

        SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_COMMON_CONFIG_DYN_RESOLUTION_CONTROL" "WQHD,FHD,HD"

        ADD_TO_WORK_DIR "$([[ "$TARGET_OS_SINGLE_SYSTEM_IMAGE" == "qssi" ]] && echo "b0qxxx" || echo "b0sxxx")" \
            "system" "system/bin/bootanimation" 0 2000 755 "u:object_r:bootanim_exec:s0"
        ADD_TO_WORK_DIR "$([[ "$TARGET_OS_SINGLE_SYSTEM_IMAGE" == "qssi" ]] && echo "b0qxxx" || echo "b0sxxx")" \
            "system" "system/bin/surfaceflinger" 0 2000 755 "u:object_r:surfaceflinger_exec:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/battery_error.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/battery_low.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/battery_protection.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/battery_temperature_error.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/battery_temperature_limit.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/battery_water_usb.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/incomplete_connect.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/lcd_density.txt" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/new_vi_0_100.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/new_vi_1_100.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/new_vi_2_100.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/new_vi_level_0_1.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/new_vi_level_0_2.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/new_vi_level_0_3.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/new_vi_level_0_4.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/new_vi_level_1_1.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/new_vi_level_1_2.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/new_vi_level_1_3.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/new_vi_level_1_4.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/new_vi_level_2_1.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/new_vi_level_2_2.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/new_vi_level_2_3.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/new_vi_level_2_4.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/slow_charging_usb.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/temperature_limit_usb.spi" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/water_protection_usb.spi" 0 0 644 "u:object_r:system_file:s0"

        if [ "$TARGET_PLATFORM_SDK_VERSION" -ge "36" ]; then
            APPLY_PATCH "system" "system/framework/framework.jar" \
                "$MODPATH/resolution/framework.jar/0001-Enable-FW_SUPPORT_MULTI_RESOLUTION.patch"
        else
            APPLY_PATCH "system" "system/framework/framework.jar" \
                "$MODPATH/resolution/framework.jar/0001-Enable-FW_DYNAMIC_RESOLUTION_CONTROL.patch"
        fi
        APPLY_PATCH "system" "system/framework/gamemanager.jar" \
            "$MODPATH/resolution/gamemanager.jar/0001-Enable-dynamic-resolution-control.patch"
        APPLY_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
            "$MODPATH/resolution/SecSettings.apk/0001-Enable-dynamic-resolution-control.patch"
        SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
            "smali_classes2/com/android/settings/Utils\$\$ExternalSyntheticLambda2.smali" "remove"
        EVAL "sed -i \"s/^\.implements.*/.implements Landroidx\/core\/view\/OnApplyWindowInsetsListener;/g\" \"$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/smali_classes2/com/android/settings/Utils\\\$\\\$ExternalSyntheticLambda3.smali\""
        SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
            "smali_classes2/com/android/settings/applications/manageapplications/ManageApplications\$ApplicationsAdapter\$\$ExternalSyntheticLambda3.smali" "remove"
        SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
            "smali_classes2/com/android/settings/applications/manageapplications/ManageApplications\$ApplicationsAdapter\$\$ExternalSyntheticLambda7.smali" "remove"
        SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
            "smali_classes2/com/android/settings/applications/manageapplications/ManageApplications\$ApplicationsAdapter\$\$ExternalSyntheticLambda9.smali" "remove"
        SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
            "smali_classes2/com/android/settings/applications/manageapplications/ManageApplications\$ApplicationsAdapter\$\$ExternalSyntheticOutline0.smali" "remove"
        if [ "$TARGET_PLATFORM_SDK_VERSION" -lt "36" ]; then
            APPLY_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
                "$MODPATH/resolution/SecSettings.apk/0002-Backport-legacy-DYN_RESOLUTION_CONTROL-code.patch"
            EVAL "sed -i \"/static fields/,+3d\" \"$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/smali_classes4/com/samsung/android/settings/display/ScreenResolutionFragment.smali\""
            SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
                "smali_classes4/com/samsung/android/settings/display/controller/ScreenResolutionPreferenceController\$2.smali" "remove"
        fi
        APPLY_PATCH "system_ext" "priv-app/SystemUI/SystemUI.apk" \
            "$MODPATH/resolution/SystemUI.apk/0001-Enable-dynamic-resolution-control.patch"
    fi
else
    if ! $TARGET_COMMON_SUPPORT_DYN_RESOLUTION_CONTROL; then
        # TODO handle this condition
        LOG_MISSING_PATCHES "SOURCE_COMMON_SUPPORT_DYN_RESOLUTION_CONTROL" "TARGET_COMMON_SUPPORT_DYN_RESOLUTION_CONTROL"
    fi
fi

# SEC_PRODUCT_FEATURE_COMMON_SUPPORT_EMBEDDED_SIM
if $SOURCE_COMMON_SUPPORT_EMBEDDED_SIM; then
    if ! $TARGET_COMMON_SUPPORT_EMBEDDED_SIM; then
        SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_COMMON_CONFIG_EMBEDDED_SIM_SLOTSWITCH" --delete
    fi
else
    if $TARGET_COMMON_SUPPORT_EMBEDDED_SIM; then
        # TODO handle this condition
        LOG_MISSING_PATCHES "SOURCE_COMMON_SUPPORT_EMBEDDED_SIM" "TARGET_COMMON_SUPPORT_EMBEDDED_SIM"
    fi
fi

# SEC_PRODUCT_FEATURE_COMMON_SUPPORT_HDR_EFFECT
if $SOURCE_COMMON_SUPPORT_HDR_EFFECT; then
    if ! $TARGET_COMMON_SUPPORT_HDR_EFFECT; then
        SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_COMMON_SUPPORT_HDR_EFFECT" --delete

        APPLY_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
            "$MODPATH/mdnie/hdr/SecSettings.apk/0001-Disable-HDR-Settings.patch"
        APPLY_PATCH "system" "system/priv-app/SettingsProvider/SettingsProvider.apk" \
            "$MODPATH/mdnie/hdr/SettingsProvider.apk/0001-Disable-HDR-Settings.patch"
    else
        if [ ! "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_COMMON_SUPPORT_HDR_EFFECT")" ]; then
            SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_COMMON_SUPPORT_HDR_EFFECT" "TRUE"
        fi
    fi
else
    if $TARGET_COMMON_SUPPORT_HDR_EFFECT; then
        # TODO handle this condition
        LOG_MISSING_PATCHES "SOURCE_COMMON_SUPPORT_HDR_EFFECT" "TARGET_COMMON_SUPPORT_HDR_EFFECT"
    fi
fi

# SEC_PRODUCT_FEATURE_FINGERPRINT_CONFIG_SENSOR
if [[ "$SOURCE_FINGERPRINT_CONFIG_SENSOR" != "$TARGET_FINGERPRINT_CONFIG_SENSOR" ]]; then
    SMALI_PATCH "system" "system/framework/framework.jar" \
        "smali_classes6/com/samsung/android/bio/fingerprint/SemFingerprintManager.smali" "replace" \
        "getMaxTemplateNumberFromSPF()I" \
        "$SOURCE_FINGERPRINT_CONFIG_SENSOR" \
        "$TARGET_FINGERPRINT_CONFIG_SENSOR"
    SMALI_PATCH "system" "system/framework/framework.jar" \
        "smali_classes6/com/samsung/android/bio/fingerprint/SemFingerprintManager.smali" "replace" \
        "getProductFeatureValue(Landroid/content/Context;)Ljava/lang/String;" \
        "$SOURCE_FINGERPRINT_CONFIG_SENSOR" \
        "$TARGET_FINGERPRINT_CONFIG_SENSOR"
    SMALI_PATCH "system" "system/framework/framework.jar" \
        "smali_classes6/com/samsung/android/bio/fingerprint/SemFingerprintManager\$Characteristics.smali" "replaceall" \
        "$SOURCE_FINGERPRINT_CONFIG_SENSOR" \
        "$TARGET_FINGERPRINT_CONFIG_SENSOR"
    SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
        "smali_classes4/com/samsung/android/settings/biometrics/fingerprint/FingerprintSettingsUtils.smali" "replaceall" \
        "$SOURCE_FINGERPRINT_CONFIG_SENSOR" \
        "$TARGET_FINGERPRINT_CONFIG_SENSOR"

    if [[ "$(GET_FINGERPRINT_SENSOR_TYPE "$SOURCE_FINGERPRINT_CONFIG_SENSOR")" != "$(GET_FINGERPRINT_SENSOR_TYPE "$TARGET_FINGERPRINT_CONFIG_SENSOR")" ]]; then
        if [[ "$(GET_FINGERPRINT_SENSOR_TYPE "$SOURCE_FINGERPRINT_CONFIG_SENSOR")" == "ultrasonic" ]]; then
            if [[ "$(GET_FINGERPRINT_SENSOR_TYPE "$TARGET_FINGERPRINT_CONFIG_SENSOR")" == "optical" ]]; then
                SOURCE_FINGERPRINT_CONFIG_SENSOR="google_touch_display_optical,settings=3"

                if [[ "$TARGET_OS_SINGLE_SYSTEM_IMAGE" == "qssi" ]]; then
                    ADD_TO_WORK_DIR "r9qxxx" "system" "system/bin/surfaceflinger" 0 2000 755 "u:object_r:surfaceflinger_exec:s0"
                    ADD_TO_WORK_DIR "r9qxxx" "system" "system/lib/libgui.so" 0 0 644 "u:object_r:system_lib_file:s0"
                    ADD_TO_WORK_DIR "r9qxxx" "system" "system/lib/libui.so" 0 0 644 "u:object_r:system_lib_file:s0"
                    ADD_TO_WORK_DIR "r9qxxx" "system" "system/lib64/libgui.so" 0 0 644 "u:object_r:system_lib_file:s0"
                    ADD_TO_WORK_DIR "r9qxxx" "system" "system/lib64/libui.so" 0 0 644 "u:object_r:system_lib_file:s0"
                elif [[ "$TARGET_OS_SINGLE_SYSTEM_IMAGE" == "essi" ]]; then
                    ADD_TO_WORK_DIR "r9sxxx" "system" "system/bin/surfaceflinger" 0 2000 755 "u:object_r:surfaceflinger_exec:s0"
                    ADD_TO_WORK_DIR "r9sxxx" "system" "system/lib/libgui.so" 0 0 644 "u:object_r:system_lib_file:s0"
                    ADD_TO_WORK_DIR "r9sxxx" "system" "system/lib/libui.so" 0 0 644 "u:object_r:system_lib_file:s0"
                    ADD_TO_WORK_DIR "r9sxxx" "system" "system/lib64/libgui.so" 0 0 644 "u:object_r:system_lib_file:s0"
                    ADD_TO_WORK_DIR "r9sxxx" "system" "system/lib64/libui.so" 0 0 644 "u:object_r:system_lib_file:s0"
                else
                    ABORT "Unknown SSI: $TARGET_OS_SINGLE_SYSTEM_IMAGE"
                fi

                ADD_TO_WORK_DIR "r9qxxx" "system" "system/priv-app/BiometricSetting/BiometricSetting.apk" 0 0 644 "u:object_r:system_file:s0"

                APPLY_PATCH "system" "system/framework/framework.jar" \
                    "$MODPATH/fingerprint/optical_fod/framework.jar/0001-Add-optical-FOD-support.patch"
                APPLY_PATCH "system" "system/framework/services.jar" \
                    "$MODPATH/fingerprint/optical_fod/services.jar/0001-Add-optical-FOD-support.patch"
                APPLY_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
                    "$MODPATH/fingerprint/optical_fod/SecSettings.apk/0001-Add-optical-FOD-support.patch"
                APPLY_PATCH "system_ext" "priv-app/SystemUI/SystemUI.apk" \
                    "$MODPATH/fingerprint/optical_fod/SystemUI.apk/0001-Add-optical-FOD-support.patch"

                if [[ "$TARGET_FINGERPRINT_CONFIG_SENSOR" == *"no_delay_in_screen_off"* ]]; then
                    APPLY_PATCH "system" "system/priv-app/BiometricSetting/BiometricSetting.apk" \
                        "$MODPATH/fingerprint/optical_fod/BiometricSetting.apk/0001-Enable-FP_FEATURE_NO_DELAY_IN_SCREEN_OFF.patch"
                fi

                if [[ "$TARGET_FINGERPRINT_CONFIG_SENSOR" == *"transition_effect_on"* ]]; then
                    SMALI_PATCH "system" "system/framework/framework.jar" \
                        "smali_classes2/android/hardware/fingerprint/FingerprintManager.smali" "return" \
                        "semGetTransitionEffectValue()I" \
                        "1"
                elif [[ "$TARGET_FINGERPRINT_CONFIG_SENSOR" == *"transition_effect_off"* ]]; then
                    SMALI_PATCH "system" "system/framework/framework.jar" \
                        "smali_classes2/android/hardware/fingerprint/FingerprintManager.smali" "return" \
                        "semGetTransitionEffectValue()I" \
                        "0"
                fi
            elif [[ "$(GET_FINGERPRINT_SENSOR_TYPE "$TARGET_FINGERPRINT_CONFIG_SENSOR")" == "side" ]]; then
                SOURCE_FINGERPRINT_CONFIG_SENSOR="google_touch_side,navi=1"

                ADD_TO_WORK_DIR "b4qxxx" "system" "system/priv-app/BiometricSetting/BiometricSetting.apk" 0 0 644 "u:object_r:system_file:s0"
                APPLY_PATCH "system" "system/priv-app/BiometricSetting/BiometricSetting.apk" \
                    "$MODPATH/fingerprint/side_fp/BiometricSetting.apk/0001-Add-FEATURE_FINGERPRINT_JDM_HAL-support.patch"

                if [[ "$TARGET_FINGERPRINT_CONFIG_SENSOR" == *"navi=1"* ]]; then
                    LOG "- Enabling FP_FEATURE_GESTURE_MODE:Z in /system/system/framework/services.jar/smali/com/android/server/biometrics/SemBiometricFeature.smali"
                    SMALI_PATCH "system" "system/framework/services.jar" \
                        "smali/com/android/server/biometrics/SemBiometricFeature.smali" "replace" \
                        "<clinit>()V" \
                        "sput-boolean v3, Lcom/android/server/biometrics/SemBiometricFeature;->FP_FEATURE_GESTURE_MODE:Z" \
                        "sput-boolean v2, Lcom/android/server/biometrics/SemBiometricFeature;->FP_FEATURE_GESTURE_MODE:Z" \
                        > /dev/null
                fi
                if [[ "$TARGET_FINGERPRINT_CONFIG_SENSOR" == *"swipe_enroll"* ]]; then
                    LOG "- Enabling FP_FEATURE_SWIPE_ENROLL:Z in /system/system/framework/services.jar/smali/com/android/server/biometrics/SemBiometricFeature.smali"
                    SMALI_PATCH "system" "system/framework/services.jar" \
                        "smali/com/android/server/biometrics/SemBiometricFeature.smali" "replace" \
                        "<clinit>()V" \
                        "sput-boolean v3, Lcom/android/server/biometrics/SemBiometricFeature;->FP_FEATURE_SWIPE_ENROLL:Z" \
                        "sput-boolean v2, Lcom/android/server/biometrics/SemBiometricFeature;->FP_FEATURE_SWIPE_ENROLL:Z" \
                        > /dev/null
                fi
                if [[ "$TARGET_FINGERPRINT_CONFIG_SENSOR" == *"wof_off"* ]]; then
                    LOG "- Enabling FP_FEATURE_WOF_OPTION_DEFAULT_OFF:Z in /system/system/framework/services.jar/smali/com/android/server/biometrics/SemBiometricFeature.smali"
                    SMALI_PATCH "system" "system/framework/services.jar" \
                        "smali/com/android/server/biometrics/SemBiometricFeature.smali" "replace" \
                        "<clinit>()V" \
                        "sput-boolean v3, Lcom/android/server/biometrics/SemBiometricFeature;->FP_FEATURE_WOF_OPTION_DEFAULT_OFF:Z" \
                        "sput-boolean v2, Lcom/android/server/biometrics/SemBiometricFeature;->FP_FEATURE_WOF_OPTION_DEFAULT_OFF:Z" \
                        > /dev/null
                fi
            elif [[ "$(GET_FINGERPRINT_SENSOR_TYPE "$TARGET_FINGERPRINT_CONFIG_SENSOR")" != "ultrasonic" ]]; then
                # TODO handle this condition
                LOG_MISSING_PATCHES "SOURCE_FINGERPRINT_CONFIG_SENSOR" "TARGET_FINGERPRINT_CONFIG_SENSOR"
            fi
        elif [[ "$(GET_FINGERPRINT_SENSOR_TYPE "$SOURCE_FINGERPRINT_CONFIG_SENSOR")" == "side" ]] && \
                [[ "$(GET_FINGERPRINT_SENSOR_TYPE "$TARGET_FINGERPRINT_CONFIG_SENSOR")" == "optical" ]] && \
                [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
            # One UI 9 side-sensor source (Fold8) -> optical under-display target.
            # In-display/optical/ultrasonic flags are derived at runtime from
            # SEC_FLOATING_FEATURE_BIOAUTH_CONFIG_FINGERPRINT_FEATURES (target value is kept),
            # but side-sensor specifics and the HIDL sensor type mapping are compiled in.
            DECODE_APK "system" "system/framework/framework.jar"
            DECODE_APK "system" "system/framework/services.jar"
            python3 - "$APKTOOL_DIR/system/framework" <<'PYEOF' || ABORT "Failed to apply side -> optical fingerprint patches"
import glob, re, sys
root = sys.argv[1]
def one(pat):
    hits = glob.glob(root + "/" + pat)
    assert len(hits) == 1, pat
    return hits[0]

# HIDL -> AIDL: sensor position 2 (in-display) was compiled out; report UNDER_DISPLAY_OPTICAL (3)
f = one("framework.jar/smali*/android/hardware/fingerprint/HidlFingerprintSensorConfig.smali")
s = open(f).read()
old = """    const/4 v2, 0x2

    if-eq v1, v2, :cond_4
"""
new = """    const/4 v2, 0x2

    if-ne v1, v2, :cond_unica_not_udfps

    const/4 v2, 0x3

    iput-byte v2, p0, Landroid/hardware/fingerprint/HidlFingerprintSensorConfig;->sensorType:B

    goto :goto_0

    :cond_unica_not_udfps
"""
assert s.count(old) == 1, "HidlFingerprintSensorConfig"
open(f, "w").write(s.replace(old, new))

# Samsung sensor type: 1 = side, 2 = optical, 3 = ultrasonic
f = one("framework.jar/smali*/com/samsung/android/bio/fingerprint/SemFingerprintManager$Characteristics.smali")
s = open(f).read()
s, n = re.subn(r"(\.method public (?:\w+ )*getSensorType\(\)I\n\s+\.locals 0\n\n\s+)const/4 p0, 0x\d", r"\1const/4 p0, 0x2", s)
assert n == 1, "Characteristics.getSensorType"
open(f, "w").write(s)

# services: side sensor and swipe enroll are hardcoded true on the Fold8
f = one("services.jar/smali*/com/android/server/biometrics/SemBiometricFeature.smali")
s = open(f).read()
for field in ("FP_FEATURE_SENSOR_IS_SIDE", "FP_FEATURE_SWIPE_ENROLL"):
    s, n = re.subn(r"(\n(\s+)sput-boolean )(v\d+)(, Lcom/android/server/biometrics/SemBiometricFeature;->%s:Z)" % field,
                   r"\n\2const/4 v0, 0x0\n\1v0\4", s)
    assert n == 1, field
open(f, "w").write(s)
PYEOF
            LOG "- Applied side -> optical fingerprint framework patches"
        else
            # TODO handle this condition
            LOG_MISSING_PATCHES "SOURCE_FINGERPRINT_CONFIG_SENSOR" "TARGET_FINGERPRINT_CONFIG_SENSOR"
        fi
    fi

    if [[ "$SOURCE_FINGERPRINT_CONFIG_SENSOR" != "$TARGET_FINGERPRINT_CONFIG_SENSOR" ]]; then
        SMALI_PATCH "system" "system/priv-app/BiometricSetting/BiometricSetting.apk" \
            "smali/com/samsung/android/biometrics/app/setting/DisplayStateManager.smali" "replace" \
            "<init>(Lcom/samsung/android/biometrics/app/setting/BiometricsUIService;)V" \
            "$SOURCE_FINGERPRINT_CONFIG_SENSOR" \
            "$TARGET_FINGERPRINT_CONFIG_SENSOR"
    fi
fi

# SEC_PRODUCT_FEATURE_LCD_CONFIG_CONTROL_AUTO_BRIGHTNESS
if [[ "$SOURCE_LCD_CONFIG_CONTROL_AUTO_BRIGHTNESS" != "$TARGET_LCD_CONFIG_CONTROL_AUTO_BRIGHTNESS" ]]; then
    SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_LCD_CONFIG_CONTROL_AUTO_BRIGHTNESS" "$TARGET_LCD_CONFIG_CONTROL_AUTO_BRIGHTNESS"

    SMALI_PATCH "system" "system/framework/services.jar" \
        "smali_classes2/com/android/server/power/PowerManagerUtil.smali" "replace" \
        "<clinit>()V" \
        "$SOURCE_LCD_CONFIG_CONTROL_AUTO_BRIGHTNESS" \
        "$TARGET_LCD_CONFIG_CONTROL_AUTO_BRIGHTNESS"
    SMALI_PATCH "system" "system/framework/ssrm.jar" \
        "smali/com/android/server/ssrm/PreMonitor.smali" "replace" \
        "getBrightness()Ljava/lang/String;" \
        "$SOURCE_LCD_CONFIG_CONTROL_AUTO_BRIGHTNESS" \
        "$TARGET_LCD_CONFIG_CONTROL_AUTO_BRIGHTNESS"
    # One UI 9 Settings no longer bakes this value into Rune
    if [ "$SOURCE_PLATFORM_SDK_VERSION" -lt "37" ]; then
        SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
            "smali_classes4/com/samsung/android/settings/Rune.smali" "replace" \
            "<clinit>()V" \
            "$SOURCE_LCD_CONFIG_CONTROL_AUTO_BRIGHTNESS" \
            "$TARGET_LCD_CONFIG_CONTROL_AUTO_BRIGHTNESS"
    fi
fi

# SEC_PRODUCT_FEATURE_LCD_CONFIG_SEAMLESS_BRT
# SEC_PRODUCT_FEATURE_LCD_CONFIG_SEAMLESS_LUX
#
# Apply before SEC_PRODUCT_FEATURE_LCD_CONFIG_HFR_* to avoid conflicts
if [[ "$SOURCE_LCD_CONFIG_SEAMLESS_BRT" != "$TARGET_LCD_CONFIG_SEAMLESS_BRT" ]] || \
        [[ "$SOURCE_LCD_CONFIG_SEAMLESS_LUX" != "$TARGET_LCD_CONFIG_SEAMLESS_LUX" ]]; then
    if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
        if [[ "$SOURCE_LCD_CONFIG_SEAMLESS_BRT" != "none" ]] || \
                [[ "$SOURCE_LCD_CONFIG_SEAMLESS_LUX" != "none" ]] || \
                [[ "$TARGET_LCD_CONFIG_SEAMLESS_BRT" == "none" ]] || \
                [[ "$TARGET_LCD_CONFIG_SEAMLESS_LUX" == "none" ]]; then
            ABORT "Unsupported Android 17 seamless brightness transition"
        fi

        SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_LCD_CONFIG_SEAMLESS_BRT" "$TARGET_LCD_CONFIG_SEAMLESS_BRT"
        SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_LCD_CONFIG_SEAMLESS_LUX" "$TARGET_LCD_CONFIG_SEAMLESS_LUX"

        SMALI_PATCH "system" "system/framework/framework.jar" \
            "smali_classes6/com/samsung/android/hardware/display/RefreshRateConfig.smali" "replace" \
            "getMainInstance()Lcom/samsung/android/hardware/display/RefreshRateConfig;" \
            ".locals 4" \
            ".locals 5"
        printf -v API37_THRESHOLD_REGS \
            '    const-string v3, "%s"\n\n    const-string v4, "%s"' \
            "$TARGET_LCD_CONFIG_SEAMLESS_BRT" "$TARGET_LCD_CONFIG_SEAMLESS_LUX"
        SMALI_PATCH "system" "system/framework/framework.jar" \
            "smali_classes6/com/samsung/android/hardware/display/RefreshRateConfig.smali" "replace" \
            "getMainInstance()Lcom/samsung/android/hardware/display/RefreshRateConfig;" \
            'const-string v3, ""' \
            "$API37_THRESHOLD_REGS"
        SMALI_PATCH "system" "system/framework/framework.jar" \
            "smali_classes6/com/samsung/android/hardware/display/RefreshRateConfig.smali" "replace" \
            "getMainInstance()Lcom/samsung/android/hardware/display/RefreshRateConfig;" \
            'invoke-direct {v0, v3, v3, v1, v2}, Lcom/samsung/android/hardware/display/RefreshRateConfig$BrightnessThreshold;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V' \
            'invoke-direct {v0, v3, v4, v1, v2}, Lcom/samsung/android/hardware/display/RefreshRateConfig$BrightnessThreshold;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V'
        unset API37_THRESHOLD_REGS
    elif [[ "$SOURCE_LCD_CONFIG_SEAMLESS_BRT" != "none" ]] && [[ "$SOURCE_LCD_CONFIG_SEAMLESS_LUX" != "none" ]] && \
            [[ "$TARGET_LCD_CONFIG_SEAMLESS_BRT" == "none" ]] && [[ "$TARGET_LCD_CONFIG_SEAMLESS_LUX" == "none" ]]; then
        APPLY_PATCH "system" "system/framework/framework.jar" \
            "$MODPATH/hfr/framework.jar/0001-Remove-brightness-threshold-values.patch"
    elif [[ "$SOURCE_LCD_CONFIG_SEAMLESS_BRT" != "none" ]] && [[ "$SOURCE_LCD_CONFIG_SEAMLESS_LUX" != "none" ]] && \
            [[ "$TARGET_LCD_CONFIG_SEAMLESS_BRT" != "none" ]] && [[ "$TARGET_LCD_CONFIG_SEAMLESS_LUX" != "none" ]]; then
        SMALI_PATCH "system" "system/framework/framework.jar" \
            "smali_classes6/com/samsung/android/hardware/display/RefreshRateConfig.smali" "replace" \
            "dump(Ljava/io/PrintWriter;Ljava/lang/String;Z)V" \
            "SEAMLESS_BRT: $SOURCE_LCD_CONFIG_SEAMLESS_BRT" \
            "SEAMLESS_BRT: $TARGET_LCD_CONFIG_SEAMLESS_BRT"
        SMALI_PATCH "system" "system/framework/framework.jar" \
            "smali_classes6/com/samsung/android/hardware/display/RefreshRateConfig.smali" "replace" \
            "dump(Ljava/io/PrintWriter;Ljava/lang/String;Z)V" \
            "SEAMLESS_LUX: $SOURCE_LCD_CONFIG_SEAMLESS_LUX" \
            "SEAMLESS_LUX: $TARGET_LCD_CONFIG_SEAMLESS_LUX"
        SMALI_PATCH "system" "system/framework/framework.jar" \
            "smali_classes6/com/samsung/android/hardware/display/RefreshRateConfig.smali" "replace" \
            "getMainInstance()Lcom/samsung/android/hardware/display/RefreshRateConfig;" \
            "$SOURCE_LCD_CONFIG_SEAMLESS_BRT" \
            "$TARGET_LCD_CONFIG_SEAMLESS_BRT"
        SMALI_PATCH "system" "system/framework/framework.jar" \
            "smali_classes6/com/samsung/android/hardware/display/RefreshRateConfig.smali" "replace" \
            "getMainInstance()Lcom/samsung/android/hardware/display/RefreshRateConfig;" \
            "$SOURCE_LCD_CONFIG_SEAMLESS_LUX" \
            "$TARGET_LCD_CONFIG_SEAMLESS_LUX"
    else
        # TODO handle these conditions
        LOG_MISSING_PATCHES "SOURCE_LCD_CONFIG_SEAMLESS_BRT" "TARGET_LCD_CONFIG_SEAMLESS_BRT" || true
        LOG_MISSING_PATCHES "SOURCE_LCD_CONFIG_SEAMLESS_LUX" "TARGET_LCD_CONFIG_SEAMLESS_LUX"
    fi
fi

# SEC_PRODUCT_FEATURE_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE
if [[ "$SOURCE_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE" != "$TARGET_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE" ]]; then
    SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE" "$TARGET_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE"

    SMALI_PATCH "system" "system/framework/framework.jar" \
        "smali_classes6/com/samsung/android/hardware/display/RefreshRateConfig.smali" "replace" \
        "dump(Ljava/io/PrintWriter;Ljava/lang/String;Z)V" \
        "HFR_DEFAULT_REFRESH_RATE: $SOURCE_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE" \
        "HFR_DEFAULT_REFRESH_RATE: $TARGET_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE"
    SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
        "smali_classes4/com/samsung/android/settings/display/SecDisplayUtils.smali" "replace" \
        "getHighRefreshRateDefaultValue(Landroid/content/Context;I)I" \
        "$SOURCE_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE" \
        "$TARGET_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE"
    SMALI_PATCH "system" "system/priv-app/SettingsProvider/SettingsProvider.apk" \
        "smali/com/android/providers/settings/DatabaseHelper.smali" "replace" \
        "loadRefreshRateMode(Landroid/database/sqlite/SQLiteStatement;Ljava/lang/String;)V" \
        "$SOURCE_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE" \
        "$TARGET_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE"
fi

# SEC_PRODUCT_FEATURE_LCD_CONFIG_HFR_MODE
if [[ "$SOURCE_LCD_CONFIG_HFR_MODE" != "$TARGET_LCD_CONFIG_HFR_MODE" ]]; then
    SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_MODE" "$TARGET_LCD_CONFIG_HFR_MODE"

    SMALI_PATCH "system" "system/framework/framework.jar" \
        "smali_classes2/android/inputmethodservice/SemImsRune.smali" "replace" \
        "<clinit>()V" \
        "$SOURCE_LCD_CONFIG_HFR_MODE" \
        "$TARGET_LCD_CONFIG_HFR_MODE"
    if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
        SMALI_PATCH "system" "system/framework/framework.jar" \
            "smali_classes6/com/samsung/android/hardware/display/RefreshRateConfig.smali" "replace" \
            "dumpProductFeature(Ljava/io/PrintWriter;Ljava/lang/String;Z)V" \
            "$SOURCE_LCD_CONFIG_HFR_MODE" \
            "$TARGET_LCD_CONFIG_HFR_MODE"
    else
        SMALI_PATCH "system" "system/framework/framework.jar" \
            "smali_classes6/com/samsung/android/hardware/display/RefreshRateConfig.smali" "replace" \
            "dump(Ljava/io/PrintWriter;Ljava/lang/String;Z)V" \
            "HFR_MODE: $SOURCE_LCD_CONFIG_HFR_MODE" \
            "HFR_MODE: $TARGET_LCD_CONFIG_HFR_MODE"
    fi
    SMALI_PATCH "system" "system/framework/framework.jar" \
        "smali_classes6/com/samsung/android/hardware/display/RefreshRateConfig.smali" "replace" \
        "getMainInstance()Lcom/samsung/android/hardware/display/RefreshRateConfig;" \
        "$SOURCE_LCD_CONFIG_HFR_MODE" \
        "$TARGET_LCD_CONFIG_HFR_MODE"
    SMALI_PATCH "system" "system/framework/framework.jar" \
        "smali_classes6/com/samsung/android/rune/CoreRune.smali" "replace" \
        "<clinit>()V" \
        "$SOURCE_LCD_CONFIG_HFR_MODE" \
        "$TARGET_LCD_CONFIG_HFR_MODE"
    if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
        DECODE_APK "system" "system/framework/gamemanager.jar"
        REQUIRE_FIXED_COUNT \
            "$APKTOOL_DIR/system/framework/gamemanager.jar/smali/com/samsung/android/game/VrrManager.smali" \
            'iget v0, p0, Lcom/samsung/android/game/VrrManager;->mHfrMode:I' 1 \
            "GameManager runtime HFR-mode lookup"
    else
        SMALI_PATCH "system" "system/framework/gamemanager.jar" \
            "smali/com/samsung/android/game/GameManagerService.smali" "replace" \
            "isVariableRefreshRateSupported()Ljava/lang/String;" \
            "$SOURCE_LCD_CONFIG_HFR_MODE" \
            "$TARGET_LCD_CONFIG_HFR_MODE"
    fi
    SMALI_PATCH "system" "system/framework/secinputdev-service.jar" \
        "smali/com/samsung/android/hardware/secinputdev/utils/SemInputFeatures.smali" "replaceall" \
        "\\\"$SOURCE_LCD_CONFIG_HFR_MODE\\\"" \
        "\\\"$TARGET_LCD_CONFIG_HFR_MODE\\\""
    SMALI_PATCH "system" "system/framework/secinputdev-service.jar" \
        "smali/com/samsung/android/hardware/secinputdev/utils/SemInputFeaturesExtra.smali" "replaceall" \
        "\\\"$SOURCE_LCD_CONFIG_HFR_MODE\\\"" \
        "\\\"$TARGET_LCD_CONFIG_HFR_MODE\\\""
    SMALI_PATCH "system" "system/framework/services.jar" \
        "smali_classes2/com/android/server/power/PowerManagerUtil.smali" "replace" \
        "<clinit>()V" \
        "$SOURCE_LCD_CONFIG_HFR_MODE" \
        "$TARGET_LCD_CONFIG_HFR_MODE"
    SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
        "$([ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ] && echo "smali_classes3" || echo "smali_classes4")/com/samsung/android/settings/display/SecDisplayUtils.smali" "replace" \
        "getHighRefreshRateSeamlessType($([ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ] && echo "Landroid/content/Context;")I)I" \
        "$SOURCE_LCD_CONFIG_HFR_MODE" \
        "$TARGET_LCD_CONFIG_HFR_MODE"
    SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
        "$([ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ] && echo "smali_classes3" || echo "smali_classes4")/com/samsung/android/settings/display/SecDisplayUtils.smali" "replace" \
        "isSupportMaxHS60RefreshRate($([ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ] && echo "Landroid/content/Context;")I)Z" \
        "$SOURCE_LCD_CONFIG_HFR_MODE" \
        "$TARGET_LCD_CONFIG_HFR_MODE"
    SMALI_PATCH "system" "system/priv-app/SettingsProvider/SettingsProvider.apk" \
        "smali/com/android/providers/settings/DatabaseHelper.smali" "replace" \
        "loadRefreshRateMode(Landroid/database/sqlite/SQLiteStatement;Ljava/lang/String;)V" \
        "$SOURCE_LCD_CONFIG_HFR_MODE" \
        "$TARGET_LCD_CONFIG_HFR_MODE"
    SMALI_PATCH "system_ext" "priv-app/SystemUI/SystemUI.apk" \
        "smali/com/android/systemui/BasicRune.smali" "replace" \
        "<clinit>()V" \
        "$SOURCE_LCD_CONFIG_HFR_MODE" \
        "$TARGET_LCD_CONFIG_HFR_MODE"
    SMALI_PATCH "system_ext" "priv-app/SystemUI/SystemUI.apk" \
        "smali/com/android/systemui/LsRune.smali" "replace" \
        "<clinit>()V" \
        "$SOURCE_LCD_CONFIG_HFR_MODE" \
        "$TARGET_LCD_CONFIG_HFR_MODE"
fi

# SEC_PRODUCT_FEATURE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE
if [[ "$SOURCE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE" != "$TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE" ]]; then
    if [[ "$TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE" != "none" ]]; then
        SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE" "$TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE"
    else
        SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE" "0"
    fi

    if [[ "$SOURCE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE" != "none" ]]; then
        if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
            SMALI_PATCH "system" "system/framework/framework.jar" \
                "smali_classes6/com/samsung/android/hardware/display/RefreshRateConfig.smali" "replace" \
                "dumpProductFeature(Ljava/io/PrintWriter;Ljava/lang/String;Z)V" \
                "$SOURCE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE" \
                "${TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE//none/}"
        else
            SMALI_PATCH "system" "system/framework/framework.jar" \
                "smali_classes6/com/samsung/android/hardware/display/RefreshRateConfig.smali" "replace" \
                "dump(Ljava/io/PrintWriter;Ljava/lang/String;Z)V" \
                "HFR_SUPPORTED_REFRESH_RATE: $SOURCE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE" \
                "HFR_SUPPORTED_REFRESH_RATE: ${TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE//none/}"
        fi
        SMALI_PATCH "system" "system/framework/framework.jar" \
            "smali_classes6/com/samsung/android/hardware/display/RefreshRateConfig.smali" "replace" \
            "getMainInstance()Lcom/samsung/android/hardware/display/RefreshRateConfig;" \
            "$SOURCE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE" \
            "${TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE//none/}"
        SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
            "$([ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ] && echo "smali_classes3" || echo "smali_classes4")/com/samsung/android/settings/display/SecDisplayUtils.smali" "replace" \
            "getHighRefreshRateSupportedValues(I)[Ljava/lang/String;" \
            "$SOURCE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE" \
            "${TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE//none/}"
        SMALI_PATCH "system_ext" "priv-app/SystemUI/SystemUI.apk" \
            "smali_classes2/com/android/systemui/keyguard/KeyguardViewMediatorHelperImpl\$\$ExternalSyntheticLambda0.smali" "replace" \
            "invoke()Ljava/lang/Object;" \
            "$SOURCE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE" \
            "${TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE//none/}"
    else
        # TODO handle this condition
        LOG_MISSING_PATCHES "SOURCE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE" "TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE"
    fi
fi

# SEC_PRODUCT_FEATURE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE_NS
if [[ "$SOURCE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE_NS" != "$TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE_NS" ]]; then
    if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
        if [[ "$SOURCE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE_NS" != "none" ]] || \
                [[ "$TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE_NS" == "none" ]]; then
            ABORT "Unsupported Android 17 normal-speed refresh-rate transition"
        fi

        SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE_NS" \
            "$TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE_NS"
        printf -v API37_REFRESH_RATE_REGS \
            '    const-string v2, "%s"\n\n    const-string v3, "%s"' \
            "$TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE" \
            "$TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE_NS"
        SMALI_PATCH "system" "system/framework/framework.jar" \
            "smali_classes6/com/samsung/android/hardware/display/RefreshRateConfig.smali" "replace" \
            "getMainInstance()Lcom/samsung/android/hardware/display/RefreshRateConfig;" \
            "const-string v2, \"$TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE\"" \
            "$API37_REFRESH_RATE_REGS"
        unset API37_REFRESH_RATE_REGS
    elif [[ "$SOURCE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE_NS" != "none" ]]; then
        if [[ "$TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE_NS" != "none" ]]; then
            SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE_NS" "$TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE_NS"
        else
            SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE_NS" --delete
        fi

        SMALI_PATCH "system" "system/framework/framework.jar" \
            "smali_classes6/com/samsung/android/hardware/display/RefreshRateConfig.smali" "replace" \
            "dump(Ljava/io/PrintWriter;Ljava/lang/String;Z)V" \
            "HFR_SUPPORTED_REFRESH_RATE_NS: $SOURCE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE_NS" \
            "HFR_SUPPORTED_REFRESH_RATE_NS: ${TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE_NS//none/}"
        SMALI_PATCH "system" "system/framework/framework.jar" \
            "smali_classes6/com/samsung/android/hardware/display/RefreshRateConfig.smali" "replace" \
            "getMainInstance()Lcom/samsung/android/hardware/display/RefreshRateConfig;" \
            "$SOURCE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE_NS" \
            "${TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE_NS//none/}"
    else
        # TODO handle this condition
        LOG_MISSING_PATCHES "SOURCE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE_NS" "TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE_NS"
    fi
fi

# SEC_PRODUCT_FEATURE_LCD_SUPPORT_MDNIE_HW
# SEC_PRODUCT_FEATURE_LCD_CONFIG_COLOR_WEAKNESS_SOLUTION
if $SOURCE_LCD_SUPPORT_MDNIE_HW && [[ "$SOURCE_LCD_CONFIG_COLOR_WEAKNESS_SOLUTION" != "0" ]]; then
    if ! $TARGET_LCD_SUPPORT_MDNIE_HW; then
        SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_LCD_SUPPORT_MDNIE_HW" --delete

        APPLY_PATCH "system" "system/framework/framework.jar" \
            "$MODPATH/mdnie/hw/framework.jar/0001-Disable-HW-mDNIe.patch"
        if [[ "$TARGET_LCD_CONFIG_COLOR_WEAKNESS_SOLUTION" == "0" ]]; then
            APPLY_PATCH "system" "system/framework/framework.jar" \
                "$MODPATH/mdnie/hw/framework.jar/0002-Disable-A11Y_COLOR_BOOL_SUPPORT_DMC_COLORWEAKNESS.patch"
        fi
        if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
            # TODO One UI 9 port of the services.jar HW mDNIe removal (1.7k lines); not boot critical
            LOGW "Deferred: mdnie/hw/services.jar on One UI 9"
            echo "/system/system/framework/services.jar unica/patches/product_feature/mdnie/hw/services.jar/0001-Disable-HW-mDNIe.patch (deferred)" >> "$OUT_DIR/skipped_patches.txt"
        else
            APPLY_PATCH "system" "system/framework/services.jar" \
                "$MODPATH/mdnie/hw/services.jar/0001-Disable-HW-mDNIe.patch"
        fi
    fi
elif $SOURCE_LCD_SUPPORT_MDNIE_HW && [[ "$SOURCE_LCD_CONFIG_COLOR_WEAKNESS_SOLUTION" == "0" ]]; then
    # TODO handle these conditions
    LOG_MISSING_PATCHES "SOURCE_LCD_SUPPORT_MDNIE_HW" "TARGET_LCD_SUPPORT_MDNIE_HW" || true
    LOG_MISSING_PATCHES "SOURCE_LCD_CONFIG_COLOR_WEAKNESS_SOLUTION" "TARGET_LCD_CONFIG_COLOR_WEAKNESS_SOLUTION"
else
    if $TARGET_LCD_SUPPORT_MDNIE_HW || \
            [[ "$SOURCE_LCD_CONFIG_COLOR_WEAKNESS_SOLUTION" != "$TARGET_LCD_CONFIG_COLOR_WEAKNESS_SOLUTION" ]]; then
        # TODO handle these conditions
        LOG_MISSING_PATCHES "SOURCE_LCD_SUPPORT_MDNIE_HW" "TARGET_LCD_SUPPORT_MDNIE_HW" || true
        LOG_MISSING_PATCHES "SOURCE_LCD_CONFIG_COLOR_WEAKNESS_SOLUTION" "TARGET_LCD_CONFIG_COLOR_WEAKNESS_SOLUTION"
    fi
fi

# SEC_PRODUCT_FEATURE_RIL_FEATURES
if [[ "$SOURCE_RIL_FEATURES" != "$TARGET_RIL_FEATURES" ]]; then
    if [[ "$SOURCE_RIL_FEATURES" != "none" ]]; then
        if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
            SMALI_PATCH "system" "system/framework/framework.jar" \
                "smali_classes6/com/android/internal/telephony/TelephonyFeatures.smali" "replaceall" \
                "$SOURCE_RIL_FEATURES" \
                "${TARGET_RIL_FEATURES//none/}"
            SMALI_PATCH "system" "system/framework/telephony-common.jar" \
                "smali/com/android/internal/telephony/TelephonyLogger.smali" "replaceall" \
                "$SOURCE_RIL_FEATURES" \
                "${TARGET_RIL_FEATURES//none/}"
        else
            SMALI_PATCH "system" "system/framework/framework.jar" \
                "smali_classes4/com/android/internal/telephony/TelephonyFeatures.smali" "replaceall" \
                "$SOURCE_RIL_FEATURES" \
                "${TARGET_RIL_FEATURES//none/}"
            SMALI_PATCH "system" "system/framework/telephony-common.jar" \
                "smali/com/android/internal/telephony/TelephonyLogger.smali" "replace" \
                "dump(Ljava/io/FileDescriptor;Ljava/io/PrintWriter;[Ljava/lang/String;)V" \
                "$SOURCE_RIL_FEATURES" \
                "${TARGET_RIL_FEATURES//none/}"
            SMALI_PATCH "system" "system/priv-app/TeleService/TeleService.apk" \
                "smali/com/samsung/telephony/model/feature/tag/SamsungProductFeatureTag.smali" "replaceall" \
                "$SOURCE_RIL_FEATURES" \
                "${TARGET_RIL_FEATURES//none/}"
        fi
        SMALI_PATCH "system" "system/priv-app/TeleService/TeleService.apk" \
            "smali/com/samsung/telephony/model/feature/SamsungFeatureSatellite.smali" "replaceall" \
            "$SOURCE_RIL_FEATURES" \
            "${TARGET_RIL_FEATURES//none/}"
    else
        # TODO handle this condition
        LOG_MISSING_PATCHES "SOURCE_RIL_FEATURES" "TARGET_RIL_FEATURES"
    fi
fi

# SEC_PRODUCT_FEATURE_RIL_SIM_CONFIG_MULTISIM_TRAYCOUNT
if [[ "$SOURCE_RIL_SIM_CONFIG_MULTISIM_TRAYCOUNT" != "$TARGET_RIL_SIM_CONFIG_MULTISIM_TRAYCOUNT" ]]; then
    if [[ "$SOURCE_RIL_SIM_CONFIG_MULTISIM_TRAYCOUNT" == "1" ]] && \
            [[ "$TARGET_RIL_SIM_CONFIG_MULTISIM_TRAYCOUNT" != "1" ]]; then
        SMALI_PATCH "system" "system/framework/framework.jar" \
            "$([ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ] && echo "smali_classes6" || echo "smali_classes4")/com/android/internal/telephony/TelephonyFeatures.smali" "return" \
            "isOneTray()Z" \
            "false"
    elif [[ "$SOURCE_RIL_SIM_CONFIG_MULTISIM_TRAYCOUNT" != "1" ]] && \
            [[ "$TARGET_RIL_SIM_CONFIG_MULTISIM_TRAYCOUNT" == "1" ]]; then
        # TODO handle this condition
        LOG_MISSING_PATCHES "SOURCE_RIL_SIM_CONFIG_MULTISIM_TRAYCOUNT" "TARGET_RIL_SIM_CONFIG_MULTISIM_TRAYCOUNT"
    fi
fi

# SEC_PRODUCT_FEATURE_RIL_SUPPORT_WATERPROOF_SIM_TRAY_MSG
if $SOURCE_RIL_SUPPORT_WATERPROOF_SIM_TRAY_MSG; then
    if ! $TARGET_RIL_SUPPORT_WATERPROOF_SIM_TRAY_MSG; then
        APPLY_PATCH "system" "system/framework/telephony-common.jar" \
            "$MODPATH/ril/telephony-common.jar/0001-Disable-RIL_SUPPORT_WATERPROOF_SIM_TRAY_MSG.patch"
    fi
else
    if $TARGET_RIL_SUPPORT_WATERPROOF_SIM_TRAY_MSG; then
        # TODO handle this condition
        LOG_MISSING_PATCHES "SOURCE_RIL_SUPPORT_WATERPROOF_SIM_TRAY_MSG" "TARGET_RIL_SUPPORT_WATERPROOF_SIM_TRAY_MSG"
    fi
fi

# SEC_PRODUCT_FEATURE_SECURITY_SUPPORT_STRONGBOX
TARGET_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$TARGET_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$TARGET_FIRMWARE")"

if [ ! -f "$FW_DIR/$TARGET_FIRMWARE_PATH/vendor/etc/permissions/android.hardware.strongbox_keystore.xml" ]; then
    SMALI_PATCH "system" "system/framework/framework.jar" \
        "smali_classes6/com/samsung/android/service/DeviceIDProvisionService/DeviceIDProvisionManager\$DeviceIDProvisionWorker.smali" "return" \
        "isSupportStrongboxDeviceID()Z" \
        "false"
fi

# SEC_PRODUCT_FEATURE_WLAN_CONFIG_CPU_CSTATE_DISABLE_THRESHOLD
# SEC_PRODUCT_FEATURE_WLAN_CONFIG_DATA_ACTIVITY_AFFINITY_BOOSTER_THRESHOLD
# SEC_PRODUCT_FEATURE_WLAN_CONFIG_L1SS_DISABLE_THRESHOLD
if [[ "$SOURCE_WLAN_CONFIG_CPU_CSTATE_DISABLE_THRESHOLD" != "$TARGET_WLAN_CONFIG_CPU_CSTATE_DISABLE_THRESHOLD" ]] || \
        [[ "$SOURCE_WLAN_CONFIG_DATA_ACTIVITY_AFFINITY_BOOSTER_THRESHOLD" != "$TARGET_WLAN_CONFIG_DATA_ACTIVITY_AFFINITY_BOOSTER_THRESHOLD" ]] || \
        [[ "$SOURCE_WLAN_CONFIG_L1SS_DISABLE_THRESHOLD" != "$TARGET_WLAN_CONFIG_L1SS_DISABLE_THRESHOLD" ]]; then
    if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
        DECODE_APK "system" "system/framework/semwifi-service.jar"
        printf -v API37_BOOSTER_METHOD \
            '.method public getBoosterThresholds()[I\n    .locals 3\n\n    const v0, 0x%x\n\n    const v1, 0x%x\n\n    const v2, 0x%x\n\n    filled-new-array {v0, v1, v2}, [I\n\n    move-result-object v0\n\n    return-object v0\n.end method' \
            "$((TARGET_WLAN_CONFIG_DATA_ACTIVITY_AFFINITY_BOOSTER_THRESHOLD * 1048576 / 8))" \
            "$((TARGET_WLAN_CONFIG_CPU_CSTATE_DISABLE_THRESHOLD * 1048576 / 8))" \
            "$((TARGET_WLAN_CONFIG_L1SS_DISABLE_THRESHOLD * 1048576 / 8))"
        REPLACE_SMALI_METHOD \
            "$APKTOOL_DIR/system/framework/semwifi-service.jar/smali/com/samsung/android/server/wifi/SemFrameworkFacade.smali" \
            "getBoosterThresholds()[I" \
            "$API37_BOOSTER_METHOD"
        unset API37_BOOSTER_METHOD
    elif [[ "$SOURCE_WLAN_CONFIG_CPU_CSTATE_DISABLE_THRESHOLD" == "100" ]] && \
            [[ "$SOURCE_WLAN_CONFIG_DATA_ACTIVITY_AFFINITY_BOOSTER_THRESHOLD" == "0" ]] && \
            [[ "$SOURCE_WLAN_CONFIG_L1SS_DISABLE_THRESHOLD" == "0" ]]; then
        APPLY_PATCH "system" "system/framework/semwifi-service.jar" \
            "$MODPATH/wifi/thresholds/semwifi-service.jar/0001-Allow-custom-booster-thresholds-values.patch"
        SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
            "smali/com/samsung/android/server/wifi/SemFrameworkFacade.smali" "replace" \
            "getBoosterThresholds()[I" \
            "CONFIG_DATA_ACTIVITY_AFFINITY_BOOSTER_THRESHOLD" \
            "$TARGET_WLAN_CONFIG_DATA_ACTIVITY_AFFINITY_BOOSTER_THRESHOLD" | \
            sed "s/CONFIG_DATA_ACTIVITY_AFFINITY_BOOSTER_THRESHOLD/$SOURCE_WLAN_CONFIG_DATA_ACTIVITY_AFFINITY_BOOSTER_THRESHOLD/g"
        SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
            "smali/com/samsung/android/server/wifi/SemFrameworkFacade.smali" "replace" \
            "getBoosterThresholds()[I" \
            "CONFIG_CPU_CSTATE_DISABLE_THRESHOLD" \
            "$TARGET_WLAN_CONFIG_CPU_CSTATE_DISABLE_THRESHOLD" | \
            sed "s/CONFIG_CPU_CSTATE_DISABLE_THRESHOLD/$SOURCE_WLAN_CONFIG_CPU_CSTATE_DISABLE_THRESHOLD/g"
        SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
            "smali/com/samsung/android/server/wifi/SemFrameworkFacade.smali" "replace" \
            "getBoosterThresholds()[I" \
            "CONFIG_L1SS_DISABLE_THRESHOLD" \
            "$TARGET_WLAN_CONFIG_L1SS_DISABLE_THRESHOLD" | \
            sed "s/CONFIG_L1SS_DISABLE_THRESHOLD/$SOURCE_WLAN_CONFIG_L1SS_DISABLE_THRESHOLD/g"
    else
        # TODO handle these conditions
        LOG_MISSING_PATCHES "SOURCE_WLAN_CONFIG_CPU_CSTATE_DISABLE_THRESHOLD" "TARGET_WLAN_CONFIG_CPU_CSTATE_DISABLE_THRESHOLD" || true
        LOG_MISSING_PATCHES "SOURCE_WLAN_CONFIG_DATA_ACTIVITY_AFFINITY_BOOSTER_THRESHOLD" "TARGET_WLAN_CONFIG_DATA_ACTIVITY_AFFINITY_BOOSTER_THRESHOLD" || true
        LOG_MISSING_PATCHES "SOURCE_WLAN_CONFIG_L1SS_DISABLE_THRESHOLD" "TARGET_WLAN_CONFIG_L1SS_DISABLE_THRESHOLD"
    fi
fi

# SEC_PRODUCT_FEATURE_WLAN_CONFIG_CUSTOM_BACKOFF
if [[ "$SOURCE_WLAN_CONFIG_CUSTOM_BACKOFF" != "$TARGET_WLAN_CONFIG_CUSTOM_BACKOFF" ]]; then
    if [[ "$SOURCE_WLAN_CONFIG_CUSTOM_BACKOFF" != "none" ]] && [[ "$TARGET_WLAN_CONFIG_CUSTOM_BACKOFF" != "none" ]]; then
        SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
            "smali/com/samsung/android/server/wifi/SemWifiCoexManager.smali" "replaceall" \
            "$SOURCE_WLAN_CONFIG_CUSTOM_BACKOFF" \
            "$TARGET_WLAN_CONFIG_CUSTOM_BACKOFF"
    elif [[ "$SOURCE_WLAN_CONFIG_CUSTOM_BACKOFF" == "none" ]] && [[ "$TARGET_WLAN_CONFIG_CUSTOM_BACKOFF" != "none" ]]; then
        APPLY_PATCH "system" "system/framework/semwifi-service.jar" \
            "$MODPATH/wifi/custom_backoff/semwifi-service.jar/0001-Allow-custom-CUSTOM_BACKOFF-value.patch"
        SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
            "smali/com/samsung/android/server/wifi/SemWifiCoexManager.smali" "replaceall" \
            "CONFIG_CUSTOM_BACKOFF" \
            "$TARGET_WLAN_CONFIG_CUSTOM_BACKOFF" | \
            sed "s/CONFIG_CUSTOM_BACKOFF/$SOURCE_WLAN_CONFIG_CUSTOM_BACKOFF/g"
    elif [[ "$SOURCE_WLAN_CONFIG_CUSTOM_BACKOFF" != "none" ]] && [[ "$TARGET_WLAN_CONFIG_CUSTOM_BACKOFF" == "none" ]]; then
        if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
            SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
                "smali/com/samsung/android/server/wifi/SemWifiCoexManager.smali" "replaceall" \
                "$SOURCE_WLAN_CONFIG_CUSTOM_BACKOFF" \
                ""
        else
            SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
                "smali/com/samsung/android/server/wifi/SemWifiCoexManager.smali" "replaceall" \
                "$SOURCE_WLAN_CONFIG_CUSTOM_BACKOFF" \
                "CONFIG_CUSTOM_BACKOFF" > /dev/null
            APPLY_PATCH "system" "system/framework/semwifi-service.jar" \
                "$MODPATH/wifi/custom_backoff/semwifi-service.jar/0001-Remove-CUSTOM_BACKOFF-value.patch"
        fi
    fi
fi

# SEC_PRODUCT_FEATURE_WLAN_SUPPORT_80211AX
# SEC_PRODUCT_FEATURE_WLAN_SUPPORT_80211AX_6GHZ
if $SOURCE_WLAN_SUPPORT_80211AX; then
    if $TARGET_WLAN_SUPPORT_80211AX; then
        if ! $SOURCE_WLAN_SUPPORT_80211AX_6GHZ; then
            if $TARGET_WLAN_SUPPORT_80211AX_6GHZ; then
                APPLY_PATCH "system" "system/framework/semwifi-service.jar" \
                    "$MODPATH/wifi/80211ax_6ghz/semwifi-service.jar/0001-Enable-80211AX_6GHZ-support.patch"
                APPLY_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
                    "$MODPATH/wifi/80211ax_6ghz/SecSettings.apk/0001-Enable-80211AX_6GHZ-support.patch"
                APPLY_PATCH "system_ext" "priv-app/SystemUI/SystemUI.apk" \
                    "$MODPATH/wifi/80211ax_6ghz/SystemUI.apk/0001-Enable-80211AX_6GHZ-support.patch"
            fi
        else
            if ! $TARGET_WLAN_SUPPORT_80211AX_6GHZ; then
                if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
                    # One UI 9 centralizes the product decision in this facade;
                    # client feature checks consume its result independently.
                    SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
                        "smali/com/samsung/android/server/wifi/SemFrameworkFacade.smali" "return" \
                        "isSupported6Ghz()Z" \
                        "false"
                else
                    LOG_MISSING_PATCHES "SOURCE_WLAN_SUPPORT_80211AX_6GHZ" "TARGET_WLAN_SUPPORT_80211AX_6GHZ"
                fi
            fi
        fi
    else
        if $TARGET_WLAN_SUPPORT_80211AX_6GHZ; then
            ABORT "TARGET_WLAN_SUPPORT_80211AX is required by TARGET_WLAN_SUPPORT_80211AX_6GHZ"
        fi
        if ! $SOURCE_WLAN_SUPPORT_80211AX_6GHZ; then
            APPLY_PATCH "system" "system/framework/semwifi-service.jar" \
                "$MODPATH/wifi/80211ax/semwifi-service.jar/0001-Disable-80211AX-support.patch"
            APPLY_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
                "$MODPATH/wifi/80211ax/SecSettings.apk/0001-Disable-80211AX-support.patch"
            APPLY_PATCH "system_ext" "priv-app/SystemUI/SystemUI.apk" \
                "$MODPATH/wifi/80211ax/SystemUI.apk/0001-Disable-80211AX-support.patch"
        else
            # TODO handle these conditions
            LOG_MISSING_PATCHES "SOURCE_WLAN_SUPPORT_80211AX" "TARGET_WLAN_SUPPORT_80211AX" || true
            LOG_MISSING_PATCHES "SOURCE_WLAN_SUPPORT_80211AX_6GHZ" "TARGET_WLAN_SUPPORT_80211AX_6GHZ"
        fi
    fi
else
    if $SOURCE_WLAN_SUPPORT_80211AX_6GHZ; then
        ABORT "SOURCE_WLAN_SUPPORT_80211AX is required by SOURCE_WLAN_SUPPORT_80211AX_6GHZ"
    fi
    if $TARGET_WLAN_SUPPORT_80211AX; then
        # TODO handle this condition
        LOG_MISSING_PATCHES "SOURCE_WLAN_SUPPORT_80211AX" "TARGET_WLAN_SUPPORT_80211AX"
    fi
    if $TARGET_WLAN_SUPPORT_80211AX_6GHZ; then
        ABORT "TARGET_WLAN_SUPPORT_80211AX is required by TARGET_WLAN_SUPPORT_80211AX_6GHZ"
    fi
fi

# SEC_PRODUCT_FEATURE_WLAN_SUPPORT_APE_SERVICE
# SEC_PRODUCT_FEATURE_WLAN_CONFIG_CONNECTION_PERSONALIZATION
# SEC_PRODUCT_FEATURE_WLAN_CONFIG_DYNAMIC_SWITCH
if [[ "$SOURCE_WLAN_CONFIG_CONNECTION_PERSONALIZATION" != "$TARGET_WLAN_CONFIG_CONNECTION_PERSONALIZATION" ]] || \
        [[ "$SOURCE_WLAN_CONFIG_DYNAMIC_SWITCH" != "$TARGET_WLAN_CONFIG_DYNAMIC_SWITCH" ]] || \
        [[ "$SOURCE_WLAN_SUPPORT_APE_SERVICE" != "$TARGET_WLAN_SUPPORT_APE_SERVICE" ]]; then
    if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
        if [[ "$SOURCE_WLAN_CONFIG_DYNAMIC_SWITCH" != "$TARGET_WLAN_CONFIG_DYNAMIC_SWITCH" ]]; then
            REQUIRE_METHOD_FIXED_COUNT \
                "$APKTOOL_DIR/system/framework/semwifi-service.jar/smali/com/samsung/android/server/wifi/SemWifiInjector.smali" \
                "<init>(Landroid/content/Context;)V" \
                "const-string v0, \"$SOURCE_WLAN_CONFIG_DYNAMIC_SWITCH\"" \
                "1" \
                "dynamic-switch injector gate"
            SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
                "smali/com/samsung/android/server/wifi/SemWifiInjector.smali" "replace" \
                "<init>(Landroid/content/Context;)V" \
                "$SOURCE_WLAN_CONFIG_DYNAMIC_SWITCH" \
                "$TARGET_WLAN_CONFIG_DYNAMIC_SWITCH"

            REQUIRE_METHOD_FIXED_COUNT \
                "$APKTOOL_DIR/system/framework/semwifi-service.jar/smali/com/samsung/android/server/wifi/SemWifiResourceManager.smali" \
                "<init>(Landroid/content/Context;Lcom/samsung/android/server/wifi/halclient/SemWifiNative;Lcom/samsung/android/server/wifi/SemWifiInjector;)V" \
                "const-string v2, \"$SOURCE_WLAN_CONFIG_DYNAMIC_SWITCH\"" \
                "1" \
                "dynamic-switch resource-manager gate"
            SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
                "smali/com/samsung/android/server/wifi/SemWifiResourceManager.smali" "replace" \
                "<init>(Landroid/content/Context;Lcom/samsung/android/server/wifi/halclient/SemWifiNative;Lcom/samsung/android/server/wifi/SemWifiInjector;)V" \
                "$SOURCE_WLAN_CONFIG_DYNAMIC_SWITCH" \
                "$TARGET_WLAN_CONFIG_DYNAMIC_SWITCH"
        fi

        if [[ "$SOURCE_WLAN_CONFIG_CONNECTION_PERSONALIZATION" != "$TARGET_WLAN_CONFIG_CONNECTION_PERSONALIZATION" ]]; then
            REQUIRE_METHOD_FIXED_COUNT \
                "$APKTOOL_DIR/system/framework/semwifi-service.jar/smali/com/samsung/android/server/wifi/SemWifiInjector.smali" \
                "<init>(Landroid/content/Context;)V" \
                "const-string v0, \"$SOURCE_WLAN_CONFIG_CONNECTION_PERSONALIZATION\"" \
                "1" \
                "connection-personalization injector gate"
            SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
                "smali/com/samsung/android/server/wifi/SemWifiInjector.smali" "replace" \
                "<init>(Landroid/content/Context;)V" \
                "$SOURCE_WLAN_CONFIG_CONNECTION_PERSONALIZATION" \
                "$TARGET_WLAN_CONFIG_CONNECTION_PERSONALIZATION"

            REQUIRE_METHOD_FIXED_COUNT \
                "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/smali_classes4/com/samsung/android/settings/wifi/develop/compatibility/btm/BtmController.smali" \
                "getAvailabilityStatus()I" \
                "const-string p0, \"$SOURCE_WLAN_CONFIG_CONNECTION_PERSONALIZATION\"" \
                "1" \
                "connection-personalization Settings gate"
            SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
                "smali_classes4/com/samsung/android/settings/wifi/develop/compatibility/btm/BtmController.smali" "replace" \
                "getAvailabilityStatus()I" \
                "$SOURCE_WLAN_CONFIG_CONNECTION_PERSONALIZATION" \
                "$TARGET_WLAN_CONFIG_CONNECTION_PERSONALIZATION"
        fi

        if $SOURCE_WLAN_SUPPORT_APE_SERVICE && ! $TARGET_WLAN_SUPPORT_APE_SERVICE; then
            REQUIRE_METHOD_FIXED_COUNT \
                "$APKTOOL_DIR/system/framework/semwifi-service.jar/smali/com/samsung/android/server/wifi/SemWifiInjector.smali" \
                "<init>(Landroid/content/Context;)V" \
                'new-instance v0, Lcom/samsung/android/server/wifi/SemApeController;' \
                "1" \
                "APE-service constructor gate"
            SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
                "smali/com/samsung/android/server/wifi/SemWifiInjector.smali" "replace" \
                "<init>(Landroid/content/Context;)V" \
                'new-instance v0, Lcom/samsung/android/server/wifi/SemApeController;' \
                '    goto :goto_5

    new-instance v0, Lcom/samsung/android/server/wifi/SemApeController;'

            REQUIRE_FIXED_COUNT \
                "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/smali_classes4/com/samsung/android/settings/wifi/develop/ApePreferenceController.smali" \
                ".field private static final SUPPORT_APE_SERVICE:Z = true" \
                "1" \
                "APE-service Settings field"
            SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
                "smali_classes4/com/samsung/android/settings/wifi/develop/ApePreferenceController.smali" "replaceall" \
                ".field private static final SUPPORT_APE_SERVICE:Z = true" \
                ".field private static final SUPPORT_APE_SERVICE:Z = false"
            SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
                "smali_classes4/com/samsung/android/settings/wifi/develop/ApePreferenceController.smali" "return" \
                "getAvailabilityStatus()I" \
                "3"
        elif ! $SOURCE_WLAN_SUPPORT_APE_SERVICE && $TARGET_WLAN_SUPPORT_APE_SERVICE; then
            LOG_MISSING_PATCHES "SOURCE_WLAN_SUPPORT_APE_SERVICE" "TARGET_WLAN_SUPPORT_APE_SERVICE"
        fi
    elif [[ "$SOURCE_WLAN_CONFIG_CONNECTION_PERSONALIZATION" == "1" ]] && $SOURCE_WLAN_SUPPORT_APE_SERVICE; then
        if [[ "$SOURCE_WLAN_CONFIG_DYNAMIC_SWITCH" != "0" ]]; then
            SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
                "smali/com/samsung/android/server/wifi/SemWifiInjector.smali" "replace" \
                "<init>(Landroid/content/Context;)V" \
                "$SOURCE_WLAN_CONFIG_DYNAMIC_SWITCH" \
                "0" > /dev/null
        fi
        APPLY_PATCH "system" "system/framework/semwifi-service.jar" \
            "$MODPATH/wifi/connection_personalization/semwifi-service.jar/0001-Allow-custom-CONNECTION_PERSONALIZATION-value.patch"
        if [[ "$SOURCE_WLAN_CONFIG_DYNAMIC_SWITCH" != "0" ]]; then
            SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
                "smali/com/samsung/android/server/wifi/SemWifiInjector.smali" "replace" \
                "<init>(Landroid/content/Context;)V" \
                "0" \
                "$SOURCE_WLAN_CONFIG_DYNAMIC_SWITCH" > /dev/null
        fi
        SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
            "smali/com/samsung/android/server/wifi/SemWifiInjector.smali" "replace" \
            "<init>(Landroid/content/Context;)V" \
            "CONFIG_CONNECTION_PERSONALIZATION" \
            "$TARGET_WLAN_CONFIG_CONNECTION_PERSONALIZATION" | \
            sed "s/CONFIG_CONNECTION_PERSONALIZATION/$SOURCE_WLAN_CONFIG_CONNECTION_PERSONALIZATION/g"
        APPLY_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
            "$MODPATH/wifi/connection_personalization/SecSettings.apk/0001-Allow-custom-CONNECTION_PERSONALIZATION-value.patch"
        SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
            "smali_classes3/com/samsung/android/settings/wifi/develop/btm/BtmController.smali" "replace" \
            "getAvailabilityStatus()I" \
            "CONFIG_CONNECTION_PERSONALIZATION" \
            "$TARGET_WLAN_CONFIG_CONNECTION_PERSONALIZATION" | \
            sed "s/CONFIG_CONNECTION_PERSONALIZATION/$SOURCE_WLAN_CONFIG_CONNECTION_PERSONALIZATION/g"

        if [[ "$SOURCE_WLAN_CONFIG_DYNAMIC_SWITCH" != "$TARGET_WLAN_CONFIG_DYNAMIC_SWITCH" ]]; then
            SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
                "smali/com/samsung/android/server/wifi/SemWifiInjector.smali" "replace" \
                "<init>(Landroid/content/Context;)V" \
                "$SOURCE_WLAN_CONFIG_DYNAMIC_SWITCH" \
                "$TARGET_WLAN_CONFIG_DYNAMIC_SWITCH"
            SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
                "smali/com/samsung/android/server/wifi/SemWifiResourceManager.smali" "replace" \
                "<init>(Landroid/content/Context;Lcom/samsung/android/server/wifi/halclient/SemWifiNative;Lcom/samsung/android/server/wifi/SemWifiInjector;)V" \
                "$SOURCE_WLAN_CONFIG_DYNAMIC_SWITCH" \
                "$TARGET_WLAN_CONFIG_DYNAMIC_SWITCH"
            SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
                "smali_classes2/com/android/settings/development/WifiSafePreferenceController.smali" "replace" \
                "<init>(Landroid/content/Context;)V" \
                "$SOURCE_WLAN_CONFIG_DYNAMIC_SWITCH" \
                "$TARGET_WLAN_CONFIG_DYNAMIC_SWITCH"
        fi

        if ! $TARGET_WLAN_SUPPORT_APE_SERVICE; then
            APPLY_PATCH "system" "system/framework/semwifi-service.jar" \
                "$MODPATH/wifi/ape_service/semwifi-service.jar/0001-Disable-APE_SERVICE-support.patch"
            SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
                "smali/com/samsung/android/server/wifi/SemQboxController\$1.smali" "remove"
            APPLY_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
                "$MODPATH/wifi/ape_service/SecSettings.apk/0001-Disable-APE_SERVICE-support.patch"
        fi
    else
        # TODO handle these conditions
        LOG_MISSING_PATCHES "SOURCE_WLAN_CONFIG_CONNECTION_PERSONALIZATION" "TARGET_WLAN_CONFIG_CONNECTION_PERSONALIZATION" || true
        LOG_MISSING_PATCHES "SOURCE_WLAN_SUPPORT_APE_SERVICE" "TARGET_WLAN_SUPPORT_APE_SERVICE"
    fi
fi

# SEC_PRODUCT_FEATURE_WLAN_SUPPORT_MBO
if ! $SOURCE_WLAN_SUPPORT_MBO && $TARGET_WLAN_SUPPORT_MBO; then
    SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
        "smali/com/samsung/android/server/wifi/SemFrameworkFacade.smali" "return" \
        "isMBOSupported()Z" \
        "true"
elif $SOURCE_WLAN_SUPPORT_MBO && ! $TARGET_WLAN_SUPPORT_MBO; then
    SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
        "smali/com/samsung/android/server/wifi/SemFrameworkFacade.smali" "return" \
        "isMBOSupported()Z" \
        "false"
fi

# SEC_PRODUCT_FEATURE_WLAN_SUPPORT_MIMO
if ! $SOURCE_WLAN_SUPPORT_MIMO && $TARGET_WLAN_SUPPORT_MIMO; then
    SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
        "smali/com/samsung/android/server/wifi/SemWifiServiceImpl.smali" "return" \
        "getNumOfWifiAnt()I" \
        "2"
elif $SOURCE_WLAN_SUPPORT_MIMO && ! $TARGET_WLAN_SUPPORT_MIMO; then
    SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
        "smali/com/samsung/android/server/wifi/SemWifiServiceImpl.smali" "return" \
        "getNumOfWifiAnt()I" \
        "1"
fi

# SEC_PRODUCT_FEATURE_WLAN_SUPPORT_MOBILEAP_5G_BASEDON_COUNTRY
if ! $SOURCE_WLAN_SUPPORT_MOBILEAP_5G_BASEDON_COUNTRY; then
    if $TARGET_WLAN_SUPPORT_MOBILEAP_5G_BASEDON_COUNTRY; then
        APPLY_PATCH "system" "system/framework/semwifi-service.jar" \
            "$MODPATH/wifi/5g_basedon_country/semwifi-service.jar/0001-Enable-MOBILEAP_5G_BASEDON_COUNTRY-support.patch"
        SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
            "smali/com/samsung/android/server/wifi/ap/SemSoftApConfiguration.smali" "replaceall" \
            "SPF_5G_BASEDON_COUNTRY=false" \
            "SPF_5G_BASEDON_COUNTRY=true"
    fi
else
    if ! $TARGET_WLAN_SUPPORT_MOBILEAP_5G_BASEDON_COUNTRY; then
        if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
            # Retain the secure-setting override used by both firmwares, but
            # make its missing/"na" fallback false like the target firmware.
            REQUIRE_METHOD_FIXED_COUNT \
                "$APKTOOL_DIR/system/framework/semwifi-service.jar/smali/com/samsung/android/server/wifi/ap/SemWifiApServiceImpl.smali" \
                "supportWifiAp5GBasedOnCountry()Z" \
                "    :goto_0" \
                "1" \
                "country-based 5 GHz fallback gate"
            SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
                "smali/com/samsung/android/server/wifi/ap/SemWifiApServiceImpl.smali" "replace" \
                "supportWifiAp5GBasedOnCountry()Z" \
                "    :goto_0" \
                '    :goto_0
    goto :goto_1'

            REQUIRE_FIXED_COUNT \
                "$APKTOOL_DIR/system/framework/semwifi-service.jar/smali/com/samsung/android/server/wifi/ap/SemSoftApConfiguration.smali" \
                "SPF_5G_BASEDON_COUNTRY=true" \
                "1" \
                "country-based 5 GHz diagnostic"
            SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
                "smali/com/samsung/android/server/wifi/ap/SemSoftApConfiguration.smali" "replaceall" \
                "SPF_5G_BASEDON_COUNTRY=true" \
                "SPF_5G_BASEDON_COUNTRY=false"
        else
            LOG_MISSING_PATCHES "SOURCE_WLAN_SUPPORT_MOBILEAP_5G_BASEDON_COUNTRY" "TARGET_WLAN_SUPPORT_MOBILEAP_5G_BASEDON_COUNTRY"
        fi
    fi
fi

# SEC_PRODUCT_FEATURE_WLAN_SUPPORT_MOBILEAP_6G
if ! $SOURCE_WLAN_SUPPORT_MOBILEAP_6G && $TARGET_WLAN_SUPPORT_MOBILEAP_6G; then
    ADD_TO_WORK_DIR "b0qxxx" "product" "overlay/SoftapOverlay6GHz/SoftapOverlay6GHz.apk" 0 0 644 "u:object_r:system_file:s0"

    SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
        "smali/com/samsung/android/server/wifi/ap/SemSoftApConfiguration.smali" "replaceall" \
        "SPF_6G=false" \
        "SPF_6G=true"
    SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
        "smali/com/samsung/android/server/wifi/SemFrameworkFacade.smali" "return" \
        "isSupportMobileAp6G()Z" \
        "true"
elif $SOURCE_WLAN_SUPPORT_MOBILEAP_6G && ! $TARGET_WLAN_SUPPORT_MOBILEAP_6G; then
    if [ "$SOURCE_PLATFORM_SDK_VERSION" -lt "37" ]; then
        DELETE_FROM_WORK_DIR "product" "overlay/SoftapOverlay6GHz"
    fi

    SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
        "smali/com/samsung/android/server/wifi/ap/SemSoftApConfiguration.smali" "replaceall" \
        "SPF_6G=true" \
        "SPF_6G=false"
    SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
        "smali/com/samsung/android/server/wifi/SemFrameworkFacade.smali" "return" \
        "isSupportMobileAp6G()Z" \
        "false"
fi

# SEC_PRODUCT_FEATURE_WLAN_SUPPORT_MOBILEAP_DUALAP
if ! $SOURCE_WLAN_SUPPORT_MOBILEAP_DUALAP; then
    if $TARGET_WLAN_SUPPORT_MOBILEAP_DUALAP; then
        ADD_TO_WORK_DIR "dm1qxxx" "product" "overlay/SoftapOverlayDualAp/SoftapOverlayDualAp.apk" 0 0 644 "u:object_r:system_file:s0"

        APPLY_PATCH "system" "system/framework/semwifi-service.jar" \
            "$MODPATH/wifi/dualap/semwifi-service.jar/0001-Enable-MOBILEAP_DUALAP-support.patch"
        SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
            "smali/com/samsung/android/server/wifi/ap/SemSoftApConfiguration.smali" "replaceall" \
            "SPF_DualAp=false" \
            "SPF_DualAp=true"
        SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
            "smali/com/samsung/android/server/wifi/ap/SemSoftApConfiguration\$6.smali" "remove"
        SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
            "smali/com/samsung/android/server/wifi/ap/SemSoftApConfiguration\$12.smali" "remove"
        SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
            "smali/com/samsung/android/server/wifi/ap/SemSoftApConfiguration\$16.smali" "remove"
        if $TARGET_COMMON_SUPPORT_DYN_RESOLUTION_CONTROL; then
            APPLY_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
                "$MODPATH/wifi/dualap_resolution/SecSettings.apk/0001-Enable-MOBILEAP_DUALAP-support.patch"
        else
            APPLY_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
                "$MODPATH/wifi/dualap/SecSettings.apk/0001-Enable-MOBILEAP_DUALAP-support.patch"
        fi
        SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
            "smali_classes3/com/samsung/android/settings/wifi/mobileap/WifiApSmartSwitchBackupRestore\$5.smali" "remove"
    fi
else
    if ! $TARGET_WLAN_SUPPORT_MOBILEAP_DUALAP; then
        if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
            REQUIRE_FIXED_COUNT \
                "$APKTOOL_DIR/system/framework/semwifi-service.jar/smali/com/samsung/android/server/wifi/ap/SemSoftApConfiguration.smali" \
                "SPF_DualAp=true" \
                "1" \
                "DualAP diagnostic"
            SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
                "smali/com/samsung/android/server/wifi/ap/SemSoftApConfiguration.smali" "replaceall" \
                "SPF_DualAp=true" \
                "SPF_DualAp=false"
            REPLACE_SMALI_METHOD \
                "$APKTOOL_DIR/system/framework/semwifi-service.jar/smali/com/samsung/android/server/wifi/ap/SemSoftApConfiguration.smali" \
                "isWifiApEnabledWithDualBand()Z" \
                '.method public isWifiApEnabledWithDualBand()Z
    .locals 1

    const-string p0, "SemSoftApConfiguration"

    const-string v0, "isWifiApEnabledWithDualBand API:false"

    invoke-static {p0, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    const/4 p0, 0x0

    return p0
.end method'

            REQUIRE_METHOD_FIXED_COUNT \
                "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/smali/com/android/settings/Utils.smali" \
                "<clinit>()V" \
                "sput-boolean v2, Lcom/android/settings/Utils;->SPF_SupportMobileApDualAp:Z" \
                "1" \
                "DualAP Settings gate"
            SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
                "smali/com/android/settings/Utils.smali" "replace" \
                "<clinit>()V" \
                "sput-boolean v2, Lcom/android/settings/Utils;->SPF_SupportMobileApDualAp:Z" \
                "sput-boolean v1, Lcom/android/settings/Utils;->SPF_SupportMobileApDualAp:Z"
        else
            LOG_MISSING_PATCHES "SOURCE_WLAN_SUPPORT_MOBILEAP_DUALAP" "TARGET_WLAN_SUPPORT_MOBILEAP_DUALAP"
        fi
    fi
fi

# SEC_PRODUCT_FEATURE_WLAN_SUPPORT_MOBILEAP_OWE
if ! $SOURCE_WLAN_SUPPORT_MOBILEAP_OWE; then
    if $TARGET_WLAN_SUPPORT_MOBILEAP_OWE; then
        ADD_TO_WORK_DIR "dm1qxxx" "product" "overlay/SoftapOverlayOWE/SoftapOverlayOWE.apk" 0 0 644 "u:object_r:system_file:s0"

        APPLY_PATCH "system" "system/framework/semwifi-service.jar" \
            "$MODPATH/wifi/owe/semwifi-service.jar/0001-Enable-MOBILEAP_OWE-support.patch"
        SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
            "smali/com/samsung/android/server/wifi/ap/SemSoftApConfiguration.smali" "replaceall" \
            "SPF_OWE=false" \
            "SPF_OWE=true"
        APPLY_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
            "$MODPATH/wifi/owe/SecSettings.apk/0001-Enable-MOBILEAP_OWE-support.patch"
    fi
else
    if ! $TARGET_WLAN_SUPPORT_MOBILEAP_OWE; then
        if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
            REQUIRE_FIXED_COUNT \
                "$APKTOOL_DIR/system/framework/semwifi-service.jar/smali/com/samsung/android/server/wifi/ap/SemSoftApConfiguration.smali" \
                "SPF_OWE=true" \
                "1" \
                "MobileAP OWE diagnostic"
            SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
                "smali/com/samsung/android/server/wifi/ap/SemSoftApConfiguration.smali" "replaceall" \
                "SPF_OWE=true" \
                "SPF_OWE=false"

            # The Settings gate prevents new OWE selections.  Also normalize
            # restored or externally supplied OWE (security type 5) to Open at
            # the service builder, matching the target's false-SPF fallback.
            REQUIRE_METHOD_FIXED_COUNT \
                "$APKTOOL_DIR/system/framework/semwifi-service.jar/smali/com/samsung/android/server/wifi/ap/SemSoftApConfiguration.smali" \
                "setSoftApConfiguration(Landroid/net/wifi/SoftApConfiguration;Z)Landroid/net/wifi/SoftApConfiguration;" \
                'invoke-static {v8, v7}, Landroid/os/SystemProperties;->set(Ljava/lang/String;Ljava/lang/String;)V' \
                "1" \
                "MobileAP OWE service gate"
            SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
                "smali/com/samsung/android/server/wifi/ap/SemSoftApConfiguration.smali" "replace" \
                "setSoftApConfiguration(Landroid/net/wifi/SoftApConfiguration;Z)Landroid/net/wifi/SoftApConfiguration;" \
                'invoke-static {v8, v7}, Landroid/os/SystemProperties;->set(Ljava/lang/String;Ljava/lang/String;)V' \
                '    const/4 v12, 0x0

    invoke-virtual {v11, v12, v12}, Landroid/net/wifi/SoftApConfiguration$Builder;->setPassphrase(Ljava/lang/String;I)Landroid/net/wifi/SoftApConfiguration$Builder;'

            # Keep station-side Enhanced Open support intact.  Only remove OWE
            # from the hotspot security arrays selected by One UI 9 Settings.
            # Resource IDs differ per source build, resolve them by name.
            OWE_CTRL="$(cd "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk" && \
                find . -path "./smali*/com/samsung/android/settings/wifi/mobileap/configure/WifiApConfigureSecurityDropDownController.smali" | sed "s|^\./||")"
            OWE_PUBLIC="$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/res/values/public.xml"
            for OWE_PAIR in \
                    "wifi_ap_6ghz_owe_wpa3_security_type_entries:wifi_ap_6ghz_wpa3_security_type_entries" \
                    "wifi_ap_owe_wpa3_security_type_entries:wifi_ap_wpa3_security_type_entries" \
                    "wifi_ap_owe_security_type_entries1:wifi_ap_security_type_entries1"; do
                OWE_FROM="$(grep -o "type=\"array\" name=\"${OWE_PAIR%%:*}\" id=\"0x[0-9a-f]*\"" "$OWE_PUBLIC" | grep -o "0x[0-9a-f]*")"
                OWE_TO="$(grep -o "type=\"array\" name=\"${OWE_PAIR##*:}\" id=\"0x[0-9a-f]*\"" "$OWE_PUBLIC" | grep -o "0x[0-9a-f]*")"
                [ "$OWE_FROM" ] && [ "$OWE_TO" ] || ABORT "MobileAP OWE array ids not found: $OWE_PAIR"
                REQUIRE_METHOD_FIXED_COUNT \
                    "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/$OWE_CTRL" \
                    "setSecurityTypeEntryArrays(Z)V" \
                    "const v0, $OWE_FROM" \
                    "1" \
                    "MobileAP ${OWE_PAIR%%:*} array"
                SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
                    "$OWE_CTRL" "replace" \
                    "setSecurityTypeEntryArrays(Z)V" \
                    "const v0, $OWE_FROM" \
                    "const v0, $OWE_TO"
            done
            unset OWE_CTRL OWE_PUBLIC OWE_PAIR OWE_FROM OWE_TO
        else
            LOG_MISSING_PATCHES "SOURCE_WLAN_SUPPORT_MOBILEAP_OWE" "TARGET_WLAN_SUPPORT_MOBILEAP_OWE"
        fi
    fi
fi

# SEC_PRODUCT_FEATURE_WLAN_SUPPORT_MOBILEAP_POWER_SAVEMODE
if $SOURCE_WLAN_SUPPORT_MOBILEAP_POWER_SAVEMODE; then
    if ! $TARGET_WLAN_SUPPORT_MOBILEAP_POWER_SAVEMODE && [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
        # TODO One UI 9 port; hotspot power save stays enabled meanwhile
        LOGW "Deferred: MOBILEAP_POWER_SAVEMODE removal on One UI 9"
        echo "/system/system/framework/semwifi-service.jar wifi/power_savemode (deferred)" >> "$OUT_DIR/skipped_patches.txt"
    elif ! $TARGET_WLAN_SUPPORT_MOBILEAP_POWER_SAVEMODE; then
        APPLY_PATCH "system" "system/framework/semwifi-service.jar" \
            "$MODPATH/wifi/power_savemode/semwifi-service.jar/0001-Disable-MOBILEAP_POWER_SAVEMODE-support.patch"
        SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
            "smali/com/samsung/android/server/wifi/ap/SemSoftApConfiguration.smali" "replaceall" \
            "SPF_POWER_SAVEMODE=true" \
            "SPF_POWER_SAVEMODE=false"
        SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
            "smali/com/samsung/android/server/wifi/ap/SemWifiApPowerSaveImpl\$\$ExternalSyntheticLambda0.smali" "remove"
        SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
            "smali/com/samsung/android/server/wifi/ap/SemWifiApPowerSaveImpl\$\$ExternalSyntheticLambda1.smali" "remove"
    fi
else
    if $TARGET_WLAN_SUPPORT_MOBILEAP_POWER_SAVEMODE; then
        # TODO handle this condition
        LOG_MISSING_PATCHES "SOURCE_WLAN_SUPPORT_MOBILEAP_POWER_SAVEMODE" "TARGET_WLAN_SUPPORT_MOBILEAP_POWER_SAVEMODE"
    fi
fi

# SEC_PRODUCT_FEATURE_WLAN_SUPPORT_MOBILEAP_PRIORITIZE_TRAFFIC
if $SOURCE_WLAN_SUPPORT_MOBILEAP_PRIORITIZE_TRAFFIC; then
    if ! $TARGET_WLAN_SUPPORT_MOBILEAP_PRIORITIZE_TRAFFIC; then
        DELETE_FROM_WORK_DIR "system" "system/app/MhsAiService"
        DELETE_FROM_WORK_DIR "system" "system/etc/xgb_mhs_l1.model"

        APPLY_PATCH "system" "system/framework/semwifi-service.jar" \
            "$MODPATH/wifi/prioritize_traffic/semwifi-service.jar/0001-Disable-MOBILEAP_PRIORITIZE_TRAFFIC-support.patch"
        SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
            "smali/com/samsung/android/server/wifi/ap/SemSoftApConfiguration.smali" "replaceall" \
            "SPF_Prio_Traffic=true" \
            "SPF_Prio_Traffic=false"
        APPLY_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
            "$MODPATH/wifi/prioritize_traffic/SecSettings.apk/0001-Disable-MOBILEAP_PRIORITIZE_TRAFFIC-support.patch"
    fi
else
    if $TARGET_WLAN_SUPPORT_MOBILEAP_PRIORITIZE_TRAFFIC; then
        # TODO handle this condition
        LOG_MISSING_PATCHES "SOURCE_WLAN_SUPPORT_MOBILEAP_PRIORITIZE_TRAFFIC" "TARGET_WLAN_SUPPORT_MOBILEAP_PRIORITIZE_TRAFFIC"
    fi
fi

# SEC_PRODUCT_FEATURE_WLAN_SEC_SUPPORT_MOBILEAP_WIFI_CONCURRENCY
if ! $SOURCE_WLAN_SUPPORT_MOBILEAP_WIFI_CONCURRENCY; then
    if $TARGET_WLAN_SUPPORT_MOBILEAP_WIFI_CONCURRENCY; then
        # Check for target flag instead as we've already took care of this SPF above
        if ! $TARGET_WLAN_SUPPORT_MOBILEAP_POWER_SAVEMODE; then
            APPLY_PATCH "system" "system/framework/semwifi-service.jar" \
                "$MODPATH/wifi/power_savemode/semwifi-service.jar/0002-Enable-MOBILEAP_WIFI_CONCURRENCY-support.patch"
        else
            APPLY_PATCH "system" "system/framework/semwifi-service.jar" \
                "$MODPATH/wifi/wifisharing/semwifi-service.jar/0001-Enable-MOBILEAP_WIFI_CONCURRENCY-support.patch"
        fi
        SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
            "smali/com/samsung/android/server/wifi/ap/SemSoftApConfiguration.smali" "replaceall" \
            "SPF_Concurrency=false" \
            "SPF_Concurrency=true"
    fi
else
    if ! $TARGET_WLAN_SUPPORT_MOBILEAP_WIFI_CONCURRENCY; then
        # TODO handle this condition
        LOG_MISSING_PATCHES "SOURCE_WLAN_SUPPORT_MOBILEAP_WIFI_CONCURRENCY" "TARGET_WLAN_SUPPORT_MOBILEAP_WIFI_CONCURRENCY"
    fi
fi

# SEC_PRODUCT_FEATURE_WLAN_SUPPORT_MOBILEAP_WIFISHARING_LITE
if ! $SOURCE_WLAN_SUPPORT_MOBILEAP_WIFISHARING_LITE; then
    if $TARGET_WLAN_SUPPORT_MOBILEAP_WIFISHARING_LITE; then
        # Check for target flag instead as we've already took care of this SPF above
        if ! $TARGET_WLAN_SUPPORT_MOBILEAP_POWER_SAVEMODE; then
            APPLY_PATCH "system" "system/framework/semwifi-service.jar" \
                "$MODPATH/wifi/power_savemode/semwifi-service.jar/0003-Enable-MOBILEAP_WIFISHARING_LITE-support.patch"
        else
            APPLY_PATCH "system" "system/framework/semwifi-service.jar" \
                "$MODPATH/wifi/wifisharing/semwifi-service.jar/0002-Enable-MOBILEAP_WIFISHARING_LITE-support.patch"
        fi
        SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
            "smali/com/samsung/android/server/wifi/ap/SemSoftApConfiguration.smali" "replaceall" \
            "SPF_WS_Lite=false" \
            "SPF_WS_Lite=true"
    fi
else
    if ! $TARGET_WLAN_SUPPORT_MOBILEAP_WIFISHARING_LITE; then
        # TODO handle this condition
        LOG_MISSING_PATCHES "SOURCE_WLAN_SUPPORT_MOBILEAP_WIFISHARING_LITE" "TARGET_WLAN_SUPPORT_MOBILEAP_WIFISHARING_LITE"
    fi
fi

# SEC_PRODUCT_FEATURE_WLAN_SUPPORT_TWT_CONTROL
# SEC_PRODUCT_FEATURE_WLAN_SUPPORT_LOWLATENCY
if $SOURCE_WLAN_SUPPORT_TWT_CONTROL && $SOURCE_WLAN_SUPPORT_LOWLATENCY; then
    if ! $TARGET_WLAN_SUPPORT_TWT_CONTROL; then
        if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
            # One UI 9 obtains the TWT feature bits from the vendor feature
            # string instead of populating the old API36 default map.  Gate
            # the public support query itself so LOWLATENCY remains enabled.
            REPLACE_SMALI_METHOD \
                "$APKTOOL_DIR/system/framework/semwifi-service.jar/smali/com/samsung/android/server/wifi/driver/WifiDriverFeatureProvider.smali" \
                "isTwtSupported()Z" \
                '.method public isTwtSupported()Z
    .locals 1

    const/4 v0, 0x0

    return v0
.end method'
        else
            APPLY_PATCH "system" "system/framework/semwifi-service.jar" \
                "$MODPATH/wifi/twt_control/semwifi-service.jar/0001-Disable-TWT_CONTROL-support.patch"
        fi

        if ! $TARGET_WLAN_SUPPORT_LOWLATENCY; then
            APPLY_PATCH "system" "system/framework/semwifi-service.jar" \
                "$MODPATH/wifi/twt_control/semwifi-service.jar/0002-Disable-LOWLATENCY-support.patch"
        fi
    elif ! $TARGET_WLAN_SUPPORT_LOWLATENCY; then
        APPLY_PATCH "system" "system/framework/semwifi-service.jar" \
            "$MODPATH/wifi/lowlatency/semwifi-service.jar/0001-Disable-LOWLATENCY-support.patch"
    fi
else
    if ! $SOURCE_WLAN_SUPPORT_TWT_CONTROL && $TARGET_WLAN_SUPPORT_TWT_CONTROL; then
        # TODO handle this condition
        LOG_MISSING_PATCHES "SOURCE_WLAN_SUPPORT_TWT_CONTROL" "TARGET_WLAN_SUPPORT_TWT_CONTROL"
    elif ! $SOURCE_WLAN_SUPPORT_LOWLATENCY && $TARGET_WLAN_SUPPORT_LOWLATENCY; then
        # TODO handle this condition
        LOG_MISSING_PATCHES "SOURCE_WLAN_SUPPORT_LOWLATENCY" "TARGET_WLAN_SUPPORT_LOWLATENCY"
    fi
fi

# SEC_PRODUCT_FEATURE_WLAN_SUPPORT_SWITCH_FOR_INDIVIDUAL_APPS
if $SOURCE_WLAN_SUPPORT_SWITCH_FOR_INDIVIDUAL_APPS; then
    if ! $TARGET_WLAN_SUPPORT_SWITCH_FOR_INDIVIDUAL_APPS; then
        APPLY_PATCH "system" "system/framework/semwifi-service.jar" \
            "$MODPATH/wifi/individual_apps/semwifi-service.jar/0001-Disable-SWITCH_FOR_INDIVIDUAL_APPS-support.patch"
    fi
else
    if $TARGET_WLAN_SUPPORT_SWITCH_FOR_INDIVIDUAL_APPS; then
        # TODO handle this condition
        LOG_MISSING_PATCHES "SOURCE_WLAN_SUPPORT_SWITCH_FOR_INDIVIDUAL_APPS" "TARGET_WLAN_SUPPORT_SWITCH_FOR_INDIVIDUAL_APPS"
    fi
fi

# SEC_PRODUCT_FEATURE_WLAN_SUPPORT_WIFI_TO_CELLULAR
if ! $SOURCE_WLAN_SUPPORT_WIFI_TO_CELLULAR && $TARGET_WLAN_SUPPORT_WIFI_TO_CELLULAR; then
    SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
        "smali/com/samsung/android/server/wifi/SemFrameworkFacade.smali" "return" \
        "isWifiToCellularSupported()Z" \
        "true"
elif $SOURCE_WLAN_SUPPORT_WIFI_TO_CELLULAR && ! $TARGET_WLAN_SUPPORT_WIFI_TO_CELLULAR; then
    SMALI_PATCH "system" "system/framework/semwifi-service.jar" \
        "smali/com/samsung/android/server/wifi/SemFrameworkFacade.smali" "return" \
        "isWifiToCellularSupported()Z" \
        "false"
fi

unset TARGET_FIRMWARE_PATH
unset -f GET_FINGERPRINT_SENSOR_TYPE LOG_MISSING_PATCHES REQUIRE_FIXED_COUNT REQUIRE_METHOD_FIXED_COUNT REPLACE_SMALI_METHOD
