SKIPUNZIP=1
# See module.prop.
[ -f "$WORK_DIR/system/system/priv-app/SamsungCamera/SamsungCamera.apk" ] || ABORT "camera_store_guard: no /system/priv-app/SamsungCamera"
EVAL "cp -f \"$MODPATH/k4-camera-guard\" \"$WORK_DIR/system/system/bin/k4-camera-guard\""
SET_METADATA "system" "system/bin/k4-camera-guard" 0 2000 755 "u:object_r:system_file:s0"
cat > "$WORK_DIR/system/system/etc/init/k4_camera_guard.rc" << 'RCEOF'
# Samsung Camera store-update guard (target/a52sxq/patches/camera_store_guard)
on property:sys.boot_completed=1
    start k4_camera_guard

service k4_camera_guard /system/bin/sh /system/bin/k4-camera-guard
    user root
    group root
    seclabel u:r:shell:s0
    oneshot
    disabled
RCEOF
SET_METADATA "system" "system/etc/init/k4_camera_guard.rc" 0 0 644 "u:object_r:system_file:s0"
LOG "- Samsung Camera: a /data update is dropped at boot (k4-camera-guard)"
