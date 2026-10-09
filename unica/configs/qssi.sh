# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# UN1CA configuration file for Snapdragon devices (qssi)

# Galaxy S26 Ultra SM-S948B EUX S948BXXS4BZIG (CP2A.260605.016, SDK 37; switched from the S25 SM-S931B on 2026-10-09:
# same Android build). The IMEI field is only a TAC (samloader completes it); the firmware is pre-downloaded/extracted
# in out/fw/SM-S948B_EUX.
#
# Every SOURCE_* value below was re-derived on 2026-10-09 from out/fw/SM-S948B_EUX: the literal the consuming
# SMALI_PATCH/REQUIRE_* searches for was read from the S26 Ultra smali (decoded into ~/.cache/s26u_smali: framework.jar,
# services.jar, ssrm.jar, semwifi-service.jar, telephony-common.jar, secinputdev-service.jar, esecomm.jar,
# SecSettings.apk, SettingsProvider.apk, SystemUI.apk, SecureElement.apk, SamsungDeviceHealthManagerService.apk),
# every patch-referenced smali was diffed against the S25 decode (~/.cache/s25smali) and cross-checked against
# system/etc/floating_feature.xml and the build.props; all unica/patches were then dry-run against the S26U tree
# with these values (no ABORT / LOG_MISSING_PATCHES / failed SMALI_PATCH).
# Values that are not a smali literal and could not be verified one-to-one (kept, see why):
# - SOURCE_LCD_CONFIG_COLOR_WEAKNESS_SOLUTION: not compiled in as a literal; only used as "!= 0" in product_feature.
#   The S26U A11yRune (DMC_COLORWEAKNESS) is byte-identical to the S25 one and SemMdnieManagerService only differs
#   in its .source line -> 3 kept (upstream S25 Ultra config uses 3 as well).
# - SOURCE_BLUETOOTH_SUPPORT_*: not consumed by any script (unica/patches/bluetooth has no profile patches any more).
#   The S26U Bluetooth.apk (com.android.bt.apex) only differs from the S25 one by the removed AdapterService$6
#   "[BT SAR]HEAD" receiver (HEAD_SAR_BACKOFF compiled out -> false); AdapterService mAccelerSensor,
#   A2dpService$AudioManagerAudioDeviceCallback and the a2dpsink classes are unchanged -> kept.
# - SOURCE_WLAN_SUPPORT_LOWLATENCY / TWT_CONTROL: on API 37 these come from the vendor feature string; the S26U
#   WifiDriverFeatureProvider only differs from the S25 one in its .source line -> kept true.
# - SOURCE_FRAMEWORK_SUPPORT_FOLDABLE_TYPE_FOLD / HALF_FOLDED_MODE, SOURCE_LCD_CONFIG_SUB_HFR_*, SOURCE_CAMERA_APP_FLAVOR:
#   not consumed by any script; set from the S26U floating_feature.xml / SamsungCamera.apk (all entries except
#   SEC-INF/buildinfo.xml and the signature are CRC-identical to the S25 hal3-release build).
SOURCE_FIRMWARE="SM-S948B/EUX/35003251"
SOURCE_EXTRA_FIRMWARES=()
# system/build.prop ro.build.version.sdk=37
SOURCE_PLATFORM_SDK_VERSION=37
# vendor/build.prop ro.product.first_api_level=36; "36" in EsecommAdapter, HdmSakManager, TAProxy, SystemServer
# ("MAINLINE_API_LEVEL: 36"), PowerManagerUtil, EngmodeService$EngmodeTimeThread
SOURCE_PRODUCT_SHIPPING_API_LEVEL=36
# vendor/build.prop ro.board.api_level=202504 / ro.board.first_api_level=202504 (Android 16 vendor API)
SOURCE_BOARD_API_LEVEL=36

# SEC Product Feature
# framework.jar SemMultiMicManager.isSupported()/isSupported(I) "08030"
SOURCE_AUDIO_CONFIG_RECORDALIVE_LIB_VERSION="08030"
# framework.jar audio/Rune.<clinit> sput-boolean v2 (true) SEC_AUDIO_SUPPORT_ACH_RINGTONE, VibRune SUPPORT_ACH:Z = true
# (both files byte-identical to the S25)
SOURCE_AUDIO_SUPPORT_ACH_RINGTONE=true
# floating_feature SEC_FLOATING_FEATURE_AUDIO_SUPPORT_DUAL_SPEAKER=TRUE; audio/Rune SEC_AUDIO_SUPPORT_DUAL_SPEAKER:Z = true
SOURCE_AUDIO_SUPPORT_DUAL_SPEAKER=true
# audio/Rune + VibRune ...VIRTUAL_VIBRATION_SOUND:Z = true
SOURCE_AUDIO_SUPPORT_VIRTUAL_VIBRATION_SOUND=true
SOURCE_BLUETOOTH_SUPPORT_A2DPSINK_PROFILE=true
SOURCE_BLUETOOTH_SUPPORT_A2DP_SBM=false
SOURCE_BLUETOOTH_SUPPORT_HEAD_SAR_BACKOFF=false
SOURCE_BLUETOOTH_SUPPORT_XLNA_CONTROL=true
# os_partitions_metadata.txt super_partition_group=qti_dynamic_partitions
SOURCE_SUPER_GROUP_NAME="qti_dynamic_partitions"
# floating_feature: no FOLDABLE_TYPE_FOLD / HALF_FOLDED_MODE keys (SIP_CONFIG_FOLD_UX_VERSION=0), SUB_HFR_MODE=0,
# no SUB_HFR_SUPPORTED_REFRESH_RATE
SOURCE_FRAMEWORK_SUPPORT_FOLDABLE_TYPE_FOLD=false
SOURCE_FRAMEWORK_SUPPORT_HALF_FOLDED_MODE=false
SOURCE_LCD_CONFIG_SUB_HFR_MODE="0"
SOURCE_LCD_CONFIG_SUB_HFR_SUPPORTED_REFRESH_RATE="none"
# SamsungCamera.apk: same hal3-release build as the S25 (SamsungCamera-1743000-17.0.00), see above
SOURCE_CAMERA_APP_FLAVOR="hal3-release"
# system/etc/permissions/sec_camerax_*.xml, sec_camerax_impl.jar, ro.camerax.extensions.enabled=true
SOURCE_CAMERA_SUPPORT_CAMERAX_EXTENSION=true
# SystemUI res/values/bools.xml config_enableDisplayCutoutProtection=false, framework-res__m3qxxx RRO does not override it
SOURCE_CAMERA_SUPPORT_CUTOUT_PROTECTION=false
# not the hal3_mass flavor (see SOURCE_CAMERA_APP_FLAVOR)
SOURCE_CAMERA_SUPPORT_MASS_APP_FLAVOR=false
# cameraservice.xml, scamera_sep.jar, priv-app/SCameraSDKService present
SOURCE_CAMERA_SUPPORT_SDK_SERVICE=true
# services.jar SemMdnieManagerService.<init>(Context) "65303"; floating COMMON_CONFIG_MDNIE_MODE=65303
SOURCE_COMMON_CONFIG_MDNIE_MODE="65303"
# floating: COMMON_CONFIG_DYN_RESOLUTION_CONTROL=WQHD,FHD,HD on the S26 Ultra
SOURCE_COMMON_SUPPORT_DYN_RESOLUTION_CONTROL=true
# floating COMMON_CONFIG_EMBEDDED_SIM_SLOTSWITCH=tsds2
SOURCE_COMMON_SUPPORT_EMBEDDED_SIM=true
# floating COMMON_SUPPORT_HDR_EFFECT=TRUE
SOURCE_COMMON_SUPPORT_HDR_EFFECT=true
# ssrm.jar Feature.<clinit> "dvfs_policy_default"; SDHMS <clinit> + <init>(Context) "dvfs_policy_default"
SOURCE_DVFSAPP_CONFIG_DVFS_POLICY_FILENAME="dvfs_policy_default"
# ssrm.jar Feature.<clinit> + SDHMS <clinit> "siop_m3q_sm8850"; floating SYSTEM_CONFIG_SIOP_POLICY_FILENAME
SOURCE_DVFSAPP_CONFIG_SSRM_POLICY_FILENAME="siop_m3q_sm8850"
# framework.jar SemFingerprintManager getMaxTemplateNumberFromSPF/getProductFeatureValue + $Characteristics;
# floating BIOAUTH_CONFIG_FINGERPRINT_FEATURES=ultrasonic_display_phone
SOURCE_FINGERPRINT_CONFIG_SENSOR="google_touch_display_ultrasonic"
SOURCE_LCD_CONFIG_COLOR_WEAKNESS_SOLUTION="3"
# services.jar PowerManagerUtil.<clinit> "5", ssrm.jar PreMonitor.getBrightness "5"; floating =5
SOURCE_LCD_CONFIG_CONTROL_AUTO_BRIGHTNESS="5"
# SecDisplayUtils.getHighRefreshRateDefaultValue, SettingsProvider loadRefreshRateMode "120"; floating =120
SOURCE_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE="120"
# "4" in RefreshRateConfig dumpProductFeature/getMainInstance, SemImsRune, CoreRune, SemInputFeatures(+Extra),
# PowerManagerUtil, SecDisplayUtils, SettingsProvider, SystemUI BasicRune/LsRune; floating HFR_MODE=4
SOURCE_LCD_CONFIG_HFR_MODE="4"
# RefreshRateConfig, SecDisplayUtils, SystemUI KeyguardViewMediatorHelperImpl$$ExternalSyntheticLambda0; floating =1,60,120
SOURCE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE="1,60,120"
# RefreshRateConfig.getMainInstance passes "" for NS and both brightness thresholds (no floating keys)
SOURCE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE_NS="none"
SOURCE_LCD_CONFIG_SEAMLESS_BRT="none"
SOURCE_LCD_CONFIG_SEAMLESS_LUX="none"
# floating LCD_SUPPORT_MDNIE_HW=TRUE
SOURCE_LCD_SUPPORT_MDNIE_HW=true
# SecureElement UtilExtension "JCOP7.2U" / "eSE_Vendor: NXP", framework SemServiceManager.<clinit> + SemService fields
SOURCE_SECURITY_CONFIG_ESE_CHIP_VENDOR="NXP"
SOURCE_SECURITY_CONFIG_ESE_COS_NAME="JCOP7.2U"
# framework.jar TelephonyFeatures RIL_FEATURES (TelephonyFeatures byte-identical to the S25)
SOURCE_RIL_FEATURES="onebinary entitlement_sa"
# framework.jar TelephonyFeatures.isOneTray() identical to the S25/Fold8 (single tray + eSIM)
SOURCE_RIL_SIM_CONFIG_MULTISIM_TRAYCOUNT="1"
# telephony-common UiccController "waterproof" extra = 0x1 (UiccController identical to the S25)
SOURCE_RIL_SUPPORT_WATERPROOF_SIM_TRAY_MSG=true
# semwifi-service SemWifiInjector.<init> ConnectionPersonalizer gate "3"; SecSettings BtmController "3"
SOURCE_WLAN_CONFIG_CONNECTION_PERSONALIZATION="3"
# SemFrameworkFacade.getBoosterThresholds parses "0" for all three
SOURCE_WLAN_CONFIG_CPU_CSTATE_DISABLE_THRESHOLD="0"
# SemWifiCoexManager CUSTOM_BACKOFF_TYPE
SOURCE_WLAN_CONFIG_CUSTOM_BACKOFF="CAM_BACK -1 -1 -1 -1 14 13 UWB_5G_CX 36 177 UWB_6G_CX 1 233 UWB_CX_CH 2 5 9 UWB_CX_TYPE 1 1"
SOURCE_WLAN_CONFIG_DATA_ACTIVITY_AFFINITY_BOOSTER_THRESHOLD="0"
# SemWifiInjector.<init> SemWifiResourceManager gate "5"; SemWifiResourceManager.<init> "5"
SOURCE_WLAN_CONFIG_DYNAMIC_SWITCH="5"
SOURCE_WLAN_CONFIG_L1SS_DISABLE_THRESHOLD="0"
# SemSoftApConfiguration SPF_* diagnostics (SPF_11ax/6G/DualAp/Concurrency/OWE/Prio_Traffic=true, SPF_WS_Lite=false,
# SPF_POWER_SAVEMODE=true), SemFrameworkFacade isMBOSupported/isWifiToCellularSupported -> true,
# SemWifiServiceImpl getNumOfWifiAnt -> 2
SOURCE_WLAN_SUPPORT_80211AX=true
SOURCE_WLAN_SUPPORT_80211AX_6GHZ=true
SOURCE_WLAN_SUPPORT_APE_SERVICE=true
SOURCE_WLAN_SUPPORT_LOWLATENCY=true
SOURCE_WLAN_SUPPORT_MBO=true
SOURCE_WLAN_SUPPORT_MIMO=true
# SemSoftApConfiguration "SPF_5G_BASEDON_COUNTRY=true"; SemWifiApServiceImpl.supportWifiAp5GBasedOnCountry() falls back to
# isRegionFor5GCountry() when the secure setting is missing/"na" (the S25 returned false there)
SOURCE_WLAN_SUPPORT_MOBILEAP_5G_BASEDON_COUNTRY=true
SOURCE_WLAN_SUPPORT_MOBILEAP_6G=true
SOURCE_WLAN_SUPPORT_MOBILEAP_DUALAP=true
SOURCE_WLAN_SUPPORT_MOBILEAP_OWE=true
SOURCE_WLAN_SUPPORT_MOBILEAP_POWER_SAVEMODE=true
SOURCE_WLAN_SUPPORT_MOBILEAP_PRIORITIZE_TRAFFIC=true
SOURCE_WLAN_SUPPORT_MOBILEAP_WIFI_CONCURRENCY=true
SOURCE_WLAN_SUPPORT_MOBILEAP_WIFISHARING_LITE=false
# SemWifiConnectivityMonitor identical to the S25 (individual_apps patch anchors present)
SOURCE_WLAN_SUPPORT_SWITCH_FOR_INDIVIDUAL_APPS=true
SOURCE_WLAN_SUPPORT_TWT_CONTROL=true
SOURCE_WLAN_SUPPORT_WIFI_TO_CELLULAR=true
