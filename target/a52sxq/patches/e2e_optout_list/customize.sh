# See module.prop. Boot-time edge-to-edge opt-out list for apps whose SDK-36 edge-to-edge looks broken (Instagram).
grep -q "force-opt-out-e2e-add" <(unzip -p "$WORK_DIR/system/system/framework/services.jar" 'classes*.dex' 2> /dev/null | strings -n 20) || \
    ABORT "e2e_optout_list: services.jar has no 'force-opt-out-e2e-add' window shell command (WindowManagerShellCommand changed)"
mkdir -p "$WORK_DIR/system/system/etc/k4"
EVAL "cp -f \"$MODPATH/force_opt_out_e2e.txt\" \"$WORK_DIR/system/system/etc/k4/force_opt_out_e2e.txt\""
SET_METADATA "system" "system/etc/k4/force_opt_out_e2e.txt" 0 0 644 "u:object_r:system_file:s0"
EVAL "cp -f \"$MODPATH/k4-e2e-optout\" \"$WORK_DIR/system/system/bin/k4-e2e-optout\""
SET_METADATA "system" "system/bin/k4-e2e-optout" 0 2000 755 "u:object_r:system_file:s0"
cat > "$WORK_DIR/system/system/etc/init/k4_e2e_optout.rc" << 'RCEOF'
# Edge-to-edge opt-out list (target/a52sxq/patches/e2e_optout_list): the window manager keeps it in memory only
on property:sys.boot_completed=1
    start k4_e2e_optout

service k4_e2e_optout /system/bin/sh /system/bin/k4-e2e-optout
    user root
    group root
    seclabel u:r:shell:s0
    oneshot
    disabled
RCEOF
SET_METADATA "system" "system/etc/init/k4_e2e_optout.rc" 0 0 644 "u:object_r:system_file:s0"
LOG "- Edge-to-edge opt-out list: $(grep -c -v -E '^\s*(#|$)' "$MODPATH/force_opt_out_e2e.txt") package(s) (Instagram) forced out at boot"
