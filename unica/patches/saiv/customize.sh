SOURCE_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$SOURCE_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$SOURCE_FIRMWARE")"
TARGET_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$TARGET_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$TARGET_FIRMWARE")"
SOURCE_FIRMWARE_ROOT="$FW_DIR/$SOURCE_FIRMWARE_PATH"
TARGET_FIRMWARE_ROOT="$FW_DIR/$TARGET_FIRMWARE_PATH"

# One UI 9 sources ship differently named/compiled models; record instead of aborting
SAIV_WARN()
{
    LOGW "SAIV: $1"
    echo "saiv: $1" >> "$OUT_DIR/skipped_patches.txt"
    return 0
}

# VALIDATE_INFO_MODELS <info file>
VALIDATE_INFO_MODELS()
{
    local INFO_FILE="$1"
    local MODEL_PATH
    local MODEL_PATHS
    local WORK_FILE

    if [ ! -s "$INFO_FILE" ]; then
        SAIV_WARN "Missing or invalid SAIV model manifest: ${INFO_FILE//$WORK_DIR/}"
    fi
    if command -v python3 > /dev/null 2>&1 && \
            ! python3 -m json.tool "$INFO_FILE" > /dev/null 2>&1; then
        SAIV_WARN "Malformed SAIV model manifest: ${INFO_FILE//$WORK_DIR/}"
    fi

    MODEL_PATHS="$(sed -n 's/.*"model_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$INFO_FILE")"
    if [ ! "$MODEL_PATHS" ]; then
        SAIV_WARN "SAIV manifest has no valid model paths: ${INFO_FILE//$WORK_DIR/}"
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
                SAIV_WARN "Unsupported SAIV model path in ${INFO_FILE//$WORK_DIR/}: $MODEL_PATH"
                ;;
        esac

        if [ ! -s "$WORK_FILE" ]; then
            SAIV_WARN "SAIV manifest references a missing model: $MODEL_PATH"
        fi
    done <<< "$MODEL_PATHS"
}

# VALIDATE_PORTABLE_TFLITE <file>
VALIDATE_PORTABLE_TFLITE()
{
    if [ ! -s "$1" ] || \
            [[ "$(dd if="$1" bs=1 skip=4 count=4 2> /dev/null)" != "TFL3" ]]; then
        SAIV_WARN "Missing or non-portable TFLite model: ${1//$WORK_DIR/}"
    fi
}

# REMOVE_FLOATING_FEATURE_TOKEN <feature> <token>
REMOVE_FLOATING_FEATURE_TOKEN()
{
    local FEATURE="$1"
    local TOKEN="$2"
    local VALUE
    local ENTRY
    local NEW_VALUE=""

    VALUE="$(GET_FLOATING_FEATURE_CONFIG "$FEATURE")"
    while IFS= read -r ENTRY; do
        ENTRY="$(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' <<< "$ENTRY")"
        if [ ! "$ENTRY" ] || [[ "$ENTRY" == "$TOKEN" ]]; then
            continue
        fi
        if [ "$NEW_VALUE" ]; then
            NEW_VALUE+=",$ENTRY"
        else
            NEW_VALUE="$ENTRY"
        fi
    done < <(tr ',' '\n' <<< "$VALUE")

    if [ "$NEW_VALUE" ]; then
        SET_FLOATING_FEATURE_CONFIG "$FEATURE" "$NEW_VALUE"
    else
        SET_FLOATING_FEATURE_CONFIG "$FEATURE" --delete
    fi
}

if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge 37 ] && \
        [ ! -d "$TARGET_FIRMWARE_ROOT/system/system/saiv" ]; then
    ABORT "Target SAIV model directory is missing"
fi
DELETE_FROM_WORK_DIR "system" "system/saiv"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/saiv" 0 0 755 "u:object_r:system_file:s0"

if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge 37 ]; then
    # One UI 9 / Android 17 model layout. Only portable source TFLite assets are
    # imported. NPU/DSP payloads remain from the target firmware.

    # FaceService SR_V7 consumes this portable TFLite bundle. Verify the entire
    # minimum bundle before replacing the target's older cluster models.
    SOURCE_VISION_CONFIG_FACE_RECOGNITION_SOLUTION="$(GET_FLOATING_FEATURE_CONFIG "$SOURCE_FIRMWARE_ROOT/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_GALLERY_CONFIG_FACE_CLUSTER_VERSION")"
    TARGET_VISION_CONFIG_FACE_RECOGNITION_SOLUTION="$(GET_FLOATING_FEATURE_CONFIG "$TARGET_FIRMWARE_ROOT/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_GALLERY_CONFIG_FACE_CLUSTER_VERSION")"
    if [[ "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GALLERY_CONFIG_FACE_CLUSTER_VERSION")" == "$SOURCE_VISION_CONFIG_FACE_RECOGNITION_SOLUTION" ]] && \
            [[ "$SOURCE_VISION_CONFIG_FACE_RECOGNITION_SOLUTION" != "$TARGET_VISION_CONFIG_FACE_RECOGNITION_SOLUTION" ]]; then
        for MODEL_FILE in faceservice_as.tflite faceservice_bd.tflite faceservice_ce.tflite \
                faceservice_fc.tflite faceservice_fd.tflite faceservice_fv.tflite fe.tflite; do
            VALIDATE_PORTABLE_TFLITE \
                "$SOURCE_FIRMWARE_ROOT/system/system/saiv/face/cluster_pb/$MODEL_FILE"
        done
        if [ -d "$WORK_DIR/system/system/saiv/face/cluster_pb" ]; then
            DELETE_FROM_WORK_DIR "system" "system/saiv/face/cluster_pb"
        fi
        ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" "system/saiv/face/cluster_pb" \
            0 0 755 "u:object_r:system_file:s0"
        for MODEL_FILE in faceservice_as.tflite faceservice_bd.tflite faceservice_ce.tflite \
                faceservice_fc.tflite faceservice_fd.tflite faceservice_fv.tflite fe.tflite; do
            if [ ! -s "$WORK_DIR/system/system/saiv/face/cluster_pb/$MODEL_FILE" ]; then
                ABORT "Failed to install Android 17 FaceService model: $MODEL_FILE"
            fi
        done
    fi

    # Keep the G996 MIDAS configuration and its Exynos 2100-compatible models.
    # Android 17's source configs select s5e9965 NNC or sm8850 DLC payloads and
    # must never be transplanted onto this vendor.
    TARGET_SAIV_CONFIG_MIDAS="$(GET_FLOATING_FEATURE_CONFIG "$TARGET_FIRMWARE_ROOT/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_SAIV_CONFIG_MIDAS")"
    if [ "$TARGET_SAIV_CONFIG_MIDAS" ] && \
            [ -s "$WORK_DIR/vendor/etc/midas/midas_config.json" ] && \
            grep -q '"t2s"' "$WORK_DIR/vendor/etc/midas/midas_config.json" && { \
                ! command -v python3 > /dev/null 2>&1 || \
                python3 -m json.tool "$WORK_DIR/vendor/etc/midas/midas_config.json" > /dev/null 2>&1;
            }; then
        SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_SAIV_CONFIG_MIDAS" "$TARGET_SAIV_CONFIG_MIDAS"
    else
        LOGW "Target MIDAS manifest is unavailable for t2s; disabling MIDAS"
        SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_SAIV_CONFIG_MIDAS" --delete
    fi

    # libUnifiedDetector in Android 17 hard-codes this new manifest path, while
    # accepting TFLite/NPU models. Map it to the target's stock Olympus-compiled
    # detector and classifier instead of copying s5e9965 NNCs or sm8850 DLCs.
    UNIFIED_INFO="$WORK_DIR/vendor/etc/saiv/image_understanding/db/unified_detector/model.info"
    TARGET_AIC_DETECTOR="$WORK_DIR/vendor/etc/saiv/image_understanding/db/aic_detector/aic_detector_cnn.tflite"
    TARGET_AIC_CLASSIFIER="$WORK_DIR/vendor/etc/saiv/image_understanding/db/aic_classifier/aic_classifier_cnn.tflite"
    if [ -s "$SOURCE_FIRMWARE_ROOT/vendor/etc/saiv/image_understanding/db/unified_detector/model.info" ] && \
            [ -s "$TARGET_AIC_DETECTOR" ] && [ -s "$TARGET_AIC_CLASSIFIER" ]; then
        ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" \
            "etc/saiv/image_understanding/db/unified_detector/model.info" \
            0 0 644 "u:object_r:vendor_configs_file:s0"
        LOG "- Mapping Android 17 UnifiedDetector to target NPU models"
        EVAL "printf '%s\n' '[
  {
    \"model\": \"ud_detector.tflite\",
    \"model_type\": \"npu\",
    \"precision\": \"qasymm8\",
    \"latency\": \"1\",
    \"compiler\": \"ENN4.13.0_S21\",
    \"model_path\": \"/vendor/etc/saiv/image_understanding/db/aic_detector/aic_detector_cnn.tflite\"
  },
  {
    \"model\": \"ud_classifier.tflite\",
    \"model_type\": \"npu\",
    \"precision\": \"qasymm8\",
    \"latency\": \"1\",
    \"compiler\": \"ENN4.13.0_S21\",
    \"model_path\": \"/vendor/etc/saiv/image_understanding/db/aic_classifier/aic_classifier_cnn.tflite\"
  }
]' > \"$UNIFIED_INFO\""
        VALIDATE_INFO_MODELS "$UNIFIED_INFO"
    else
        LOGW "No target-compatible UnifiedDetector pair; disabling Gallery image tagging"
        # Don't delete the key: SemFloatingFeature returns "" for missing keys and CMH (com.samsung.cmh)
        # ControllerUtils.isTaggerAvailable()/FeatureClassSet do value.charAt(0) -> StringIndexOutOfBoundsException.
        # "None" fails their 'V' prefix check, which disables tagging cleanly.
        SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GALLERY_CONFIG_IMAGE_TAGGER_VERSION" "None"
        if [ -d "${UNIFIED_INFO%/*}" ]; then
            DELETE_FROM_WORK_DIR "vendor" "etc/saiv/image_understanding/db/unified_detector"
        fi
    fi

    # Android 17's Photo Editor native library explicitly retains
    # /hs_segmenter/hs_segmenter.info as a compatibility fallback.
    HS_DIR="etc/saiv/image_understanding/db/hs_segmenter"
    if [ ! -d "$WORK_DIR/vendor/$HS_DIR" ] || [ ! "$(find "$WORK_DIR/vendor/$HS_DIR" -name "*.info")" ]; then
        [ -d "$WORK_DIR/vendor/$HS_DIR" ] && DELETE_FROM_WORK_DIR "vendor" "$HS_DIR"
        ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "$HS_DIR" 0 2000 755 "u:object_r:vendor_configs_file:s0"
    fi
    # Model file names differ between sources (hs_segmenter.info vs 12-23_PhotoEditor_SuggestErases_*.info)
    for HS_FILE in $(find "$WORK_DIR/vendor/$HS_DIR" -name "*.info"); do
        VALIDATE_INFO_MODELS "$HS_FILE"
    done
    for HS_FILE in $(find "$WORK_DIR/vendor/$HS_DIR" -name "*.tflite"); do
        VALIDATE_PORTABLE_TFLITE "$HS_FILE"
    done
    unset HS_DIR HS_FILE

    # PhotoRemasterService enables its ARTIFACT_DETECTOR estimator only by checking that
    # /system/lib64/libArtifactDetector_v1.camera.samsung.so exists, but the model it loads
    # (etc/saiv/image_understanding/db/artifact_detector: SNPE 2.39 DSP .dlc) is source-vendor only.
    # Without it the model input size is 0x0 and cv::resize() aborts the whole process (SIGABRT).
    if [ ! -f "$WORK_DIR/vendor/etc/saiv/image_understanding/db/artifact_detector/artifact_detector_cnn.info" ] && \
            [ -f "$WORK_DIR/system/system/lib64/libArtifactDetector_v1.camera.samsung.so" ]; then
        DELETE_FROM_WORK_DIR "system" "system/lib64/libArtifactDetector_v1.camera.samsung.so"
        sed -i "/^libArtifactDetector_v1\.camera\.samsung\.so$/d" "$WORK_DIR/system/system/etc/public.libraries-camera.samsung.txt"
    fi

    # Deleting the lib is not enough on One UI 9: RemasterDirector.initEstimators() only logs
    # ArtifactDetectorWrapper.isArtifactDetectorAvailable() and registers the wrapper for BLUR, MILD_BLUR, LDR,
    # LOWLIGHT, NOISE, DONUT_BLUR, MOIRE, FLARE, REFLECTION and SHADOW anyway; its init() (early estimator init,
    # i.e. as soon as Gallery opens Remaster) then runs ArtifactDetector.<clinit> -> System.load() ->
    # UnsatisfiedLinkError, killing the service. Make the wrapper honour its own availability check: init() does
    # nothing and estimateMulti() returns the empty result map of its existing "ArtifactDetector is null" path.
    # AnalyzerUtil.runEstimator() already treats missing class results as "no result" (null entries are filtered
    # by getNonNullEntries/overrideDetectionResults), so the other estimators and enhancers keep working.
    PRS_APK="system/priv-app/PhotoRemasterService/PhotoRemasterService.apk"
    if [ -f "$WORK_DIR/system/$PRS_APK" ] && \
            [ ! -f "$WORK_DIR/system/system/lib64/libArtifactDetector_v1.camera.samsung.so" ] && \
            [ ! -f "$WORK_DIR/vendor/lib64/libArtifactDetector_v1.camera.samsung.so" ]; then
        DECODE_APK "system" "$PRS_APK" || ABORT "Failed to decode $PRS_APK"
        LOG "- Skipping the missing artifact detector in PhotoRemasterService"
        python3 - "$APKTOOL_DIR/system/${PRS_APK//system\//}" << 'PYEOF' || ABORT "Failed to patch ArtifactDetectorWrapper"
import glob, re, sys
hits = glob.glob(sys.argv[1] + "/smali*/vizinsight/atl/artifactdetector/ArtifactDetectorWrapper.smali")
assert len(hits) == 1, "ArtifactDetectorWrapper: %d" % len(hits)
f = hits[0]
s = open(f).read()
if ":cond_unica_artifact_detector" in s:
    print("  - already patched"); sys.exit(0)
W = "Lvizinsight/atl/artifactdetector/ArtifactDetectorWrapper;"
AVAILABLE = "    invoke-static {}, %s->isArtifactDetectorAvailable()Z\n\n" % W
assert ".method public static isArtifactDetectorAvailable()Z\n" in s, "isArtifactDetectorAvailable()Z"
# every construction of the native detector must sit in the two methods patched below
assert len(re.findall(r"new-instance \w+, Lvizinsight/atl/artifactdetector/ArtifactDetector;", s)) == 2, "ArtifactDetector users"

def method(sig):
    m = re.search(r"^" + re.escape(sig) + r"\n.*?^\.end method\n", s, re.M | re.S)
    assert m, sig
    assert "new-instance" in m.group(0) and "Lvizinsight/atl/artifactdetector/ArtifactDetector;" in m.group(0), sig + ": no detector"
    return m

# init(Context): p1 is free, the method overwrites it with mArtifactDetector first thing
m = method(".method public init(Landroid/content/Context;)V")
head = ".method public init(Landroid/content/Context;)V\n    .locals 0\n\n    iget-object p1, p0, "
assert m.group(0).startswith(head), "init(Context) head"
body = m.group(0).replace("    .locals 0\n\n", "    .locals 0\n\n" + AVAILABLE +
    "    move-result p1\n\n"
    "    if-nez p1, :cond_unica_artifact_detector\n\n"
    "    return-void\n\n"
    "    :cond_unica_artifact_detector\n", 1)
s = s[:m.start()] + body + s[m.end():]

# estimateMulti(...): locals are unassigned at entry; v0 is loaded with `this` by the first instruction
m = method(".method public estimateMulti(Landroid/content/Context;Lcom/samsung/android/photoremaster/sdk/ip/BgrBuffer;ILjava/lang/String;)Ljava/util/Map;")
first = "    .end annotation\n\n    move-object/from16 v0, p0\n"
assert re.search(r"^    \.locals (\d+)$", m.group(0), re.M) and int(re.search(r"^    \.locals (\d+)$", m.group(0), re.M).group(1)) >= 1, "estimateMulti locals"
assert m.group(0).count(first) == 1, "estimateMulti head"
body = m.group(0).replace(first, "    .end annotation\n\n" + AVAILABLE +
    "    move-result v0\n\n"
    "    if-nez v0, :cond_unica_artifact_detector\n\n"
    "    new-instance v0, Ljava/util/HashMap;\n\n"
    "    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V\n\n"
    "    return-object v0\n\n"
    "    :cond_unica_artifact_detector\n"
    "    move-object/from16 v0, p0\n", 1)
s = s[:m.start()] + body + s[m.end():]
open(f, "w").write(s)
print("  - ArtifactDetectorWrapper.init()/estimateMulti() gated on isArtifactDetectorAvailable()")
PYEOF
    fi
    unset PRS_APK

    # Second half of the same service: the resolution upscaler (Gallery > Remaster on a small picture ->
    # UpscaleProcessor -> libmidas "Run AI_UPSCALE_nX LITE"). libmidas_DNNInterface picks the model set from
    # /vendor/etc/midas/midas_config.json: the entry whose models_list names ro.soc.model, else the "default" one.
    # The One UI 9 config swapped the default from the SRIBMidas_aiUPSCALER_nX_LITE_V100_INT8.tflite set (still the
    # default in One UI 8, and the set unica/patches/legacy installs for old vendors) to
    # SRIBMidas_aiUPSCALER_nX_V270_INT8.tflite, which no portable set ships. A missing model is fatal, not an
    # error: AIupscale_1x::Init() fails, calls DeInit(), and that frees a pointer its constructor never
    # initialised -> SIGABRT of the service ("Pointer tag ... was truncated"). When the default set is not
    # installed, point the default entry at the installed SNAPLITE set, taking the tensor names and execution
    # settings from the config's own entry for those files. Only 2X/3X/4X matter: the service's upscale enhancers
    # are VSWUpscale2x/3x/4xEnhancer, and the 1X slot has no installed model in either set.
    MIDAS_CONFIG="$WORK_DIR/vendor/etc/midas/midas_config.json"
    if [ -s "$MIDAS_CONFIG" ]; then
        LOG "- Matching the default MIDAS upscaler entry to the installed models"
        python3 - "$MIDAS_CONFIG" "$TARGET_PLATFORM" << 'PYEOF' || ABORT "Failed to check the MIDAS upscaler models"
import collections, json, os, re, sys
cfg, soc = sys.argv[1], sys.argv[2]
d = os.path.dirname(cfg)

def no_dups(pairs):
    keys = [k for k, _ in pairs]
    assert len(keys) == len(set(keys)), "duplicate keys: %s" % [k for k, c in collections.Counter(keys).items() if c > 1]
    return dict(pairs)

conf = json.loads(open(cfg).read(), object_pairs_hook=no_dups)
ups = [e for e in conf.get("enhancements", []) if e.get("type") == "upscale"]
assert len(ups) == 1, "upscale modules: %d" % len(ups)
infos = ups[0].get("dnn_model_info", [])
entries = [(i, m) for i in infos for m in i.get("compatible_models", [])]
if any(soc.lower() == str(x).lower() for _, m in entries for x in (m.get("models_list") or [])):
    print("  - %s has its own upscaler entry, nothing to do" % soc); sys.exit(0)
defaults = [i for i in infos if i.get("version") == "default"]
assert len(defaults) == 1 and defaults[0].get("compatible_models"), "default upscaler entry"
default = defaults[0]

def scales(files):
    return [f for f in files if re.search(r"_[234]X_", f)]

def have(files):
    return all(os.path.isfile(os.path.join(d, f)) for f in files)

cur = default["compatible_models"][0].get("model_file", [])
assert len(scales(cur)) == 3, "default upscaler files: %s" % cur
if have(scales(cur)):
    print("  - default upscaler models are installed, nothing to do"); sys.exit(0)
donors = [(i, m) for i, m in entries
          if i is not default and i.get("model_format") == "SNAPLITE" and len(m.get("model_file", [])) == len(cur)
          and len(scales(m["model_file"])) == 3 and have(scales(m["model_file"]))]
if not donors:
    print("  ! neither %s nor any other SNAPLITE upscaler set is installed, leaving the config alone" % scales(cur))
    sys.exit(0)
assert len({json.dumps([m["model_file"], i.get("input_node"), i.get("output_node")]) for i, m in donors}) == 1, \
    "ambiguous installed upscaler sets: %s" % [m["model_file"] for _, m in donors]
info, model = donors[0]
# the tensor names of that entry must be the ones the installed models really use
assert isinstance(info.get("input_node"), list) and isinstance(info.get("output_node"), list) and \
    len(info["input_node"]) == len(info["output_node"]) == len(model["model_file"]), "upscaler tensor names"
for f, i, o in zip(model["model_file"], info["input_node"], info["output_node"]):
    if f in scales(model["model_file"]):
        blob = open(os.path.join(d, f), "rb").read()
        assert i.encode() in blob and o.encode() in blob, "%s has no tensors %s/%s" % (f, i, o)
new = {"version": "default"}
new.update((k, v) for k, v in info.items() if k not in ("version", "compatible_models"))
new["compatible_models"] = default["compatible_models"]
new["compatible_models"][0]["model_file"] = list(model["model_file"])
default.clear()
default.update(new)
open(cfg, "w").write(json.dumps(conf, indent=2) + "\n")
print("  - default upscaler entry: %s -> %s" % (scales(cur), scales(model["model_file"])))
PYEOF
    fi
    unset MIDAS_CONFIG

    # The Android 17 PetService requires libPetDetector_v1 plus the new model
    # contract. The target vendor has neither, so keep the capability disabled.
    if [ ! -f "$TARGET_FIRMWARE_ROOT/vendor/lib64/libPetDetector_v1.camera.samsung.so" ]; then
        SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GALLERY_CONFIG_PET_CLUSTER_VERSION" "None"
    fi

    # libDeepDocRectify now reads doc_rectifier_cnn.info, but still supports an
    # ONNX CPU model. Point that manifest at the target's stock portable ONNX.
    SOURCE_DEWARP_INFO="$SOURCE_FIRMWARE_ROOT/vendor/etc/saiv/image_understanding/db/doc_rectifier/doc_rectifier_cnn.info"
    TARGET_DEWARP_MODEL="$WORK_DIR/vendor/saiv/image_understanding/db/smartscan_rectifier/deep_dewarp_cnn.onnx"
    WORK_DEWARP_INFO="$WORK_DIR/vendor/etc/saiv/image_understanding/db/doc_rectifier/doc_rectifier_cnn.info"
    if [[ "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_DOCUMENTSCAN_SOLUTIONS")" == *"AI_DEWARPING"* ]]; then
        if [ -s "$SOURCE_DEWARP_INFO" ] && [ -s "$TARGET_DEWARP_MODEL" ]; then
            ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" \
                "etc/saiv/image_understanding/db/doc_rectifier/doc_rectifier_cnn.info" \
                0 0 644 "u:object_r:vendor_configs_file:s0"
            LOG "- Mapping Android 17 document rectifier to target ONNX model"
            EVAL "printf '%s\n' '{
  \"version_id\": \"v2\",
  \"pcmodel\": \"2.5\",
  \"model_type\": \"cpu\",
  \"precision\": \"float32\",
  \"model_path\": \"/vendor/saiv/image_understanding/db/smartscan_rectifier/deep_dewarp_cnn.onnx\"
}' > \"$WORK_DEWARP_INFO\""
            VALIDATE_INFO_MODELS "$WORK_DEWARP_INFO"
        else
            LOGW "No target-compatible Android 17 document rectifier; disabling AI dewarping"
            REMOVE_FLOATING_FEATURE_TOKEN \
                "SEC_FLOATING_FEATURE_CAMERA_DOCUMENTSCAN_SOLUTIONS" "AI_DEWARPING"
        fi
    fi

    # Android 17 replaced smartcropping_2.0 with this exact TFLite path. The
    # library contains a built-in TFLite interpreter, so this is the only source
    # model imported by the cropper path and is not an SoC-compiled NNC/DLC.
    SOURCE_IMAGE_CROPPER_MODEL="$SOURCE_FIRMWARE_ROOT/system/system/saiv/imageCropper/sce_detector_cnn.tflite"
    if [ ! -s "$SOURCE_IMAGE_CROPPER_MODEL" ]; then
        ABORT "Android 17 ImageCropper model is missing"
    fi
    VALIDATE_PORTABLE_TFLITE "$SOURCE_IMAGE_CROPPER_MODEL"
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" \
        "system/saiv/imageCropper/sce_detector_cnn.tflite" \
        0 0 644 "u:object_r:system_file:s0"
    if [ ! -s "$WORK_DIR/system/system/saiv/imageCropper/sce_detector_cnn.tflite" ]; then
        ABORT "Failed to install Android 17 ImageCropper model"
    fi

    # libStride in Android 17 still names the target's TFLite models and searches
    # this directory. Preserve the target set instead of replacing it, but add every
    # portable model/charset/lexicon the source libStride names that the target set
    # lacks (e.g. the TextBPN text detector and ViT recognizers of One UI 9), or OCR
    # has no detector at all. NPU-specific .dla/.dlc/.nnc variants are not copied.
    STRIDE_LIB="$WORK_DIR/system/system/lib64/libStride.camera.samsung.so"
    STRIDE_DIR="system/saiv/textrecognition/stride"
    STRIDE_NEEDED=""
    if [ -f "$STRIDE_LIB" ]; then
        STRIDE_NEEDED="$(grep -aoE "mSTR_[A-Za-z0-9_]+\.(tflite|charset|bin)" "$STRIDE_LIB" | sort -u)"
    fi
    for MODEL_FILE in $STRIDE_NEEDED; do
        if [ ! -e "$WORK_DIR/system/$STRIDE_DIR/$MODEL_FILE" ] && \
                [ -s "$SOURCE_FIRMWARE_ROOT/system/$STRIDE_DIR/$MODEL_FILE" ]; then
            ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" "$STRIDE_DIR/$MODEL_FILE" \
                0 0 644 "u:object_r:system_file:s0"
        fi
    done
    for MODEL_FILE in mSTR_Arabic.tflite mSTR_Latin.tflite mSTR_CraftBPN_Refiner.tflite; do
        if [ ! "$STRIDE_NEEDED" ] || grep -qx "$MODEL_FILE" <<< "$STRIDE_NEEDED"; then
            VALIDATE_PORTABLE_TFLITE \
                "$WORK_DIR/system/$STRIDE_DIR/$MODEL_FILE"
        fi
    done
    for MODEL_FILE in $(grep -E "\.tflite$" <<< "$STRIDE_NEEDED"); do
        [ -e "$WORK_DIR/system/$STRIDE_DIR/$MODEL_FILE" ] && \
            VALIDATE_PORTABLE_TFLITE "$WORK_DIR/system/$STRIDE_DIR/$MODEL_FILE"
    done
    unset STRIDE_LIB STRIDE_DIR STRIDE_NEEDED

    # Android 17 SmartScan still supports the old _cnn.info + Caffe CPU fallback.
    VALIDATE_INFO_MODELS \
        "$WORK_DIR/vendor/etc/saiv/image_understanding/db/SS_segmenter/SS_segmenter_cnn.info"
else
# SEC_PRODUCT_FEATURE_VISION_CONFIG_FACE_RECOGNITION_SOLUTION
SOURCE_VISION_CONFIG_FACE_RECOGNITION_SOLUTION="$(GET_FLOATING_FEATURE_CONFIG "$FW_DIR/$SOURCE_FIRMWARE_PATH/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_GALLERY_CONFIG_FACE_CLUSTER_VERSION")"
TARGET_VISION_CONFIG_FACE_RECOGNITION_SOLUTION="$(GET_FLOATING_FEATURE_CONFIG "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_GALLERY_CONFIG_FACE_CLUSTER_VERSION")"
if [[ "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GALLERY_CONFIG_FACE_CLUSTER_VERSION")" == "$SOURCE_VISION_CONFIG_FACE_RECOGNITION_SOLUTION" ]]; then
    if [[ "$TARGET_VISION_CONFIG_FACE_RECOGNITION_SOLUTION" != "$SOURCE_VISION_CONFIG_FACE_RECOGNITION_SOLUTION" ]] || \
            [ "$TARGET_PLATFORM_SDK_VERSION" -lt "$SOURCE_PLATFORM_SDK_VERSION" ]; then
        if [ -d "$WORK_DIR/system/system/saiv/face/cluster_pb" ]; then
            DELETE_FROM_WORK_DIR "system" "system/saiv/face/cluster_pb"
        fi
        ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" "system/saiv/face/cluster_pb" 0 0 755 "u:object_r:system_file:s0"
    fi
fi

# SEC_PRODUCT_FEATURE_SAIV_CONFIG_MIDAS
if [ ! -f "$WORK_DIR/vendor/etc/midas/moire_detection/moire_detection.tflite" ]; then
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "etc/midas/moire_detection/moire_detection.tflite" 0 0 644 "u:object_r:vendor_configs_file:s0"
fi
if [ ! "$(find "$WORK_DIR/vendor/etc/midas" -maxdepth 1 -type f -name "SRIBMQA_aiFiQA*" 2> /dev/null)" ]; then
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "etc/midas/SRIBMQA_aiFiQA_V100_FP32.tflite" 0 0 644 "u:object_r:vendor_configs_file:s0"
fi
if [ ! -f "$WORK_DIR/vendor/etc/midas/SRIBMQA_aiIQA_V100_FP32.tflite" ]; then
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "etc/midas/SRIBMQA_aiIQA_V100_FP32.tflite" 0 0 644 "u:object_r:vendor_configs_file:s0"
fi
if [ "$(find "$WORK_DIR/vendor/etc/midas" -maxdepth 1 -type f -name "*UPSCALER_*_LITE*" 2> /dev/null)" ]; then
    # Ensure AI_UPSCALE LITE models are loaded if available
    if ! sed -n "/\"midasSR_devices\"/,/]/p" "$WORK_DIR/vendor/etc/midas/midas_config.json" | grep -q "\"$(GET_PROP "ro.product.device")\""; then
        LOG "- Patching /vendor/etc/midas/midas_config.json"
        EVAL "sed -i \"/\\\"midasSR_devices\\\"[^[]*\\[/a\\\\    \\\"$(GET_PROP "ro.product.device")\\\",\" \"$WORK_DIR/vendor/etc/midas/midas_config.json\""
    fi
fi

# SEC_PRODUCT_FEATURE_GALLERY_CONFIG_IMAGE_TAGGER_VERSION
SOURCE_GALLERY_CONFIG_IMAGE_TAGGER_VERSION="$(GET_FLOATING_FEATURE_CONFIG "$FW_DIR/$SOURCE_FIRMWARE_PATH/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_GALLERY_CONFIG_IMAGE_TAGGER_VERSION")"
TARGET_GALLERY_CONFIG_IMAGE_TAGGER_VERSION="$(GET_FLOATING_FEATURE_CONFIG "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_GALLERY_CONFIG_IMAGE_TAGGER_VERSION")"
if [[ "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GALLERY_CONFIG_IMAGE_TAGGER_VERSION")" == "$SOURCE_GALLERY_CONFIG_IMAGE_TAGGER_VERSION" ]]; then
    if [[ "$TARGET_GALLERY_CONFIG_IMAGE_TAGGER_VERSION" != "$SOURCE_GALLERY_CONFIG_IMAGE_TAGGER_VERSION" ]] || \
            [ "$TARGET_PLATFORM_SDK_VERSION" -lt "$SOURCE_PLATFORM_SDK_VERSION" ]; then
        if [ -d "$WORK_DIR/system/system/saiv/image_understanding/db/aig" ]; then
            DELETE_FROM_WORK_DIR "system" "system/saiv/image_understanding/db/aig"
        fi
        ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" "system/saiv/image_understanding/db/aig" 0 0 755 "u:object_r:system_file:s0"
        if [ -d "$WORK_DIR/vendor/saiv/image_understanding/db/aig_classifier" ]; then
            DELETE_FROM_WORK_DIR "vendor" "saiv/image_understanding/db/aig_classifier"
        fi
        ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "saiv/image_understanding/db/aig_classifier" 0 2000 755 "u:object_r:vendor_snap_file:s0"
        if [ -d "$WORK_DIR/vendor/saiv/image_understanding/db/aig_document_classifier" ]; then
            DELETE_FROM_WORK_DIR "vendor" "saiv/image_understanding/db/aig_document_classifier"
        fi
        ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "saiv/image_understanding/db/aig_document_classifier" 0 2000 755 "u:object_r:vendor_snap_file:s0"
        if [ -d "$WORK_DIR/vendor/saiv/image_understanding/db/aig_document_detector" ]; then
            DELETE_FROM_WORK_DIR "vendor" "saiv/image_understanding/db/aig_document_detector"
        fi
        ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "saiv/image_understanding/db/aig_document_detector" 0 2000 755 "u:object_r:vendor_snap_file:s0"
    fi
fi

# Photo Editor "oneUI-full-release"/"genAI-full-release" flavor models
if [ -f "$WORK_DIR/system/system/priv-app/PhotoEditor_Full/PhotoEditor_Full.apk" ] || \
        [ -f "$WORK_DIR/system/system/priv-app/PhotoEditor_AIFull/PhotoEditor_AIFull.apk" ]; then
    if [ ! -d "$WORK_DIR/vendor/etc/saiv/image_understanding/db/hs_segmenter" ] || \
            [ "$TARGET_PLATFORM_SDK_VERSION" -lt "$SOURCE_PLATFORM_SDK_VERSION" ]; then
        if [ -d "$WORK_DIR/vendor/etc/saiv/image_understanding/db/hs_segmenter" ]; then
            DELETE_FROM_WORK_DIR "vendor" "etc/saiv/image_understanding/db/hs_segmenter"
        fi
        ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "etc/saiv/image_understanding/db/hs_segmenter" 0 0 644 "u:object_r:vendor_configs_file:s0"
    fi
else
    if [ -d "$WORK_DIR/vendor/etc/saiv/image_understanding/db/hs_segmenter" ]; then
        DELETE_FROM_WORK_DIR "vendor" "etc/saiv/image_understanding/db/hs_segmenter"
    fi
fi

# SEC_PRODUCT_FEATURE_GALLERY_CONFIG_PET_CLUSTER_VERSION
SOURCE_GALLERY_CONFIG_PET_CLUSTER_VERSION="$(GET_FLOATING_FEATURE_CONFIG "$FW_DIR/$SOURCE_FIRMWARE_PATH/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_GALLERY_CONFIG_PET_CLUSTER_VERSION")"
TARGET_GALLERY_CONFIG_PET_CLUSTER_VERSION="$(GET_FLOATING_FEATURE_CONFIG "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_GALLERY_CONFIG_PET_CLUSTER_VERSION")"
if [[ "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GALLERY_CONFIG_PET_CLUSTER_VERSION")" == "$SOURCE_GALLERY_CONFIG_PET_CLUSTER_VERSION" ]]; then
    if [[ "$SOURCE_GALLERY_CONFIG_PET_CLUSTER_VERSION" != "None" ]]; then
        if [[ "$TARGET_GALLERY_CONFIG_PET_CLUSTER_VERSION" != "$SOURCE_GALLERY_CONFIG_PET_CLUSTER_VERSION" ]] || \
                [ "$TARGET_PLATFORM_SDK_VERSION" -lt "$SOURCE_PLATFORM_SDK_VERSION" ]; then
            if [ -d "$WORK_DIR/vendor/saiv/image_understanding/db/pet_detector" ]; then
                DELETE_FROM_WORK_DIR "vendor" "saiv/image_understanding/db/pet_detector"
            fi
            ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "saiv/image_understanding/db/pet_detector" 0 2000 755 "u:object_r:vendor_snap_file:s0"
            if [ -d "$WORK_DIR/vendor/saiv/image_understanding/db/pet_mypetsearch" ]; then
                DELETE_FROM_WORK_DIR "vendor" "saiv/image_understanding/db/pet_mypetsearch"
            fi
            ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "saiv/image_understanding/db/pet_mypetsearch" 0 2000 755 "u:object_r:vendor_snap_file:s0"
        fi
    else
        if [ -d "$WORK_DIR/vendor/saiv/image_understanding/db/pet_detector" ]; then
            DELETE_FROM_WORK_DIR "vendor" "saiv/image_understanding/db/pet_detector"
        fi
        if [ -d "$WORK_DIR/vendor/saiv/image_understanding/db/pet_mypetsearch" ]; then
            DELETE_FROM_WORK_DIR "vendor" "saiv/image_understanding/db/pet_mypetsearch"
        fi
    fi
fi

# SEC_PRODUCT_FEATURE_VISION_CONFIG_BIXBYVISION_VERSION
if [ -f "$WORK_DIR/system/system/priv-app/BixbyVisionFramework3.5/BixbyVisionFramework3.5.apk" ]; then
    if [ ! -d "$WORK_DIR/vendor/etc/saiv/image_understanding/db/slens_classifier" ] || \
            [ "$TARGET_PLATFORM_SDK_VERSION" -lt "$SOURCE_PLATFORM_SDK_VERSION" ]; then
        if [ -d "$WORK_DIR/system/system/saiv/image_understanding/db/slens_classifier" ]; then
            DELETE_FROM_WORK_DIR "system" "system/saiv/image_understanding/db/slens_classifier"
        fi
        ADD_TO_WORK_DIR "gts11xx" "system" "system/saiv/image_understanding/db/slens_classifier/slens_classifier_cnn.sni" 0 0 644 "u:object_r:system_file:s0"
        if [ -d "$WORK_DIR/vendor/etc/saiv/image_understanding/db/slens_classifier" ]; then
            DELETE_FROM_WORK_DIR "vendor" "etc/saiv/image_understanding/db/slens_classifier"
        fi
        ADD_TO_WORK_DIR "gts11xx" "vendor" "etc/saiv/image_understanding/db/slens_classifier/slens_classifier_cnn.tflite" 0 0 644 "u:object_r:vendor_configs_file:s0"
    fi
    if [ ! -d "$WORK_DIR/vendor/etc/saiv/image_understanding/db/slens_detector" ] || \
            [ "$TARGET_PLATFORM_SDK_VERSION" -lt "$SOURCE_PLATFORM_SDK_VERSION" ]; then
        if [ -d "$WORK_DIR/system/system/saiv/image_understanding/db/slens_detector" ]; then
            DELETE_FROM_WORK_DIR "system" "system/saiv/image_understanding/db/slens_detector"
        fi
        ADD_TO_WORK_DIR "gts11xx" "system" "system/saiv/image_understanding/db/slens_detector/slens_detector_cnn.sni" 0 0 644 "u:object_r:system_file:s0"
        if [ -d "$WORK_DIR/vendor/etc/saiv/image_understanding/db/slens_detector" ]; then
            DELETE_FROM_WORK_DIR "vendor" "etc/saiv/image_understanding/db/slens_detector"
        fi
        ADD_TO_WORK_DIR "gts11xx" "vendor" "etc/saiv/image_understanding/db/slens_detector/slens_detector_cnn.tflite" 0 0 644 "u:object_r:vendor_configs_file:s0"
    fi
else
    if [ -d "$WORK_DIR/system/system/saiv/image_understanding/db/slens_classifier" ]; then
        DELETE_FROM_WORK_DIR "system" "system/saiv/image_understanding/db/slens_classifier"
    fi
    if [ -d "$WORK_DIR/system/system/saiv/image_understanding/db/slens_detector" ]; then
        DELETE_FROM_WORK_DIR "system" "system/saiv/image_understanding/db/slens_detector"
    fi
    if [ -d "$WORK_DIR/vendor/etc/saiv/image_understanding/db/slens_classifier" ]; then
        DELETE_FROM_WORK_DIR "vendor" "etc/saiv/image_understanding/db/slens_classifier"
    fi
    if [ -d "$WORK_DIR/vendor/etc/saiv/image_understanding/db/slens_detector" ]; then
        DELETE_FROM_WORK_DIR "vendor" "etc/saiv/image_understanding/db/slens_detector"
    fi
fi

# SEC_PRODUCT_FEATURE_CAMERA_CONFIG_DOCUMENT_DEWARP_VERSION
SOURCE_CAMERA_CONFIG_DOCUMENT_DEWARP_VERSION="$(GET_FLOATING_FEATURE_CONFIG "$FW_DIR/$SOURCE_FIRMWARE_PATH/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_CAMERA_DOCUMENTSCAN_SOLUTIONS")"
TARGET_CAMERA_CONFIG_DOCUMENT_DEWARP_VERSION="$(GET_FLOATING_FEATURE_CONFIG "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_CAMERA_DOCUMENTSCAN_SOLUTIONS")"
if [[ "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_DOCUMENTSCAN_SOLUTIONS")" == "$SOURCE_CAMERA_CONFIG_DOCUMENT_DEWARP_VERSION" ]]; then
    if [[ "$SOURCE_CAMERA_CONFIG_DOCUMENT_DEWARP_VERSION" == *"AI_DEWARPING"* ]]; then
        if [[ "$TARGET_CAMERA_CONFIG_DOCUMENT_DEWARP_VERSION" != *"AI_DEWARPING"* ]] || \
                [ "$TARGET_PLATFORM_SDK_VERSION" -lt "$SOURCE_PLATFORM_SDK_VERSION" ]; then
            ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" \
                "system" "system/saiv/image_understanding/db/smartscan_rectifier/deep_dewarp_cnn.sni" 0 0 644 "u:object_r:system_file:s0"
            ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" \
                "vendor" "saiv/image_understanding/db/smartscan_rectifier/deep_dewarp_cnn.onnx" 0 0 644 "u:object_r:vendor_snap_file:s0"
        fi
    else
        if [ -d "$WORK_DIR/system/system/saiv/image_understanding/db/smartscan_rectifier" ]; then
            DELETE_FROM_WORK_DIR "system" "system/saiv/image_understanding/db/smartscan_rectifier"
        fi
        if [ -d "$WORK_DIR/vendor/saiv/image_understanding/db/smartscan_rectifier" ]; then
            DELETE_FROM_WORK_DIR "vendor" "saiv/image_understanding/db/smartscan_rectifier"
        fi
    fi
fi

# SEC_PRODUCT_FEATURE_VISION_CONFIG_SMART_CROPPING_SOLUTION
if [ ! -d "$WORK_DIR/system/system/saiv/smartcropping_2.0" ] || \
        [ "$TARGET_PLATFORM_SDK_VERSION" -lt "$SOURCE_PLATFORM_SDK_VERSION" ]; then
    if [ -d "$WORK_DIR/system/system/saiv/smartcropping_2.0" ]; then
        DELETE_FROM_WORK_DIR "system" "system/saiv/smartcropping_2.0"
    fi
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" "system/saiv/smartcropping_2.0/db/smartcrop_saliency_deploy.prototxt" 0 0 644 "u:object_r:system_file:s0"
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" "system/saiv/smartcropping_2.0/db/smartcrop_saliency_train" 0 0 644 "u:object_r:system_file:s0"
fi
if [ ! -d "$WORK_DIR/vendor/saiv/image_understanding/db/sce_detector" ] || \
        [ "$TARGET_PLATFORM_SDK_VERSION" -lt "$SOURCE_PLATFORM_SDK_VERSION" ]; then
    if [ -d "$WORK_DIR/vendor/saiv/image_understanding/db/sce_detector" ]; then
        DELETE_FROM_WORK_DIR "vendor" "saiv/image_understanding/db/sce_detector"
    fi
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "saiv/image_understanding/db/sce_detector/sce_detector_cnn.tflite" 0 0 644 "u:object_r:vendor_snap_file:s0"
fi

# SEC_PRODUCT_FEATURE_CAMERA_CONFIG_STRIDE_OCR_VERSION
if [ -d "$WORK_DIR/system/system/saiv/textrecognition" ]; then
    DELETE_FROM_WORK_DIR "system" "system/saiv/textrecognition"
fi
ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" "system/saiv/textrecognition" 0 0 755 "u:object_r:system_file:s0"

# SEC_PRODUCT_FEATURE_CAMERA_CONFIG_VENDOR_LIB_INFO:=*smart_scan.samsung.v2*
if [ -f "$WORK_DIR/system/system/lib64/libSmartScan.camera.samsung.so" ]; then
    if [ ! -d "$WORK_DIR/vendor/etc/saiv/image_understanding/db/SS_segmenter" ] || \
            [ "$TARGET_PLATFORM_SDK_VERSION" -lt "$SOURCE_PLATFORM_SDK_VERSION" ]; then
        if [ -d "$WORK_DIR/vendor/etc/saiv/image_understanding/db/SS_segmenter" ]; then
            DELETE_FROM_WORK_DIR "vendor" "etc/saiv/image_understanding/db/SS_segmenter"
        fi
        ADD_TO_WORK_DIR "a34xxx" "vendor" "etc/saiv/image_understanding/db/SS_segmenter/SS_segmenter_cnn.tflite" 0 0 644 "u:object_r:vendor_configs_file:s0"
        ADD_TO_WORK_DIR "a34xxx" "vendor" "etc/saiv/image_understanding/db/SS_segmenter/SS_segmenter_cnn.info" 0 0 644 "u:object_r:vendor_configs_file:s0"
    fi
fi
fi

unset SOURCE_FIRMWARE_PATH TARGET_FIRMWARE_PATH SOURCE_FIRMWARE_ROOT TARGET_FIRMWARE_ROOT \
    SOURCE_VISION_CONFIG_FACE_RECOGNITION_SOLUTION TARGET_VISION_CONFIG_FACE_RECOGNITION_SOLUTION \
    SOURCE_GALLERY_CONFIG_IMAGE_TAGGER_VERSION TARGET_GALLERY_CONFIG_IMAGE_TAGGER_VERSION \
    SOURCE_GALLERY_CONFIG_PET_CLUSTER_VERSION TARGET_GALLERY_CONFIG_PET_CLUSTER_VERSION \
    SOURCE_CAMERA_CONFIG_DOCUMENT_DEWARP_VERSION TARGET_CAMERA_CONFIG_DOCUMENT_DEWARP_VERSION \
    TARGET_SAIV_CONFIG_MIDAS UNIFIED_INFO TARGET_AIC_DETECTOR TARGET_AIC_CLASSIFIER \
    SOURCE_DEWARP_INFO TARGET_DEWARP_MODEL WORK_DEWARP_INFO SOURCE_IMAGE_CROPPER_MODEL \
    MODEL_FILE
unset -f VALIDATE_INFO_MODELS VALIDATE_PORTABLE_TFLITE REMOVE_FLOATING_FEATURE_TOKEN
unset -f SAIV_WARN
