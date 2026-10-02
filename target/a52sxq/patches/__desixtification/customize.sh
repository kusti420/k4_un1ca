# One UI 9 (Fold8 Ultra) ships a 64-bit-only system, but the A52s vendor still runs
# audio, codec2, omx, widevine and cas as 32-bit processes. Both the Fold8 system and
# the ichthys32 prebuilts are built from CP2A.260605.016, so the 32-bit bionic and
# /system/lib set are taken from there. Samsung's 64-bit runtime is kept untouched
# (its libc exports the knox_nap property calls), only lib/ and the 32-bit linker
# are added to com.android.runtime.

ICHTHYS32="$SRC_DIR/prebuilts/ichthys32"

# [
DECODE_APEX()
{
    LOG "- Decoding ${1//$WORK_DIR/}"
    EVAL "apktool d -j \"$(nproc)\" -o \"$TMP_DIR\" -r \"$1\""
}

EXTRACT_PAYLOAD()
{
    LOG "- Unpacking apex_payload.img"

    local MNT="$TMP_DIR/tmp_out"
    mkdir -p "$MNT" "$TMP_DIR/unknown/apex_payload"
    if [[ "$(xxd -p -s 1024 -l 4 "$TMP_DIR/unknown/apex_payload.img")" == "e2e1f5e0" ]]; then
        EVAL "fuse.erofs \"$TMP_DIR/unknown/apex_payload.img\" \"$MNT\""
    else
        EVAL "fuse2fs -o ro,fakeroot \"$TMP_DIR/unknown/apex_payload.img\" \"$MNT\""
    fi
    EVAL "cp -a -T \"$MNT\" \"$TMP_DIR/unknown/apex_payload\""
    rm -rf "$TMP_DIR/unknown/apex_payload/lost+found"

    EVAL "find \"$MNT\" | xargs -I \"{}\" -P \"$(nproc)\" stat -c \"%n %u %g %a capabilities=0x0\" \"{}\" > \"$TMP_DIR/unknown/fs_config-apex_payload\""
    EVAL "find \"$MNT\" | xargs -I \"{}\" -P \"$(nproc)\" sh -c 'echo \"\$1 \$(getfattr -n security.selinux --only-values -h --absolute-names \"\$1\")\"' \"sh\" \"{}\" > \"$TMP_DIR/unknown/file_context-apex_payload\""
    EVAL "fusermount3 -u \"$MNT\""
    rmdir "$MNT"

    sed -i "/lost+found/d" "$TMP_DIR/unknown/fs_config-apex_payload" "$TMP_DIR/unknown/file_context-apex_payload"
    sed -i -e "s|$MNT |/ |g" -e "s|$MNT||g" "$TMP_DIR/unknown/file_context-apex_payload"
    sed -i -e "s|\.|\\\.|g" -e "s|\+|\\\+|g" -e "s|\[|\\\[|g" \
        -e "s|\]|\\\]|g" -e "s|\*|\\\*|g" "$TMP_DIR/unknown/file_context-apex_payload"
    sed -i -e "s|$MNT | |g" -e "s|$MNT/||g" "$TMP_DIR/unknown/fs_config-apex_payload"
    rm -f "$TMP_DIR/unknown/apex_payload.img"
}

# ADD_PAYLOAD_ENTRY <path relative to payload root> <uid> <gid> <mode> <label>
ADD_PAYLOAD_ENTRY()
{
    local ESCAPED
    ESCAPED="$(sed -e "s|\.|\\\.|g" -e "s|\+|\\\+|g" <<< "/$1")"
    sed -i "\|^$1 |d" "$TMP_DIR/unknown/fs_config-apex_payload"
    echo "$1 $2 $3 $4 capabilities=0x0" >> "$TMP_DIR/unknown/fs_config-apex_payload"
    grep -q -F "$ESCAPED " "$TMP_DIR/unknown/file_context-apex_payload" || \
        echo "$ESCAPED $5" >> "$TMP_DIR/unknown/file_context-apex_payload"
}

BUILD_PAYLOAD()
{
    LOG "- Building apex_payload.img"
    sort -o "$TMP_DIR/unknown/fs_config-apex_payload" "$TMP_DIR/unknown/fs_config-apex_payload"
    sort -o "$TMP_DIR/unknown/file_context-apex_payload" "$TMP_DIR/unknown/file_context-apex_payload"
    "$SRC_DIR/scripts/build_fs_image.sh" "ext4" --no-avb \
        -o "$TMP_DIR/unknown/apex_payload.img" -p "system" \
        "$TMP_DIR/unknown/apex_payload" "$TMP_DIR/unknown/file_context-apex_payload" "$TMP_DIR/unknown/fs_config-apex_payload" \
        > /dev/null || ABORT "Failed to build runtime apex_payload.img"
    rm -rf "$TMP_DIR/unknown/apex_payload" "$TMP_DIR/unknown/file_context-apex_payload" "$TMP_DIR/unknown/fs_config-apex_payload"
}

SIGN_PAYLOAD()
{
    LOG "- Signing apex_payload.img with AVB"
    local SALT
    SALT="$(sha256sum "$TMP_DIR/unknown/apex_manifest.pb" | cut -d " " -f 1)"
    EVAL "avbtool add_hashtree_footer --do_not_generate_fec --algorithm \"SHA256_RSA4096\" --hash_algorithm \"sha256\" --key \"$SRC_DIR/security/avb/testkey_rsa4096.pem\" --prop \"apex.key:com.android.runtime\" --salt \"$SALT\" --image \"$TMP_DIR/unknown/apex_payload.img\""
    EVAL "avbtool extract_public_key --key \"$SRC_DIR/security/avb/testkey_rsa4096.pem\" --output \"$TMP_DIR/unknown/apex_pubkey\""
}

BUILD_APEX()
{
    LOG "- Building ${1//$WORK_DIR/}"
    mkdir -p "$TMP_DIR/build/apk"
    cp -a "$TMP_DIR/original/META-INF" "$TMP_DIR/build/apk/META-INF"
    EVAL "apktool b -j \"$(nproc)\" \"$TMP_DIR\""
    mv -f "$TMP_DIR/dist/$(basename "$1")" "$1"
}

SIGN_APEX()
{
    LOG "- Signing ${1//$WORK_DIR/}"
    local CERT_PREFIX="aosp"
    if $ROM_IS_OFFICIAL; then
        CERT_PREFIX="unica"
    fi
    EVAL "signapk -a 4096 --align-file-size \"$SRC_DIR/security/${CERT_PREFIX}_platform.x509.pem\" \"$SRC_DIR/security/${CERT_PREFIX}_platform.pk8\" \"$1\" \"$1.signed\""
    mv -f "$1.signed" "$1"
}
# ]

if [ ! -d "$ICHTHYS32/system/lib" ] || [ ! -d "$ICHTHYS32/runtime/lib" ]; then
    ABORT "Missing 32-bit prebuilts in ${ICHTHYS32//$SRC_DIR\//}"
fi

RUNTIME_APEX="$WORK_DIR/system/system/apex/com.android.runtime.apex"
if [ -f "$WORK_DIR/system/system/bin/bootstrap/linker" ]; then
    LOG "\033[0;33m! 32-bit runtime already present, skipping\033[0m"
else
    LOG_STEP_IN "- Adding 32-bit bionic to com.android.runtime"
    [ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR"

    DECODE_APEX "$RUNTIME_APEX"
    EXTRACT_PAYLOAD

    P="$TMP_DIR/unknown/apex_payload"
    EVAL "cp -a \"$ICHTHYS32/runtime/lib\" \"$P/lib\""
    EVAL "cp -a \"$ICHTHYS32/runtime/bin/linker\" \"$ICHTHYS32/runtime/bin/crash_dump32\" \"$P/bin/\""
    ln -sf "linker" "$P/bin/linker_asan"
    # crash_dump32 links these dynamically and resolves them inside the runtime APEX namespace;
    # without them 32-bit processes (camera/audio/codec HALs here) get no tombstones
    for f in libbase.so liblog.so libprocinfo.so libunwindstack.so libc++.so liblzma.so libz.so; do
        EVAL "cp -a \"$ICHTHYS32/system/lib/$f\" \"$P/lib/$f\""
    done

    ADD_PAYLOAD_ENTRY "lib" 0 2000 755 "u:object_r:system_lib_file:s0"
    ADD_PAYLOAD_ENTRY "lib/bionic" 0 2000 755 "u:object_r:system_lib_file:s0"
    while IFS= read -r f; do
        ADD_PAYLOAD_ENTRY "${f#"$P/"}" 1000 1000 644 "u:object_r:system_lib_file:s0"
    done < <(find "$P/lib" -mindepth 1 ! -type d)
    ADD_PAYLOAD_ENTRY "bin/linker" 0 2000 755 "u:object_r:system_linker_exec:s0"
    ADD_PAYLOAD_ENTRY "bin/linker_asan" 0 2000 755 "u:object_r:system_file:s0"
    ADD_PAYLOAD_ENTRY "bin/crash_dump32" 0 2000 755 "u:object_r:crash_dump_exec:s0"

    BUILD_PAYLOAD
    SIGN_PAYLOAD
    BUILD_APEX "$RUNTIME_APEX"
    SIGN_APEX "$RUNTIME_APEX"
    rm -rf "$TMP_DIR"
    unset P
    LOG_STEP_OUT

    LOG_STEP_IN "- Adding CP2A 32-bit system libraries"
    # Don't clobber any 32-bit blob the source already ships (Samsung-specific ones)
    while IFS= read -r f; do
        REL="${f#"$ICHTHYS32/system/"}"
        if [ ! -e "$WORK_DIR/system/system/$REL" ] && [ ! -L "$WORK_DIR/system/system/$REL" ]; then
            ADD_TO_WORK_DIR "$ICHTHYS32" "system" "system/$REL" 0 0 644 "u:object_r:system_lib_file:s0" > /dev/null
        fi
    done < <(find "$ICHTHYS32/system/lib" -mindepth 1 -maxdepth 1)
    ADD_TO_WORK_DIR "$ICHTHYS32" "system" "system/bin/bootstrap/linker" 0 0 755 "u:object_r:system_linker_exec:s0"
    ADD_TO_WORK_DIR "$ICHTHYS32" "system" "system/bin/bootstrap/linker_asan" 0 0 755 "u:object_r:system_linker_exec:s0"
    ln -sf "/apex/com.android.runtime/bin/linker" "$WORK_DIR/system/system/bin/linker"
    ln -sf "/apex/com.android.runtime/bin/linker" "$WORK_DIR/system/system/bin/linker_asan"
    SET_METADATA "system" "system/bin/linker" 0 2000 755 "u:object_r:system_file:s0"
    SET_METADATA "system" "system/bin/linker_asan" 0 2000 755 "u:object_r:system_file:s0"
    LOG_STEP_OUT
fi

LOG_STEP_IN "- Selecting the 64-bit-only zygote"
SET_PROP "vendor" "ro.vendor.product.cpu.abilist" "arm64-v8a"
SET_PROP "vendor" "ro.vendor.product.cpu.abilist32" ""
SET_PROP "vendor" "ro.vendor.product.cpu.abilist64" "arm64-v8a"
SET_PROP "vendor" "ro.zygote" "zygote64"
SET_PROP "vendor" "dalvik.vm.dex2oat64.enabled" "true"
LOG_STEP_OUT

unset ICHTHYS32 RUNTIME_APEX REL
unset -f DECODE_APEX EXTRACT_PAYLOAD ADD_PAYLOAD_ENTRY BUILD_PAYLOAD SIGN_PAYLOAD BUILD_APEX SIGN_APEX
