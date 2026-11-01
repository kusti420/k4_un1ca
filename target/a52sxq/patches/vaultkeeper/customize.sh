TFW="$(cut -d "/" -f 1 <<< "$TARGET_FIRMWARE")/$(cut -d "/" -f 2 <<< "$TARGET_FIRMWARE")"
# The 64-bit pair is mandatory: without it the source libvkmanager (AIDL client) stays and Bluetooth never turns on.
# The 32-bit pair serves the 32-bit vendor clients; A528BXXU5FWK4 ships both pairs, so a miss is a broken firmware
# extraction, not a feature difference.
for d in lib lib64; do
    for f in libvkmanager.so vendor.samsung.hardware.security.vaultkeeper@2.0.so; do
        [ -f "$FW_DIR/${TFW//\//_}/system/system/$d/$f" ] || ABORT "vaultkeeper: $d/$f not found in the target firmware ($TFW)"
        ADD_TO_WORK_DIR "$TFW" "system" "system/$d/$f" 0 0 644 "u:object_r:system_lib_file:s0" \
            || ABORT "vaultkeeper: failed to add $d/$f"
    done
done
unset TFW d f
