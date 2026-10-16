# Helpers for the remaster_models patch (see module.prop). Sourced by customize.sh (source check, device patch stage)
# and by target/a52sxq/post_mods.sh (install, after unica/patches/legacy replaced /vendor/etc/midas).
#
# Sources: the extracted firmwares the build already has (nothing is kept in git).
#   T = target firmware (stock A52s A528BXXU5FWK4 vendor), S = source firmware (S26 Ultra)
# Each line: <T|S> <path under vendor/etc/midas in that firmware> <path under /vendor/etc/midas to install>
REMASTER_MODELS_LIST="\
T SRIBMidas_aiHDR_Global_INT16_V430_sm7325_snpe1502.dlc SRIBMidas_aiHDR_Global_INT16_V430_sm7325_snpe1502.dlc
T SRIBMidas_aiHDR_Local_INT16_V430_sm7325_snpe1502.dlc SRIBMidas_aiHDR_Local_INT16_V430_sm7325_snpe1502.dlc
T SRIBMQA_aiIQA_V100_FP32.tflite SRIBMQA_aiIQA_V100_FP32.tflite
T SRIBMQA_aiFiQA_V100_FP32.tflite SRIBMQA_aiFiQA_V100_FP32.tflite
S 16_8_PhotoRemaster_MQA_aiBLURESTIMATE_V100_FP32.tflite 16_8_PhotoRemaster_MQA_aiBLURESTIMATE_V100_FP32.tflite
S 16_9_PhotoRemaster_MQA_aiNOISEDETECT_V100_FP32.tflite 16_9_PhotoRemaster_MQA_aiNOISEDETECT_V100_FP32.tflite
S moire_detection/moire_detection.tflite moire_detection/moire_detection.tflite"

# REMASTER_MODELS_SRC <T|S> -> firmware root
REMASTER_MODELS_SRC()
{
    case "$1" in
        T) echo "$FW_DIR/$TARGET_FIRMWARE_PATH" ;;
        S) echo "$FW_DIR/$SOURCE_FIRMWARE_PATH" ;;
        *) return 1 ;;
    esac
}

REMASTER_MODELS_CHECK_SOURCES()
{
    local WHICH FROM TO ROOT
    while read -r WHICH FROM TO; do
        [ "$WHICH" ] || continue
        ROOT="$(REMASTER_MODELS_SRC "$WHICH")" || ABORT "remaster_models: bad source tag $WHICH"
        [ -s "$ROOT/vendor/etc/midas/$FROM" ] || ABORT "remaster_models: ${ROOT//$SRC_DIR\//}/vendor/etc/midas/$FROM is missing. It ships in the stock firmware this build extracts (T = $TARGET_FIRMWARE, S = $SOURCE_FIRMWARE); re-extract that firmware (scripts/extract_fw.sh). Without the two aiHDR .dlc files Gallery Remaster crashes photoremasterservice (SIGABRT in AIhdr::DeInit)."
    done <<< "$REMASTER_MODELS_LIST"
}

REMASTER_MODELS_INSTALL()
{
    local MIDAS="$WORK_DIR/vendor/etc/midas"
    local WHICH FROM TO ROOT

    [ -s "$MIDAS/midas_config.json" ] || ABORT "remaster_models: /vendor/etc/midas/midas_config.json not found"
    REMASTER_MODELS_CHECK_SOURCES

    LOG_STEP_IN "- Installing the SM7325 Remaster models into /vendor/etc/midas"
    while read -r WHICH FROM TO; do
        [ "$WHICH" ] || continue
        ROOT="$(REMASTER_MODELS_SRC "$WHICH")"
        if [[ "$TO" == */* ]] && [ ! -d "$MIDAS/$(dirname "$TO")" ]; then
            EVAL "mkdir -p \"$MIDAS/$(dirname "$TO")\"" || ABORT "remaster_models: mkdir for $TO failed"
            SET_METADATA "vendor" "etc/midas/$(dirname "$TO")" 0 2000 755 "u:object_r:vendor_configs_file:s0"
        fi
        EVAL "cp -f \"$ROOT/vendor/etc/midas/$FROM\" \"$MIDAS/$TO\"" || ABORT "remaster_models: failed to install $TO"
        SET_METADATA "vendor" "etc/midas/$TO" 0 0 644 "u:object_r:vendor_configs_file:s0"
    done <<< "$REMASTER_MODELS_LIST"

    # Resolve every module the way libmidas_DNNInterface does (entry whose models_list names ro.soc.model, else the
    # "default" entry) and check the installed files. HDR is mandatory: REMASTER_V4 applies it to every picture and a
    # missing HDR model aborts the service. Anything else unresolved is only listed.
    python3 - "$MIDAS/midas_config.json" "${TARGET_PLATFORM^^}" << 'PYEOF' || ABORT "remaster_models: the SM7325 HDR models do not resolve, see above"
import json, os, sys
cfg, soc = sys.argv[1], sys.argv[2]
d = os.path.dirname(cfg)
conf = json.load(open(cfg))
assert conf.get("device_property") == "ro.soc.model", "device_property is %r, expected ro.soc.model" % conf.get("device_property")
hdr_ok = False
for section in ("enhancements", "detection"):
    for mod in conf.get(section, []):
        pick = None
        for info in mod.get("dnn_model_info", []):
            for m in info.get("compatible_models", []):
                if any(soc.lower() == str(x).lower() for x in (m.get("models_list") or [])):
                    pick = pick or ("soc", m.get("model_file", []))
        if not pick:
            for info in mod.get("dnn_model_info", []):
                if info.get("version") == "default" and info.get("compatible_models"):
                    pick = ("default", info["compatible_models"][0].get("model_file", []))
                    break
        if not pick:
            continue
        missing = [f for f in dict.fromkeys(pick[1]) if not os.path.isfile(os.path.join(d, f))]
        print("  - %s %s (%s): %s" % (section[:3], mod.get("type"), pick[0], "ok" if not missing else "MISSING " + ", ".join(missing)))
        if mod.get("type") == "hdr":
            hdr_ok = pick[0] == "soc" and not missing
if not hdr_ok:
    print("  ! hdr does not resolve to an installed %s model set" % soc)
    sys.exit(1)
PYEOF

    LOG_STEP_OUT
}
