TFW="$(cut -d "/" -f 1 <<< "$TARGET_FIRMWARE")/$(cut -d "/" -f 2 <<< "$TARGET_FIRMWARE")"
for d in lib lib64; do
    for f in libvkmanager.so vendor.samsung.hardware.security.vaultkeeper@2.0.so; do
        [ -f "$FW_DIR/${TFW//\//_}/system/system/$d/$f" ] || continue
        ADD_TO_WORK_DIR "$TFW" "system" "system/$d/$f" 0 0 644 "u:object_r:system_lib_file:s0"
    done
done
unset TFW
