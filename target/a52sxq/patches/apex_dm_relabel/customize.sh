# See module.prop and k4-apex-dm-relabel.
SRC="$SRC_DIR/target/a52sxq/patches/apex_dm_relabel"
SYS="$WORK_DIR/system/system"
CIL="$SYS/etc/selinux/plat_sepolicy.cil"

EVAL "cp -f \"$SRC/k4-apex-dm-relabel\" \"$SYS/bin/k4-apex-dm-relabel\"" || ABORT "apex_dm_relabel: script copy failed"
SET_METADATA "system" "system/bin/k4-apex-dm-relabel" 0 2000 755 "u:object_r:system_file:s0"
EVAL "cp -f \"$SRC/k4_apex_dm_relabel.rc\" \"$SYS/etc/init/k4_apex_dm_relabel.rc\"" || ABORT "apex_dm_relabel: rc copy failed"
SET_METADATA "system" "system/etc/init/k4_apex_dm_relabel.rc" 0 0 644 "u:object_r:system_file:s0"

# SELinux: a small enforcing domain that may only read the APEX list, list /dev/block/mapper and read its *.apex links,
# stat dm nodes and write dm uevent files.
# init compiles the split policy at boot, so a rule naming a type that does not exist would stop the boot.
[ -f "$CIL" ] || ABORT "apex_dm_relabel: plat_sepolicy.cil not found"
if ! grep -q -x -F "(type k4apexdm)" "$CIL"; then
    for t in init shell_exec toolbox_exec system_file apex_mnt_dir apex_info_file block_device dm_device apex_dm_device \
        sysfs sysfs_dm kmsg_device; do
        grep -q -x -F "(type $t)" "$CIL" || ABORT "apex_dm_relabel: type $t not in plat_sepolicy.cil, review sepolicy.cil"
    done
    [ "$(grep -c "^(typeattributeset domain (" "$CIL")" = 1 ] || ABORT "apex_dm_relabel: no single domain attribute set in plat_sepolicy.cil"
    sed -i "s/^(typeattributeset domain (/(typeattributeset domain (k4apexdm /" "$CIL"
    grep -q "^(typeattributeset domain (k4apexdm " "$CIL" || ABORT "apex_dm_relabel: failed to add k4apexdm to domain"
    [ -z "$(tail -c 1 "$CIL")" ] || echo >> "$CIL"
    cat "$SRC/sepolicy.cil" >> "$CIL"
fi
grep -q -x -F "(allow k4apexdm apex_dm_device (lnk_file (read getattr)))" "$CIL" || ABORT "apex_dm_relabel: rules missing from plat_sepolicy.cil"

LOG "- APEX dm block devices get their apex_dm_device label back before PackageManager scans them (dm KOBJ_ADD before the name hash insert on kernels < 5.15)"
unset SRC SYS CIL t
