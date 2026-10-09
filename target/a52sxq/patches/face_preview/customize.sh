# Face registration on One UI 9 + HIDL face HAL: the HAL sends preview frames through
# FaceManager.EnrollmentCallback.onImageProcessed(byte[] nv21, w, h, orientation, format, Bundle{memoryfile_descriptor})
# (system_server SemFaceServiceExImpl.sendImageProcessed), but the Fold8 BiometricSetting's enrollment callback
# (FaceEnrollActivity$6) only handles onEnrollmentFrame/Progress/Error and relies on the HAL drawing into the
# Surface it created from the face_preview TextureView. Add the missing callback: it hands the frame to
# com.k4.face.K4FacePreview, which converts NV21 -> JPEG -> Bitmap, rotates/mirrors it and draws it into that
# TextureView's SurfaceTexture.
BSS="system/priv-app/BiometricSetting/BiometricSetting.apk"
DECODE_APK "system" "$BSS" || ABORT "Failed to decode $BSS"
DIR="$APKTOOL_DIR/system/${BSS//system\//}"
# The anonymous callback class is FaceEnrollActivity$6 on the Fold8 and S25 builds; locate it by its superclass so a
# renumbered class ($5, $7, ...) is still found.
CB="$(grep -l -x '\.super Landroid/hardware/face/FaceManager\$EnrollmentCallback;' \
    "$DIR"/smali*/com/samsung/android/biometrics/app/setting/face/FaceEnrollActivity\$*.smali 2> /dev/null)"
if [ "$(wc -l <<< "$CB")" -gt 1 ]; then
    ABORT "More than one FaceManager.EnrollmentCallback in FaceEnrollActivity: $CB"
fi
if [ -f "$CB" ]; then
    LOG "- Rendering the HIDL face HAL preview frames in the enrollment screen (${CB##*/})"
    SMALI_ROOT="${CB%%/com/samsung/*}"
    mkdir -p "$SMALI_ROOT/com/k4/face"
    cp -f "$SRC_DIR/target/$TARGET_CODENAME/patches/face_preview/K4FacePreview.smali" "$SMALI_ROOT/com/k4/face/K4FacePreview.smali"
    python3 - "$CB" "$DIR/res/values/public.xml" << 'PYEOF' || ABORT "Failed to patch FaceEnrollActivity\$6"
import re, sys
cb, pub = sys.argv[1], sys.argv[2]
src = open(cb).read()
if "onImageProcessed([BIIIILandroid/os/Bundle;)V" in src:
    print("  - FaceEnrollActivity$6 already patched"); sys.exit(0)
m = re.search(r'<public type="id" name="face_preview" id="(0x[0-9a-f]+)" />', open(pub).read())
if not m: sys.exit("id/face_preview not found in public.xml")
rid = m.group(1)
cls = re.search(r"^\.class [^\n]*?(L[^;\s]+;)\s*$", src, re.M).group(1)
outer = re.search(r"^\.field public final synthetic this\$0:(L[^;]+;)", src, re.M).group(1)
method = """
# k4_un1ca: draw the HIDL face HAL's callback preview frames into the face_preview TextureView
.method public final onImageProcessed([BIIIILandroid/os/Bundle;)V
    .locals 2

    iget-object v0, p0, %s->this$0:%s

    const v1, %s

    invoke-virtual {v0, v1}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;

    move-result-object v1

    invoke-static/range {v1 .. v8}, Lcom/k4/face/K4FacePreview;->render(Landroid/view/View;Ljava/lang/Object;[BIIIILandroid/os/Bundle;)V

    return-void
.end method
""" % (cls, outer, rid)
open(cb, "w").write(src.rstrip("\n") + "\n" + method)
print("  - Added onImageProcessed to %s (face_preview=%s)" % (cls, rid))
PYEOF
else
    LOG "- No FaceManager.EnrollmentCallback in FaceEnrollActivity in this source, skipping"
fi
unset BSS DIR CB SMALI_ROOT
