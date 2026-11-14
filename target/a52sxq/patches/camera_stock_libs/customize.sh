SKIPUNZIP=1

# See module.prop. Same files and public.libraries entries as the stock A52s system.
TARGET_LIB64="$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/lib64"
PUBLIC_CAM="$WORK_DIR/system/system/etc/public.libraries-camera.samsung.txt"
PUBLIC_ARC="$WORK_DIR/system/system/etc/public.libraries-arcsoft.txt"
for p in "$PUBLIC_CAM" "$PUBLIC_ARC"; do
    [ -f "$p" ] || ABORT "camera_stock_libs: ${p//$WORK_DIR/} not found"
done
for f in libUltraWideDistortionCorrection.camera.samsung.so libPortraitDistortionCorrection.arcsoft.so \
        libPortraitDistortionCorrectionCali.arcsoft.so libFacialBasedSelfieCorrection.camera.samsung.so \
        libSceneDetector_v1.camera.samsung.so; do
    [ -f "$TARGET_LIB64/$f" ] || ABORT "camera_stock_libs: target firmware has no system/lib64/$f"
    ADD_TO_WORK_DIR "$FW_DIR/$TARGET_FIRMWARE_PATH" "system" "system/lib64/$f" 0 0 644 "u:object_r:system_lib_file:s0"
    case "$f" in *.arcsoft.so) p="$PUBLIC_ARC" ;; *) p="$PUBLIC_CAM" ;; esac
    grep -q "^$f$" "$p" || echo "$f" >> "$p"
done
for f in libOpenCv.camera.samsung.so libBeauty_v4.camera.samsung.so; do
    grep -q "^$f$" "$PUBLIC_CAM" || ABORT "camera_stock_libs: $f is not a public camera library"
done
LOG "- Camera: A52s ultra wide (UWDC/PDC), selfie shape correction and scene detector libraries"
unset TARGET_LIB64 PUBLIC_CAM PUBLIC_ARC f p
