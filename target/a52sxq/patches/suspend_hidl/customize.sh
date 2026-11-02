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
# The kernel wake locks belong to no process, so if the shim restarts while it holds one (e.g. radio-interface.<pid>),
# a fresh instance would start with an empty refcount map and never release it - no deep sleep until reboot. Since the
# 2026-11-01 build (shim_release_stale_wakelocks.patch, applied in the IchthysOS tree) main() first wake_unlocks every
# "<name>.<digits>" entry of /sys/power/wake_lock left by a previous instance. The old clients do NOT reconnect by
# themselves (VNDK v30 libpower caches the service in a function static, no death recipient), so the rc restarts them
# with the shim (onrestart lines, 2026-11-02 race review).
# It runs in the stock system_suspend domain (sysfs_wake_lock rw, block_suspend, add system_suspend_hwservice; the
# vendor policy already lets the HAL domains find system_suspend_hwservice_30_0 and binder-call system_suspend_server).
SRC="$SRC_DIR/target/a52sxq/patches/suspend_hidl"
SUSPEND_SVC="$WORK_DIR/system/system/bin/hw/android.system.suspend-service"

[ -f "$SUSPEND_SVC" ] || ABORT "suspend_hidl: ${SUSPEND_SVC//$WORK_DIR/} not in the work dir"
# intentional skip: a source whose suspend service still serves android.system.suspend@1.0 itself needs no shim
if ! grep -q "suspend@1.0" "$SUSPEND_SVC"; then
    LOG "- Adding the android.system.suspend@1.0 HIDL shim for the VNDK 30 vendor HALs"
    for f in android.system.suspend-hidl-shim android.system.suspend@1.0.so android.system.suspend-hidl-shim.rc android.system.suspend-hidl-shim.xml; do
        [ -f "$SRC/$f" ] || ABORT "suspend_hidl: $f missing from the patch dir"
    done
    # pinned: IchthysOS build of vendor/k4/suspend-hidl-shim (update after a rebuild)
    [ "$(sha256sum "$SRC/android.system.suspend-hidl-shim" | cut -d " " -f 1)" = "478495b64702a95d0a94436696f463a2fbb0f2b0a92dd645500ea7b470a01257" ] || \
        ABORT "suspend_hidl: android.system.suspend-hidl-shim is not the reviewed build"
    [ "$(sha256sum "$SRC/android.system.suspend@1.0.so" | cut -d " " -f 1)" = "2bbc13d5ec2298216cd18a736a9f8aba2c830909b7294d435d09329d8133dfaf" ] || \
        ABORT "suspend_hidl: android.system.suspend@1.0.so is not the reviewed build"

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
    LOG "  (skipped: the source android.system.suspend-service still serves suspend@1.0 itself, no shim needed)"
fi
unset SRC SUSPEND_SVC
