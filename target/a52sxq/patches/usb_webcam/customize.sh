# See module.prop. Vendor half of "Use phone as webcam"; the kernel half is kernel/0009-*.patch (k4-patches).
# Runs after kernel_bone_machine (modules are applied in C-sorted order), so work_dir/kernel/boot.img is the final kernel.
SRC="$SRC_DIR/target/a52sxq/patches/usb_webcam"
USB_SH="$WORK_DIR/vendor/bin/init.qcom.usb.sh"
USB_RC="$WORK_DIR/vendor/etc/init/hw/init.qcom.usb.rc"

[ -f "$WORK_DIR/kernel/boot.img" ] || ABORT "usb_webcam: work_dir/kernel/boot.img not found"
if ! grep -a -q "streaming_maxpacket" "$WORK_DIR/kernel/boot.img"; then
    # Stock kernel, or a bone-machine build without k4-patches/0009: no UVC gadget, so no Webcam option either
    LOG "- Kernel has no UVC gadget function (CONFIG_USB_CONFIGFS_F_UVC): webcam support skipped"
else
    [ -f "$USB_SH" ] || ABORT "usb_webcam: ${USB_SH//$WORK_DIR/} not found"
    [ -f "$USB_RC" ] || ABORT "usb_webcam: ${USB_RC//$WORK_DIR/} not found"
    grep -q "functions/uvc.0" "$USB_RC" || ABORT "usb_webcam: ${USB_RC//$WORK_DIR/} does not create the uvc.0 function"
    if grep -q "sys.usb.config=uvc" "$USB_RC"; then
        ABORT "usb_webcam: the vendor already has uvc USB configurations, review this patch against it"
    fi

    LOG "- Replacing the CAF uvc block of init.qcom.usb.sh with a trigger for k4_usb_webcam.rc"
    # The block starts at the exact "if [ -d .../uvc.0 ]; then" line and ends at the first line that is just "fi"
    START='if [ -d /config/usb_gadget/g1/functions/uvc.0 ]; then'
    [ "$(grep -c -x -F "$START" "$USB_SH")" = "1" ] || ABORT "usb_webcam: uvc block not found (once) in ${USB_SH//$WORK_DIR/}"
    awk -v start="$START" '
        $0 == start { print; print "\tsetprop vendor.usb.uvc.function.init 1"; skip = 1; next }
        skip && $0 == "fi" { print; skip = 0; done = 1; next }
        skip { next }
        { print }
        END { if (!done) exit 1 }
    ' "$USB_SH" > "$TMP_DIR/init.qcom.usb.sh" || ABORT "usb_webcam: uvc block of ${USB_SH//$WORK_DIR/} has no closing fi"
    # cat keeps the file's own mode/inode; fs_config/file_contexts already describe it
    EVAL "cat \"$TMP_DIR/init.qcom.usb.sh\" > \"$USB_SH\" && rm -f \"$TMP_DIR/init.qcom.usb.sh\""
    grep -q -x -F "	setprop vendor.usb.uvc.function.init 1" "$USB_SH" || ABORT "usb_webcam: failed to patch ${USB_SH//$WORK_DIR/}"
    if grep -q "streaming/h264\|streaming/uncompressed" "$USB_SH"; then
        ABORT "usb_webcam: old uvc descriptors are still in ${USB_SH//$WORK_DIR/}"
    fi

    LOG "- Adding the UVC descriptors and the uvc / uvc,adb USB configurations (/vendor/etc/init/k4_usb_webcam.rc)"
    EVAL "cp -f \"$SRC/k4_usb_webcam.rc\" \"$WORK_DIR/vendor/etc/init/k4_usb_webcam.rc\"" || ABORT "usb_webcam: rc copy failed"
    SET_METADATA "vendor" "etc/init/k4_usb_webcam.rc" 0 0 644 "u:object_r:vendor_configs_file:s0"

    # Read by UsbManager.isUvcSupportEnabled() (SecSettings shows "Webcam" in the USB options) and DeviceAsWebcam.
    # usb_uvc_enabled_prop is a vendor config prop: it belongs in vendor/build.prop.
    SET_PROP "vendor" "ro.usb.uvc.enabled" "true"
    unset START
fi
unset SRC USB_SH USB_RC
