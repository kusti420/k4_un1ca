# Samsung Calculator and Clock: not in the S26 Ultra system images (Galaxy Store "restore" apps there), so the port
# had neither. APKs are the Galaxy Store builds for SM-S948B / API 37 (stubDownload.as), signed by Samsung Cert.
# Staged like the ReSukiSU manager: unica/patches/_debloat deletes /system/preload after the target patches run and
# unica/mods/preload copies .extra_preload/* into /system/preload and registers it in vpl_apks_count_list.txt.
# PrePackageInstaller then installs them to /data/app on first boot / after an upgrade, skipping an APK when the
# same or a higher version is already installed.
RESTORE_APPS_DIR="$SRC_DIR/prebuilts/samsung_restore_apps"
while read -r NAME APK SHA; do
    [ -f "$RESTORE_APPS_DIR/$APK" ] || ABORT "samsung_restore_apps: $APK not found in prebuilts/samsung_restore_apps"
    [ "$(sha256sum "$RESTORE_APPS_DIR/$APK" | cut -d " " -f 1)" = "$SHA" ] || ABORT "samsung_restore_apps: sha256 mismatch for $APK"
    if [ -d "$WORK_DIR/system/system/app/$NAME" ] || [ -d "$WORK_DIR/system/system/priv-app/$NAME" ]; then
        LOG "- $NAME is already a system app in this base, skipping"
        continue
    fi
    mkdir -p "$WORK_DIR/.extra_preload/$NAME"
    cp -f "$RESTORE_APPS_DIR/$APK" "$WORK_DIR/.extra_preload/$NAME/$NAME.apk"
    LOG "- $NAME (${APK%.apk}) staged for /system/preload"
done << 'LIST'
SecCalculator SecCalculator_12.6.00.35.apk 50aa3f9b70ee7af8e9243d826107605b358ef4af6e999e1a4b714e067e48b8d1
ClockPackage ClockPackage_12.6.05.23.apk cba916854df8c8ab262b11e916dccde170e127bcde7c12119cdc61d24d0cb977
LIST
unset RESTORE_APPS_DIR NAME APK SHA
