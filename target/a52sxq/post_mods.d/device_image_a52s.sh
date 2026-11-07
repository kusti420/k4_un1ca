# Sourced from post_mods.sh (after unica/mods/device_image, which device patches run before).
# Settings > About phone header:
# - Picture: SecSettings downloads it from Samsung's SCPM server (DeviceImageManager$1, item 2, cached as
#   files/DeviceImage.png) for a product code. unica/mods/device_image hardcodes the S26 Ultra's (SM-S948BZDGEUX), and
#   for real A52s codes the server only has a front view (and some, e.g. SM-A528BZKCXEO, are not registered at all).
#   Ship Samsung's front+back renders instead (prebuilts/device_image, one per colour) and point
#   DeviceImageFileUtils.getImageFilePath() at the one for the colour in ril.product_code (black when unknown); the
#   download thread returns at once, so nothing overwrites or re-fetches it.
# - Model name: ModelNameGetter reads ro.product.model, which the ROM sets to SM-S948B for the S26U features. Read the
#   bootloader's real model (ro.boot.em.model, SM-A528B) there instead, falling back to ro.product.model. Settings only.
SECSETTINGS="system/priv-app/SecSettings/SecSettings.apk"
DECODE_APK "system" "$SECSETTINGS" || ABORT "Failed to decode $SECSETTINGS"
SS_DIR="$APKTOOL_DIR/system/${SECSETTINGS//system\//}"
AP="com/samsung/android/settings/deviceinfo/aboutphone"
DIFU="$(ls "$SS_DIR"/smali*/$AP/DeviceImageFileUtils.smali 2> /dev/null)"
DIM1="$(ls "$SS_DIR"/smali*/$AP/DeviceImageManager\$1.smali 2> /dev/null)"
MNG="$(ls "$SS_DIR"/smali*/$AP/ModelNameGetter.smali 2> /dev/null)"
for f in "$DIFU" "$DIM1" "$MNG"; do
    [ -f "$f" ] && [ "$(wc -l <<< "$f")" -eq 1 ] || ABORT "device_image_a52s: SecSettings About phone classes not found"
done

DI_DIR="$WORK_DIR/system/system/etc/k4_device_image"
mkdir -p "$DI_DIR"
for c in ZK LV LG ZW; do
    cp -f "$SRC_DIR/prebuilts/device_image/a52s_$c.png" "$DI_DIR/" || ABORT "device_image_a52s: missing a52s_$c.png"
done
SET_METADATA "system" "system/etc/k4_device_image" 0 0 755 "u:object_r:system_file:s0"
for c in ZK LV LG ZW; do
    SET_METADATA "system" "system/etc/k4_device_image/a52s_$c.png" 0 0 644 "u:object_r:system_file:s0"
done

LOG "- About phone: A52s 5G picture (front and back, phone's colour) and real model name"
python3 - "$DIFU" "$DIM1" "$MNG" <<'PY' || ABORT "device_image_a52s: smali patch failed"
import re, sys
difu, dim1, mng = sys.argv[1:4]

s = open(difu).read()
m = re.search(r"\.method public static getImageFilePath\(Landroid/content/Context;\)Ljava/lang/String;\n.*?\.end method\n", s, re.S)
assert m and 'const-string v1, "DeviceImage.png"' in m.group(0), "getImageFilePath changed"
D = "/system/etc/k4_device_image/a52s_"
new = f""".method public static getImageFilePath(Landroid/content/Context;)Ljava/lang/String;
    .locals 4

    const-string v0, "ril.product_code"

    invoke-static {{v0}}, Landroid/os/SystemProperties;->get(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    const-string v1, "ZK"

    invoke-virtual {{v0}}, Ljava/lang/String;->length()I

    move-result v2

    const/16 v3, 0xa

    if-lt v2, v3, :k4_colour

    const/16 v2, 0x8

    invoke-virtual {{v0, v2, v3}}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v1

    :k4_colour
    new-instance v0, Ljava/lang/StringBuilder;

    const-string v2, "{D}"

    invoke-direct {{v0, v2}}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {{v0, v1}}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v2, ".png"

    invoke-virtual {{v0, v2}}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {{v0}}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    new-instance v1, Ljava/io/File;

    invoke-direct {{v1, v0}}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {{v1}}, Ljava/io/File;->exists()Z

    move-result v2

    if-nez v2, :k4_found

    const-string v0, "{D}ZK.png"

    :k4_found
    return-object v0
.end method
"""
open(difu, "w").write(s[:m.start()] + new + s[m.end():])

s = open(dim1).read()
old = ".method public final run()V\n    .locals 7\n"
assert s.count(old) == 1, "DeviceImageManager$1.run changed"
open(dim1, "w").write(s.replace(old, old + "\n    return-void\n"))

s = open(mng).read()
old = ('    const-string v2, "ro.product.model"\n\n'
       '    invoke-static {v2}, Landroid/os/SystemProperties;->get(Ljava/lang/String;)Ljava/lang/String;\n\n'
       '    move-result-object v2\n')
assert s.count(old) == 1, "ModelNameGetter changed"
new = ('    const-string v2, "ro.boot.em.model"\n\n'
       '    invoke-static {v2}, Landroid/os/SystemProperties;->get(Ljava/lang/String;)Ljava/lang/String;\n\n'
       '    move-result-object v2\n\n'
       '    invoke-static {v2}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z\n\n'
       '    move-result v3\n\n'
       '    if-eqz v3, :k4_model_ok\n\n'
       '    const-string v2, "ro.product.model"\n\n'
       '    invoke-static {v2}, Landroid/os/SystemProperties;->get(Ljava/lang/String;)Ljava/lang/String;\n\n'
       '    move-result-object v2\n\n'
       '    :k4_model_ok\n')
open(mng, "w").write(s.replace(old, new))
PY
unset SECSETTINGS SS_DIR AP DIFU DIM1 MNG DI_DIR c f
