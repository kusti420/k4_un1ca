SKIPUNZIP=1
# See module.prop.
EVAL "cp -f \"$MODPATH/k4-appcloud-guard\" \"$WORK_DIR/system/system/bin/k4-appcloud-guard\""
SET_METADATA "system" "system/bin/k4-appcloud-guard" 0 2000 755 "u:object_r:system_file:s0"
cat > "$WORK_DIR/system/system/etc/init/k4_appcloud_guard.rc" << 'RCEOF'
# AppCloud removal (target/a52sxq/patches/appcloud_guard)
on property:sys.boot_completed=1
    start k4_appcloud_guard

service k4_appcloud_guard /system/bin/sh /system/bin/k4-appcloud-guard
    user root
    group root
    seclabel u:r:shell:s0
    oneshot
    disabled
RCEOF
SET_METADATA "system" "system/etc/init/k4_appcloud_guard.rc" 0 0 644 "u:object_r:system_file:s0"
LOG "- AppCloud (ironSource/Aura, from the stock /prism CSC partition) is removed for the user at boot (k4-appcloud-guard)"
