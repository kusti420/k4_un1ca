SKIPUNZIP=1

while IFS= read -r f; do
    case "$f" in
        firmware/*) LABEL="u:object_r:vendor_firmware_file:s0" ;;
        *) LABEL="u:object_r:same_process_hal_file:s0" ;;
    esac
    ADD_TO_WORK_DIR "$MODPATH" "vendor" "$f" 0 0 644 "$LABEL"
done < <(cd "$MODPATH/vendor" && find . -type f | sed "s|^\./||" | LC_ALL=C sort)

LOG "- Adreno V@0849 GPU driver installed"

# The stock vendor advertises the Vulkan version of its own V@0530 driver (android.hardware.vulkan.version 1.1.0 =
# 0x401000). V@0849 is a Vulkan 1.3 driver (vkjson apiVersion 1.3.295), so PackageManager kept reporting 1.1 and apps
# or store filters that require 1.3 through <uses-feature> saw the phone as unsupported. Advertise 1.3.0 (0x403000).
VKXML="$WORK_DIR/vendor/etc/permissions/android.hardware.vulkan.version-1_1.xml"
[ -f "$VKXML" ] || ABORT "adreno_driver: ${VKXML//$WORK_DIR/} not found"
if grep -q 'name="android.hardware.vulkan.version" version="4198400"' "$VKXML"; then
    EVAL "sed -i 's|name=\"android.hardware.vulkan.version\" version=\"4198400\"|name=\"android.hardware.vulkan.version\" version=\"4206592\"|' \"$VKXML\""
    LOG "- android.hardware.vulkan.version 1.1 -> 1.3"
fi
grep -q 'name="android.hardware.vulkan.version" version="4206592"' "$VKXML" || ABORT "adreno_driver: failed to set the Vulkan feature version"
unset VKXML
