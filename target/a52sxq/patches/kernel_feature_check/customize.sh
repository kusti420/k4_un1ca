# See module.prop. Report only: nothing here changes how the kernel or any feature is configured.
SRC="$SRC_DIR/target/a52sxq/patches/kernel_feature_check"
SYS="$WORK_DIR/system/system"
CIL="$SYS/etc/selinux/plat_sepolicy.cil"
VCIL="$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"

# Tester command and the boot-time check (one line to logcat tag K4KernelCheck + sys.k4.kernel.* properties)
EVAL "cp -f \"$SRC/k4-kernel-diag\" \"$SYS/bin/k4-kernel-diag\"" || ABORT "kernel_feature_check: diag copy failed"
SET_METADATA "system" "system/bin/k4-kernel-diag" 0 2000 755 "u:object_r:system_file:s0"
EVAL "cp -f \"$SRC/k4_kernel_check.rc\" \"$SYS/etc/init/k4_kernel_check.rc\"" || ABORT "kernel_feature_check: rc copy failed"
SET_METADATA "system" "system/etc/init/k4_kernel_check.rc" 0 0 644 "u:object_r:system_file:s0"

# SELinux: a small enforcing domain for the check. The init shell domain (sec_system_init_shell) cannot read
# /proc/version, kallsyms, config.gz, cgroups or most of sysfs, and cannot set system_prop. init compiles the split
# policy at boot, so a rule naming a type that does not exist would stop the boot: check every type first.
[ -f "$CIL" ] || ABORT "kernel_feature_check: plat_sepolicy.cil not found"
[ -f "$VCIL" ] || ABORT "kernel_feature_check: vendor_sepolicy.cil not found"
if ! grep -q -x -F "(type k4kcheck)" "$CIL"; then
    for t in init shell_exec toolbox_exec system_file proc_version proc proc_kallsyms config_gz proc_cgroups sysfs \
        sysfs_btf configfs property_socket system_prop usb_uvc_enabled_prop; do
        grep -q -x -F "(type $t)" "$CIL" || ABORT "kernel_feature_check: type $t not in plat_sepolicy.cil, review sepolicy.cil"
    done
    # secilc rejects a second typeattributeset for an attribute, so extend the existing domain set
    [ "$(grep -c "^(typeattributeset domain (" "$CIL")" = 1 ] || ABORT "kernel_feature_check: no single domain attribute set in plat_sepolicy.cil"
    sed -i "s/^(typeattributeset domain (/(typeattributeset domain (k4kcheck /" "$CIL"
    grep -q "^(typeattributeset domain (k4kcheck " "$CIL" || ABORT "kernel_feature_check: failed to add k4kcheck to domain"
    [ -z "$(tail -c 1 "$CIL")" ] || echo >> "$CIL"
    cat "$SRC/sepolicy.cil" >> "$CIL"
    # Vendor sysfs labels (battery/pass_through, kgsl): only if this vendor defines them; without them those probes
    # report "not checked" instead of a false MISSING.
    while read -r RULE; do
        t="$(echo "$RULE" | cut -d " " -f 3)"
        if grep -q -x -F "(type $t)" "$VCIL"; then
            echo "$RULE" >> "$CIL"
        else
            LOGW "kernel_feature_check: vendor type $t not found, k4-kernel-diag cannot check what it labels at boot"
        fi
    done < "$SRC/sepolicy_vendor_types.cil"
fi
grep -q -x -F "(allow k4kcheck shell_exec (file (read getattr map execute open entrypoint)))" "$CIL" || \
    ABORT "kernel_feature_check: k4kcheck rules missing from plat_sepolicy.cil"

LOG "- Added k4-kernel-diag and the boot-time kernel check (logcat K4KernelCheck, sys.k4.kernel.*)"
unset SRC SYS CIL VCIL RULE t
