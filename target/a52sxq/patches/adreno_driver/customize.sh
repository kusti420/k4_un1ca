SKIPUNZIP=1

while IFS= read -r f; do
    case "$f" in
        firmware/*) LABEL="u:object_r:vendor_firmware_file:s0" ;;
        *) LABEL="u:object_r:same_process_hal_file:s0" ;;
    esac
    ADD_TO_WORK_DIR "$MODPATH" "vendor" "$f" 0 0 644 "$LABEL"
done < <(cd "$MODPATH/vendor" && find . -type f | sed "s|^\./||" | LC_ALL=C sort)

LOG "- Adreno V@0849 GPU driver installed"
