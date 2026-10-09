# Copyright (c) 2026 kusti420
# SPDX-License-Identifier: GPL-3.0-or-later

# Debloat list for Galaxy A52s 5G (a52sxq)
# - Add entries inside the specific partition containing that file (<PARTITION>_DEBLOAT+="")
# - DO NOT add the partition name at the start of any entry (eg. "/system/dpolicy_system")
# - DO NOT add a slash at the start of any entry (eg. "/dpolicy_system")

# Qualcomm QCC / QDMA device-management + SMQ telemetry agent (com.qti.qcc, persistent): needs the vendor
# IQccvndhal that the A52s vendor doesn't ship ("Qccvndhal is not found in either HIDL or AIDL"). Not on stock A52s.
SYSTEM_EXT_DEBLOAT+="
app/QCC
bin/qccsyshal_aidl-service
etc/init/vendor.qti.qccsyshal_aidl-service.rc
etc/permissions/com.qti.qcc.vendor_qcc.xml
etc/vintf/manifest/vendor.qti.qccsyshal_aidl-service.xml
lib64/libqcc.so
lib64/libqcc_file_agent_sys.so
lib64/libqccdme.so
lib64/libqccfileservice.so
lib64/vendor.qti.hardware.qccsyshal@1.0.so
lib64/vendor.qti.hardware.qccsyshal@1.1.so
lib64/vendor.qti.hardware.qccsyshal@1.2.so
lib64/vendor.qti.hardware.qccvndhal@1.0.so
lib64/vendor.qti.qccsyshal_aidl-V1-ndk.so
lib64/vendor.qti.qccsyshal_aidl-halimpl.so
lib64/vendor.qti.qccvndhal_aidl-V1-ndk.so
lib64/vendor.qti.qccvndhal_aidl-V2-ndk.so
"

# Qualcomm NTN satellite stack: the SM7325 modem has no NTN. The S25 (SM-S931B) no longer ships the NtnSatApp
# (vendor.qti.data.ntnsatapp) but still carries its now-orphaned jar/JNI/SDK libs (they only reference each other).
# android.telephony.satellite (SatelliteClient.jar) is an AOSP shared library apps link against: kept.
SYSTEM_EXT_DEBLOAT+="
framework/vendor.qti.data.ntn-V1-java.jar
framework/vendor.qti.data.ntn-V1-java.jar.fsv_meta
lib64/libNtnJni.so
lib64/libQmsNtnProto.so
lib64/libqms_ntnsatellite_sdk.so
"

# SM8750 (Adreno 830) updatable GPU driver (com.samsung.gamedriver.sm8750). Only the S25 vendor sets
# ro.gfx.driver.0 to it; the A52s vendor doesn't (cf. GameDriver-SM8450 in platform/sm7325)
SYSTEM_DEBLOAT+="
system/priv-app/GameDriver-SM8750
"

# Knox KPP / NGK audit: run as vendor_ker, an OEM AID the A52s vendor/etc/passwd doesn't define, so init
# rejects the service and the chown fails. Not on stock A52s.
SYSTEM_DEBLOAT+="
system/bin/ngk_security_audit
system/etc/init/kpp.init.rc
system/etc/init/ngk_security_audit_common.rc
system/lib64/libngkms.so
"

# Galaxy Z Fold8 (SM-F976B / China SM-F9760, still the a52sxq_cn source) and Galaxy S26 Ultra (SM-S948B) leftovers that
# the S25 (SM-S931B) source doesn't ship. Entries a source doesn't have are skipped.
if [[ "$SOURCE_FIRMWARE" == "SM-F976"* || "$SOURCE_FIRMWARE" == "SM-S948"* ]]; then
    # Qualcomm NTN satellite service (vendor.qti.data.ntnsatapp, persistent ".dataservices"): telephony never binds it
    # ("Unable to bind to the satellite service because the package is undefined")
    SYSTEM_EXT_DEBLOAT+="
app/NtnSatApp
"
    # SM8850 (Adreno 840) updatable GPU driver stub
    SYSTEM_DEBLOAT+="
system/priv-app/GameDriver-SM8850
"
    # Wi-Fi RTT: stock A52s doesn't declare it; SystemServer only starts RttService when the feature is present
    SYSTEM_DEBLOAT+="
system/etc/permissions/android.hardware.wifi.rtt.xml
"
    # UWB test app + RRO (no UWB on A52s). The com.android.uwb apex (also on stock), com.samsung.android.uwb_extras.jar
    # (BOOTCLASSPATH) and semuwb-service.jar (SYSTEMSERVERCLASSPATH) MUST stay.
    SYSTEM_DEBLOAT+="
system/app/UwbTest
system/etc/permissions/privapp-permissions-com.sec.android.app.uwbtest.xml
system/etc/init/digitalkey_init_uwb_tss2.rc
"
    PRODUCT_DEBLOAT+="
overlay/UwbRROverlay.apk
"
fi

# Galaxy S26 Ultra (SM-S948B) only services that can't run on SM7325:
# - DckTimeSyncService: UWB digital car key time sync (no UWB); no other package uses its library
# - AIOSKernelService: loads libQnnHtpV81Skel.so (SM8850 Hexagon NPU)
# - VideoScan: boot-time scan job on SM8850 SNPE models (mediacontextanalyzer/*SM8850*.dlc)
if [[ "$SOURCE_FIRMWARE" == "SM-S948"* ]]; then
    SYSTEM_EXT_DEBLOAT+="
priv-app/DckTimeSyncService
framework/org.carconnectivity.android.digitalkey.timesync.jar
"
    SYSTEM_DEBLOAT+="
system/etc/permissions/org.carconnectivity.android.digitalkey.timesync.xml
system/etc/permissions/privapp-permissions-com.samsung.android.dcktimesync.xml
system/priv-app/AIOSKernelService
system/etc/permissions/privapp-permissions-com.samsung.android.aioskernelservice.xml
system/priv-app/VideoScan
system/etc/permissions/privapp-permissions-com.samsung.videoscan.xml
system/etc/default-permissions/default-permissions-com.samsung.videoscan.xml
"
fi
