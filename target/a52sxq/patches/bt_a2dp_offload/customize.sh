# com.android.bt.apex from the source firmware with app/Bluetooth@<build>/Bluetooth.apk patched: A2dpService.isOffloadSupportedCodec(I)Z
# also returns true for Samsung codec ids 0x2 (AAC), 0x10 (aptX HD) and 0x40 (LDAC); SBC/aptX/SSC/hifi keep the stock prop logic.
# A2dpServiceHelper.updateBtDevToAudio(): the "HQ audio" codec state (LDAC/SSC enabled for the device) no longer forces the
# software (hifi) path, which this vendor cannot drive.
# Rebuilt with rebuild_apex.sh (ext4 payload unshared + grown, AVB hashtree re-signed with ../tethering/keys/payload.pem,
# container signed with ../tethering/keys/container.*). The inner APK is signed with security/aosp_platform like every other
# system app of this build. Must be regenerated whenever the source firmware (and thus Bluetooth.apk) changes.
#
# Current prebuilt: regenerated 2026-10-09 from the Galaxy S25 SM-S931B One UI 9 S931BXXUCDZIF (CP2A.260605.016)
#   source com.android.bt.apex sha256 e5ff03d5e8e5b0a35cf5d483570ed0edcf0595669067ef22aca1ed80bb7d879b (version 370399999)
#   shipped  com.android.bt.apex sha256 b5c70b90f4de8db4247a3be7f66a7a9a6192b05210815c9138ab430faf9c5332
# Verified: only app/Bluetooth@CP2A.260605.016/Bluetooth.apk differs from the S25 payload; the smali diff (2 files of code:
# the 3-codec guard in isOffloadSupportedCodec and "const/4 v6, 0x0" after checkHqCodecState) is byte-identical to the
# Fold8 (F976BXXU1AZFW, source sha256 da4f2353...) prebuilt's diff; same AVB key/algorithm, container cert and inner cert.
# The S25 product build.prop carries the same persist.bluetooth.samsung.a2dp_offload.cap=sbc-aptx-ssc-hifi and
# bluetooth.hfp.swb.supported=true as the Fold8, so the prop overrides below are still needed.
# The guard pins the exact source APEX: any other source (or another S25 build) must re-run rebuild_apex.sh and update
# BT_A2DP_SOURCE_APEX_SHA256.
BT_A2DP_SOURCE_APEX_SHA256="e5ff03d5e8e5b0a35cf5d483570ed0edcf0595669067ef22aca1ed80bb7d879b"
BT_A2DP_SOURCE_APEX="$FW_DIR/$(cut -d "/" -f 1 -s <<< "$SOURCE_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$SOURCE_FIRMWARE")/system/system/apex/com.android.bt.apex"
if [[ "$SOURCE_FIRMWARE" != "SM-S931B/"* ]] || [[ "$(GET_PROP "system" "ro.build.id")" != "CP2A.260605.016" ]]; then
    ABORT "bt_a2dp_offload: prebuilt com.android.bt.apex was made for SM-S931B CP2A.260605.016; run rebuild_apex.sh for this source"
fi
if [ ! -f "$BT_A2DP_SOURCE_APEX" ] || \
        [[ "$(sha256sum "$BT_A2DP_SOURCE_APEX" | cut -d " " -f 1)" != "$BT_A2DP_SOURCE_APEX_SHA256" ]]; then
    ABORT "bt_a2dp_offload: source com.android.bt.apex is not the S931BXXUCDZIF one the prebuilt was made from; run rebuild_apex.sh for this source"
fi
unset BT_A2DP_SOURCE_APEX_SHA256 BT_A2DP_SOURCE_APEX
DELETE_FROM_WORK_DIR "system" "system/apex/com.android.bt.apex"
EVAL "cp -a \"$SRC_DIR/target/a52sxq/patches/bt_a2dp_offload/com.android.bt.apex\" \"$WORK_DIR/system/system/apex/com.android.bt.apex\""
SET_METADATA "system" "system/apex/com.android.bt.apex" 0 0 644 "u:object_r:system_file:s0"
LOG "- Replaced com.android.bt.apex with the all-codec A2DP offload build"

# The Bluetooth app builds its offload codec list from persist.bluetooth.samsung.a2dp_offload.cap. The source (Fold8, and
# the S25 too) product/etc/build.prop sets the flagship DSP set "sbc-aptx-ssc-hifi", so AAC, aptX HD and LDAC were never offload
# candidates: the native stack kept a software session (IsCodecOffloadingEnabled: software codec={LDAC}) that this
# vendor's audio HAL never reports ready for ("A2DP profile is not ready") and LDAC/AAC headsets stayed silent.
# Use the A52s DSP set from persist.vendor.bt.a2dp_offload_cap (sbc-aptx-aptxtws-aptxhd-aac-ldac) in Samsung's tokens,
# plus Samsung's own SSC (Galaxy Buds) codec: the vendor offload library has an SSC encoder. "hifi" (0x100) is left out: the
# vendor offload library has no hifi/UHQ encoder (no "hifi" strings in liba2dpoffload/libbthost_if). SSC: "Received SSC encoder supported BT device".
# Without "ssc" here A2dpService.isOffloadSupportedCodec(0x80) is false and SSC headsets get the (silent) software path.
BT_OFFLOAD_CAP="sbc-aac-aptx-aptx_hd-ldac-ssc"
SET_PROP "product" "persist.bluetooth.samsung.a2dp_offload.cap" "$BT_OFFLOAD_CAP"
# A value stored in /data/property by an earlier build would win over build.prop; re-apply once persist props are loaded.
cat > "$WORK_DIR/system/system/etc/init/a52sxq_bt_offload.rc" << RCEOF
# A52s A2DP offload codec set for the One UI 9 Bluetooth app. See the a52sxq_bt_a2dp_offload patch.
on property:ro.persistent_properties.ready=true
    setprop persist.bluetooth.samsung.a2dp_offload.cap $BT_OFFLOAD_CAP
RCEOF
SET_METADATA "system" "system/etc/init/a52sxq_bt_offload.rc" 0 0 644 "u:object_r:system_file:s0"
LOG "- A2DP offload codec set: $BT_OFFLOAD_CAP"
unset BT_OFFLOAD_CAP

# HFP super-wideband: the source (Fold8, S25) product build.prop sets bluetooth.hfp.swb.supported=true, so the One UI 9 stack offers
# LC3/aptX super-wideband voice and, once a headset accepts it, tells the HAL "bt_lc3_swb=on;g_sco_samplerate=32000".
# The A52s A14 audio HAL / DSP never did 32 kHz SCO: it doesn't know bt_lc3_swb, and its bt_swb key is an aptX speech
# mode parsed with atoi, so translating on/off would turn SWB mode 0 on in both cases. Stock A14 doesn't set the prop
# (false) and calls use mSBC wideband (16 kHz). Match stock so calls on SWB-capable headsets keep working.
SET_PROP "product" "bluetooth.hfp.swb.supported" "false"
LOG "- HFP super-wideband voice disabled (A14 HAL has no 32 kHz SCO)"
