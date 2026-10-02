# Samsung Internet Browser
# https://play.google.com/store/apps/details?id=com.sec.android.app.sbrowser
SBROWSER_SHA256="7cb6a12122398801353e26ef94aed6fb6058bef307664f35e1010e3fea35e53c"
LOG "- Downloading Samsung Internet app"
DOWNLOAD_FILE "$(GET_GALAXY_STORE_DOWNLOAD_URL "com.sec.android.app.sbrowser")" \
    "$WORK_DIR/system/system/preload/SBrowser/SBrowser.apk"
SBROWSER_ACTUAL_SHA256="$(sha256sum \
    "$WORK_DIR/system/system/preload/SBrowser/SBrowser.apk" | cut -d " " -f 1)"
if [ "$SBROWSER_ACTUAL_SHA256" != "$SBROWSER_SHA256" ]; then
    ABORT "Samsung Internet digest mismatch: expected $SBROWSER_SHA256, found $SBROWSER_ACTUAL_SHA256"
fi

while IFS= read -r i; do
    i="${i//$WORK_DIR\/system\//}"

    if [ -d "$WORK_DIR/system/$i" ]; then
        SET_METADATA "system" "$i" 0 0 755 "u:object_r:system_file:s0"
    else
        SET_METADATA "system" "$i" 0 0 644 "u:object_r:system_file:s0"
    fi

    if [[ "$i" == *".apk" ]] && \
            ! grep -q "$i" "$WORK_DIR/system/system/etc/vpl_apks_count_list.txt"; then
        LOG "- Adding \"$i\" to /system/system/etc/vpl_apks_count_list.txt"
        EVAL "echo \"$i\" >> \"$WORK_DIR/system/system/etc/vpl_apks_count_list.txt\""
    fi
done <<< "$(find "$WORK_DIR/system/system/preload")"

unset SBROWSER_ACTUAL_SHA256 SBROWSER_SHA256
