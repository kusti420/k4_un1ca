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

# Qualcomm NTN satellite service (vendor.qti.data.ntnsatapp, persistent ".dataservices"): the SM7325 modem has no
# NTN and telephony never binds it ("Unable to bind to the satellite service because the package is undefined").
# android.telephony.satellite (SatelliteClient.jar) is an AOSP shared library apps link against: kept.
SYSTEM_EXT_DEBLOAT+="
app/NtnSatApp
framework/vendor.qti.data.ntn-V1-java.jar
framework/vendor.qti.data.ntn-V1-java.jar.fsv_meta
lib64/libNtnJni.so
lib64/libQmsNtnProto.so
lib64/libqms_ntnsatellite_sdk.so
"

# SM8850 (Adreno 840) updatable GPU driver stub, ro.gfx.driver.0 unset (cf. GameDriver-SM8450 in platform/sm7325)
SYSTEM_DEBLOAT+="
system/priv-app/GameDriver-SM8850
"

# Knox KPP / NGK audit: run as vendor_ker, an OEM AID the A52s vendor/etc/passwd doesn't define, so init
# rejects the service and the chown fails. Not on stock A52s.
SYSTEM_DEBLOAT+="
system/bin/ngk_security_audit
system/etc/init/kpp.init.rc
system/etc/init/ngk_security_audit_common.rc
system/lib64/libngkms.so
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
