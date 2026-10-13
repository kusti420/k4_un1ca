SKIPUNZIP=1

# Driver set to install: "863" (V@0863.1, built 12/24/25) or "849" (V@0849.0, built 09/19/25). Both are from the
# same Qualcomm branch (AU_LINUX_ANDROID_LA.VENDOR.14.3.4.11), carry the same 23 files with identical DT_NEEDED
# lists and the very same a660 SQE microcode, so switching is this one line. 849 is the default again since 9.3.26
# (testers asked for the 863 set to be taken out).
ADRENO_DRIVER="849"

DRIVER_DIR="$MODPATH/v$ADRENO_DRIVER"
[ -d "$DRIVER_DIR/vendor/lib64/egl" ] || ABORT "adreno_driver: no driver set for ADRENO_DRIVER=\"$ADRENO_DRIVER\" (${DRIVER_DIR//$SRC_DIR\//})"

while IFS= read -r f; do
    case "$f" in
        firmware/*) LABEL="u:object_r:vendor_firmware_file:s0" ;;
        *) LABEL="u:object_r:same_process_hal_file:s0" ;;
    esac
    ADD_TO_WORK_DIR "$DRIVER_DIR" "vendor" "$f" 0 0 644 "$LABEL"
done < <(cd "$DRIVER_DIR/vendor" && find . -type f | sed "s|^\./||" | LC_ALL=C sort)

# Never ship a mix of two driver versions: the GLES library in the image must be the selected one
grep -q -a -F "V@0$ADRENO_DRIVER." "$WORK_DIR/vendor/lib64/egl/libGLESv2_adreno.so" || \
    ABORT "adreno_driver: /vendor/lib64/egl/libGLESv2_adreno.so is not V@0$ADRENO_DRIVER"

LOG "- Adreno V@0$ADRENO_DRIVER GPU driver installed"

# The stock vendor advertises the Vulkan version of its own V@0530 driver (android.hardware.vulkan.version 1.1.0 =
# 0x401000). V@0849 reports Vulkan 1.3 on the Adreno 642L (vkjson apiVersion 1.3.295) and V@0863 is a newer build of
# the same branch, so PackageManager kept reporting 1.1 and apps or store filters that require 1.3 through
# <uses-feature> saw the phone as unsupported. Advertise 1.3.0 (0x403000). Do not raise this further before
# `cmd gpu vkjson` on the phone shows that the installed driver reports more: the flag must not exceed the driver.
VKXML="$WORK_DIR/vendor/etc/permissions/android.hardware.vulkan.version-1_1.xml"
[ -f "$VKXML" ] || ABORT "adreno_driver: ${VKXML//$WORK_DIR/} not found"
if grep -q 'name="android.hardware.vulkan.version" version="4198400"' "$VKXML"; then
    EVAL "sed -i 's|name=\"android.hardware.vulkan.version\" version=\"4198400\"|name=\"android.hardware.vulkan.version\" version=\"4206592\"|' \"$VKXML\""
    LOG "- android.hardware.vulkan.version 1.1 -> 1.3"
fi
grep -q 'name="android.hardware.vulkan.version" version="4206592"' "$VKXML" || ABORT "adreno_driver: failed to set the Vulkan feature version"
unset VKXML ADRENO_DRIVER DRIVER_DIR
