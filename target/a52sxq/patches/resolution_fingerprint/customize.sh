# From the resolution audit of 2026-10-13 (/mnt/B1/OneUi9/scratch/resaudit; dry-run with proposed/dryrun.sh). See module.prop.
# Verify after flashing: select HD+, reboot, then (phone unlocked)  adb shell dumpsys fingerprint | grep -A1 "FOD :"
# must still print fod_rect=Rect(420, 2017 - 658, 2255) and "TSP : set_fod_rect,420,2017,658,2255".
SERVICES="system/framework/services.jar"
DECODE_APK "system" "$SERVICES" || ABORT "Failed to decode $SERVICES"
LOG "- FOD rect: pairing DisplayMetrics.xdpi with the logical display width (SemUdfpsHelper.fetchDisplayInfo)"
python3 - "$APKTOOL_DIR/system/${SERVICES//system\//}" << 'PYEOF' || ABORT "Failed to patch SemUdfpsHelper"
import glob, os, re, sys
root = sys.argv[1]
hits = glob.glob(root + "/smali*/com/android/server/biometrics/sensors/fingerprint/SemUdfpsHelper.smali")
assert len(hits) == 1, "SemUdfpsHelper: %d" % len(hits)
f = hits[0]
s = open(f).read()
K4 = "Lcom/android/server/biometrics/sensors/fingerprint/K4DpiWidth;"
m = re.search(r"^\.method public static fetchDisplayInfo\(Landroid/content/Context;\)"
              r"Lcom/android/server/biometrics/sensors/fingerprint/SemUdfpsHelper\$DisplayInfo;\n.*?^\.end method\n", s, re.M | re.S)
assert m, "fetchDisplayInfo"
body = m.group(0)
# Display v1 -> getMode() -> p0 ; getMetrics(v1, v2) ; p0.getPhysicalWidth() ; / v2.xdpi
old = re.compile(
    r"( +invoke-virtual \{v1\}, Landroid/view/Display;->getMode\(\)Landroid/view/Display\$Mode;\n\n"
    r" +move-result-object p0\n\n"
    r" +new-instance v2, Landroid/util/DisplayMetrics;\n\n"
    r" +invoke-direct \{v2\}, Landroid/util/DisplayMetrics;-><init>\(\)V\n\n"
    r" +invoke-virtual \{v1, v2\}, Landroid/view/Display;->getMetrics\(Landroid/util/DisplayMetrics;\)V\n\n"
    r")( +)invoke-virtual \{p0\}, Landroid/view/Display\$Mode;->getPhysicalWidth\(\)I\n(?=\n +move-result p0\n\n +int-to-float p0, p0\n\n"
    r" +iget v1, v2, Landroid/util/DisplayMetrics;->xdpi:F\n\n +div-float/2addr p0, v1\n)")
new_call = "invoke-static {v1, p0}, %s->get(Landroid/view/Display;Landroid/view/Display$Mode;)I\n" % K4
if new_call in body:
    print("  - fetchDisplayInfo already patched")
else:
    assert body.count("->getPhysicalWidth()I") == 1, "getPhysicalWidth calls: %d" % body.count("->getPhysicalWidth()I")
    hit = old.findall(body)
    assert len(hit) == 1, "mode width / xdpi sequence: %d" % len(hit)
    body2 = old.sub(lambda mm: mm.group(1) + mm.group(2) + new_call, body)
    s = s[:m.start()] + body2 + s[m.end():]
    open(f, "w").write(s)
    print("  - fetchDisplayInfo: Display.Mode.getPhysicalWidth() -> K4DpiWidth.get(display, mode)")
dst = os.path.join(os.path.dirname(f), "K4DpiWidth.smali")
open(dst, "w").write("""\
.class public final %(K4)s
.super Ljava/lang/Object;
.source "K4DpiWidth.java"


# a52sxq resolution_fingerprint patch: the width (rotation 0) of the pixel grid that DisplayMetrics.xdpi of a display
# refers to. patches/resolution_scaling scales the physical dpi with a forced display size, so that grid is the
# logical (forced) one, not the active display mode's. Falls back to the mode's width.

# direct methods
.method private constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static get(Landroid/view/Display;Landroid/view/Display$Mode;)I
    .locals 2

    :try_start_0
    new-instance v0, Landroid/view/DisplayInfo;

    invoke-direct {v0}, Landroid/view/DisplayInfo;-><init>()V

    invoke-virtual {p0, v0}, Landroid/view/Display;->getDisplayInfo(Landroid/view/DisplayInfo;)Z

    move-result v1

    if-eqz v1, :cond_mode

    invoke-virtual {v0}, Landroid/view/DisplayInfo;->getNaturalWidth()I

    move-result v0
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    if-lez v0, :cond_mode

    return v0

    :catch_0
    move-exception v0

    :cond_mode
    invoke-virtual {p1}, Landroid/view/Display$Mode;->getPhysicalWidth()I

    move-result v0

    return v0
.end method
""" % dict(K4=K4))
print("  - helper %s" % os.path.relpath(dst, root))
PYEOF

BSS="system/priv-app/BiometricSetting/BiometricSetting.apk"
DECODE_APK "system" "$BSS" || ABORT "Failed to decode $BSS"
LOG "- Optical light disc: recompute the position every time the light is switched on (LightSourceView)"
python3 - "$APKTOOL_DIR/system/${BSS//system\//}" << 'PYEOF' || ABORT "Failed to patch LightSourceView.handleLightSource"
import glob, re, sys
hits = glob.glob(sys.argv[1] + "/smali*/com/samsung/android/biometrics/app/setting/fingerprint/LightSourceView.smali")
assert len(hits) == 1, "LightSourceView"
f = hits[0]
s = open(f).read()
LSV = "Lcom/samsung/android/biometrics/app/setting/fingerprint/LightSourceView;"
m = re.search(r"^\.method public final handleLightSource\(Z\)V\n.*?^\.end method\n", s, re.M | re.S)
assert m, "handleLightSource"
body = m.group(0)
guard = re.compile(r" +iget v0, p0, %s->mCurrentRotation:I\n\n"
                   r" +iget-object v1, p0, %s->mContext:Landroid/content/Context;\n\n"
                   r" +invoke-static \{v1\}, Lcom/samsung/android/biometrics/app/setting/Utils;->getRotation\(Landroid/content/Context;\)I\n\n"
                   r" +move-result v1\n\n"
                   r" +if-eq v0, v1, :cond_0\n\n"
                   r"(?= +invoke-virtual \{p0\}, %s->setLightSourceInfo\(\)V\n)" % (re.escape(LSV), re.escape(LSV), re.escape(LSV)))
if "mCurrentRotation" not in body:
    print("  - handleLightSource already patched")
else:
    assert len(guard.findall(body)) == 1, "rotation guard"
    s = s[:m.start()] + guard.sub("", body) + s[m.end():]
    open(f, "w").write(s)
    print("  - handleLightSource: rotation guard removed")
PYEOF
unset SERVICES BSS
