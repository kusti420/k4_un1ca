# Sourced from post_mods.sh (after unica/mods/device_image, which device patches run before).
# About phone shows a picture that Settings downloads from Samsung's SCPM server (DeviceImageManager$1, item 2) for a
# product code. unica/mods/device_image replaces the code with a fixed S26 Ultra one (SM-S948BZDGEUX), so the header
# showed an S26 Ultra with S Pen. This puts back the stock source, the phone's own ril.product_code (e.g.
# SM-A528BZKCSEB), so the server returns the A52s 5G picture in the phone's own colour. Falls back to SM-A528BZKCSEB
# when the property is empty. The cached /data/user_de/0/com.android.settings/files/DeviceImage.png is replaced on the
# next About phone visit once it is older than a day.
SECSETTINGS="system/priv-app/SecSettings/SecSettings.apk"
DECODE_APK "system" "$SECSETTINGS" || ABORT "Failed to decode $SECSETTINGS"

DIM="$APKTOOL_DIR/system/${SECSETTINGS//system\//}/$(cd "$APKTOOL_DIR/system/${SECSETTINGS//system\//}" && \
    find . -path './smali*/com/samsung/android/settings/deviceinfo/aboutphone/DeviceImageManager$1.smali' | sed 's|^\./||')"
[ -f "$DIM" ] || ABORT "DeviceImageManager\$1.smali not found in SecSettings"
[ "$(grep -c '^    const-string v0, "SM-S948BZDGEUX"$' "$DIM")" = 1 ] || \
    ABORT "DeviceImageManager\$1 no longer has the single hardcoded SM-S948BZDGEUX model code from unica/mods/device_image"
# v2 is free here: it held the isAvailable() result just consumed by the if-eqz above, and the next line reloads it
grep -A2 '^    const-string v0, "SM-S948BZDGEUX"$' "$DIM" | grep -q '^    const-string v2, "requestPki - model_code = "$' || \
    ABORT "DeviceImageManager\$1: unexpected code after the model code"

LOG "- About phone: device picture for the phone's own product code (ril.product_code)"
python3 - "$DIM" <<'PY' || ABORT "Failed to patch DeviceImageManager\$1"
import sys
p = sys.argv[1]
s = open(p).read()
old = '    const-string v0, "SM-S948BZDGEUX"\n'
new = ('    const-string v0, "ril.product_code"\n\n'
       '    invoke-static {v0}, Landroid/os/SystemProperties;->get(Ljava/lang/String;)Ljava/lang/String;\n\n'
       '    move-result-object v0\n\n'
       '    invoke-static {v0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z\n\n'
       '    move-result v2\n\n'
       '    if-eqz v2, :k4_product_code_ok\n\n'
       '    const-string v0, "SM-A528BZKCSEB"\n\n'
       '    :k4_product_code_ok\n')
assert s.count(old) == 1
open(p, "w").write(s.replace(old, new))
PY
unset SECSETTINGS DIM
