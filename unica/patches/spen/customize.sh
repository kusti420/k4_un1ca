SOURCE_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$SOURCE_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$SOURCE_FIRMWARE")"
TARGET_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$TARGET_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$TARGET_FIRMWARE")"

SOURCE_HAS_SPEN="$(test -n "$(find "$FW_DIR/$SOURCE_FIRMWARE_PATH/system/system/etc/permissions" -type f -name "com.sec.feature.spen_usp*.xml")" && echo "true" || echo "false")"
TARGET_HAS_SPEN="$(test -n "$(find "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/etc/permissions" -type f -name "com.sec.feature.spen_usp*.xml")" && echo "true" || echo "false")"

if ! $SOURCE_HAS_SPEN; then
    if $TARGET_HAS_SPEN; then
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/app/AirGlance/AirGlance.apk" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/app/LiveDrawing/LiveDrawing.apk" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/etc/default-permissions/default-permissions-com.samsung.android.service.aircommand.xml" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/etc/permissions/privapp-permissions-com.samsung.android.app.readingglass.xml" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/etc/permissions/privapp-permissions-com.samsung.android.service.aircommand.xml" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/etc/permissions/privapp-permissions-com.samsung.android.service.airviewdictionary.xml" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/etc/sysconfig/airviewdictionaryservice.xml" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/etc/public.libraries-smps.samsung.txt" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "$([[ "$TARGET_OS_SINGLE_SYSTEM_IMAGE" == "qssi" ]] && echo "b0qxxx" || echo "b0sxxx")" \
            "system" "system/lib/libandroid_runtime.so" 0 0 644 "u:object_r:system_lib_file:s0"
        ADD_TO_WORK_DIR "$([[ "$TARGET_OS_SINGLE_SYSTEM_IMAGE" == "qssi" ]] && echo "b0qxxx" || echo "b0sxxx")" \
            "system" "system/lib/libsmpsft.smps.samsung.so" 0 0 644 "u:object_r:system_lib_file:s0"
        ADD_TO_WORK_DIR "$([[ "$TARGET_OS_SINGLE_SYSTEM_IMAGE" == "qssi" ]] && echo "b0qxxx" || echo "b0sxxx")" \
            "system" "system/lib64/libandroid_runtime.so" 0 0 644 "u:object_r:system_lib_file:s0"
        ADD_TO_WORK_DIR "$([[ "$TARGET_OS_SINGLE_SYSTEM_IMAGE" == "qssi" ]] && echo "b0qxxx" || echo "b0sxxx")" \
            "system" "system/lib64/libsmpsft.smps.samsung.so" 0 0 644 "u:object_r:system_lib_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/media/audio/pensounds" 0 0 755 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/priv-app/AirCommand/AirCommand.apk" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/priv-app/AirReadingGlass/AirReadingGlass.apk" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "b0qxxx" "system" "system/priv-app/SmartEye/SmartEye.apk" 0 0 644 "u:object_r:system_file:s0"
    else
        LOG "\033[0;33m! Nothing to do\033[0m"
    fi
else
    if ! $TARGET_HAS_SPEN; then
        # S Pen source (e.g. Galaxy S26 Ultra) on a target without a pen: drop the pen feature declaration and the
        # pen-only apps/blobs (the inverse of the list added above for pen targets on pen-less sources).
        while IFS= read -r f; do
            DELETE_FROM_WORK_DIR "system" "$f"
        done < <(cd "$WORK_DIR/system" && find "system/etc/permissions" -maxdepth 1 -type f -name "com.sec.feature.spen_usp*.xml")
        for f in \
            "system/app/AirGlance" \
            "system/app/LiveDrawing" \
            "system/etc/default-permissions/default-permissions-com.samsung.android.service.aircommand.xml" \
            "system/etc/permissions/privapp-permissions-com.samsung.android.app.readingglass.xml" \
            "system/etc/permissions/privapp-permissions-com.samsung.android.service.aircommand.xml" \
            "system/etc/permissions/privapp-permissions-com.samsung.android.service.airviewdictionary.xml" \
            "system/etc/sysconfig/airviewdictionaryservice.xml" \
            "system/media/audio/pensounds" \
            "system/priv-app/AirCommand" \
            "system/priv-app/AirReadingGlass" \
            "system/priv-app/SmartEye"; do
            [ -e "$WORK_DIR/system/$f" ] && DELETE_FROM_WORK_DIR "system" "$f"
        done
        unset f
    fi
fi

unset SOURCE_FIRMWARE_PATH TARGET_FIRMWARE_PATH SOURCE_HAS_SPEN TARGET_HAS_SPEN
