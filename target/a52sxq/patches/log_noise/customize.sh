# See module.prop. Rules from /mnt/B1/OneUi9/scratch/deepdive_1016/selinux_hal/proposed_rules.cil (A1, D1-D3).
SET_PROP "system" "log.tag.QtiSurfaceFlingerExtension" "E"

# K4LN_APPEND <cil> <line>
K4LN_APPEND()
{
    [ -f "$1" ] || ABORT "log_noise: ${1//$WORK_DIR/} not found"
    if ! grep -q -x -F -- "$2" "$1"; then
        [ -z "$(tail -c 1 "$1")" ] || echo >> "$1"
        printf '%s\n' "$2" >> "$1"
    fi
    grep -q -x -F -- "$2" "$1" || ABORT "log_noise: failed to add a rule to ${1//$WORK_DIR/}"
}
PLAT="$WORK_DIR/system/system/etc/selinux/plat_sepolicy.cil"
SEXT="$WORK_DIR/system/system/system_ext/etc/selinux/system_ext_sepolicy.cil"
VEND="$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
K4LN_APPEND "$PLAT" "(allowx domain file_type (ioctl file (0xf514 0xf522 0xf528)))"
K4LN_APPEND "$SEXT" "(dontaudit mediaserver vendor_sys_gpp_prop (file (read getattr map open)))"
K4LN_APPEND "$VEND" "(dontaudit appdomain vendor_display_prop (file (read getattr map open)))"
K4LN_APPEND "$VEND" "(dontaudit mediaserver_30_0 vendor_display_prop (file (read getattr map open)))"
LOG "- Less log/audit noise (SurfaceFlinger corner radius warnings, Samsung F2FS ioctls, unset vendor display props)"
unset PLAT SEXT VEND
unset -f K4LN_APPEND
