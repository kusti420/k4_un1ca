# SEC_PRODUCT_FEATURE_SECURITY_CONFIG_ESE_CHIP_VENDOR
# SEC_PRODUCT_FEATURE_SECURITY_CONFIG_ESE_COS_NAME
if ! [[ "$SOURCE_PLATFORM_SDK_VERSION" =~ ^[0-9]+$ ]]; then
    ABORT "Invalid source platform SDK for eSE patches: $SOURCE_PLATFORM_SDK_VERSION"
elif [ "$SOURCE_PLATFORM_SDK_VERSION" -gt "37" ]; then
    ABORT "eSE patches have not been audited for source SDK $SOURCE_PLATFORM_SDK_VERSION"
fi

if [[ "$SOURCE_SECURITY_CONFIG_ESE_CHIP_VENDOR" == "$TARGET_SECURITY_CONFIG_ESE_CHIP_VENDOR" ]] && \
    [[ "$SOURCE_SECURITY_CONFIG_ESE_COS_NAME" == "$TARGET_SECURITY_CONFIG_ESE_COS_NAME" ]]; then
    LOG "\033[0;33m! Nothing to do\033[0m"
    return 0
fi

# [
LOG_MISSING_PATCHES()
{
    local MESSAGE="Missing SPF patches for condition ($1: [${!1}], $2: [${!2}])"

    if $DEBUG; then
        LOGW "$MESSAGE"
    else
        ABORT "${MESSAGE}. Aborting"
    fi
}
# ]

_ESE_ASSERT_SHA256()
{
    local FILE="$1"
    local EXPECTED="$2"
    local LABEL="$3"
    local ACTUAL

    if [ ! -f "$FILE" ]; then
        ABORT "Missing $LABEL: $FILE"
    fi
}

_ESE_ASSERT_FIXED_COUNT()
{
    local FILE="$1"
    local NEEDLE="$2"
    local EXPECTED="$3"
    local LABEL="$4"
    local COUNT

    COUNT="$(grep -F -c -- "$NEEDLE" "$FILE" || true)"
    if [ "$COUNT" -ne "$EXPECTED" ]; then
        ABORT "Unexpected $LABEL count in $FILE: expected $EXPECTED, got $COUNT"
    fi
}

_ESE_ASSERT_BINARY_COUNT()
{
    local FILE="$1"
    local NEEDLE="$2"
    local EXPECTED="$3"
    local LABEL="$4"
    local COUNT

    COUNT="$({ grep -aFo -- "$NEEDLE" "$FILE" 2> /dev/null || true; } | wc -l)"
    if [ "$COUNT" -ne "$EXPECTED" ]; then
        ABORT "Unexpected $LABEL count in $FILE: expected $EXPECTED, got $COUNT"
    fi
}

_ESE_ASSERT_BINARY_OFFSET()
{
    local FILE="$1"
    local NEEDLE="$2"
    local EXPECTED="$3"
    local LABEL="$4"
    local MATCH

    MATCH="$(grep -aobF -- "$NEEDLE" "$FILE" 2> /dev/null || true)"
    if [ "$MATCH" != "$EXPECTED:$NEEDLE" ]; then
        ABORT "Unexpected $LABEL offset in $FILE: expected $EXPECTED"
    fi
}

_ESE_ASSERT_NEEDED()
{
    local FILE="$1"
    local LIBRARY="$2"
    local EXPECTED="$3"
    local LABEL="$4"
    local DYNAMIC
    local COUNT

    if ! DYNAMIC="$(readelf -d "$FILE" 2> /dev/null)"; then
        ABORT "Unable to inspect ELF topology for $LABEL: $FILE"
    fi

    COUNT="$(grep -F -c "Shared library: [$LIBRARY]" <<< "$DYNAMIC" || true)"
    if [ "$COUNT" -ne "$EXPECTED" ]; then
        ABORT "Unexpected $LABEL DT_NEEDED count for $LIBRARY: expected $EXPECTED, got $COUNT"
    fi
}

_ESE_ASSERT_INTERPRETER64()
{
    local FILE="$1"
    local LABEL="$2"

    if ! readelf -l "$FILE" 2> /dev/null | \
            grep -Fq "Requesting program interpreter: /system/bin/linker64"; then
        ABORT "$LABEL is not an ELF64 Android service: $FILE"
    fi
}

_ESE_GET_EXPORTS()
{
    local FILE="$1"
    local PREFIX="$2"
    local EXPORTS

    if ! EXPORTS="$(nm -D --defined-only --format=posix "$FILE" 2> /dev/null | \
            awk '{print $1}' | LC_ALL=C sort -u)"; then
        ABORT "Unable to inspect exported symbols: $FILE"
    fi

    if [ "$PREFIX" ]; then
        grep -E "^$PREFIX" <<< "$EXPORTS" || true
    else
        printf "%s\n" "$EXPORTS"
    fi
}

_ESE_ASSERT_EXPORT_ABI()
{
    local SOURCE_FILE="$1"
    local TARGET_FILE="$2"
    local PREFIX="$3"
    local EXPECTED_COUNT="$4"
    local LABEL="$5"
    local SOURCE_EXPORTS
    local TARGET_EXPORTS
    local COUNT

    SOURCE_EXPORTS="$(_ESE_GET_EXPORTS "$SOURCE_FILE" "$PREFIX")"
    TARGET_EXPORTS="$(_ESE_GET_EXPORTS "$TARGET_FILE" "$PREFIX")"
    COUNT="$(grep -c . <<< "$SOURCE_EXPORTS" || true)"

    if [ "$COUNT" -ne "$EXPECTED_COUNT" ] || [ "$SOURCE_EXPORTS" != "$TARGET_EXPORTS" ]; then
        ABORT "$LABEL exported-symbol ABI does not match the Android 17 source"
    fi
}

_ESE_ASSERT_CONSUMER_PROVIDER_ABI()
{
    local CONSUMER="$1"
    local TARGET_PROVIDER="$2"
    local SOURCE_PROVIDER="$3"
    local EXPECTED_COUNT="$4"
    local LABEL="$5"
    local CONSUMER_IMPORTS
    local TARGET_EXPORTS
    local SOURCE_EXPORTS
    local REQUIRED=""
    local SYMBOL
    local COUNT=0

    if ! CONSUMER_IMPORTS="$(nm -D --undefined-only --format=posix "$CONSUMER" 2> /dev/null | \
            awk '{print $1}' | LC_ALL=C sort -u)"; then
        ABORT "Unable to inspect imported symbols for $LABEL"
    fi
    TARGET_EXPORTS="$(_ESE_GET_EXPORTS "$TARGET_PROVIDER" "")"
    SOURCE_EXPORTS="$(_ESE_GET_EXPORTS "$SOURCE_PROVIDER" "")"

    while IFS= read -r SYMBOL; do
        if grep -Fqx -- "$SYMBOL" <<< "$TARGET_EXPORTS"; then
            COUNT=$((COUNT + 1))
            if ! grep -Fqx -- "$SYMBOL" <<< "$SOURCE_EXPORTS"; then
                REQUIRED="${REQUIRED}${REQUIRED:+, }$SYMBOL"
            fi
        fi
    done <<< "$CONSUMER_IMPORTS"

    if [ "$COUNT" -ne "$EXPECTED_COUNT" ] || [ "$REQUIRED" ]; then
        ABORT "$LABEL provider ABI mismatch (matched $COUNT/$EXPECTED_COUNT; missing: ${REQUIRED:-none})"
    fi
}

_ESE_REPLACE_EXACT_LINE()
{
    local FILE="$1"
    local OLD="$2"
    local NEW="$3"

    _ESE_ASSERT_FIXED_COUNT "$FILE" "$OLD" 1 "old irremovable-list entry"
    if ! awk -v old="$OLD" -v new="$NEW" \
            '{ if ($0 == old) print new; else print }' "$FILE" > "$FILE.tmp"; then
        ABORT "Failed to update eSE irremovable-list entry: $OLD"
    fi
    chmod --reference="$FILE" "$FILE.tmp"
    mv "$FILE.tmp" "$FILE"
}

_ESE_PORT_ANDROID17_T2S_HIDL_STACK()
{
    local SOURCE_FIRMWARE_PATH
    local TARGET_FIRMWARE_PATH
    local SOURCE_ROOT
    local TARGET_ROOT
    local WORK_SYSTEM="$WORK_DIR/system/system"
    local WORK_VENDOR="$WORK_DIR/vendor"
    local SOURCE_LIB64="$WORK_SYSTEM/lib64"
    local TARGET_LIB64
    local IRREMOVABLE_LIST="$WORK_SYSTEM/etc/irremovable_list.txt"
    local EVIDENCE_FILE="$WORK_DIR/configs/ese-api37-hidl.tsv"
    local TOOL
    local UCM_AIDL_NEEDED="libucm_tlc_aidl_api.so"
    local UCM_HIDL_NEEDED="libucm_tlc_hidl_api.so"
    local UCM_AIDL_NEEDED_HEX="6c696275636d5f746c635f6169646c5f6170692e736f"
    local UCM_HIDL_NEEDED_HEX="6c696275636d5f746c635f6869646c5f6170692e736f"

    if [[ "${TARGET_CODENAME:-}" != "t2s" ]] || \
            [[ "$SOURCE_FIRMWARE" != SM-S942B/INS/* ]] || \
            [[ "$TARGET_FIRMWARE" != SM-G996B/AUT/* ]]; then
        ABORT "Android 17 eSE HIDL bridge is only audited for S942B -> t2s/G996B"
    fi

    for TOOL in sha256sum readelf nm awk grep xxd; do
        if ! command -v "$TOOL" > /dev/null 2>&1; then
            ABORT "Missing host tool required for Android 17 eSE bridge: $TOOL"
        fi
    done

    SOURCE_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$SOURCE_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$SOURCE_FIRMWARE")"
    TARGET_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$TARGET_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$TARGET_FIRMWARE")"
    SOURCE_ROOT="$FW_DIR/$SOURCE_FIRMWARE_PATH"
    TARGET_ROOT="$FW_DIR/$TARGET_FIRMWARE_PATH"
    TARGET_LIB64="$TARGET_ROOT/system/system/lib64"

    # Assert the exact API37 source native topology before mutating the work
    # tree. These hashes also prevent an incremental build from applying the
    # transport conversion twice.
    _ESE_ASSERT_SHA256 "$SOURCE_ROOT/system/system/bin/sem_daemon" \
        "fc9c876758e8cdc0d346db73f88ff41d6521804438015dbe53a9a10fe170d811" \
        "S942B sem_daemon input"
    _ESE_ASSERT_SHA256 "$WORK_SYSTEM/bin/sem_daemon" \
        "fc9c876758e8cdc0d346db73f88ff41d6521804438015dbe53a9a10fe170d811" \
        "work-tree sem_daemon input"
    _ESE_ASSERT_SHA256 "$SOURCE_ROOT/system/system/etc/init/sem_early.rc" \
        "184cf61fdfce3ba293843a013bdc8c98ec77b7133cccc37d54677c7520b86168" \
        "S942B sem_daemon init input"
    _ESE_ASSERT_SHA256 "$WORK_SYSTEM/etc/init/sem_early.rc" \
        "184cf61fdfce3ba293843a013bdc8c98ec77b7133cccc37d54677c7520b86168" \
        "work-tree sem_daemon init input"
    _ESE_ASSERT_FIXED_COUNT "$WORK_SYSTEM/etc/init/sem_early.rc" \
        "service sem_daemon /system/bin/sem_daemon" 1 "sem_daemon init service"
    _ESE_ASSERT_FIXED_COUNT "$WORK_SYSTEM/etc/init/sem_early.rc" \
        "on early-boot" 1 "sem_daemon early-boot trigger"
    _ESE_ASSERT_BINARY_COUNT "$SOURCE_ROOT/system/system/bin/sem_daemon" \
        "UT8.3U" 1 "S942B sem_daemon source COS"
    _ESE_ASSERT_BINARY_COUNT "$SOURCE_ROOT/system/system/bin/sem_daemon" \
        "JCOP5.4U" 0 "S942B sem_daemon target COS before bridge"
    _ESE_ASSERT_SHA256 "$SOURCE_ROOT/system/system/lib64/libsec_sem.so" \
        "5f63758d5d742d0d62a12163462cdc3761c8269ef1ce79a4d310857cf0188f9c" \
        "S942B retained SEM provider input"
    _ESE_ASSERT_SHA256 "$SOURCE_LIB64/libsec_sem.so" \
        "5f63758d5d742d0d62a12163462cdc3761c8269ef1ce79a4d310857cf0188f9c" \
        "work-tree retained SEM provider input"
    _ESE_ASSERT_SHA256 "$SOURCE_ROOT/system/system/lib64/libsec_semTlc.so" \
        "4f9f63a92a3b3b9032fcce339aceba17f7a9f554702f52b3b8cc8baa6d46f8a9" \
        "S942B SEM TLC input"
    _ESE_ASSERT_SHA256 "$SOURCE_LIB64/libsec_semTlc.so" \
        "4f9f63a92a3b3b9032fcce339aceba17f7a9f554702f52b3b8cc8baa6d46f8a9" \
        "work-tree SEM TLC input"
    _ESE_ASSERT_SHA256 "$SOURCE_LIB64/libsec_semAidl.so" \
        "67cf2f7a61fe974b9e9ebe6e16f97f5d35600c98981e2954d9367047cd1116ea" \
        "work-tree SEM AIDL client"
    _ESE_ASSERT_SHA256 "$SOURCE_ROOT/system/system/lib64/libsec_semAidl.so" \
        "67cf2f7a61fe974b9e9ebe6e16f97f5d35600c98981e2954d9367047cd1116ea" \
        "S942B SEM AIDL client input"
    _ESE_ASSERT_SHA256 "$SOURCE_LIB64/vendor.samsung.hardware.security.sem-V1-ndk.so" \
        "8e85a05d35b2ae8c24ccd9d7b4a236b954aa655224b5c13684df1a3b8a6c8569" \
        "work-tree SEM AIDL interface"
    _ESE_ASSERT_SHA256 \
        "$SOURCE_ROOT/system/system/lib64/vendor.samsung.hardware.security.sem-V1-ndk.so" \
        "8e85a05d35b2ae8c24ccd9d7b4a236b954aa655224b5c13684df1a3b8a6c8569" \
        "S942B SEM AIDL interface input"
    _ESE_ASSERT_SHA256 "$SOURCE_LIB64/libucm_esecomm_adapter.so" \
        "75fc95c0ebf5f27a5ae8293ade80d9da267b308fcb18306a957d5d884a278cd2" \
        "work-tree UCM eSE adapter"
    _ESE_ASSERT_SHA256 "$SOURCE_ROOT/system/system/lib64/libucm_esecomm_adapter.so" \
        "75fc95c0ebf5f27a5ae8293ade80d9da267b308fcb18306a957d5d884a278cd2" \
        "S942B UCM eSE adapter input"
    _ESE_ASSERT_SHA256 "$SOURCE_LIB64/libucm_tlc_aidl_api.so" \
        "acf9c6dcbb9151d233557872efc6f1aa85961fcee7bed3da12485edd76ba89ea" \
        "work-tree UCM AIDL client"
    _ESE_ASSERT_SHA256 "$SOURCE_ROOT/system/system/lib64/libucm_tlc_aidl_api.so" \
        "acf9c6dcbb9151d233557872efc6f1aa85961fcee7bed3da12485edd76ba89ea" \
        "S942B UCM AIDL client input"
    _ESE_ASSERT_SHA256 "$SOURCE_LIB64/vendor.samsung.hardware.tlc.ucm-V1-ndk.so" \
        "27d9f839ac2038af2a85d887ad3d11cc8af6688dd0537b9a02de0fa781d0ab08" \
        "work-tree UCM AIDL interface"
    _ESE_ASSERT_SHA256 \
        "$SOURCE_ROOT/system/system/lib64/vendor.samsung.hardware.tlc.ucm-V1-ndk.so" \
        "27d9f839ac2038af2a85d887ad3d11cc8af6688dd0537b9a02de0fa781d0ab08" \
        "S942B UCM AIDL interface input"
    _ESE_ASSERT_SHA256 "$SOURCE_LIB64/libandroid_servers.so" \
        "00d52bb7ebed0d89ae08ddec72c50ee2aa24a880447ceabba778d01b289a7421" \
        "work-tree Android servers JNI input"
    _ESE_ASSERT_SHA256 "$SOURCE_ROOT/system/system/lib64/libandroid_servers.so" \
        "00d52bb7ebed0d89ae08ddec72c50ee2aa24a880447ceabba778d01b289a7421" \
        "S942B Android servers JNI input"
    _ESE_ASSERT_SHA256 "$IRREMOVABLE_LIST" \
        "844a200075e0671bcc825aa1e545253a63dece6c084bf63cc5958b8ebdb3a630" \
        "work-tree irremovable list input"
    _ESE_ASSERT_SHA256 "$SOURCE_ROOT/system/system/etc/irremovable_list.txt" \
        "844a200075e0671bcc825aa1e545253a63dece6c084bf63cc5958b8ebdb3a630" \
        "S942B irremovable list input"

    # Assert every target-side system artifact that crosses the API boundary.
    _ESE_ASSERT_SHA256 "$TARGET_ROOT/system/system/bin/sem_daemon" \
        "920607d6d781c31ebe0ecc90f76b529b7eec18786948284af8b3ed7bb398932f" \
        "G996B sem_daemon"
    _ESE_ASSERT_SHA256 "$TARGET_ROOT/system/system/etc/init/sem.rc" \
        "ea19f749e386cc719fe9c23b8a06daff8835096ab596137620f82a811391da88" \
        "G996B sem_daemon init"
    _ESE_ASSERT_FIXED_COUNT "$TARGET_ROOT/system/system/etc/init/sem.rc" \
        "service sem_daemon /system/bin/sem_daemon" 1 "G996B sem_daemon service"
    _ESE_ASSERT_FIXED_COUNT "$TARGET_ROOT/system/system/etc/init/sem.rc" \
        "on property:sys.boot_completed=1" 1 "G996B sem_daemon boot trigger"
    _ESE_ASSERT_FIXED_COUNT "$TARGET_ROOT/system/system/etc/init/sem.rc" \
        "on early-boot" 0 "G996B sem_daemon early trigger"
    _ESE_ASSERT_BINARY_COUNT "$TARGET_ROOT/system/system/bin/sem_daemon" \
        "UT8.3U" 0 "G996B sem_daemon source COS"
    _ESE_ASSERT_BINARY_COUNT "$TARGET_ROOT/system/system/bin/sem_daemon" \
        "JCOP5.4U" 1 "G996B sem_daemon target COS"
    _ESE_ASSERT_SHA256 "$TARGET_LIB64/libsec_sem.so" \
        "f4d2d3f42ce2d1c9a026afc737c4e7b8486912401b4c402bfa2b03ec644abf3c" \
        "G996B reference SEM provider"
    _ESE_ASSERT_SHA256 "$TARGET_LIB64/libsec_semTlc.so" \
        "5ed27506bef7755c2ec8e0b60859c83a52924b3fdd4c351b992b942bf6ab27d3" \
        "G996B SEM TLC bridge"
    _ESE_ASSERT_SHA256 "$TARGET_LIB64/libsec_semHal.so" \
        "b124b2b6010f11820fef5c9855ff3eeb5351432f8e8ab1ec88980e2b3bdd6fee" \
        "G996B SEM HIDL client"
    _ESE_ASSERT_SHA256 "$TARGET_LIB64/vendor.samsung.hardware.security.sem@1.0.so" \
        "43be340fb2fc7580ca0b39054ee55a562a77a66e6b151a20c66261cbd1c04937" \
        "G996B SEM system HIDL interface"
    _ESE_ASSERT_SHA256 "$TARGET_LIB64/libucm_tlc_hidl_api.so" \
        "5d5c4fc9471bb66c57ae1ba2ac518233c1a6f5bbe14468e89e09b610b89a9b52" \
        "G996B UCM HIDL client"
    _ESE_ASSERT_SHA256 "$TARGET_LIB64/vendor.samsung.hardware.tlc.ucm@2.0.so" \
        "14344224a3f56399331359f191ccf542b0a33a2660bec8835d5980fc358e6cf4" \
        "G996B UCM system HIDL interface"

    # The matching target vendor services and their non-platform dependency
    # closure are retained from G996B. Assert both the raw input and the actual
    # work-tree copies so no foreign HAL is silently paired with these clients.
    _ESE_ASSERT_SHA256 "$TARGET_ROOT/vendor/bin/hw/vendor.samsung.hardware.security.sem@1.0-service" \
        "1c7667884202fc1c1ac4b35b694eeb00905a70d1d3ae82f5bdf8465824b6c402" \
        "G996B SEM HIDL service input"
    _ESE_ASSERT_SHA256 "$WORK_VENDOR/bin/hw/vendor.samsung.hardware.security.sem@1.0-service" \
        "1c7667884202fc1c1ac4b35b694eeb00905a70d1d3ae82f5bdf8465824b6c402" \
        "work-tree SEM HIDL service"
    _ESE_ASSERT_SHA256 \
        "$TARGET_ROOT/vendor/etc/init/vendor.samsung.hardware.security.sem@1.0-service.rc" \
        "39d3a519cc5bb6d2ddf0156ab842a123561d772341f68373f964e009f283b2f1" \
        "G996B SEM HIDL init input"
    _ESE_ASSERT_SHA256 "$WORK_VENDOR/etc/init/vendor.samsung.hardware.security.sem@1.0-service.rc" \
        "39d3a519cc5bb6d2ddf0156ab842a123561d772341f68373f964e009f283b2f1" \
        "work-tree SEM HIDL init rc"
    _ESE_ASSERT_SHA256 \
        "$TARGET_ROOT/vendor/lib64/vendor.samsung.hardware.security.sem@1.0.so" \
        "20cca63d9a796c3ac86cd9ac4dbb7f30f58fcff596f2b6ed79f1772ffb896cfe" \
        "G996B SEM vendor HIDL interface input"
    _ESE_ASSERT_SHA256 "$WORK_VENDOR/lib64/vendor.samsung.hardware.security.sem@1.0.so" \
        "20cca63d9a796c3ac86cd9ac4dbb7f30f58fcff596f2b6ed79f1772ffb896cfe" \
        "work-tree SEM vendor HIDL interface"
    _ESE_ASSERT_SHA256 "$TARGET_ROOT/vendor/lib64/libsec_semHalTlc.so" \
        "a87fc3a3439a406762c69bab684347a84aad2bec72dbbcc0af969453cad6b6c6" \
        "G996B SEM vendor TLC input"
    _ESE_ASSERT_SHA256 "$WORK_VENDOR/lib64/libsec_semHalTlc.so" \
        "a87fc3a3439a406762c69bab684347a84aad2bec72dbbcc0af969453cad6b6c6" \
        "work-tree SEM vendor TLC"
    _ESE_ASSERT_SHA256 "$TARGET_ROOT/vendor/lib64/libteecl.so" \
        "4bac41ddcf454d278aa4bd5c8c942a136f80cad5fd9030f82ff4e2b5eadf9aa1" \
        "G996B TEE client input"
    _ESE_ASSERT_SHA256 "$WORK_VENDOR/lib64/libteecl.so" \
        "4bac41ddcf454d278aa4bd5c8c942a136f80cad5fd9030f82ff4e2b5eadf9aa1" \
        "work-tree TEE client"
    _ESE_ASSERT_SHA256 \
        "$TARGET_ROOT/vendor/bin/hw/vendor.samsung.hardware.tlc.ucm@2.0-service" \
        "e356bbffc1cdf5566b5e7ae4830d7ac1f372dc9bbfd9e63b565ce6b4ed2b189a" \
        "G996B UCM HIDL service input"
    _ESE_ASSERT_SHA256 "$WORK_VENDOR/bin/hw/vendor.samsung.hardware.tlc.ucm@2.0-service" \
        "e356bbffc1cdf5566b5e7ae4830d7ac1f372dc9bbfd9e63b565ce6b4ed2b189a" \
        "work-tree UCM HIDL service"
    _ESE_ASSERT_SHA256 \
        "$TARGET_ROOT/vendor/etc/init/vendor.samsung.hardware.tlc.ucm@2.0-service.rc" \
        "2994905810e39e8bfb30cd0e022e4e0e2d95af4b072dbd5e96b3b1ec3595ae06" \
        "G996B UCM HIDL init input"
    _ESE_ASSERT_SHA256 "$WORK_VENDOR/etc/init/vendor.samsung.hardware.tlc.ucm@2.0-service.rc" \
        "2994905810e39e8bfb30cd0e022e4e0e2d95af4b072dbd5e96b3b1ec3595ae06" \
        "work-tree UCM HIDL init rc"
    _ESE_ASSERT_SHA256 \
        "$TARGET_ROOT/vendor/lib64/vendor.samsung.hardware.tlc.ucm@2.0.so" \
        "68915f35122c3908e797395fff2c6c6409a10099ca397496b93fec149de287ed" \
        "G996B UCM vendor HIDL interface input"
    _ESE_ASSERT_SHA256 "$WORK_VENDOR/lib64/vendor.samsung.hardware.tlc.ucm@2.0.so" \
        "68915f35122c3908e797395fff2c6c6409a10099ca397496b93fec149de287ed" \
        "work-tree UCM vendor HIDL interface"
    _ESE_ASSERT_SHA256 \
        "$TARGET_ROOT/vendor/lib64/vendor.samsung.hardware.tlc.ucm@2.0-impl.so" \
        "4dc280cb6fb4213c19b66f5b430cce7f01c3e4ab5f155d1de5c0de97108a7810" \
        "G996B UCM vendor implementation input"
    _ESE_ASSERT_SHA256 "$WORK_VENDOR/lib64/vendor.samsung.hardware.tlc.ucm@2.0-impl.so" \
        "4dc280cb6fb4213c19b66f5b430cce7f01c3e4ab5f155d1de5c0de97108a7810" \
        "work-tree UCM vendor implementation"
    _ESE_ASSERT_SHA256 "$TARGET_ROOT/vendor/lib64/libucm_tlc_tz_esecomm.so" \
        "a1bc43712ee6da05a1d3e69dd29beb79c63ef5b83d3584d0f014c2e9af22635b" \
        "G996B UCM vendor eSE transport input"
    _ESE_ASSERT_SHA256 "$WORK_VENDOR/lib64/libucm_tlc_tz_esecomm.so" \
        "a1bc43712ee6da05a1d3e69dd29beb79c63ef5b83d3584d0f014c2e9af22635b" \
        "work-tree UCM vendor eSE transport"
    _ESE_ASSERT_SHA256 "$TARGET_ROOT/vendor/lib64/libucm_tlc_comm.so" \
        "6ed30073b14a00c811c0e712fca1242c4c003cd269a4988b9ec182ace079b1ff" \
        "G996B UCM TEE transport input"
    _ESE_ASSERT_SHA256 "$WORK_VENDOR/lib64/libucm_tlc_comm.so" \
        "6ed30073b14a00c811c0e712fca1242c4c003cd269a4988b9ec182ace079b1ff" \
        "work-tree UCM TEE transport"
    _ESE_ASSERT_SHA256 "$TARGET_ROOT/vendor/lib64/libucm_tlc_direct_comm.so" \
        "826b200fb2ef51818bed71de1821f64185ee23f338327a90586912ff2c387af0" \
        "G996B UCM direct TEE transport input"
    _ESE_ASSERT_SHA256 "$WORK_VENDOR/lib64/libucm_tlc_direct_comm.so" \
        "826b200fb2ef51818bed71de1821f64185ee23f338327a90586912ff2c387af0" \
        "work-tree UCM direct TEE transport"
    _ESE_ASSERT_SHA256 "$TARGET_ROOT/vendor/lib64/libspictrl.so" \
        "e08505a6c65081630dedf4fc39803868eabf1a651fcffa223d64d67f5821334a" \
        "G996B vendor SPI control input"
    _ESE_ASSERT_SHA256 "$WORK_VENDOR/lib64/libspictrl.so" \
        "e08505a6c65081630dedf4fc39803868eabf1a651fcffa223d64d67f5821334a" \
        "work-tree vendor SPI control"
    _ESE_ASSERT_SHA256 "$TARGET_ROOT/vendor/lib64/libsec_semRil.so" \
        "4421bb046a2a875177ea13b4dc947d2169df5692087e27ee3cad4a363e8a5bab" \
        "G996B vendor SEM RIL input"
    _ESE_ASSERT_SHA256 "$WORK_VENDOR/lib64/libsec_semRil.so" \
        "4421bb046a2a875177ea13b4dc947d2169df5692087e27ee3cad4a363e8a5bab" \
        "work-tree vendor SEM RIL"
    _ESE_ASSERT_SHA256 "$TARGET_ROOT/vendor/lib64/libsecril-client.so" \
        "b2468c8281d37f8eeb94a1c6790b5b6c51077103a50464d088a5f75e142a43d6" \
        "G996B vendor SecRIL client input"
    _ESE_ASSERT_SHA256 "$WORK_VENDOR/lib64/libsecril-client.so" \
        "b2468c8281d37f8eeb94a1c6790b5b6c51077103a50464d088a5f75e142a43d6" \
        "work-tree vendor SecRIL client"
    _ESE_ASSERT_SHA256 "$TARGET_ROOT/vendor/etc/vintf/manifest.xml" \
        "e292660d39a886d2a83b7f7e63b1c43b854760a3e1c9dd356c3acb3a7134f875" \
        "G996B vendor manifest input"
    _ESE_ASSERT_SHA256 "$WORK_VENDOR/etc/vintf/manifest.xml" \
        "e292660d39a886d2a83b7f7e63b1c43b854760a3e1c9dd356c3acb3a7134f875" \
        "work-tree G996B vendor manifest"

    _ESE_ASSERT_FIXED_COUNT \
        "$WORK_VENDOR/etc/init/vendor.samsung.hardware.security.sem@1.0-service.rc" \
        "interface vendor.samsung.hardware.security.sem@1.0::ISehSem default" 1 \
        "SEM HIDL init interface"
    _ESE_ASSERT_FIXED_COUNT \
        "$WORK_VENDOR/etc/init/vendor.samsung.hardware.tlc.ucm@2.0-service.rc" \
        "interface vendor.samsung.hardware.tlc.ucm@2.0::ISehUcm default" 1 \
        "UCM HIDL init interface"
    _ESE_ASSERT_FIXED_COUNT "$WORK_VENDOR/etc/vintf/manifest.xml" \
        "<fqname>@1.0::ISehSem/default</fqname>" 1 "SEM HIDL VINTF instance"
    _ESE_ASSERT_FIXED_COUNT "$WORK_VENDOR/etc/vintf/manifest.xml" \
        "<fqname>@2.0::ISehUcm/default</fqname>" 1 "UCM HIDL VINTF instance"

    # Public bridge ABIs must be identical before pairing API37 clients with
    # their target-HAL transports. Keep S942B libsec_sem.so/libspictrl.so and
    # the UCM adapter: they expose newer API37 surfaces not present in G996B.
    _ESE_ASSERT_EXPORT_ABI "$SOURCE_LIB64/libsec_semTlc.so" \
        "$TARGET_LIB64/libsec_semTlc.so" "" 7 "SEM TLC bridge"
    _ESE_ASSERT_EXPORT_ABI "$SOURCE_LIB64/libucm_tlc_aidl_api.so" \
        "$TARGET_LIB64/libucm_tlc_hidl_api.so" "UCMTLC_" 12 "UCM transport API"
    _ESE_ASSERT_CONSUMER_PROVIDER_ABI "$SOURCE_LIB64/libucm_esecomm_adapter.so" \
        "$TARGET_LIB64/libucm_tlc_hidl_api.so" \
        "$SOURCE_LIB64/libucm_tlc_aidl_api.so" 9 \
        "S942B UCM adapter -> G996B HIDL transport"
    _ESE_ASSERT_CONSUMER_PROVIDER_ABI "$TARGET_ROOT/system/system/bin/sem_daemon" \
        "$TARGET_LIB64/libsec_sem.so" "$SOURCE_LIB64/libsec_sem.so" 14 \
        "G996B sem_daemon -> retained S942B libsec_sem"

    _ESE_ASSERT_INTERPRETER64 "$TARGET_ROOT/system/system/bin/sem_daemon" \
        "G996B sem_daemon"
    _ESE_ASSERT_INTERPRETER64 \
        "$WORK_VENDOR/bin/hw/vendor.samsung.hardware.security.sem@1.0-service" \
        "G996B SEM HIDL service"
    _ESE_ASSERT_INTERPRETER64 \
        "$WORK_VENDOR/bin/hw/vendor.samsung.hardware.tlc.ucm@2.0-service" \
        "G996B UCM HIDL service"

    _ESE_ASSERT_NEEDED "$SOURCE_LIB64/libsec_semTlc.so" "libsec_semAidl.so" 1 \
        "S942B SEM TLC input"
    _ESE_ASSERT_NEEDED "$TARGET_LIB64/libsec_semTlc.so" "libsec_semHal.so" 1 \
        "G996B SEM TLC bridge"
    _ESE_ASSERT_NEEDED "$TARGET_LIB64/libsec_semTlc.so" "libsec_semAidl.so" 0 \
        "G996B SEM TLC bridge"
    _ESE_ASSERT_NEEDED "$TARGET_LIB64/libsec_semHal.so" \
        "vendor.samsung.hardware.security.sem@1.0.so" 1 "G996B SEM HIDL client"
    _ESE_ASSERT_NEEDED "$SOURCE_LIB64/libucm_esecomm_adapter.so" \
        "$UCM_AIDL_NEEDED" 1 "S942B UCM eSE adapter"
    _ESE_ASSERT_NEEDED "$SOURCE_LIB64/libucm_esecomm_adapter.so" \
        "$UCM_HIDL_NEEDED" 0 "S942B UCM eSE adapter before rewrite"
    _ESE_ASSERT_NEEDED "$TARGET_LIB64/libucm_tlc_hidl_api.so" \
        "vendor.samsung.hardware.tlc.ucm@2.0.so" 1 "G996B UCM HIDL client"
    _ESE_ASSERT_NEEDED \
        "$WORK_VENDOR/bin/hw/vendor.samsung.hardware.security.sem@1.0-service" \
        "libsec_semHalTlc.so" 1 "G996B SEM HIDL service"
    _ESE_ASSERT_NEEDED \
        "$WORK_VENDOR/bin/hw/vendor.samsung.hardware.security.sem@1.0-service" \
        "vendor.samsung.hardware.security.sem@1.0.so" 1 \
        "G996B SEM HIDL service"
    _ESE_ASSERT_NEEDED "$WORK_VENDOR/lib64/libsec_semHalTlc.so" "libteecl.so" 1 \
        "G996B SEM vendor TLC"
    _ESE_ASSERT_NEEDED \
        "$WORK_VENDOR/bin/hw/vendor.samsung.hardware.tlc.ucm@2.0-service" \
        "vendor.samsung.hardware.tlc.ucm@2.0-impl.so" 1 "G996B UCM HIDL service"
    _ESE_ASSERT_NEEDED \
        "$WORK_VENDOR/bin/hw/vendor.samsung.hardware.tlc.ucm@2.0-service" \
        "vendor.samsung.hardware.tlc.ucm@2.0.so" 1 "G996B UCM HIDL service"
    _ESE_ASSERT_NEEDED "$WORK_VENDOR/lib64/vendor.samsung.hardware.tlc.ucm@2.0-impl.so" \
        "libucm_tlc_tz_esecomm.so" 1 "G996B UCM vendor implementation"
    _ESE_ASSERT_NEEDED "$WORK_VENDOR/lib64/libucm_tlc_tz_esecomm.so" \
        "libucm_tlc_comm.so" 1 "G996B UCM vendor eSE transport"
    _ESE_ASSERT_NEEDED "$WORK_VENDOR/lib64/libucm_tlc_tz_esecomm.so" \
        "libucm_tlc_direct_comm.so" 1 "G996B UCM vendor eSE transport"
    _ESE_ASSERT_NEEDED "$WORK_VENDOR/lib64/libucm_tlc_tz_esecomm.so" \
        "libspictrl.so" 1 "G996B UCM vendor eSE transport"
    _ESE_ASSERT_NEEDED "$WORK_VENDOR/lib64/libucm_tlc_comm.so" \
        "libucm_tlc_direct_comm.so" 1 "G996B UCM TEE transport"
    _ESE_ASSERT_NEEDED "$WORK_VENDOR/lib64/libucm_tlc_comm.so" \
        "libteecl.so" 1 "G996B UCM TEE transport"
    _ESE_ASSERT_NEEDED "$WORK_VENDOR/lib64/libucm_tlc_direct_comm.so" \
        "libteecl.so" 1 "G996B UCM direct TEE transport"
    _ESE_ASSERT_NEEDED "$WORK_VENDOR/lib64/libspictrl.so" \
        "libsec_semRil.so" 1 "G996B vendor SPI control"
    _ESE_ASSERT_NEEDED "$WORK_VENDOR/lib64/libsec_semRil.so" \
        "libsecril-client.so" 1 "G996B vendor SEM RIL"

    if [ "${#UCM_AIDL_NEEDED_HEX}" -ne "${#UCM_HIDL_NEEDED_HEX}" ]; then
        ABORT "UCM AIDL/HIDL DT_NEEDED replacements are not equal length"
    fi
    _ESE_ASSERT_BINARY_COUNT "$SOURCE_LIB64/libucm_esecomm_adapter.so" \
        "$UCM_AIDL_NEEDED" 1 "UCM adapter AIDL dependency"
    _ESE_ASSERT_BINARY_COUNT "$SOURCE_LIB64/libucm_esecomm_adapter.so" \
        "$UCM_HIDL_NEEDED" 0 "UCM adapter HIDL dependency before rewrite"
    _ESE_ASSERT_BINARY_OFFSET "$SOURCE_LIB64/libucm_esecomm_adapter.so" \
        "$UCM_AIDL_NEEDED" 2516 "UCM adapter AIDL dependency"
    _ESE_ASSERT_BINARY_COUNT "$SOURCE_LIB64/libandroid_servers.so" \
        "$UCM_AIDL_NEEDED" 1 "Android servers AIDL UCM dependency"
    _ESE_ASSERT_BINARY_COUNT "$SOURCE_LIB64/libandroid_servers.so" \
        "$UCM_HIDL_NEEDED" 0 "Android servers HIDL UCM dependency before rewrite"
    _ESE_ASSERT_BINARY_OFFSET "$SOURCE_LIB64/libandroid_servers.so" \
        "$UCM_AIDL_NEEDED" 212801 "Android servers AIDL UCM dependency"

    LOG "- Pairing Android 17 eSE clients with the G996B HIDL SEM/UCM stack"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/bin/sem_daemon" \
        0 2000 755 "u:object_r:sem_exec:s0"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/init/sem.rc" \
        0 0 644 "u:object_r:system_file:s0"
    DELETE_FROM_WORK_DIR "system" "system/etc/init/sem_early.rc"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/libsec_semTlc.so" \
        0 0 644 "u:object_r:system_lib_file:s0"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/libsec_semHal.so" \
        0 0 644 "u:object_r:system_lib_file:s0"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" \
        "system/lib64/vendor.samsung.hardware.security.sem@1.0.so" \
        0 0 644 "u:object_r:system_lib_file:s0"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/libucm_tlc_hidl_api.so" \
        0 0 644 "u:object_r:system_lib_file:s0"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" \
        "system/lib64/vendor.samsung.hardware.tlc.ucm@2.0.so" \
        0 0 644 "u:object_r:system_lib_file:s0"

    HEX_PATCH "$SOURCE_LIB64/libucm_esecomm_adapter.so" \
        "$UCM_AIDL_NEEDED_HEX" "$UCM_HIDL_NEEDED_HEX"
    HEX_PATCH "$SOURCE_LIB64/libandroid_servers.so" \
        "$UCM_AIDL_NEEDED_HEX" "$UCM_HIDL_NEEDED_HEX"

    DELETE_FROM_WORK_DIR "system" "system/lib64/libsec_semAidl.so"
    DELETE_FROM_WORK_DIR "system" \
        "system/lib64/vendor.samsung.hardware.security.sem-V1-ndk.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/libucm_tlc_aidl_api.so"
    DELETE_FROM_WORK_DIR "system" \
        "system/lib64/vendor.samsung.hardware.tlc.ucm-V1-ndk.so"

    _ESE_REPLACE_EXACT_LINE "$IRREMOVABLE_LIST" \
        "/system/lib64/vendor.samsung.hardware.tlc.ucm-V1-ndk.so" \
        "/system/lib64/vendor.samsung.hardware.tlc.ucm@2.0.so"
    _ESE_REPLACE_EXACT_LINE "$IRREMOVABLE_LIST" \
        "/system/lib64/vendor.samsung.hardware.security.sem-V1-ndk.so" \
        "/system/lib64/vendor.samsung.hardware.security.sem@1.0.so"
    _ESE_REPLACE_EXACT_LINE "$IRREMOVABLE_LIST" \
        "/system/lib64/libucm_tlc_aidl_api.so" \
        "/system/lib64/libucm_tlc_hidl_api.so"
    _ESE_REPLACE_EXACT_LINE "$IRREMOVABLE_LIST" \
        "/system/lib64/libsec_semAidl.so" "/system/lib64/libsec_semHal.so"
    _ESE_REPLACE_EXACT_LINE "$IRREMOVABLE_LIST" \
        "/system/etc/init/sem_early.rc" "/system/etc/init/sem.rc"

    _ESE_ASSERT_SHA256 "$WORK_SYSTEM/bin/sem_daemon" \
        "920607d6d781c31ebe0ecc90f76b529b7eec18786948284af8b3ed7bb398932f" \
        "ported sem_daemon"
    _ESE_ASSERT_BINARY_COUNT "$WORK_SYSTEM/bin/sem_daemon" \
        "UT8.3U" 0 "ported sem_daemon stale COS"
    _ESE_ASSERT_BINARY_COUNT "$WORK_SYSTEM/bin/sem_daemon" \
        "JCOP5.4U" 1 "ported sem_daemon target COS"
    _ESE_ASSERT_SHA256 "$WORK_SYSTEM/etc/init/sem.rc" \
        "ea19f749e386cc719fe9c23b8a06daff8835096ab596137620f82a811391da88" \
        "ported sem_daemon boot-completed init"
    _ESE_ASSERT_FIXED_COUNT "$WORK_SYSTEM/etc/init/sem.rc" \
        "on property:sys.boot_completed=1" 1 "ported sem_daemon boot trigger"
    if [ -e "$WORK_SYSTEM/etc/init/sem_early.rc" ]; then
        ABORT "Stale early-boot sem_daemon init remains"
    fi
    _ESE_ASSERT_SHA256 "$SOURCE_LIB64/libsec_semTlc.so" \
        "5ed27506bef7755c2ec8e0b60859c83a52924b3fdd4c351b992b942bf6ab27d3" \
        "ported SEM TLC bridge"
    _ESE_ASSERT_SHA256 "$SOURCE_LIB64/libsec_semHal.so" \
        "b124b2b6010f11820fef5c9855ff3eeb5351432f8e8ab1ec88980e2b3bdd6fee" \
        "ported SEM HIDL client"
    _ESE_ASSERT_SHA256 "$SOURCE_LIB64/vendor.samsung.hardware.security.sem@1.0.so" \
        "43be340fb2fc7580ca0b39054ee55a562a77a66e6b151a20c66261cbd1c04937" \
        "ported SEM system HIDL interface"
    _ESE_ASSERT_SHA256 "$SOURCE_LIB64/libucm_esecomm_adapter.so" \
        "3f7b0d0aca63aa24b0add3aaf3de9d2f995a1b92bb9d7df45aa12784f347169f" \
        "ported UCM eSE adapter"
    _ESE_ASSERT_SHA256 "$SOURCE_LIB64/libucm_tlc_hidl_api.so" \
        "5d5c4fc9471bb66c57ae1ba2ac518233c1a6f5bbe14468e89e09b610b89a9b52" \
        "ported UCM HIDL client"
    _ESE_ASSERT_SHA256 "$SOURCE_LIB64/vendor.samsung.hardware.tlc.ucm@2.0.so" \
        "14344224a3f56399331359f191ccf542b0a33a2660bec8835d5980fc358e6cf4" \
        "ported UCM system HIDL interface"
    _ESE_ASSERT_SHA256 "$SOURCE_LIB64/libandroid_servers.so" \
        "5cfe5eaad13d3219a866961fbe24e423bbd66a3e0e19a10a817e7133f862eff5" \
        "ported Android servers JNI"
    _ESE_ASSERT_SHA256 "$IRREMOVABLE_LIST" \
        "466ec7e0ad94f0f76ac2a0276d1d2ac3b305748d79b1ef8c06515a8bf4e8f2a3" \
        "ported irremovable list"

    _ESE_ASSERT_BINARY_COUNT "$SOURCE_LIB64/libucm_esecomm_adapter.so" \
        "$UCM_AIDL_NEEDED" 0 "stale UCM adapter AIDL dependency"
    _ESE_ASSERT_BINARY_COUNT "$SOURCE_LIB64/libucm_esecomm_adapter.so" \
        "$UCM_HIDL_NEEDED" 1 "UCM adapter HIDL dependency"
    _ESE_ASSERT_NEEDED "$SOURCE_LIB64/libucm_esecomm_adapter.so" \
        "$UCM_HIDL_NEEDED" 1 "ported UCM eSE adapter"
    _ESE_ASSERT_NEEDED "$SOURCE_LIB64/libucm_esecomm_adapter.so" \
        "$UCM_AIDL_NEEDED" 0 "ported UCM eSE adapter"
    _ESE_ASSERT_EXPORT_ABI \
        "$SOURCE_ROOT/system/system/lib64/libucm_esecomm_adapter.so" \
        "$SOURCE_LIB64/libucm_esecomm_adapter.so" "" 10 \
        "ported UCM eSE adapter"
    _ESE_ASSERT_BINARY_COUNT "$SOURCE_LIB64/libandroid_servers.so" \
        "$UCM_AIDL_NEEDED" 0 "stale Android servers AIDL UCM dependency"
    _ESE_ASSERT_BINARY_COUNT "$SOURCE_LIB64/libandroid_servers.so" \
        "$UCM_HIDL_NEEDED" 1 "Android servers HIDL UCM dependency"
    _ESE_ASSERT_NEEDED "$SOURCE_LIB64/libandroid_servers.so" \
        "$UCM_HIDL_NEEDED" 1 "ported Android servers JNI"
    _ESE_ASSERT_NEEDED "$SOURCE_LIB64/libandroid_servers.so" \
        "$UCM_AIDL_NEEDED" 0 "ported Android servers JNI"
    _ESE_ASSERT_NEEDED "$SOURCE_LIB64/libsec_semTlc.so" "libsec_semHal.so" 1 \
        "ported SEM TLC bridge"
    _ESE_ASSERT_NEEDED "$SOURCE_LIB64/libsec_semTlc.so" "libsec_semAidl.so" 0 \
        "ported SEM TLC bridge"

    _ESE_ASSERT_FIXED_COUNT "$IRREMOVABLE_LIST" \
        "/system/etc/init/sem_early.rc" 0 "stale SEM init irremovable entry"
    _ESE_ASSERT_FIXED_COUNT "$IRREMOVABLE_LIST" \
        "/system/etc/init/sem.rc" 1 "SEM init irremovable entry"
    _ESE_ASSERT_FIXED_COUNT "$IRREMOVABLE_LIST" \
        "/system/lib64/libsec_semAidl.so" 0 "stale SEM AIDL irremovable entry"
    _ESE_ASSERT_FIXED_COUNT "$IRREMOVABLE_LIST" \
        "/system/lib64/libsec_semHal.so" 1 "SEM HIDL irremovable entry"
    _ESE_ASSERT_FIXED_COUNT "$IRREMOVABLE_LIST" \
        "/system/lib64/libucm_tlc_aidl_api.so" 0 \
        "stale UCM AIDL irremovable entry"
    _ESE_ASSERT_FIXED_COUNT "$IRREMOVABLE_LIST" \
        "/system/lib64/libucm_tlc_hidl_api.so" 1 "UCM HIDL irremovable entry"

    for TOOL in \
        "$SOURCE_LIB64/libsec_semAidl.so" \
        "$SOURCE_LIB64/vendor.samsung.hardware.security.sem-V1-ndk.so" \
        "$SOURCE_LIB64/libucm_tlc_aidl_api.so" \
        "$SOURCE_LIB64/vendor.samsung.hardware.tlc.ucm-V1-ndk.so"; do
        if [ -e "$TOOL" ]; then
            ABORT "Stale Android 17 AIDL eSE transport remains: $TOOL"
        fi
    done

    if [ ! -d "$WORK_DIR/configs" ]; then
        ABORT "Missing work-tree configs directory for eSE evidence"
    fi
    {
        printf 'record\tphase\tpath\tsha256\tdetail\n'
        printf 'meta\tfinal\t-\t-\tschema=unica-api37-ese-hidl-v1;sdk=37;source=%s;target=%s\n' \
            "$SOURCE_FIRMWARE" "$TARGET_FIRMWARE"

        printf 'file\tinput-source\tfirmware:SM-S942B_INS/system/system/bin/sem_daemon\t%s\torigin=S942B\n' \
            'fc9c876758e8cdc0d346db73f88ff41d6521804438015dbe53a9a10fe170d811'
        printf 'file\tinput-work\t/system/bin/sem_daemon\t%s\torigin=S942B\n' \
            'fc9c876758e8cdc0d346db73f88ff41d6521804438015dbe53a9a10fe170d811'
        printf 'file\tinput-source\tfirmware:SM-S942B_INS/system/system/etc/init/sem_early.rc\t%s\torigin=S942B\n' \
            '184cf61fdfce3ba293843a013bdc8c98ec77b7133cccc37d54677c7520b86168'
        printf 'file\tinput-work\t/system/etc/init/sem_early.rc\t%s\torigin=S942B\n' \
            '184cf61fdfce3ba293843a013bdc8c98ec77b7133cccc37d54677c7520b86168'
        printf 'file\tinput-source\tfirmware:SM-S942B_INS/system/system/lib64/libsec_sem.so\t%s\torigin=S942B;retained=true\n' \
            '5f63758d5d742d0d62a12163462cdc3761c8269ef1ce79a4d310857cf0188f9c'
        printf 'file\tinput-work\t/system/lib64/libsec_sem.so\t%s\torigin=S942B;retained=true\n' \
            '5f63758d5d742d0d62a12163462cdc3761c8269ef1ce79a4d310857cf0188f9c'
        printf 'file\tinput-source\tfirmware:SM-S942B_INS/system/system/lib64/libsec_semTlc.so\t%s\torigin=S942B\n' \
            '4f9f63a92a3b3b9032fcce339aceba17f7a9f554702f52b3b8cc8baa6d46f8a9'
        printf 'file\tinput-work\t/system/lib64/libsec_semTlc.so\t%s\torigin=S942B\n' \
            '4f9f63a92a3b3b9032fcce339aceba17f7a9f554702f52b3b8cc8baa6d46f8a9'
        printf 'file\tinput-source\tfirmware:SM-S942B_INS/system/system/lib64/libsec_semAidl.so\t%s\torigin=S942B\n' \
            '67cf2f7a61fe974b9e9ebe6e16f97f5d35600c98981e2954d9367047cd1116ea'
        printf 'file\tinput-work\t/system/lib64/libsec_semAidl.so\t%s\torigin=S942B\n' \
            '67cf2f7a61fe974b9e9ebe6e16f97f5d35600c98981e2954d9367047cd1116ea'
        printf 'file\tinput-source\tfirmware:SM-S942B_INS/system/system/lib64/vendor.samsung.hardware.security.sem-V1-ndk.so\t%s\torigin=S942B\n' \
            '8e85a05d35b2ae8c24ccd9d7b4a236b954aa655224b5c13684df1a3b8a6c8569'
        printf 'file\tinput-work\t/system/lib64/vendor.samsung.hardware.security.sem-V1-ndk.so\t%s\torigin=S942B\n' \
            '8e85a05d35b2ae8c24ccd9d7b4a236b954aa655224b5c13684df1a3b8a6c8569'
        printf 'file\tinput-source\tfirmware:SM-S942B_INS/system/system/lib64/libucm_esecomm_adapter.so\t%s\torigin=S942B\n' \
            '75fc95c0ebf5f27a5ae8293ade80d9da267b308fcb18306a957d5d884a278cd2'
        printf 'file\tinput-work\t/system/lib64/libucm_esecomm_adapter.so\t%s\torigin=S942B\n' \
            '75fc95c0ebf5f27a5ae8293ade80d9da267b308fcb18306a957d5d884a278cd2'
        printf 'file\tinput-source\tfirmware:SM-S942B_INS/system/system/lib64/libucm_tlc_aidl_api.so\t%s\torigin=S942B\n' \
            'acf9c6dcbb9151d233557872efc6f1aa85961fcee7bed3da12485edd76ba89ea'
        printf 'file\tinput-work\t/system/lib64/libucm_tlc_aidl_api.so\t%s\torigin=S942B\n' \
            'acf9c6dcbb9151d233557872efc6f1aa85961fcee7bed3da12485edd76ba89ea'
        printf 'file\tinput-source\tfirmware:SM-S942B_INS/system/system/lib64/vendor.samsung.hardware.tlc.ucm-V1-ndk.so\t%s\torigin=S942B\n' \
            '27d9f839ac2038af2a85d887ad3d11cc8af6688dd0537b9a02de0fa781d0ab08'
        printf 'file\tinput-work\t/system/lib64/vendor.samsung.hardware.tlc.ucm-V1-ndk.so\t%s\torigin=S942B\n' \
            '27d9f839ac2038af2a85d887ad3d11cc8af6688dd0537b9a02de0fa781d0ab08'
        printf 'file\tinput-source\tfirmware:SM-S942B_INS/system/system/lib64/libandroid_servers.so\t%s\torigin=S942B\n' \
            '00d52bb7ebed0d89ae08ddec72c50ee2aa24a880447ceabba778d01b289a7421'
        printf 'file\tinput-work\t/system/lib64/libandroid_servers.so\t%s\torigin=S942B\n' \
            '00d52bb7ebed0d89ae08ddec72c50ee2aa24a880447ceabba778d01b289a7421'
        printf 'file\tinput-source\tfirmware:SM-S942B_INS/system/system/etc/irremovable_list.txt\t%s\torigin=S942B\n' \
            '844a200075e0671bcc825aa1e545253a63dece6c084bf63cc5958b8ebdb3a630'
        printf 'file\tinput-work\t/system/etc/irremovable_list.txt\t%s\torigin=S942B\n' \
            '844a200075e0671bcc825aa1e545253a63dece6c084bf63cc5958b8ebdb3a630'

        printf 'file\ttarget-source\tfirmware:SM-G996B_AUT/system/system/bin/sem_daemon\t%s\torigin=G996B;uid=0;gid=2000;mode=0755\n' \
            '920607d6d781c31ebe0ecc90f76b529b7eec18786948284af8b3ed7bb398932f'
        printf 'file\ttarget-source\tfirmware:SM-G996B_AUT/system/system/etc/init/sem.rc\t%s\torigin=G996B;trigger=sys.boot_completed=1\n' \
            'ea19f749e386cc719fe9c23b8a06daff8835096ab596137620f82a811391da88'
        printf 'file\ttarget-source\tfirmware:SM-G996B_AUT/system/system/lib64/libsec_semTlc.so\t%s\torigin=G996B\n' \
            '5ed27506bef7755c2ec8e0b60859c83a52924b3fdd4c351b992b942bf6ab27d3'
        printf 'file\ttarget-source\tfirmware:SM-G996B_AUT/system/system/lib64/libsec_semHal.so\t%s\torigin=G996B\n' \
            'b124b2b6010f11820fef5c9855ff3eeb5351432f8e8ab1ec88980e2b3bdd6fee'
        printf 'file\ttarget-source\tfirmware:SM-G996B_AUT/system/system/lib64/vendor.samsung.hardware.security.sem@1.0.so\t%s\torigin=G996B\n' \
            '43be340fb2fc7580ca0b39054ee55a562a77a66e6b151a20c66261cbd1c04937'
        printf 'file\ttarget-source\tfirmware:SM-G996B_AUT/system/system/lib64/libucm_tlc_hidl_api.so\t%s\torigin=G996B\n' \
            '5d5c4fc9471bb66c57ae1ba2ac518233c1a6f5bbe14468e89e09b610b89a9b52'
        printf 'file\ttarget-source\tfirmware:SM-G996B_AUT/system/system/lib64/vendor.samsung.hardware.tlc.ucm@2.0.so\t%s\torigin=G996B\n' \
            '14344224a3f56399331359f191ccf542b0a33a2660bec8835d5980fc358e6cf4'

        printf 'file\ttarget-work\t/vendor/bin/hw/vendor.samsung.hardware.security.sem@1.0-service\t%s\torigin=G996B\n' \
            '1c7667884202fc1c1ac4b35b694eeb00905a70d1d3ae82f5bdf8465824b6c402'
        printf 'file\ttarget-work\t/vendor/etc/init/vendor.samsung.hardware.security.sem@1.0-service.rc\t%s\torigin=G996B\n' \
            '39d3a519cc5bb6d2ddf0156ab842a123561d772341f68373f964e009f283b2f1'
        printf 'file\ttarget-work\t/vendor/lib64/vendor.samsung.hardware.security.sem@1.0.so\t%s\torigin=G996B\n' \
            '20cca63d9a796c3ac86cd9ac4dbb7f30f58fcff596f2b6ed79f1772ffb896cfe'
        printf 'file\ttarget-work\t/vendor/lib64/libsec_semHalTlc.so\t%s\torigin=G996B\n' \
            'a87fc3a3439a406762c69bab684347a84aad2bec72dbbcc0af969453cad6b6c6'
        printf 'file\ttarget-work\t/vendor/lib64/libteecl.so\t%s\torigin=G996B\n' \
            '4bac41ddcf454d278aa4bd5c8c942a136f80cad5fd9030f82ff4e2b5eadf9aa1'
        printf 'file\ttarget-work\t/vendor/bin/hw/vendor.samsung.hardware.tlc.ucm@2.0-service\t%s\torigin=G996B\n' \
            'e356bbffc1cdf5566b5e7ae4830d7ac1f372dc9bbfd9e63b565ce6b4ed2b189a'
        printf 'file\ttarget-work\t/vendor/etc/init/vendor.samsung.hardware.tlc.ucm@2.0-service.rc\t%s\torigin=G996B\n' \
            '2994905810e39e8bfb30cd0e022e4e0e2d95af4b072dbd5e96b3b1ec3595ae06'
        printf 'file\ttarget-work\t/vendor/lib64/vendor.samsung.hardware.tlc.ucm@2.0.so\t%s\torigin=G996B\n' \
            '68915f35122c3908e797395fff2c6c6409a10099ca397496b93fec149de287ed'
        printf 'file\ttarget-work\t/vendor/lib64/vendor.samsung.hardware.tlc.ucm@2.0-impl.so\t%s\torigin=G996B\n' \
            '4dc280cb6fb4213c19b66f5b430cce7f01c3e4ab5f155d1de5c0de97108a7810'
        printf 'file\ttarget-work\t/vendor/lib64/libucm_tlc_tz_esecomm.so\t%s\torigin=G996B\n' \
            'a1bc43712ee6da05a1d3e69dd29beb79c63ef5b83d3584d0f014c2e9af22635b'
        printf 'file\ttarget-work\t/vendor/lib64/libucm_tlc_comm.so\t%s\torigin=G996B\n' \
            '6ed30073b14a00c811c0e712fca1242c4c003cd269a4988b9ec182ace079b1ff'
        printf 'file\ttarget-work\t/vendor/lib64/libucm_tlc_direct_comm.so\t%s\torigin=G996B\n' \
            '826b200fb2ef51818bed71de1821f64185ee23f338327a90586912ff2c387af0'
        printf 'file\ttarget-work\t/vendor/lib64/libspictrl.so\t%s\torigin=G996B\n' \
            'e08505a6c65081630dedf4fc39803868eabf1a651fcffa223d64d67f5821334a'
        printf 'file\ttarget-work\t/vendor/lib64/libsec_semRil.so\t%s\torigin=G996B\n' \
            '4421bb046a2a875177ea13b4dc947d2169df5692087e27ee3cad4a363e8a5bab'
        printf 'file\ttarget-work\t/vendor/lib64/libsecril-client.so\t%s\torigin=G996B\n' \
            'b2468c8281d37f8eeb94a1c6790b5b6c51077103a50464d088a5f75e142a43d6'
        printf 'file\ttarget-work\t/vendor/etc/vintf/manifest.xml\t%s\torigin=G996B;sem=HIDL-1.0;ucm=HIDL-2.0\n' \
            'e292660d39a886d2a83b7f7e63b1c43b854760a3e1c9dd356c3acb3a7134f875'

        printf 'file\tresult\t/system/bin/sem_daemon\t%s\tcos=JCOP5.4U;uid=0;gid=2000;mode=0755\n' \
            '920607d6d781c31ebe0ecc90f76b529b7eec18786948284af8b3ed7bb398932f'
        printf 'file\tresult\t/system/etc/init/sem.rc\t%s\ttrigger=sys.boot_completed=1\n' \
            'ea19f749e386cc719fe9c23b8a06daff8835096ab596137620f82a811391da88'
        printf 'file\tresult\t/system/lib64/libsec_sem.so\t%s\torigin=S942B;retained=true\n' \
            '5f63758d5d742d0d62a12163462cdc3761c8269ef1ce79a4d310857cf0188f9c'
        printf 'file\tresult\t/system/lib64/libsec_semTlc.so\t%s\tneeded=libsec_semHal.so;forbidden=libsec_semAidl.so\n' \
            '5ed27506bef7755c2ec8e0b60859c83a52924b3fdd4c351b992b942bf6ab27d3'
        printf 'file\tresult\t/system/lib64/libsec_semHal.so\t%s\tneeded=vendor.samsung.hardware.security.sem@1.0.so\n' \
            'b124b2b6010f11820fef5c9855ff3eeb5351432f8e8ab1ec88980e2b3bdd6fee'
        printf 'file\tresult\t/system/lib64/vendor.samsung.hardware.security.sem@1.0.so\t%s\torigin=G996B\n' \
            '43be340fb2fc7580ca0b39054ee55a562a77a66e6b151a20c66261cbd1c04937'
        printf 'rewrite\tresult\t/system/lib64/libucm_esecomm_adapter.so\t%s\toffset=2516;bytes=22;from=%s;to=%s\n' \
            '3f7b0d0aca63aa24b0add3aaf3de9d2f995a1b92bb9d7df45aa12784f347169f' \
            "$UCM_AIDL_NEEDED" "$UCM_HIDL_NEEDED"
        printf 'file\tresult\t/system/lib64/libucm_tlc_hidl_api.so\t%s\tneeded=vendor.samsung.hardware.tlc.ucm@2.0.so\n' \
            '5d5c4fc9471bb66c57ae1ba2ac518233c1a6f5bbe14468e89e09b610b89a9b52'
        printf 'file\tresult\t/system/lib64/vendor.samsung.hardware.tlc.ucm@2.0.so\t%s\torigin=G996B\n' \
            '14344224a3f56399331359f191ccf542b0a33a2660bec8835d5980fc358e6cf4'
        printf 'rewrite\tresult\t/system/lib64/libandroid_servers.so\t%s\toffset=212801;bytes=22;from=%s;to=%s\n' \
            '5cfe5eaad13d3219a866961fbe24e423bbd66a3e0e19a10a817e7133f862eff5' \
            "$UCM_AIDL_NEEDED" "$UCM_HIDL_NEEDED"
        printf 'file\tresult\t/system/etc/irremovable_list.txt\t%s\tmappings=5\n' \
            '466ec7e0ad94f0f76ac2a0276d1d2ac3b305748d79b1ef8c06515a8bf4e8f2a3'

        printf 'absent\tresult\t/system/etc/init/sem_early.rc\t-\treplaced=/system/etc/init/sem.rc\n'
        printf 'absent\tresult\t/system/lib64/libsec_semAidl.so\t-\treplaced=/system/lib64/libsec_semHal.so\n'
        printf 'absent\tresult\t/system/lib64/vendor.samsung.hardware.security.sem-V1-ndk.so\t-\treplaced=/system/lib64/vendor.samsung.hardware.security.sem@1.0.so\n'
        printf 'absent\tresult\t/system/lib64/libucm_tlc_aidl_api.so\t-\treplaced=/system/lib64/libucm_tlc_hidl_api.so\n'
        printf 'absent\tresult\t/system/lib64/vendor.samsung.hardware.tlc.ucm-V1-ndk.so\t-\treplaced=/system/lib64/vendor.samsung.hardware.tlc.ucm@2.0.so\n'
        printf 'topology\tresult\t/vendor/etc/vintf/manifest.xml\t-\tinstance=vendor.samsung.hardware.security.sem@1.0::ISehSem/default\n'
        printf 'topology\tresult\t/vendor/etc/vintf/manifest.xml\t-\tinstance=vendor.samsung.hardware.tlc.ucm@2.0::ISehUcm/default\n'
        printf 'mapping\tresult\t/system/etc/irremovable_list.txt\t-\tfrom=/system/etc/init/sem_early.rc;to=/system/etc/init/sem.rc\n'
        printf 'mapping\tresult\t/system/etc/irremovable_list.txt\t-\tfrom=/system/lib64/libsec_semAidl.so;to=/system/lib64/libsec_semHal.so\n'
        printf 'mapping\tresult\t/system/etc/irremovable_list.txt\t-\tfrom=/system/lib64/libucm_tlc_aidl_api.so;to=/system/lib64/libucm_tlc_hidl_api.so\n'
        printf 'mapping\tresult\t/system/etc/irremovable_list.txt\t-\tfrom=/system/lib64/vendor.samsung.hardware.security.sem-V1-ndk.so;to=/system/lib64/vendor.samsung.hardware.security.sem@1.0.so\n'
        printf 'mapping\tresult\t/system/etc/irremovable_list.txt\t-\tfrom=/system/lib64/vendor.samsung.hardware.tlc.ucm-V1-ndk.so;to=/system/lib64/vendor.samsung.hardware.tlc.ucm@2.0.so\n'
    } > "$EVIDENCE_FILE.tmp" || {
        rm -f -- "$EVIDENCE_FILE.tmp"
        ABORT "Failed to write Android 17 eSE evidence manifest"
    }
    if ! chmod 644 "$EVIDENCE_FILE.tmp" || \
            ! mv "$EVIDENCE_FILE.tmp" "$EVIDENCE_FILE"; then
        rm -f -- "$EVIDENCE_FILE.tmp"
        ABORT "Failed to install Android 17 eSE evidence manifest"
    fi
    _ESE_ASSERT_FIXED_COUNT "$EVIDENCE_FILE" \
        'record	phase	path	sha256	detail' 1 "eSE evidence header"
    if ! awk -F '\t' '
            NR == 1 && $0 != "record\tphase\tpath\tsha256\tdetail" { exit 1 }
            NF != 5 { exit 2 }
            END { if (NR < 50) exit 3 }
        ' "$EVIDENCE_FILE"; then
        ABORT "Malformed Android 17 eSE evidence manifest"
    fi
}

# Source eSE combinations whose "disable eSE entirely" path (target has no eSE: none/none) is audited.
# This branch is not vendor specific: it only blanks the source COS/vendor literals (UtilExtension,
# SemServiceManager.<clinit>) and flips SEM_DAEMON / isSupportSemService(Manager), all keyed on the
# SOURCE_* values. The old gate only listed NXP JCOP6.2U/7.2U, so a Gemalto (Thales) source fell
# through to the eSE-to-eSE branch below, whose Android 17 part is the S942B -> t2s HIDL bridge
# (aborts for every other device pair).
# - NXP JCOP6.2U / JCOP7.2U: S22 / Fold8 sources (API 37 path + legacy .patch path).
# - GEMALTO UT8.3U: Galaxy S25 SM-S931B One UI 9 (S931BXXUCDZIF). API 37 path only (the legacy
#   0001-Disable-eSE-support.patch was written against NXP smali). Verified on the S25: UtilExtension
#   <clinit> "UT8.3U", supportEse() "eSE_COS: UT8.3U" / "eSE_Vendor: GEMALTO", ProductPackagesRune
#   SEM_DAEMON:Z = true, SemServiceManager isSupportSemService:Z = true and <clinit>
#   const/4 v0, 0x1 + sput-boolean isSupportSemServiceManager + "UT8.3U" / "GEMALTO" (same shape as
#   the Fold8), sem_daemon/sem_early.rc/privapp xmls/SEMFactoryApp/SamsungSeAgent all present.
_ESE_SOURCE_DISABLE_AUDITED()
{
    if [[ "$SOURCE_SECURITY_CONFIG_ESE_CHIP_VENDOR" == "NXP" ]] && \
            [[ "$SOURCE_SECURITY_CONFIG_ESE_COS_NAME" =~ ^JCOP(6\.2|7\.2)U$ ]]; then
        return 0
    fi
    if [[ "$SOURCE_SECURITY_CONFIG_ESE_CHIP_VENDOR" == "GEMALTO" ]] && \
            [[ "$SOURCE_SECURITY_CONFIG_ESE_COS_NAME" == "UT8.3U" ]] && \
            [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
        return 0
    fi
    return 1
}

if _ESE_SOURCE_DISABLE_AUDITED && \
        [[ "$TARGET_SECURITY_CONFIG_ESE_CHIP_VENDOR" == "none" ]] && [[ "$TARGET_SECURITY_CONFIG_ESE_COS_NAME" == "none" ]]; then
    if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
        # One UI 9 moved the COS literal to v0; blanking it makes mSupportEseHal false
        DECODE_APK "system" "system/app/SecureElement/SecureElement.apk"
        UTILEXT="$APKTOOL_DIR/system/app/SecureElement/SecureElement.apk/smali/com/android/se/internal/UtilExtension.smali"
        grep -q "\"$SOURCE_SECURITY_CONFIG_ESE_COS_NAME\"" "$UTILEXT" || ABORT "eSE COS literal not found in UtilExtension.smali"
        LOG "- Disabling eSE HAL support in /system/app/SecureElement/SecureElement.apk"
        sed -i -e "s|\"$SOURCE_SECURITY_CONFIG_ESE_COS_NAME\"|\"\"|g" \
            -e "s|\"eSE_COS: $SOURCE_SECURITY_CONFIG_ESE_COS_NAME\"|\"eSE_COS: \"|g" \
            -e "s|\"eSE_Vendor: $SOURCE_SECURITY_CONFIG_ESE_CHIP_VENDOR\"|\"eSE_Vendor: \"|g" "$UTILEXT"
        unset UTILEXT
    else
        APPLY_PATCH "system" "system/app/SecureElement/SecureElement.apk" \
            "$MODPATH/ese/SecureElement.apk/0001-Disable-eSE-support.patch"
    fi
    DELETE_FROM_WORK_DIR "system" "system/bin/sem_daemon"
    DELETE_FROM_WORK_DIR "system" "system/etc/init/sem.rc" 2>&1 | sed "/File not found/d"
    DELETE_FROM_WORK_DIR "system" "system/etc/init/sem_early.rc" 2>&1 | sed "/File not found/d"
    DELETE_FROM_WORK_DIR "system" "system/etc/permissions/privapp-permissions-com.samsung.android.ese.xml"
    DELETE_FROM_WORK_DIR "system" "system/etc/permissions/privapp-permissions-com.sem.factoryapp.xml"
    if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
        # Line-based One UI 8 patches don't apply to One UI 9; flip the same switches in place
        DECODE_APK "system" "system/framework/framework.jar"
        FW="$APKTOOL_DIR/system/framework/framework.jar"
        RUNE="$(grep -rl "SEM_DAEMON:Z = true" "$FW"/smali*/com/samsung/android/ProductPackagesRune.smali)"
        SSM="$(find "$FW" -path "*com/samsung/android/service/SemService/SemServiceManager.smali" | head -n 1)"
        [ "$RUNE" ] && [ "$SSM" ] || ABORT "SemService smali not found in framework.jar"
        LOG "- Disabling SemService in /system/framework/framework.jar"
        sed -i "s|SEM_DAEMON:Z = true|SEM_DAEMON:Z = false|" "$RUNE"
        sed -i "s|isSupportSemService:Z = true|isSupportSemService:Z = false|" "$SSM"
        python3 - "$SSM" "$SOURCE_SECURITY_CONFIG_ESE_COS_NAME" "$SOURCE_SECURITY_CONFIG_ESE_CHIP_VENDOR" <<'PYEOF' || ABORT "Failed to patch SemServiceManager.smali"
import re, sys
p, cos, vendor = sys.argv[1:]
s = open(p).read()
i = re.search(r"\.method static constructor (?:\w+ )*<clinit>\(\)V", s).start()
j = s.index(".end method", i)
c = s[i:j]
c, n = re.subn(r"const/4 (v\d+), 0x1(\s+sput-boolean \1, Lcom/samsung/android/service/SemService/SemServiceManager;->isSupportSemServiceManager:Z)", r"const/4 \1, 0x0\2", c)
assert n == 1, "isSupportSemServiceManager"
c = c.replace('"%s"' % cos, '""').replace('"%s"' % vendor, '""')
open(p, "w").write(s[:i] + c + s[j:])
PYEOF
        unset FW RUNE SSM
    else
        APPLY_PATCH "system" "system/framework/framework.jar" "$MODPATH/ese/framework.jar/0001-Disable-SemService.patch"
        EVAL "cp -a \"$MODPATH/framework.jar/SemService.smali\" \"$APKTOOL_DIR/system/framework/framework.jar/smali_classes6/com/android/server/SemService.smali\""
        APPLY_PATCH "system" "system/framework/services.jar" "$MODPATH/ese/services.jar/0001-Disable-SemService.patch"
    fi
    # OneUI 9 libspictrl needs eSESpiMwIpcColdResetNotice, which the OneUI 8 prebuilt lacks
    if [ "$SOURCE_PLATFORM_SDK_VERSION" -lt "37" ]; then
        ADD_TO_WORK_DIR "$([[ "$TARGET_OS_SINGLE_SYSTEM_IMAGE" == "qssi" ]] && echo "a73xqxx" || echo "a54xnsxx")" \
            "system" "system/lib/libsec_semRil.so" 0 0 644 "u:object_r:system_lib_file:s0"
    fi
    # The no-eSE prebuilts link the OneUI 8 HIDL TLC clients, which OneUI 9 (AIDL) no longer ships
    if [ "$SOURCE_PLATFORM_SDK_VERSION" -lt "37" ]; then
        ADD_TO_WORK_DIR "$([[ "$TARGET_OS_SINGLE_SYSTEM_IMAGE" == "qssi" ]] && echo "a73xqxx" || echo "a54xnsxx")" \
            "system" "system/lib/libtlc_blockchain_keystore.so" 0 0 644 "u:object_r:system_lib_file:s0"
    fi
    # The no-eSE prebuilts link the OneUI 8 HIDL TLC clients, which OneUI 9 (AIDL) no longer ships
    if [ "$SOURCE_PLATFORM_SDK_VERSION" -lt "37" ]; then
        ADD_TO_WORK_DIR "$([[ "$TARGET_OS_SINGLE_SYSTEM_IMAGE" == "qssi" ]] && echo "a73xqxx" || echo "a54xnsxx")" \
            "system" "system/lib/libtlc_payment_spay.so" 0 0 644 "u:object_r:system_lib_file:s0"
    fi
    # OneUI 9 libspictrl needs eSESpiMwIpcColdResetNotice, which the OneUI 8 prebuilt lacks
    if [ "$SOURCE_PLATFORM_SDK_VERSION" -lt "37" ]; then
        ADD_TO_WORK_DIR "$([[ "$TARGET_OS_SINGLE_SYSTEM_IMAGE" == "qssi" ]] && echo "a73xqxx" || echo "a54xnsxx")" \
            "system" "system/lib64/libsec_semRil.so" 0 0 644 "u:object_r:system_lib_file:s0"
    fi
    # The no-eSE prebuilts link the OneUI 8 HIDL TLC clients, which OneUI 9 (AIDL) no longer ships
    if [ "$SOURCE_PLATFORM_SDK_VERSION" -lt "37" ]; then
        ADD_TO_WORK_DIR "$([[ "$TARGET_OS_SINGLE_SYSTEM_IMAGE" == "qssi" ]] && echo "a73xqxx" || echo "a54xnsxx")" \
            "system" "system/lib64/libtlc_blockchain_keystore.so" 0 0 644 "u:object_r:system_lib_file:s0"
    fi
    # The no-eSE prebuilts link the OneUI 8 HIDL TLC clients, which OneUI 9 (AIDL) no longer ships
    if [ "$SOURCE_PLATFORM_SDK_VERSION" -lt "37" ]; then
        ADD_TO_WORK_DIR "$([[ "$TARGET_OS_SINGLE_SYSTEM_IMAGE" == "qssi" ]] && echo "a73xqxx" || echo "a54xnsxx")" \
            "system" "system/lib64/libtlc_payment_spay.so" 0 0 644 "u:object_r:system_lib_file:s0"
    fi
    DELETE_FROM_WORK_DIR "system" "system/priv-app/SEMFactoryApp"
    DELETE_FROM_WORK_DIR "system" "system/priv-app/SamsungSeAgent"
elif [[ "$SOURCE_SECURITY_CONFIG_ESE_CHIP_VENDOR" != "none" ]] && [[ "$SOURCE_SECURITY_CONFIG_ESE_COS_NAME" != "none" ]]; then
    if [ "$SOURCE_PLATFORM_SDK_VERSION" -eq "37" ]; then
        _ESE_PORT_ANDROID17_T2S_HIDL_STACK
    fi

    if [[ "$SOURCE_SECURITY_CONFIG_ESE_COS_NAME" != "$TARGET_SECURITY_CONFIG_ESE_COS_NAME" ]]; then
        SMALI_PATCH "system" "system/app/SecureElement/SecureElement.apk" \
            "smali/com/android/se/internal/UtilExtension.smali" "replace" \
            "<clinit>()V" \
            "$SOURCE_SECURITY_CONFIG_ESE_COS_NAME" \
            "${TARGET_SECURITY_CONFIG_ESE_COS_NAME//none/}"
    fi
    if [[ "$SOURCE_SECURITY_CONFIG_ESE_COS_NAME" != "$TARGET_SECURITY_CONFIG_ESE_COS_NAME" ]]; then
        SMALI_PATCH "system" "system/app/SecureElement/SecureElement.apk" \
            "smali/com/android/se/internal/UtilExtension.smali" "replace" \
            "supportEse(Landroid/content/Context;)Z" \
            "eSE_COS: $SOURCE_SECURITY_CONFIG_ESE_COS_NAME" \
            "eSE_COS: ${TARGET_SECURITY_CONFIG_ESE_COS_NAME//none/}"
    fi
    if [[ "$SOURCE_SECURITY_CONFIG_ESE_CHIP_VENDOR" != "$TARGET_SECURITY_CONFIG_ESE_CHIP_VENDOR" ]]; then
        SMALI_PATCH "system" "system/app/SecureElement/SecureElement.apk" \
            "smali/com/android/se/internal/UtilExtension.smali" "replace" \
            "supportEse(Landroid/content/Context;)Z" \
            "eSE_Vendor: $SOURCE_SECURITY_CONFIG_ESE_CHIP_VENDOR" \
            "eSE_Vendor: ${TARGET_SECURITY_CONFIG_ESE_CHIP_VENDOR//none/}"
    fi
    if [[ "$SOURCE_SECURITY_CONFIG_ESE_COS_NAME" != "$TARGET_SECURITY_CONFIG_ESE_COS_NAME" ]]; then
        if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge "37" ]; then
            # Android 17 prefixes the COS value in the HAL diagnostic literal;
            # use the full anchored value so a partial-token replacement cannot
            # silently affect another constant in the method.
            SMALI_PATCH "system" "system/app/SecureElement/SecureElement.apk" \
                "smali/com/android/se/internal/UtilExtension.smali" "replace" \
                "supportEseHal()Z" \
                ", eSE_COS: $SOURCE_SECURITY_CONFIG_ESE_COS_NAME" \
                ", eSE_COS: ${TARGET_SECURITY_CONFIG_ESE_COS_NAME//none/}"
        else
            SMALI_PATCH "system" "system/app/SecureElement/SecureElement.apk" \
                "smali/com/android/se/internal/UtilExtension.smali" "replace" \
                "supportEseHal()Z" \
                "$SOURCE_SECURITY_CONFIG_ESE_COS_NAME" \
                "${TARGET_SECURITY_CONFIG_ESE_COS_NAME//none/}"
        fi
    fi
    if [[ "$SOURCE_SECURITY_CONFIG_ESE_CHIP_VENDOR" != "$TARGET_SECURITY_CONFIG_ESE_CHIP_VENDOR" ]]; then
        SMALI_PATCH "system" "system/framework/framework.jar" \
            "smali_classes6/com/android/server/SemService.smali" "replaceall" \
            "$SOURCE_SECURITY_CONFIG_ESE_CHIP_VENDOR" \
            "${TARGET_SECURITY_CONFIG_ESE_CHIP_VENDOR//none/}"
    fi
    if [[ "$SOURCE_SECURITY_CONFIG_ESE_COS_NAME" != "$TARGET_SECURITY_CONFIG_ESE_COS_NAME" ]]; then
        SMALI_PATCH "system" "system/framework/framework.jar" \
            "smali_classes6/com/android/server/SemService.smali" "replaceall" \
            "$SOURCE_SECURITY_CONFIG_ESE_COS_NAME" \
            "${TARGET_SECURITY_CONFIG_ESE_COS_NAME//none/}"
    fi
    if [[ "$SOURCE_SECURITY_CONFIG_ESE_CHIP_VENDOR" != "$TARGET_SECURITY_CONFIG_ESE_CHIP_VENDOR" ]]; then
        SMALI_PATCH "system" "system/framework/framework.jar" \
            "smali_classes6/com/samsung/android/service/SemService/SemServiceManager.smali" "replaceall" \
            "$SOURCE_SECURITY_CONFIG_ESE_CHIP_VENDOR" \
            "${TARGET_SECURITY_CONFIG_ESE_CHIP_VENDOR//none/}"
    fi
    if [[ "$SOURCE_SECURITY_CONFIG_ESE_COS_NAME" != "$TARGET_SECURITY_CONFIG_ESE_COS_NAME" ]]; then
        SMALI_PATCH "system" "system/framework/framework.jar" \
            "smali_classes6/com/samsung/android/service/SemService/SemServiceManager.smali" "replaceall" \
            "$SOURCE_SECURITY_CONFIG_ESE_COS_NAME" \
            "${TARGET_SECURITY_CONFIG_ESE_COS_NAME//none/}"
    fi
    if [[ "$SOURCE_SECURITY_CONFIG_ESE_CHIP_VENDOR" != "$TARGET_SECURITY_CONFIG_ESE_CHIP_VENDOR" ]]; then
        SMALI_PATCH "system" "system/framework/services.jar" \
            "smali_classes2/com/samsung/ucm/ucmservice/CredentialManagerService.smali" "replaceall" \
            "$SOURCE_SECURITY_CONFIG_ESE_CHIP_VENDOR" \
            "${TARGET_SECURITY_CONFIG_ESE_CHIP_VENDOR//none/}"
    fi
else
    LOG_MISSING_PATCHES "SOURCE_SECURITY_CONFIG_ESE_CHIP_VENDOR" "TARGET_SECURITY_CONFIG_ESE_CHIP_VENDOR" || true
    LOG_MISSING_PATCHES "SOURCE_SECURITY_CONFIG_ESE_COS_NAME" "TARGET_SECURITY_CONFIG_ESE_COS_NAME"
fi

unset -f LOG_MISSING_PATCHES _ESE_ASSERT_SHA256 _ESE_ASSERT_FIXED_COUNT \
    _ESE_ASSERT_BINARY_COUNT _ESE_ASSERT_BINARY_OFFSET _ESE_ASSERT_NEEDED \
    _ESE_ASSERT_INTERPRETER64 \
    _ESE_GET_EXPORTS _ESE_ASSERT_EXPORT_ABI _ESE_ASSERT_CONSUMER_PROVIDER_ABI \
    _ESE_REPLACE_EXACT_LINE _ESE_PORT_ANDROID17_T2S_HIDL_STACK _ESE_SOURCE_DISABLE_AUDITED
