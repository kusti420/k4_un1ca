# De-Googled variant: strip the Google services stack from the global Fold8 base. The China (CHC) firmware was
# checked as an alternative base on 2026-10-04 and ships the very same GSF/Play Store/GmsCore APEX, so removing them
# here gives the same result without re-matching every binary patch against different F9760 binaries.
# Deliberately kept: Google-signed mainline APEXes (the platform's own modules), NetworkStackGoogle,
# CaptivePortalLoginGoogle, DocumentsUIGoogle, GooglePackageInstaller, the permission controller overlays,
# GoogleExtServicesConfigOverlay/HealthFitness/ModuleMetadata overlays (module config) and WebViewGoogle64 +
# TrichromeLibrary64, since the firmware has no other WebView provider. GmsConfigOverlayCommon (which pointed
# config_webview_packages at Google WebView) is removed, so the target framework-res overlay now carries that list.
LOG_STEP_IN "- Removing the Google services stack"

_DEGOOGLE_DELETE()
{
    local PARTITION="$1"
    shift
    local f
    for f in "$@"; do
        DELETE_FROM_WORK_DIR "$PARTITION" "$f" 2>&1 | sed "/File not found/d"
    done
}

_DEGOOGLE_DELETE "product" \
    "app/GoogleCalendarSyncAdapter" "app/GoogleLocationHistory" "app/Photos" "app/SpeechServicesByGoogle" \
    "app/com.google.mainline.telemetry" "app/com.google.mainline.adservices" "app/GoogleLpaOverlay" \
    "priv-app/AICore" "priv-app/AndroidAutoStub" "priv-app/ConfigUpdater" "priv-app/GmsCore" \
    "priv-app/GooglePartnerSetup" "priv-app/GoogleRestore" "priv-app/HotwordEnrollmentOKGoogleEx3HEXAGON" \
    "priv-app/HotwordEnrollmentXGoogleEx3HEXAGON" "priv-app/Messages" "priv-app/Phonesky" "priv-app/Turbo" \
    "priv-app/Velvet" \
    "apex/com.google.android.gmssystem.prodvic.apex" \
    "overlay/GmsConfigOverlayCommon.apk" "overlay/GmsConfigOverlayADVerifier.apk" "overlay/GmsConfigOverlayASI.apk" \
    "overlay/GmsConfigOverlayGeotz.apk" "overlay/GmsConfigOverlayGSA.apk" "overlay/GmsQSfastpairOverlay.apk" \
    "overlay/GoogleDeviceSupervisionOverlay.apk" \
    "etc/default-permissions/default-permissions-google.xml" \
    "etc/permissions/privapp-permissions-google-product.xml" "etc/permissions/privapp-permissions-google-comms-suite.xml" \
    "etc/permissions/com.google.android.callcore.xml" "etc/permissions/turboapk-permissions.xml" \
    "etc/preferred-apps/google.xml" \
    "etc/sysconfig/allowed_apex_com.google.android.gmssystem.xml" "etc/sysconfig/google_aicore_QC_SM8850.xml" \
    "etc/sysconfig/google_am.xml" "etc/sysconfig/google_duo.xml" "etc/sysconfig/google-initial-package-stopped-states.xml" \
    "etc/sysconfig/google_searcle.xml" "etc/sysconfig/google-staged-installer-whitelist.xml" "etc/sysconfig/google_turbo.xml" \
    "etc/sysconfig/google.xml" "etc/sysconfig/google_xr_projected.xml" "etc/sysconfig/turbo.xml" "etc/sysconfig/aer.xml" \
    "etc/sysconfig/asi_features.xml" "etc/sysconfig/qsb_feature.xml" "etc/sysconfig/sysconfig_contextual_search.xml" \
    "etc/sysconfig/sysconfig_gemini.xml" "etc/sysconfig/carrierwifi-sysconfig.xml"

_DEGOOGLE_DELETE "system" \
    "system/app/TalkBack" "system/app/GooglePrintRecommendationService" "system/app/ChromeCustomizations" \
    "system/priv-app/EuiccGoogle" "system/priv-app/GameDriver-SM8850" \
    "system/etc/sysconfig/preinstalled-packages-com.google.android.marvin.talkback.xml" \
    "system/etc/sysconfig/preinstalled-packages-com.google.android.apps.accessibility.voiceaccess.xml" \
    "system/etc/sysconfig/preinstalled-packages-com.google.audio.hearing.visualization.accessibility.scribe.xml" \
    "system/etc/default-permissions/default-permissions-com.google.android.euicc.xml" \
    "system/etc/permissions/privapp-permissions-google-euicc.xml"

_DEGOOGLE_DELETE "system_ext" \
    "priv-app/GoogleFeedback" "priv-app/GoogleServicesFramework" \
    "etc/default-permissions/default-permissions-com.google.android.mosey.xml" \
    "etc/permissions/privapp-permissions-com.google.android.mosey.xml" \
    "etc/sysconfig/preinstalled-packages-com.google.android.mosey.xml"

# Google client/RKP props: nothing left to use them, and they identify the build as a Google-bundled one
for part in system product; do
    for p in ro.com.google.cdb.spa1 ro.com.google.clientidbase.tx ro.com.google.clientidbase ro.com.google.gmsversion \
            com.google.android.gms.eliminate_loading remote_provisioning.hostname; do
        [ "$(GET_PROP "$part" "$p")" ] && SET_PROP "$part" "$p" --delete
    done
done
SET_PROP "system" "ro.k4.variant" "degoogled"

unset -f _DEGOOGLE_DELETE
unset part p
LOG_STEP_OUT
