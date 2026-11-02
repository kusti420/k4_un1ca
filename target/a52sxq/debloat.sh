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

# Galaxy S26 Ultra on-device AI indexers that run on the CPU here and scale with the user's data (2026-11-02 heat hunt;
# neither app is on stock A52s). Their callers check that the package is installed (Story, Smart Suggestions);
# post_mods.sh deletes the matching floating features.
# - MediaSearch (com.samsung.mediasearch, Gallery natural-language search): 95 MB image-embedding TFLite on 4 CPU
#   threads, no NPU/GPU delegate, job every 15 min indexing the whole gallery + videos (up to 1000 items/run on charge)
# - MFContents (com.samsung.mfcontents, "My favorite contents"): per-photo feature vectors + on-device training
if [[ "$SOURCE_FIRMWARE" == "SM-S948"* ]]; then
    SYSTEM_DEBLOAT+="
system/priv-app/MediaSearch
system/etc/permissions/privapp-permissions-com.samsung.mediasearch.xml
system/etc/default-permissions/default-permissions-com.samsung.mediasearch.xml
system/etc/sysconfig/preinstalled-packages-com.samsung.mediasearch.xml
system/priv-app/MFContents
system/etc/mfcontents
system/etc/permissions/privapp-permissions-com.samsung.mfcontents.xml
system/etc/default-permissions/default-permissions-com.samsung.mfcontents.xml
system/etc/sysconfig/preinstalled-packages-com.samsung.mfcontents.xml
"
fi

# On-device Gauss LLM (com.samsung.android.offline.languagemodel): unica already drops the S26 store stub and there is
# no SM7325 runtime for it (see post_mods.sh); its leftover preinstall whitelist goes too
SYSTEM_DEBLOAT+="
system/etc/sysconfig/preinstalled-packages-com.samsung.android.offline.languagemodel.xml
"

# Link to Windows: keep the S26 Ultra's Microsoft app (YourPhone_P1_5, com.microsoft.appmanager, ~84 MB). unica drops
# it on One UI 9 without importing a stub, and the S26 Ultra LinkToWindowsService (com.samsung.android.mdx) then
# answers every entry point (Connected devices > Link to Windows, the quick panel tile) with "To use Link to Windows,
# enable the Link to Windows app in Settings": SystemRepository.isPackageEnabled() is false for a package that is not
# installed. Its privapp-permissions and preload allowlist entries are still in the base. Super has ~2 GB spare.
LTW_DEBLOAT_ENTRY="system/priv-app/YourPhone_P1_5"
grep -q -x -F "$LTW_DEBLOAT_ENTRY" <<< "$SYSTEM_DEBLOAT" || ABORT "debloat: $LTW_DEBLOAT_ENTRY is no longer in the unica list, re-check Link to Windows"
[ -f "$WORK_DIR/system/$LTW_DEBLOAT_ENTRY/YourPhone_P1_5.apk" ] || ABORT "debloat: no $LTW_DEBLOAT_ENTRY in this base"
[ -f "$WORK_DIR/system/system/etc/permissions/privapp-permissions-com.microsoft.appmanager.xml" ] \
    || ABORT "debloat: privapp-permissions-com.microsoft.appmanager.xml missing, Link to Windows would not get its permissions"
SYSTEM_DEBLOAT="$(grep -v -x -F "$LTW_DEBLOAT_ENTRY" <<< "$SYSTEM_DEBLOAT")"
LOG "- Keeping the Link to Windows app (com.microsoft.appmanager)"
unset LTW_DEBLOAT_ENTRY
