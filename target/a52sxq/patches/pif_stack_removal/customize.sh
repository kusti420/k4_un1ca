SKIPUNZIP=1

# The ROM ships no Play Integrity setup any more (see module.prop). Installs the one-time cleanup of what the old
# pif_stack left in /data: /system/bin/k4-pif-cleanup, started by /system/etc/init/k4_pif_cleanup.rc after boot in
# KernelSU's own domain (k4_metamod only runs after its gate found KernelSU, so u:r:ksu:s0 exists then; boot_completed
# so `settings` works). Without KernelSU nothing runs. Needs ksu_metamodule (its services, its status property type).

[ -f "$WORK_DIR/system/system/etc/init/k4_metamodule.rc" ] || \
    ABORT "pif_stack_removal: needs ksu_metamodule (k4_metamodule.rc not in the work dir)"
for f in system/bin/k4-gmscompat system/etc/init/k4_gmscompat.rc system/etc/k4/gmscompat; do
    [ ! -e "$WORK_DIR/system/$f" ] || ABORT "pif_stack_removal: $f is still in the work dir (pif_stack not removed?)"
done

EVAL "cp -f \"$MODPATH/k4-pif-cleanup\" \"$WORK_DIR/system/system/bin/k4-pif-cleanup\""
SET_METADATA "system" "system/bin/k4-pif-cleanup" 0 2000 755 "u:object_r:system_file:s0"

cat > "$WORK_DIR/system/system/etc/init/k4_pif_cleanup.rc" << 'RC'
# One-time cleanup of the old ROM Play Integrity stack (target/a52sxq/patches/pif_stack_removal)
on property:sys.boot_completed=1 && property:init.svc.k4_metamod=stopped
    start k4_pif_cleanup

service k4_pif_cleanup /system/bin/timeout 120 /system/bin/sh /system/bin/k4-pif-cleanup
    user root
    group root
    seclabel u:r:ksu:s0
    oneshot
    disabled
RC
SET_METADATA "system" "system/etc/init/k4_pif_cleanup.rc" 0 0 644 "u:object_r:system_file:s0"

# result property: the status type of ksu_metamodule (set by the ksu domain, readable from adb shell)
PLAT_PC="$WORK_DIR/system/system/etc/selinux/plat_property_contexts"
grep -q "k4_metamod_status_prop" "$PLAT_PC" || ABORT "pif_stack_removal: k4_metamod_status_prop not in plat_property_contexts"
if ! grep -q "^sys\.k4\.pifcleanup " "$PLAT_PC"; then
    [ -z "$(tail -c 1 "$PLAT_PC")" ] || echo >> "$PLAT_PC"
    printf '%-28s u:object_r:k4_metamod_status_prop:s0\n' sys.k4.pifcleanup >> "$PLAT_PC"
fi

LOG "- No Play Integrity stack; k4-pif-cleanup removes the old one from /data once"
unset PLAT_PC f
