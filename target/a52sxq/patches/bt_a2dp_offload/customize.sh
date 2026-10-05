# com.android.bt.apex from the source firmware with app/Bluetooth@<build>/Bluetooth.apk patched: A2dpService.isOffloadSupportedCodec(I)Z
# also returns true for Samsung codec ids 0x2 (AAC), 0x10 (aptX HD) and 0x40 (LDAC); SBC/aptX/SSC/hifi keep the stock prop logic.
# A2dpServiceHelper.updateBtDevToAudio(): the "HQ audio" codec state (LDAC/SSC enabled for the device) no longer forces the
# software (hifi) path, which this vendor cannot drive.
# Rebuilt with rebuild_apex.sh (ext4 payload unshared + grown, AVB hashtree re-signed with ../tethering/keys/payload.pem,
# container signed with ../tethering/keys/container.*). The inner APK is signed with security/aosp_platform like every other
# system app of this build. Must be regenerated whenever the source firmware (and thus Bluetooth.apk) changes.
if [[ "$SOURCE_FIRMWARE" != "SM-F976B/"* ]] || [[ "$(GET_PROP "system" "ro.build.id")" != "CP2A.260605.016" ]]; then
    ABORT "bt_a2dp_offload: prebuilt com.android.bt.apex was made for SM-F976B CP2A.260605.016; run rebuild_apex.sh for this source"
fi
DELETE_FROM_WORK_DIR "system" "system/apex/com.android.bt.apex"
EVAL "cp -a \"$SRC_DIR/target/a52sxq/patches/bt_a2dp_offload/com.android.bt.apex\" \"$WORK_DIR/system/system/apex/com.android.bt.apex\""
SET_METADATA "system" "system/apex/com.android.bt.apex" 0 0 644 "u:object_r:system_file:s0"
LOG "- Replaced com.android.bt.apex with the all-codec A2DP offload build"
