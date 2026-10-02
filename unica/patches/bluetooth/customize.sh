if [ ! -f "$WORK_DIR/system/system/lib64/libbluetooth_jni.so" ]; then
    LOG_STEP_IN "- Extracting libbluetooth_jni.so from com.android.bt.apex"

    if [ -d "$TMP_DIR" ]; then
        # An interrupted build can leave the payload fuse-mounted, which makes rm -rf fail
        mountpoint -q "$TMP_DIR/tmp_out" && EVAL "fusermount3 -u \"$TMP_DIR/tmp_out\""
        EVAL "rm -rf \"$TMP_DIR\""
    fi
    mkdir -p "$TMP_DIR"

    EVAL "unzip -j \"$WORK_DIR/system/system/apex/com.android.bt.apex\" \"apex_payload.img\" -d \"$TMP_DIR\""

    mkdir -p "$TMP_DIR/tmp_out"
    if [[ "$(xxd -p -s 1024 -l 4 "$TMP_DIR/apex_payload.img")" == "e2e1f5e0" ]]; then
        EVAL "fuse.erofs \"$TMP_DIR/apex_payload.img\" \"$TMP_DIR/tmp_out\""
    else
        EVAL "fuse2fs -o ro,fakeroot \"$TMP_DIR/apex_payload.img\" \"$TMP_DIR/tmp_out\""
    fi
    EVAL "cat \"$TMP_DIR/tmp_out/lib64/libbluetooth_jni.so\" > \"$WORK_DIR/system/system/lib64/libbluetooth_jni.so\""

    EVAL "fusermount3 -u \"$TMP_DIR/tmp_out\""
    rm -rf "$TMP_DIR"

    SET_METADATA "system" "system/lib64/libbluetooth_jni.so" 0 0 644 "u:object_r:system_lib_file:s0"

    LOG_STEP_OUT
fi

# Disable VaultKeeper support
# Before: [tbnz w8, #0, #0xXXXXXX]
# After: [b #0xXXXXXX]
if xxd -p -c 0 "$WORK_DIR/system/system/lib64/libbluetooth_jni.so" | grep -q "2897773948050037"; then
    HEX_PATCH "$WORK_DIR/system/system/lib64/libbluetooth_jni.so" \
        "2897773948050037" "289777392a000014"
elif xxd -p -c 0 "$WORK_DIR/system/system/lib64/libbluetooth_jni.so" | grep -q "2897663948050037"; then
    HEX_PATCH "$WORK_DIR/system/system/lib64/libbluetooth_jni.so" \
        "2897663948050037" "289766392a000014"
elif xxd -p -c 0 "$WORK_DIR/system/system/lib64/libbluetooth_jni.so" | grep -q "e863403948050037"; then
    HEX_PATCH "$WORK_DIR/system/system/lib64/libbluetooth_jni.so" \
        "e863403948050037" "e86340392a000014" 
else
    ABORT "No known patch available for the supplied libbluetooth_jni.so"
fi