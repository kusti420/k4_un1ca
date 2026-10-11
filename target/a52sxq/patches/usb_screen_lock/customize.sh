# See module.prop. The A14 vendor chowns its usb_control nodes from "on init" in init.qcom.usb.rc; add usb_sl there.
RC="$WORK_DIR/vendor/etc/init/hw/init.qcom.usb.rc"
[ -f "$RC" ] || ABORT "usb_screen_lock: ${RC//$WORK_DIR/} not found"
if grep -q "usb_control/usb_sl" "$RC" || grep -q "usb_control[[:space:]]\+usb_sl" "$WORK_DIR/vendor/ueventd.rc" 2> /dev/null; then
    LOG "- usb_sl is already handed to system, nothing to do"
else
    ANCHOR="    chmod 0664 /sys/class/usb_notify/usb_control/usb_data_enabled"
    [ "$(grep -c -x -F "$ANCHOR" "$RC")" = "1" ] || ABORT "usb_screen_lock: usb_data_enabled anchor not found in ${RC//$WORK_DIR/}"
    LOG "- Handing /sys/class/usb_notify/usb_control/usb_sl to system (0664 system usb)"
    EVAL "sed -i \"s|^$ANCHOR$|&\\n    chown system usb /sys/class/usb_notify/usb_control/usb_sl\\n    chmod 0664 /sys/class/usb_notify/usb_control/usb_sl|\" \"$RC\""
    grep -q -x -F "    chown system usb /sys/class/usb_notify/usb_control/usb_sl" "$RC" || ABORT "Failed to patch ${RC//$WORK_DIR/}"
fi
unset RC ANCHOR
