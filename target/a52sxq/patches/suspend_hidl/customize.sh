# The A52s vendor (VNDK 30) HALs take wake locks through libpower -> android.system.suspend@1.0::ISystemSuspend
# (hwbinder). AOSP removed that HIDL front end from android.system.suspend-service (system/hardware/interfaces
# e17d431), so on the One UI 9 system rild, emservice, the sensors multihal, audio, camera... all log
# "ISystemSuspend::getService() failed" and run without wake locks (missed wakeups in deep sleep).
#
# android.system.suspend-hidl-shim is built from source in the IchthysOS tree (vendor/k4/suspend-hidl-shim, HIDL
# interface restored from git e17d431^). It registers ISystemSuspend/default over hwbinder and backs every IWakeLock
# with a kernel wake lock written to /sys/power/wake_lock (refcounted per "<name>.<pid>"), released on
# IWakeLock::release() or client death. It never touches the AIDL service, /sys/power/state or wakeup_count: while a
# kernel wake lock is held the AIDL service simply blocks in its wakeup_count read.
# It runs in the stock system_suspend domain (sysfs_wake_lock rw, block_suspend, add system_suspend_hwservice; the
# vendor policy already lets the HAL domains find system_suspend_hwservice_30_0 and binder-call system_suspend_server).
SRC="$SRC_DIR/target/a52sxq/patches/suspend_hidl"
SUSPEND_SVC="$WORK_DIR/system/system/bin/hw/android.system.suspend-service"

if [ -f "$SUSPEND_SVC" ] && ! grep -q "suspend@1.0" "$SUSPEND_SVC"; then
    LOG "- Adding the android.system.suspend@1.0 HIDL shim for the VNDK 30 vendor HALs"
    for f in android.system.suspend-hidl-shim android.system.suspend@1.0.so android.system.suspend-hidl-shim.rc android.system.suspend-hidl-shim.xml; do
        [ -f "$SRC/$f" ] || ABORT "suspend_hidl: $f missing from the patch dir"
    done

    EVAL "cp -a \"$SRC/android.system.suspend-hidl-shim\" \"$WORK_DIR/system/system/bin/hw/android.system.suspend-hidl-shim\""
    SET_METADATA "system" "system/bin/hw/android.system.suspend-hidl-shim" 0 2000 755 "u:object_r:system_suspend_exec:s0"
    EVAL "cp -a \"$SRC/android.system.suspend@1.0.so\" \"$WORK_DIR/system/system/lib64/android.system.suspend@1.0.so\""
    SET_METADATA "system" "system/lib64/android.system.suspend@1.0.so" 0 0 644 "u:object_r:system_lib_file:s0"
    EVAL "cp -a \"$SRC/android.system.suspend-hidl-shim.rc\" \"$WORK_DIR/system/system/etc/init/android.system.suspend-hidl-shim.rc\""
    SET_METADATA "system" "system/etc/init/android.system.suspend-hidl-shim.rc" 0 0 644 "u:object_r:system_file:s0"
    EVAL "cp -a \"$SRC/android.system.suspend-hidl-shim.xml\" \"$WORK_DIR/system/system/etc/vintf/manifest/android.system.suspend-hidl-shim.xml\""
    SET_METADATA "system" "system/etc/vintf/manifest/android.system.suspend-hidl-shim.xml" 0 0 644 "u:object_r:system_file:s0"

    # init needs a domain for the new executable: reuse system_suspend via its exec type
    PLAT_FC="$WORK_DIR/system/system/etc/selinux/plat_file_contexts"
    if ! grep -q "suspend-hidl-shim" "$PLAT_FC"; then
        EVAL "echo \"/system/bin/hw/android\\.system\\.suspend-hidl-shim		u:object_r:system_suspend_exec:s0\" >> \"$PLAT_FC\""
    fi
    grep -q "suspend-hidl-shim" "$PLAT_FC" || ABORT "suspend_hidl: plat_file_contexts entry not added"
    unset PLAT_FC
else
    LOG "- Source suspend service already serves HIDL (or is missing), skipping the shim"
fi
unset SRC SUSPEND_SVC
