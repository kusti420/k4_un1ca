# [
_LOG() { if $DEBUG; then LOGW "$1"; else ABORT "$1"; fi }

LOG_MISSING_PATCHES()
{
    local MESSAGE="Missing SPF patches for condition ($1: [${!1}], $2: [${!2}])"

    if $DEBUG; then
        LOGW "$MESSAGE"
    else
        ABORT "${MESSAGE}. Aborting"
    fi
}

# VALIDATE_CAMERA_MODEL_MANIFEST <manifest>
VALIDATE_CAMERA_MODEL_MANIFEST()
{
    local MANIFEST="$1"
    local MODEL_PATH
    local WORK_FILE

    if [ ! -s "$MANIFEST" ]; then
        ABORT "Missing camera model manifest: ${MANIFEST//$WORK_DIR/}"
    fi
    if command -v python3 > /dev/null 2>&1 && \
            ! python3 -m json.tool "$MANIFEST" > /dev/null 2>&1; then
        ABORT "Malformed camera model manifest: ${MANIFEST//$WORK_DIR/}"
    fi

    while IFS= read -r MODEL_PATH; do
        case "$MODEL_PATH" in
            /system/*)
                WORK_FILE="$WORK_DIR/system/system/${MODEL_PATH#/system/}"
                ;;
            /vendor/*)
                WORK_FILE="$WORK_DIR/vendor/${MODEL_PATH#/vendor/}"
                ;;
            *)
                continue
                ;;
        esac

        if [[ "$MODEL_PATH" == */ ]] && [ ! -d "$WORK_FILE" ]; then
            ABORT "Camera manifest references a missing model directory: $MODEL_PATH"
        elif [[ "$MODEL_PATH" != */ ]] && [ ! -s "$WORK_FILE" ]; then
            ABORT "Camera manifest references a missing model: $MODEL_PATH"
        fi
    done < <(grep -o -E '"/(system|vendor)/[^"]+"' "$MANIFEST" 2> /dev/null | tr -d '"' || true)
}

# IS_PORTABLE_TFLITE <file>
IS_PORTABLE_TFLITE()
{
    [ -s "$1" ] && [[ "$(dd if="$1" bs=1 skip=4 count=4 2> /dev/null)" == "TFL3" ]]
}
# ]

SOURCE_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$SOURCE_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$SOURCE_FIRMWARE")"
TARGET_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$TARGET_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$TARGET_FIRMWARE")"

if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge 37 ] && \
        [ ! -d "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/cameradata/portrait_data" ]; then
    ABORT "Target camera portrait model directory is missing"
fi
DELETE_FROM_WORK_DIR "system" "system/cameradata/portrait_data"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/cameradata/portrait_data" 0 0 755 "u:object_r:system_file:s0"
if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge 37 ]; then
    VALIDATE_CAMERA_MODEL_MANIFEST \
        "$WORK_DIR/system/system/cameradata/portrait_data/single_bokeh_feature.json"
fi
if [ -f "$SRC_DIR/target/$TARGET_CODENAME/camera/singletake/service-feature.xml" ]; then
    LOG "- Adding /system/system/cameradata/singletake/service-feature.xml"
    EVAL "cp -a \"$SRC_DIR/target/$TARGET_CODENAME/camera/singletake/service-feature.xml\" \"$WORK_DIR/system/system/cameradata/singletake/service-feature.xml\""
else
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" \
        "system" "system/cameradata/singletake/service-feature.xml" 0 0 644 "u:object_r:system_file:s0"
fi
if [ -f "$SRC_DIR/target/$TARGET_CODENAME/camera/aremoji-feature.xml" ]; then
    LOG "- Adding /system/system/cameradata/aremoji-feature.xml"
    EVAL "cp -a \"$SRC_DIR/target/$TARGET_CODENAME/camera/aremoji-feature.xml\" \"$WORK_DIR/system/system/cameradata/aremoji-feature.xml\""
else
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" \
        "system" "system/cameradata/aremoji-feature.xml" 0 0 644 "u:object_r:system_file:s0"
fi
if [ -f "$SRC_DIR/target/$TARGET_CODENAME/camera/camera-feature.xml" ]; then
    LOG "- Adding /system/system/cameradata/camera-feature.xml"
    EVAL "cp -a \"$SRC_DIR/target/$TARGET_CODENAME/camera/camera-feature.xml\" \"$WORK_DIR/system/system/cameradata/camera-feature.xml\""
elif [[ "$SOURCE_PLATFORM_SDK_VERSION" == "$TARGET_PLATFORM_SDK_VERSION" ]]; then
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" \
        "system" "system/cameradata/camera-feature.xml" 0 0 644 "u:object_r:system_file:s0"
else
    _LOG "File not found: $SRC_DIR/target/$TARGET_CODENAME/camera/camera-feature.xml"
fi

LOG_STEP_IN
if grep -q "DURING_SMARTVIEW" "$WORK_DIR/system/system/cameradata/camera-feature.xml" 2> /dev/null; then
    LOG "- Removing Smart View limitations flags"
    EVAL "sed -i \"/DURING_SMARTVIEW/d\" \"$WORK_DIR/system/system/cameradata/camera-feature.xml\""
fi
if [ "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GRAPHICS_SUPPORT_3D_SURFACE_TRANSITION_FLAG")" ]; then
    if grep -q "SUPPORT_LIVE_BLUR" "$WORK_DIR/system/system/cameradata/camera-feature.xml" 2> /dev/null; then
        LOG "- Removing native blur disable flag"
        EVAL "sed -i \"/SUPPORT_LIVE_BLUR/d\" \"$WORK_DIR/system/system/cameradata/camera-feature.xml\""
    fi
fi
LOG_STEP_OUT

# Samsung Camera "hal3_mass-phone-release" app flavor
if ! $SOURCE_CAMERA_SUPPORT_MASS_APP_FLAVOR; then
    if $TARGET_CAMERA_SUPPORT_MASS_APP_FLAVOR; then
        ADD_TO_WORK_DIR "r9qxxx" "system" "system/priv-app/SamsungCamera/SamsungCamera.apk" 0 0 644 "u:object_r:system_file:s0"
        ADD_TO_WORK_DIR "r9qxxx" "system" "system/priv-app/SamsungCamera/SamsungCamera.apk.prof" 0 0 644 "u:object_r:system_file:s0"

        # The prebuilt only knows One UI versions up to its own release and throws
        # "get : argument is invalid - <ro.build.version.oneui>" from Camera.onCreate on newer
        # platforms (One UI 9 = 90000). Fall back to the newest version it knows instead.
        DECODE_APK "system" "system/priv-app/SamsungCamera/SamsungCamera.apk"
        CAMERA_DIR="$APKTOOL_DIR/system/priv-app/SamsungCamera/SamsungCamera.apk"
        ONEUI_ENUM="$(grep -rl "get : argument is invalid - " "$CAMERA_DIR"/smali* | head -n 1)"
        if [ "$ONEUI_ENUM" ] && grep -q "mOneUiVersionCode" "$ONEUI_ENUM"; then
            LOG "- Making SamsungCamera fall back to its newest known One UI version"
            python3 - "$ONEUI_ENUM" << 'PYEOF' || ABORT "Failed to patch ${ONEUI_ENUM//$APKTOOL_DIR/}"
import re, sys
p = sys.argv[1]
s = open(p).read()
cls = re.search(r"^\.class [^\n]* (L[^;\s]+;)", s, re.M).group(1)
last = re.findall(r"^\.field public static final enum (\w+):" + re.escape(cls), s, re.M)[-1]
pat = re.compile(r"(:cond_\d+\n)\s+new-instance (v\d+), Ljava/lang/IllegalArgumentException;\n\s+const-string v\d+, \"get : argument is invalid - \"\n.*?\n\s+throw \2\n", re.S)
s, n = pat.subn(lambda m: "%s    sget-object %s, %s->%s:%s\n\n    return-object %s\n" % (m.group(1), m.group(2), cls, last, cls, m.group(2)), s, count=1)
assert n == 1, "throw block not found"
open(p, "w").write(s)
PYEOF
        fi
        unset CAMERA_DIR ONEUI_ENUM
    fi
else
    if ! $TARGET_CAMERA_SUPPORT_MASS_APP_FLAVOR; then
        # TODO handle this condition
        LOG_MISSING_PATCHES "SOURCE_CAMERA_SUPPORT_MASS_APP_FLAVOR" "TARGET_CAMERA_SUPPORT_MASS_APP_FLAVOR"
    fi
fi

# Add/delete Snapchat CameraKit Plugin if SHOOTING_MODE_FUN is (not) available
if [ -f "$WORK_DIR/system/system/app/FunModeSDK/FunModeSDK.apk" ]; then
    if ! grep -q "SHOOTING_MODE_FUN" "$WORK_DIR/system/system/cameradata/camera-feature.xml" 2> /dev/null; then
        DELETE_FROM_WORK_DIR "system" "system/app/FunModeSDK"
    fi
else
    if grep -q "SHOOTING_MODE_FUN" "$WORK_DIR/system/system/cameradata/camera-feature.xml" 2> /dev/null; then
        ADD_TO_WORK_DIR "a73xqxx" "system" "system/app/FunModeSDK" 0 0 755 "u:object_r:system_file:s0"
    fi
fi

# Single take "stp1-release" app flavor
if grep -q "SUPPORT_SINGLE_TAKE_HIGHLIGHT_VIDEOS.*true" "$FW_DIR/$SOURCE_FIRMWARE_PATH/system/system/cameradata/camera-feature.xml" 2> /dev/null && \
        ! grep -q "SUPPORT_SINGLE_TAKE_HIGHLIGHT_VIDEOS.*true" "$WORK_DIR/system/system/cameradata/camera-feature.xml" 2> /dev/null; then
    ADD_TO_WORK_DIR "a73xqxx" "system" "system/priv-app/SingleTakeService/SingleTakeService.apk" 0 0 644 "u:object_r:system_file:s0"
elif ! grep -q "SUPPORT_SINGLE_TAKE_HIGHLIGHT_VIDEOS.*true" "$FW_DIR/$SOURCE_FIRMWARE_PATH/system/system/cameradata/camera-feature.xml" 2> /dev/null && \
        grep -q "SUPPORT_SINGLE_TAKE_HIGHLIGHT_VIDEOS.*true" "$WORK_DIR/system/system/cameradata/camera-feature.xml" 2> /dev/null; then
    # TODO handle this condition
    # shellcheck disable=SC2034
    SOURCE_SUPPORT_SINGLE_TAKE_HIGHLIGHT_VIDEOS=false
    # shellcheck disable=SC2034
    TARGET_SUPPORT_SINGLE_TAKE_HIGHLIGHT_VIDEOS=true
    LOG_MISSING_PATCHES "SOURCE_SUPPORT_SINGLE_TAKE_HIGHLIGHT_VIDEOS" "TARGET_SUPPORT_SINGLE_TAKE_HIGHLIGHT_VIDEOS"
    unset SOURCE_SUPPORT_SINGLE_TAKE_HIGHLIGHT_VIDEOS TARGET_SUPPORT_SINGLE_TAKE_HIGHLIGHT_VIDEOS
fi

# SEC_PRODUCT_FEATURE_CAMERA_SINGLETAKE_SOLUTIONS
if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge 37 ]; then
    if ! grep -q "ENABLE_SINGLE_TAKE_LITE.*true" "$WORK_DIR/system/system/cameradata/singletake/service-feature.xml" 2>/dev/null && \
            ! grep -q "SUPPORT_SMART_CROP.*false" "$WORK_DIR/system/system/cameradata/singletake/service-feature.xml" 2>/dev/null; then
        # One UI 9's libfixsal still names this exact portable fallback. Keep the
        # target copy instead of requesting the removed Android 17 source path.
        if ! IS_PORTABLE_TFLITE "$WORK_DIR/vendor/etc/singletake/SmartCrop/SmartCrop.tflite"; then
            LOGW "Target SmartCrop model is unavailable; disabling Single Take Smart Crop"
            EVAL "sed -i '/name=\"SUPPORT_SMART_CROP\"/s/value=\"true\"/value=\"false\"/' \"$WORK_DIR/system/system/cameradata/singletake/service-feature.xml\""
        fi
    fi
else
    if ! grep -q "ENABLE_SINGLE_TAKE_LITE.*true" "$WORK_DIR/system/system/cameradata/singletake/service-feature.xml" 2>/dev/null && \
            ! grep -q "SUPPORT_SMART_CROP.*false" "$WORK_DIR/system/system/cameradata/singletake/service-feature.xml" 2>/dev/null; then
        if [ -d "$FW_DIR/$SOURCE_FIRMWARE_PATH/vendor/etc/singletake/SmartCrop" ]; then
            if [ ! -d "$WORK_DIR/vendor/etc/singletake/SmartCrop" ] || \
                    [ "$TARGET_PLATFORM_SDK_VERSION" -lt "$SOURCE_PLATFORM_SDK_VERSION" ]; then
                ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" \
                    "etc/singletake/SmartCrop/SmartCrop.tflite" 0 0 644 "u:object_r:vendor_configs_file:s0"
            fi
        else
            # TODO handle this condition
            # shellcheck disable=SC2034
            SOURCE_SUPPORT_SMART_CROP=false
            # shellcheck disable=SC2034
            TARGET_SUPPORT_SMART_CROP=true
            LOG_MISSING_PATCHES "SOURCE_SUPPORT_SMART_CROP" "TARGET_SUPPORT_SMART_CROP"
            unset SOURCE_SUPPORT_SMART_CROP TARGET_SUPPORT_SMART_CROP
        fi
    else
        if [ -d "$WORK_DIR/vendor/etc/singletake/SmartCrop" ]; then
            DELETE_FROM_WORK_DIR "vendor" "etc/singletake/SmartCrop"
        fi
    fi
fi

# SEC_PRODUCT_FEATURE_CAMERA_CONFIG_ACTION_CLASSIFIER
SOURCE_CAMERA_CONFIG_ACTION_CLASSIFIER="$(GET_FLOATING_FEATURE_CONFIG "$FW_DIR/$SOURCE_FIRMWARE_PATH/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_CAMERA_CONFIG_ACTION_CLASSIFIER")"
TARGET_CAMERA_CONFIG_ACTION_CLASSIFIER="$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_CONFIG_ACTION_CLASSIFIER")"
if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge 37 ] && { \
        [ ! -f "$FW_DIR/$SOURCE_FIRMWARE_PATH/system/system/lib64/libVideoClassifier.camera.samsung.so" ] || \
        [ ! -d "$FW_DIR/$SOURCE_FIRMWARE_PATH/vendor/etc/singletake/dynamic_viewing" ];
}; then
    # Android 17 removed both the legacy consumer and its model directory.
    # Keeping the old feature flag would only make Single Take request a backend
    # which is no longer present in the source framework.
    LOG "- Disabling legacy Single Take action classifier"
    SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_CONFIG_ACTION_CLASSIFIER" --delete
    if [ -d "$WORK_DIR/vendor/etc/singletake/dynamic_viewing" ]; then
        DELETE_FROM_WORK_DIR "vendor" "etc/singletake/dynamic_viewing"
    fi
    if [ -f "$WORK_DIR/system/system/lib64/libVideoClassifier.camera.samsung.so" ]; then
        DELETE_FROM_WORK_DIR "system" "system/lib64/libVideoClassifier.camera.samsung.so"
    fi
    if [ -f "$WORK_DIR/system/system/lib64/libtensorflowLite2_11_0_dynamic_camera.so" ]; then
        DELETE_FROM_WORK_DIR "system" "system/lib64/libtensorflowLite2_11_0_dynamic_camera.so"
    fi
else
    if [ "$SOURCE_CAMERA_CONFIG_ACTION_CLASSIFIER" ]; then
        if [ "$TARGET_CAMERA_CONFIG_ACTION_CLASSIFIER" ]; then
            if [ -d "$WORK_DIR/vendor/etc/singletake/dynamic_viewing" ]; then
                DELETE_FROM_WORK_DIR "vendor" "etc/singletake/dynamic_viewing"
            fi
            ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "etc/singletake/dynamic_viewing" 0 2000 755 "u:object_r:vendor_configs_file:s0"
        else
            DELETE_FROM_WORK_DIR "system" "system/lib64/libVideoClassifier.camera.samsung.so"
            DELETE_FROM_WORK_DIR "system" "system/lib64/libtensorflowLite2_11_0_dynamic_camera.so"
        fi
    else
        if [ "$TARGET_CAMERA_CONFIG_ACTION_CLASSIFIER" ]; then
            # TODO handle this condition
            LOG_MISSING_PATCHES "SOURCE_CAMERA_CONFIG_ACTION_CLASSIFIER" "TARGET_CAMERA_CONFIG_ACTION_CLASSIFIER"
        fi
    fi
fi

# SEC_PRODUCT_FEATURE_CAMERA_CONFIG_GPPM_SOLUTIONS
SOURCE_CAMERA_CONFIG_GPPM_SOLUTIONS="$(GET_FLOATING_FEATURE_CONFIG "$FW_DIR/$SOURCE_FIRMWARE_PATH/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_CAMERA_CONFIG_GPPM_SOLUTIONS")"
TARGET_CAMERA_CONFIG_GPPM_SOLUTIONS="$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_CONFIG_GPPM_SOLUTIONS")"
if [[ "$SOURCE_CAMERA_CONFIG_GPPM_SOLUTIONS" != "$TARGET_CAMERA_CONFIG_GPPM_SOLUTIONS" ]]; then
    if [ "$SOURCE_CAMERA_CONFIG_GPPM_SOLUTIONS" ]; then
        if [ ! "$TARGET_CAMERA_CONFIG_GPPM_SOLUTIONS" ] && \
                [ ! -f "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/priv-app/GlobalPostProcMgr/GlobalPostProcMgr.apk" ]; then
            DELETE_FROM_WORK_DIR "system" "system/etc/default-permissions/default-permissions-com.samsung.android.globalpostprocmgr.xml"
            DELETE_FROM_WORK_DIR "system" "system/etc/permissions/privapp-permissions-com.samsung.android.globalpostprocmgr.xml"
            DELETE_FROM_WORK_DIR "system" "system/priv-app/GlobalPostProcMgr"
        fi
        if [[ "$SOURCE_CAMERA_CONFIG_GPPM_SOLUTIONS" == *"startrail"* ]] && \
                [[ "$TARGET_CAMERA_CONFIG_GPPM_SOLUTIONS" != *"startrail"* ]]; then
            DELETE_FROM_WORK_DIR "system" "system/lib64/libstartrail.camera.samsung.so"
        elif [[ "$SOURCE_CAMERA_CONFIG_GPPM_SOLUTIONS" != *"startrail"* ]] && \
                [[ "$TARGET_CAMERA_CONFIG_GPPM_SOLUTIONS" == *"startrail"* ]]; then
            # TODO handle this condition
            LOG_MISSING_PATCHES "SOURCE_CAMERA_CONFIG_GPPM_SOLUTIONS" "TARGET_CAMERA_CONFIG_GPPM_SOLUTIONS"
        fi
        if [[ "$SOURCE_CAMERA_CONFIG_GPPM_SOLUTIONS" == *"motionclipper"* ]] && \
                [[ "$TARGET_CAMERA_CONFIG_GPPM_SOLUTIONS" != *"motionclipper"* ]]; then
            # One UI 9's Wallpaper & style (DressRoom) object capture loads libdvs too
            # (UnsatisfiedLinkError in srib.vizinsight.dvs.DVS.initJni without it)
            if [ "$SOURCE_PLATFORM_SDK_VERSION" -lt "37" ]; then
                DELETE_FROM_WORK_DIR "system" "system/lib64/libdvs.camera.samsung.so"
            fi
        elif [[ "$SOURCE_CAMERA_CONFIG_GPPM_SOLUTIONS" != *"motionclipper"* ]] && \
                [[ "$TARGET_CAMERA_CONFIG_GPPM_SOLUTIONS" == *"motionclipper"* ]]; then
            # TODO handle this condition
            LOG_MISSING_PATCHES "SOURCE_CAMERA_CONFIG_GPPM_SOLUTIONS" "TARGET_CAMERA_CONFIG_GPPM_SOLUTIONS"
        fi
    else
        if [ "$TARGET_CAMERA_CONFIG_GPPM_SOLUTIONS" ]; then
            # TODO handle this condition
            LOG_MISSING_PATCHES "SOURCE_CAMERA_CONFIG_GPPM_SOLUTIONS" "TARGET_CAMERA_CONFIG_GPPM_SOLUTIONS"
        fi
    fi
fi

# SEC_PRODUCT_FEATURE_CAMERA_SUPPORT_SDK_SERVICE
if $SOURCE_CAMERA_SUPPORT_SDK_SERVICE; then
    if ! $TARGET_CAMERA_SUPPORT_SDK_SERVICE; then
        DELETE_FROM_WORK_DIR "system" "system/etc/permissions/cameraservice.xml"
        DELETE_FROM_WORK_DIR "system" "system/framework/scamera_sep.jar"
        DELETE_FROM_WORK_DIR "system" "system/priv-app/SCameraSDKService"
    fi
else
    if $TARGET_CAMERA_SUPPORT_SDK_SERVICE; then
        # TODO handle this condition
        LOG_MISSING_PATCHES "SOURCE_CAMERA_SUPPORT_SDK_SERVICE" "TARGET_CAMERA_SUPPORT_SDK_SERVICE"
    fi
fi

# SEC_PRODUCT_FEATURE_CAMERA_SUPPORT_CAMERAX_EXTENSION
if $SOURCE_CAMERA_SUPPORT_CAMERAX_EXTENSION; then
    if ! $TARGET_CAMERA_SUPPORT_CAMERAX_EXTENSION; then
        DELETE_FROM_WORK_DIR "system" "system/etc/permissions/sec_camerax_impl.xml"
        DELETE_FROM_WORK_DIR "system" "system/etc/permissions/sec_camerax_service.xml"
        DELETE_FROM_WORK_DIR "system" "system/framework/sec_camerax_impl.jar"
        DELETE_FROM_WORK_DIR "system" "system/lib/libsec_camerax_util_jni.camera.samsung.so"
        DELETE_FROM_WORK_DIR "system" "system/lib64/libsec_camerax_util_jni.camera.samsung.so"
        DELETE_FROM_WORK_DIR "system" "system/priv-app/sec_camerax_service"
        SET_PROP "system" "ro.camerax.extensions.enabled" --delete
    fi
else
    if $TARGET_CAMERA_SUPPORT_CAMERAX_EXTENSION; then
        # TODO handle this condition
        LOG_MISSING_PATCHES "SOURCE_CAMERA_SUPPORT_CAMERAX_EXTENSION" "TARGET_CAMERA_SUPPORT_CAMERAX_EXTENSION"
    fi
fi

# SEC_PRODUCT_FEATURE_GALLERY_CONFIG_PET_CLUSTER_VERSION
SOURCE_GALLERY_CONFIG_PET_CLUSTER_VERSION="$(GET_FLOATING_FEATURE_CONFIG "$FW_DIR/$SOURCE_FIRMWARE_PATH/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_GALLERY_CONFIG_PET_CLUSTER_VERSION")"
TARGET_GALLERY_CONFIG_PET_CLUSTER_VERSION="$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GALLERY_CONFIG_PET_CLUSTER_VERSION")"
STOCK_TARGET_GALLERY_CONFIG_PET_CLUSTER_VERSION="$(GET_FLOATING_FEATURE_CONFIG "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_GALLERY_CONFIG_PET_CLUSTER_VERSION")"
if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge 37 ] && { \
        [[ "$STOCK_TARGET_GALLERY_CONFIG_PET_CLUSTER_VERSION" == "None" ]] || \
        [ ! -f "$FW_DIR/$TARGET_FIRMWARE_PATH/vendor/lib64/libPetDetector_v1.camera.samsung.so" ];
}; then
    # PetService in the Android 17 source uses libPetDetector_v1 and the new
    # aic_pet_detector contract. The Exynos 2100 vendor exposes neither.
    LOG "- Disabling PetService on the target vendor"
    SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GALLERY_CONFIG_PET_CLUSTER_VERSION" "None"
    TARGET_GALLERY_CONFIG_PET_CLUSTER_VERSION="None"
    if grep -q 'name="SUPPORT_PET_DETECTION".*value="true"' \
            "$WORK_DIR/system/system/cameradata/singletake/service-feature.xml" 2> /dev/null; then
        EVAL "sed -i '/name=\"SUPPORT_PET_DETECTION\"/s/value=\"true\"/value=\"false\"/' \"$WORK_DIR/system/system/cameradata/singletake/service-feature.xml\""
    fi
    [ ! -f "$WORK_DIR/system/system/etc/default-permissions/default-permissions-com.samsung.petservice.xml" ] || \
        DELETE_FROM_WORK_DIR "system" "system/etc/default-permissions/default-permissions-com.samsung.petservice.xml"
    [ ! -f "$WORK_DIR/system/system/etc/permissions/privapp-permissions-com.samsung.petservice.xml" ] || \
        DELETE_FROM_WORK_DIR "system" "system/etc/permissions/privapp-permissions-com.samsung.petservice.xml"
    [ ! -f "$WORK_DIR/system/system/lib64/libPetClustering.camera.samsung.so" ] || \
        DELETE_FROM_WORK_DIR "system" "system/lib64/libPetClustering.camera.samsung.so"
    [ ! -d "$WORK_DIR/system/system/priv-app/PetService" ] || \
        DELETE_FROM_WORK_DIR "system" "system/priv-app/PetService"
else
    if [[ "$SOURCE_GALLERY_CONFIG_PET_CLUSTER_VERSION" != "None" ]]; then
        if [[ "$TARGET_GALLERY_CONFIG_PET_CLUSTER_VERSION" == "None" ]]; then
            DELETE_FROM_WORK_DIR "system" "system/etc/default-permissions/default-permissions-com.samsung.petservice.xml"
            DELETE_FROM_WORK_DIR "system" "system/etc/permissions/privapp-permissions-com.samsung.petservice.xml"
            DELETE_FROM_WORK_DIR "system" "system/lib64/libPetClustering.camera.samsung.so"
            DELETE_FROM_WORK_DIR "system" "system/priv-app/PetService"
        fi
    else
        if [[ "$TARGET_GALLERY_CONFIG_PET_CLUSTER_VERSION" != "None" ]]; then
            # TODO handle this condition
            LOG_MISSING_PATCHES "SOURCE_GALLERY_CONFIG_PET_CLUSTER_VERSION" "TARGET_GALLERY_CONFIG_PET_CLUSTER_VERSION"
        fi
    fi
fi

# SEC_PRODUCT_FEATURE_SAIV_CONFIG_ARDOODLE_LIB
SOURCE_SAIV_CONFIG_ARDOODLE_LIB="$(GET_FLOATING_FEATURE_CONFIG "$FW_DIR/$SOURCE_FIRMWARE_PATH/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_SAIV_CONFIG_ARDOODLE_LIB")"
TARGET_SAIV_CONFIG_ARDOODLE_LIB="$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_SAIV_CONFIG_ARDOODLE_LIB")"
if [[ "$SOURCE_SAIV_CONFIG_ARDOODLE_LIB" != "$TARGET_SAIV_CONFIG_ARDOODLE_LIB" ]]; then
    if [ "$SOURCE_SAIV_CONFIG_ARDOODLE_LIB" ]; then
        if [[ "$SOURCE_SAIV_CONFIG_ARDOODLE_LIB" == *"IMG_PICKING"* ]] && \
                [[ "$TARGET_SAIV_CONFIG_ARDOODLE_LIB" != *"IMG_PICKING"* ]]; then
            DELETE_FROM_WORK_DIR "system" "system/etc/ardoodle"
        elif [[ "$SOURCE_SAIV_CONFIG_ARDOODLE_LIB" != *"IMG_PICKING"* ]] && \
                [[ "$TARGET_SAIV_CONFIG_ARDOODLE_LIB" == *"IMG_PICKING"* ]]; then
            # TODO handle this condition
            LOG_MISSING_PATCHES "SOURCE_SAIV_CONFIG_ARDOODLE_LIB" "TARGET_SAIV_CONFIG_ARDOODLE_LIB"
        fi
    else
        if [ "$TARGET_SAIV_CONFIG_ARDOODLE_LIB" ]; then
            # TODO handle this condition
            LOG_MISSING_PATCHES "SOURCE_SAIV_CONFIG_ARDOODLE_LIB" "TARGET_SAIV_CONFIG_ARDOODLE_LIB"
        fi
    fi
fi

# Camera libs debloat
if ! grep -q "\"system\"" "$WORK_DIR/system/system/cameradata/portrait_data/single_bokeh_feature.json" 2> /dev/null; then
    DELETE_FROM_WORK_DIR "system" "system/lib64/libRelighting_API.camera.samsung.so"
fi
if ! grep -q "SUPPORT_PET_DETECTION.*true" "$WORK_DIR/system/system/cameradata/singletake/service-feature.xml" 2> /dev/null && \
        [[ "$TARGET_SAIV_CONFIG_ARDOODLE_LIB" != *"PET_DETECTION"* ]]; then
    DELETE_FROM_WORK_DIR "system" "system/lib64/lib_pet_detection.arcsoft.so"
fi
if ! grep -q "SUPPORT_SINGLE_TAKE_BURST_CAPTURE.*true" "$WORK_DIR/system/system/cameradata/camera-feature.xml" 2> /dev/null; then
    DELETE_FROM_WORK_DIR "system" "system/lib64/libBestPhoto.camera.samsung.so"
fi
SOURCE_CAMERA_CONFIG_VENDOR_LIB_INFO="$(GET_FLOATING_FEATURE_CONFIG "$FW_DIR/$SOURCE_FIRMWARE_PATH/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_CAMERA_CONFIG_VENDOR_LIB_INFO")"
TARGET_CAMERA_CONFIG_VENDOR_LIB_INFO="$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_CONFIG_VENDOR_LIB_INFO")"
if [[ "$SOURCE_CAMERA_CONFIG_VENDOR_LIB_INFO" == *"aebhdr.arcsoft.v1"* ]] && \
        [[ "$TARGET_CAMERA_CONFIG_VENDOR_LIB_INFO" != *"aebhdr.arcsoft.v1"* ]]; then
    DELETE_FROM_WORK_DIR "system" "system/lib64/libAEBHDR_wrapper.camera.samsung.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/libae_bracket_hdr.arcsoft.so"
fi
if [ -f "$WORK_DIR/vendor/lib64/libDualCamBokehCapture.camera.samsung.so" ] || {
    [[ "$SOURCE_CAMERA_CONFIG_VENDOR_LIB_INFO" == *"dual_bokeh.samsung"* ]] && \
        [[ "$TARGET_CAMERA_CONFIG_VENDOR_LIB_INFO" != *"dual_bokeh.samsung"* ]]
}; then
    DELETE_FROM_WORK_DIR "system" "system/lib64/libDualCamBokehCapture.camera.samsung.so"
    if [ ! -f "$WORK_DIR/system/system/lib64/libRelighting_API.camera.samsung.so" ]; then
        DELETE_FROM_WORK_DIR "system" "system/lib64/libarcsoft_dualcam_portraitlighting.so"
    fi
    if ! grep -q "GlassSegSDK" "$WORK_DIR/system/system/cameradata/portrait_data/single_bokeh_feature.json" 2> /dev/null; then
        DELETE_FROM_WORK_DIR "system" "system/lib64/libarcsoft_single_cam_glasses_seg.so"
    fi
    DELETE_FROM_WORK_DIR "system" "system/lib64/libarcsoft_superresolution_bokeh.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/libdualcam_refocus_image.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/libhigh_dynamic_range_bokeh.so"
fi
if {
    [[ "$SOURCE_CAMERA_CONFIG_VENDOR_LIB_INFO" == *"fusion_high_res.arcsoft.v1"* ]] && \
        [[ "$TARGET_CAMERA_CONFIG_VENDOR_LIB_INFO" != *"fusion_high_res.arcsoft.v1"* ]]
} || {
    [[ "$SOURCE_CAMERA_CONFIG_VENDOR_LIB_INFO" == *"high_res.arcsoft.v2"* ]] && \
        [[ "$TARGET_CAMERA_CONFIG_VENDOR_LIB_INFO" != *"high_res.arcsoft.v2"* ]]
}; then
    DELETE_FROM_WORK_DIR "system" "system/lib64/libHREnhancementAPI.camera.samsung.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/libhighres_enhancement.arcsoft.so"
fi
if [[ "$SOURCE_CAMERA_CONFIG_VENDOR_LIB_INFO" == *"fr_tracking.arcsoft.v1"* ]] && \
        [[ "$TARGET_CAMERA_CONFIG_VENDOR_LIB_INFO" != *"fr_tracking.arcsoft.v1"* ]]; then
    DELETE_FROM_WORK_DIR "system" "system/lib64/libFaceRecognition.arcsoft.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/libfrtracking_engine.arcsoft.so"
fi
if [[ "$SOURCE_CAMERA_CONFIG_VENDOR_LIB_INFO" == *"hybridhdr.arcsoft.v1"* ]] && \
        [[ "$TARGET_CAMERA_CONFIG_VENDOR_LIB_INFO" != *"hybridhdr.arcsoft.v1"* ]]; then
    DELETE_FROM_WORK_DIR "system" "system/lib64/libhybridHDR_wrapper.camera.samsung.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/libhybrid_high_dynamic_range.arcsoft.so"
fi
if [[ "$SOURCE_CAMERA_CONFIG_VENDOR_LIB_INFO" == *"pro_single_rgb.mpi.v1"* ]] && \
        [[ "$TARGET_CAMERA_CONFIG_VENDOR_LIB_INFO" != *"pro_single_rgb.mpi.v1"* ]]; then
    DELETE_FROM_WORK_DIR "system" "system/lib64/libAIQSolution_MPISingleRGB40.camera.samsung.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/libMPISingleRGB40.camera.samsung.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/libMPISingleRGB40Tuning.camera.samsung.so"
fi
if [[ "$SOURCE_CAMERA_CONFIG_VENDOR_LIB_INFO" == *"scene_detection.samsung.v1"* ]] && \
        [[ "$TARGET_CAMERA_CONFIG_VENDOR_LIB_INFO" != *"scene_detection.samsung.v1"* ]]; then
    DELETE_FROM_WORK_DIR "system" "system/lib64/libSceneDetector_v1.camera.samsung.so"
fi
if [[ "$SOURCE_CAMERA_CONFIG_VENDOR_LIB_INFO" == *"smart_scan.samsung"* ]] && \
        [[ "$TARGET_CAMERA_CONFIG_VENDOR_LIB_INFO" != *"smart_scan.samsung"* ]]; then
    DELETE_FROM_WORK_DIR "system" "system/lib64/libSmartScan.camera.samsung.so"
fi
if [[ "$SOURCE_CAMERA_CONFIG_VENDOR_LIB_INFO" == *"super_night.mpi.v2"* ]] && \
        [[ "$TARGET_CAMERA_CONFIG_VENDOR_LIB_INFO" != *"super_night.mpi.v2"* ]]; then
    DELETE_FROM_WORK_DIR "system" "system/lib64/libAIQSolution_MPI.camera.samsung.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/libLocalTM_pcc.camera.samsung.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/libMultiFrameProcessing30.camera.samsung.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/libMultiFrameProcessing30.snapwrapper.camera.samsung.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/libMultiFrameProcessing30Tuning.camera.samsung.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/libObjectDetector_v1.camera.samsung.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/libSwIsp_core.camera.samsung.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/libSwIsp_wrapper_v1.camera.samsung.so"
fi
if [[ "$SOURCE_CAMERA_CONFIG_VENDOR_LIB_INFO" == *"super_resolution_raw.arcsoft"* ]] && \
        [[ "$TARGET_CAMERA_CONFIG_VENDOR_LIB_INFO" != *"super_resolution_raw.arcsoft"* ]]; then
    DELETE_FROM_WORK_DIR "system" "system/lib64/libsuperresolutionraw_wrapper_v2.camera.samsung.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/libsuperresolution_raw.arcsoft.so"
fi
SOURCE_CAMERA_DOCUMENTSCAN_SOLUTIONS="$(GET_FLOATING_FEATURE_CONFIG "$FW_DIR/$SOURCE_FIRMWARE_PATH/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_CAMERA_DOCUMENTSCAN_SOLUTIONS")"
TARGET_CAMERA_DOCUMENTSCAN_SOLUTIONS="$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_DOCUMENTSCAN_SOLUTIONS")"
if [[ "$SOURCE_CAMERA_DOCUMENTSCAN_SOLUTIONS" == *"AI_DEWARPING"* ]] && \
        [[ "$TARGET_CAMERA_DOCUMENTSCAN_SOLUTIONS" != *"AI_DEWARPING"* ]]; then
    DELETE_FROM_WORK_DIR "system" "system/lib64/libDeepDocRectify.camera.samsung.so"
fi
if [[ "$SOURCE_CAMERA_DOCUMENTSCAN_SOLUTIONS" == *"SHADOW_REMOVAL"* ]] && \
        [[ "$TARGET_CAMERA_DOCUMENTSCAN_SOLUTIONS" != *"SHADOW_REMOVAL"* ]]; then
    DELETE_FROM_WORK_DIR "system" "system/lib64/libDocShadowRemoval.arcsoft.so"
fi
if [ -f "$WORK_DIR/system/system/lib64/libImageSegmenter_v1.camera.samsung.so" ] && \
        [ ! -d "$WORK_DIR/vendor/etc/portrait_data/LF_segmenter" ]; then
    DELETE_FROM_WORK_DIR "system" "system/lib64/libImageSegmenter_v1.camera.samsung.so"
fi

# Fix device model number in photo/video metadata
while IFS= read -r f; do
    HEX_PATCH "$f" "726f2e70726f647563742e6d6f64656c00" "726f2e626f6f742e656d2e6d6f64656c00"
done < <(grep -r -w -l "ro.product.model" "$WORK_DIR/vendor" | grep "camera")
for f in \
    "$WORK_DIR/system/system/lib/libstagefright.so" \
    "$WORK_DIR/system/system/lib64/libstagefright.so"; do
    # Android 17 Samsung flagships are 64-bit-only and no longer ship the
    # 32-bit stagefright library. Patch each ABI only when that stock binary is
    # present; HEX_PATCH remains strict for every existing copy.
    if [ -f "$f" ]; then
        HEX_PATCH "$f" \
            "726f2e70726f647563742e6d6f64656c00" "726f2e626f6f742e656d2e6d6f64656c00"
    fi
done
unset f

# Fix object capture
if [[ "$TARGET_OS_SINGLE_SYSTEM_IMAGE" == "essi" ]]; then
    if {
        [[ "$(GET_PROP "system" "ro.product.device")" =~ r0|g0|b0 ]] && \
            ! [[ "$(GET_PROP "vendor" "ro.product.vendor.device")" =~ r0|g0|b0 ]]
    } || {
        [[ "$(GET_PROP "system" "ro.product.device")" == "a56"* ]] && \
            [[ "$(GET_PROP "vendor" "ro.product.vendor.device")" != "a56"* ]]
    }; then
        HEX_PATCH "$WORK_DIR/system/system/lib64/libobjectcapture_jni.arcsoft.so" \
            "e503162a47020094e022009121008052e203162a" "8500805247020094e02200912100805282008052"
    elif ! [[ "$(GET_PROP "system" "ro.product.device")" =~ r0|g0|b0 ]] && \
            [[ "$(GET_PROP "vendor" "ro.product.vendor.device")" =~ r0|g0|b0 ]]; then
        HEX_PATCH "$WORK_DIR/system/system/lib64/libobjectcapture_jni.arcsoft.so" \
            "e503162a47020094e022009121008052e203162a" "4500805247020094e02200912100805242008052"
    elif [[ "$(GET_PROP "system" "ro.product.device")" != "a56"* ]] && \
            [[ "$(GET_PROP "vendor" "ro.product.vendor.device")" == "a56"* ]]; then
        HEX_PATCH "$WORK_DIR/system/system/lib64/libobjectcapture_jni.arcsoft.so" \
            "e503162a47020094e022009121008052e203162a" "c500805247020094e022009121008052c2008052"
    fi
fi

# Fix portrait mode
if [ -f "$WORK_DIR/vendor/lib64/libDualCamBokehCapture.camera.samsung.so" ]; then
    if grep -q "ro.build.flavor" "$WORK_DIR/vendor/lib64/libDualCamBokehCapture.camera.samsung.so" 2> /dev/null; then
        SET_PROP "system" "ro.build.flavor" "$(GET_PROP "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/build.prop" "ro.build.flavor")"
    elif grep -q "ro.product.name" "$WORK_DIR/vendor/lib64/libDualCamBokehCapture.camera.samsung.so" 2> /dev/null; then
        HEX_PATCH "$WORK_DIR/vendor/lib/libDualCamBokehCapture.camera.samsung.so" \
            "726f2e70726f647563742e6e616d6500" "726f2e756e6963612e63616d65726100"
        HEX_PATCH "$WORK_DIR/vendor/lib/liblivefocus_capture_engine.so" \
            "726f2e70726f647563742e6e616d6500" "726f2e756e6963612e63616d65726100"
        HEX_PATCH "$WORK_DIR/vendor/lib/liblivefocus_preview_engine.so" \
            "726f2e70726f647563742e6e616d6500" "726f2e756e6963612e63616d65726100"
        HEX_PATCH "$WORK_DIR/vendor/lib64/libDualCamBokehCapture.camera.samsung.so" \
            "726f2e70726f647563742e6e616d6500" "726f2e756e6963612e63616d65726100"
        HEX_PATCH "$WORK_DIR/vendor/lib64/liblivefocus_capture_engine.so" \
            "726f2e70726f647563742e6e616d6500" "726f2e756e6963612e63616d65726100"
        HEX_PATCH "$WORK_DIR/vendor/lib64/liblivefocus_preview_engine.so" \
            "726f2e70726f647563742e6e616d6500" "726f2e756e6963612e63616d65726100"
        LOG "- Patching /system/system/etc/selinux/plat_property_contexts"
        EVAL "echo \"ro.unica.camera u:object_r:build_prop:s0 exact string\"  >> \"$WORK_DIR/system/system/etc/selinux/plat_property_contexts\""
        SET_PROP "system" "ro.unica.camera" "$(GET_PROP "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/build.prop" "ro.product.system.name")"
    fi
fi

# Enable camera cutout protection
# Skip patch if SystemUI RRO exists
if [ ! "$(find "$WORK_DIR/product/overlay" -maxdepth 1 -type f -name "SystemUI*" 2> /dev/null)" ]; then
    if [[ "$SOURCE_CAMERA_SUPPORT_CUTOUT_PROTECTION" != "$TARGET_CAMERA_SUPPORT_CUTOUT_PROTECTION" ]]; then
        DECODE_APK "system_ext" "priv-app/SystemUI/SystemUI.apk"
        if $TARGET_CAMERA_SUPPORT_CUTOUT_PROTECTION; then
            LOG "- Enabling camera cutout protection"
        else
            LOG "- Disabling camera cutout protection"
        fi
        EVAL "sed -i \"s/config_enableDisplayCutoutProtection\\\">$SOURCE_CAMERA_SUPPORT_CUTOUT_PROTECTION/config_enableDisplayCutoutProtection\\\">$TARGET_CAMERA_SUPPORT_CUTOUT_PROTECTION/\" \"$APKTOOL_DIR/system_ext/priv-app/SystemUI/SystemUI.apk/res/values/bools.xml\""
    fi
fi

unset SOURCE_FIRMWARE_PATH TARGET_FIRMWARE_PATH \
    SOURCE_CAMERA_CONFIG_ACTION_CLASSIFIER TARGET_CAMERA_CONFIG_ACTION_CLASSIFIER \
    SOURCE_CAMERA_CONFIG_GPPM_SOLUTIONS TARGET_CAMERA_CONFIG_GPPM_SOLUTIONS \
    SOURCE_GALLERY_CONFIG_PET_CLUSTER_VERSION TARGET_GALLERY_CONFIG_PET_CLUSTER_VERSION \
    STOCK_TARGET_GALLERY_CONFIG_PET_CLUSTER_VERSION \
    SOURCE_SAIV_CONFIG_ARDOODLE_LIB TARGET_SAIV_CONFIG_ARDOODLE_LIB \
    SOURCE_CAMERA_CONFIG_VENDOR_LIB_INFO TARGET_CAMERA_CONFIG_VENDOR_LIB_INFO \
    SOURCE_CAMERA_DOCUMENTSCAN_SOLUTIONS TARGET_CAMERA_DOCUMENTSCAN_SOLUTIONS
unset -f _LOG LOG_MISSING_PATCHES VALIDATE_CAMERA_MODEL_MANIFEST IS_PORTABLE_TFLITE
