# See module.prop. Rules from /mnt/B1/OneUi9/scratch/deepdive_1016/selinux_hal/proposed_rules.cil (A1, D1-D3).
SET_PROP "system" "log.tag.QtiSurfaceFlingerExtension" "E"
# Battery-health sampler of services.jar (com.android.server.bsoh.utils.L.d: unconditional Log.d, ~360 lines/min while
# charging; stock S26U code) and the A52s vendor BT HAL's in-band-sleep/wakelock traces (D/I on every UART wake while
# the controller is up in BLE_ON for Nearby device scanning; stock A52s vendor). Warnings and errors still get through.
SET_PROP "system" "log.tag.BSOHChargingDataCollector" "W"
SET_PROP "system" "log.tag.vendor.qti.bluetooth@1.0-ibs_handler" "W"
SET_PROP "system" "log.tag.vendor.qti.bluetooth@1.0-wake_lock" "W"

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
LOG "- Less log/audit noise (SurfaceFlinger corner radius warnings, BSOH charging sampler, BT HAL IBS traces, Samsung F2FS ioctls, unset vendor display props)"
unset PLAT SEXT VEND
unset -f K4LN_APPEND
