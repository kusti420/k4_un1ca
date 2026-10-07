OLD_POS="/sys/class/fingerprint/fingerprint/position"
NEW_POS="/sys/devices/virtual/fingerprint/fingerprint/position"

for SPEC in "system|system/framework/services.jar" \
        "system_ext|priv-app/SystemUI/SystemUI.apk" \
        "system|system/priv-app/AODService_v80/AODService_v80.apk"; do
    PART="${SPEC%%|*}"
    FILE="${SPEC#*|}"
    if [[ "$PART" == "system_ext" ]]; then
        [ -f "$WORK_DIR/system/system/system_ext/$FILE" ] || [ -f "$WORK_DIR/system_ext/$FILE" ] || continue
    else
        [ -f "$WORK_DIR/system/$FILE" ] || continue
    fi
    DECODE_APK "$PART" "$FILE" || ABORT "Failed to decode $FILE"
    DIR="$APKTOOL_DIR/$PART/${FILE//system\//}"
    while IFS= read -r SMALI; do
        LOG "- Using $NEW_POS in ${SMALI//$APKTOOL_DIR/}"
        sed -i "s|$OLD_POS|$NEW_POS|g" "$SMALI"
    done < <(grep -rl "$OLD_POS" "$DIR"/smali* 2> /dev/null)
done

# Optical FOD illumination. On stock One UI the fingerprint HBM chain is:
#   SurfaceFlinger "Fingerprint Indisplay Layer" -> its buffer is allocated with Samsung's private gralloc
#   usage bit 34 -> vendor gralloc turns that into private handle flag 0x2000 (GetHandleFlags) -> the QTI
#   composer marks the layer and sets the DRM connector property "fingerprint_mask" (HWDeviceDRM::SetupAtomic)
#   -> the kernel enters finger-mask HBM at the level stored in mask_brightness and notifies
#   actual_mask_brightness, which BiometricSetting watches before it releases the queued touch-down
#   (request 9 -> sehRequest 22).
# The Fold8 SurfaceFlinger has none of that, so BiometricSetting's UdfpsMaskWindow does it itself: while the
# mask is shown (and on every turnOnHBM) it attaches a 16x16, alpha 0.01 child layer whose HardwareBuffer
# carries usage bit 34, and writes the HBM level (331, what SemUdfpsOpticalHelper computes for this panel)
# to mask_brightness. BiometricSetting is system_app, which may write sysfs_lcd_writable.
BSS="system/priv-app/BiometricSetting/BiometricSetting.apk"
if [ -f "$WORK_DIR/system/$BSS" ]; then
    DECODE_APK "system" "$BSS" || ABORT "Failed to decode $BSS"
    LOG "- Adding a fingerprint indisplay layer to UdfpsMaskWindow"
    python3 - "$APKTOOL_DIR/system/${BSS//system\//}" << 'PYEOF' || ABORT "Failed to patch UdfpsMaskWindow"
import glob, re, sys
hits = glob.glob(sys.argv[1] + "/smali*/com/samsung/android/biometrics/app/setting/fingerprint/UdfpsMaskWindow.smali")
assert len(hits) == 1, "UdfpsMaskWindow"
f = hits[0]
s = open(f).read()
cls = "Lcom/samsung/android/biometrics/app/setting/fingerprint/UdfpsMaskWindow;"
base = "Lcom/samsung/android/biometrics/app/setting/SysUiWindow;->mBaseView:Landroid/view/View;"
fod = f"invoke-static {{v1, v0}}, {cls}->unicaFodLayer(Landroid/view/View;Z)V"
mask = f"invoke-static {{v0}}, {cls}->unicaSetMask(Ljava/lang/String;)V"
if "unicaFodLayer" not in s:
    vis = "    invoke-super {p0, p1}, Lcom/samsung/android/biometrics/app/setting/SysUiWindow;->setVisibility(I)V\n"
    rem = "    invoke-super {p0}, Lcom/samsung/android/biometrics/app/setting/SysUiWindow;->removeView()V\n"
    assert s.count(vis) == 1 and s.count(rem) == 1, "UdfpsMaskWindow anchors"
    s = s.replace(vis, vis + f"""
    iget-object v1, p0, {base}

    if-nez p1, :cond_unica_mask_off

    const-string v0, "331"

    {mask}

    const/4 v0, 0x1

    {fod}

    goto :goto_unica_mask

    :cond_unica_mask_off
    const/4 v0, 0x0

    {fod}

    :goto_unica_mask
""")
    s = s.replace(rem, f"""    const/4 v0, 0x0

    const/4 v1, 0x0

    {fod}

""" + rem)
    # turnOnHBM runs on every finger-down, after the window has a surface: (re)attach the layer there too
    m = re.search(r"(\.method public final turnOnHBM\(\)V\n\s+\.locals )(\d+)\n", s)
    assert m, "turnOnHBM"
    s = s[:m.start()] + m.group(1) + str(max(2, int(m.group(2)))) + f"""

    iget-object v1, p0, {base}

    const/4 v0, 0x1

    {fod}
""" + s[m.end():]
    s = s.replace(".class public final " + cls, ".class public final " + cls, 1)
    s = re.sub(r"(\n# instance fields\n|\n# direct methods\n)",
               "\n.field public static unicaFod:Landroid/view/SurfaceControl;\n\\1", s, count=1)
    s += f"""
.method public static unicaSetMask(Ljava/lang/String;)V
    .locals 2

    :try_start_unica
    new-instance v0, Ljava/io/FileOutputStream;

    const-string v1, "/sys/devices/virtual/lcd/panel/mask_brightness"

    invoke-direct {{v0, v1}}, Ljava/io/FileOutputStream;-><init>(Ljava/lang/String;)V

    invoke-virtual {{p0}}, Ljava/lang/String;->getBytes()[B

    move-result-object v1

    invoke-virtual {{v0, v1}}, Ljava/io/FileOutputStream;->write([B)V

    invoke-virtual {{v0}}, Ljava/io/FileOutputStream;->close()V
    :try_end_unica
    .catch Ljava/lang/Exception; {{:try_start_unica .. :try_end_unica}} :catch_unica

    return-void

    :catch_unica
    move-exception v0

    const-string v1, "BSS_UdfpsMaskWindow"

    invoke-virtual {{v0}}, Ljava/lang/Throwable;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {{v1, v0}}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    return-void
.end method

.method public static unicaFodLayer(Landroid/view/View;Z)V
    .locals 10

    :try_start_fod
    sget-object v0, {cls}->unicaFod:Landroid/view/SurfaceControl;

    if-nez p1, :cond_fod_show

    if-eqz v0, :cond_fod_done

    new-instance v1, Landroid/view/SurfaceControl$Transaction;

    invoke-direct {{v1}}, Landroid/view/SurfaceControl$Transaction;-><init>()V

    const/4 v2, 0x0

    invoke-virtual {{v1, v0, v2}}, Landroid/view/SurfaceControl$Transaction;->reparent(Landroid/view/SurfaceControl;Landroid/view/SurfaceControl;)Landroid/view/SurfaceControl$Transaction;

    invoke-virtual {{v1}}, Landroid/view/SurfaceControl$Transaction;->apply()V

    invoke-virtual {{v0}}, Landroid/view/SurfaceControl;->release()V

    const/4 v0, 0x0

    sput-object v0, {cls}->unicaFod:Landroid/view/SurfaceControl;

    const-string v3, "BSS_UdfpsMaskWindow"

    const-string v4, "unica: fingerprint indisplay layer off"

    invoke-static {{v3, v4}}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    goto :cond_fod_done

    :cond_fod_show
    if-nez v0, :cond_fod_done

    if-eqz p0, :cond_fod_done

    invoke-virtual {{p0}}, Landroid/view/View;->getRootSurfaceControl()Landroid/view/AttachedSurfaceControl;

    move-result-object v1

    if-eqz v1, :cond_fod_done

    const/16 v4, 0x10

    const/16 v5, 0x10

    const/4 v6, 0x1

    const/4 v7, 0x1

    const-wide v8, 0x400000900L

    invoke-static/range {{v4 .. v9}}, Landroid/hardware/HardwareBuffer;->create(IIIIJ)Landroid/hardware/HardwareBuffer;

    move-result-object v2

    new-instance v3, Landroid/view/SurfaceControl$Builder;

    invoke-direct {{v3}}, Landroid/view/SurfaceControl$Builder;-><init>()V

    const-string v4, "unica_fod_indisplay"

    invoke-virtual {{v3, v4}}, Landroid/view/SurfaceControl$Builder;->setName(Ljava/lang/String;)Landroid/view/SurfaceControl$Builder;

    move-result-object v3

    invoke-virtual {{v3}}, Landroid/view/SurfaceControl$Builder;->build()Landroid/view/SurfaceControl;

    move-result-object v0

    invoke-interface {{v1, v0}}, Landroid/view/AttachedSurfaceControl;->buildReparentTransaction(Landroid/view/SurfaceControl;)Landroid/view/SurfaceControl$Transaction;

    move-result-object v1

    if-nez v1, :cond_fod_parented

    invoke-virtual {{v0}}, Landroid/view/SurfaceControl;->release()V

    goto :cond_fod_done

    :cond_fod_parented
    invoke-virtual {{v1, v0, v2}}, Landroid/view/SurfaceControl$Transaction;->setBuffer(Landroid/view/SurfaceControl;Landroid/hardware/HardwareBuffer;)Landroid/view/SurfaceControl$Transaction;

    const v3, 0x3c23d70a    # 0.01f

    invoke-virtual {{v1, v0, v3}}, Landroid/view/SurfaceControl$Transaction;->setAlpha(Landroid/view/SurfaceControl;F)Landroid/view/SurfaceControl$Transaction;

    const v3, 0x7fffffff

    invoke-virtual {{v1, v0, v3}}, Landroid/view/SurfaceControl$Transaction;->setLayer(Landroid/view/SurfaceControl;I)Landroid/view/SurfaceControl$Transaction;

    const/4 v3, 0x1

    invoke-virtual {{v1, v0, v3}}, Landroid/view/SurfaceControl$Transaction;->setVisibility(Landroid/view/SurfaceControl;Z)Landroid/view/SurfaceControl$Transaction;

    invoke-virtual {{v1}}, Landroid/view/SurfaceControl$Transaction;->apply()V

    sput-object v0, {cls}->unicaFod:Landroid/view/SurfaceControl;

    const-string v3, "BSS_UdfpsMaskWindow"

    const-string v4, "unica: fingerprint indisplay layer on"

    invoke-static {{v3, v4}}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_fod
    .catch Ljava/lang/Throwable; {{:try_start_fod .. :try_end_fod}} :catch_fod

    :cond_fod_done
    return-void

    :catch_fod
    move-exception v0

    const-string v1, "BSS_UdfpsMaskWindow"

    invoke-virtual {{v0}}, Ljava/lang/Throwable;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {{v1, v0}}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    return-void
.end method
"""
    open(f, "w").write(s)
PYEOF
fi

# Screen-off (AOD) fingerprint: on a FOD press with the screen off, BiometricSetting turns the display on and shows
# the mask window, but at that point the window has no surface yet, so the indisplay layer above can't be attached
# (SurfaceFlinger: "created and destroyed in the same transaction") and nothing retries: no HBM, the queued touch
# is never delivered and only the second press (window now has a surface) unlocks. Attach the layer (again) from
# LightSourceView.surfaceCreated, the SurfaceView inside the mask window, which fires once the surface is valid.
if [ -f "$WORK_DIR/system/$BSS" ]; then
    LOG "- Attaching the fingerprint indisplay layer on mask surface creation"
    python3 - "$APKTOOL_DIR/system/${BSS//system\//}" << 'PYEOF' || ABORT "Failed to patch LightSourceView"
import glob, sys
hits = glob.glob(sys.argv[1] + "/smali*/com/samsung/android/biometrics/app/setting/fingerprint/LightSourceView.smali")
assert len(hits) == 1, "LightSourceView"
f = hits[0]
s = open(f).read()
if ":cond_unica_fod_surface" in s:
    sys.exit(0)
anchor = ".method public final surfaceCreated(Landroid/view/SurfaceHolder;)V\n    .locals 2\n"
assert s.count(anchor) == 1, "surfaceCreated"
s = s.replace(anchor, anchor + """
    invoke-virtual {p0}, Landroid/view/View;->getRootView()Landroid/view/View;

    move-result-object v0

    invoke-virtual {v0}, Landroid/view/View;->getVisibility()I

    move-result v1

    if-nez v1, :cond_unica_fod_surface

    const/4 v1, 0x1

    invoke-static {v0, v1}, Lcom/samsung/android/biometrics/app/setting/fingerprint/UdfpsMaskWindow;->unicaFodLayer(Landroid/view/View;Z)V

    :cond_unica_fod_surface
""")
open(f, "w").write(s)
PYEOF
fi

# The Fold source SystemUI was built with LsRune.SECURITY_FINGERPRINT_IN_DISPLAY=false, so R8 dropped every
# in-display sensor layout branch: DeviceState.sInDisplayFingerprintHeight is never computed (the sensor position
# setter has no caller left), the lock screen indication (charging text) is drawn inside the sensor area and the
# bouncer's Emergency call button sits right on the sensor. Restore the stock One UI formulas: indication bottom
# margin = sensor height + keyguard_indication_margin_bottom_fingerprint_low[_with_nowbar], bouncer bottom padding
# = sensor height (both only for a low sensor with fingerprint unlock enabled), and let DeviceType report an
# in-display sensor (lock screen fingerprint help/error texts, AOD plugin).
SYSTEMUI="priv-app/SystemUI/SystemUI.apk"
if [ -f "$WORK_DIR/system/system/system_ext/$SYSTEMUI" ] || [ -f "$WORK_DIR/system_ext/$SYSTEMUI" ]; then
    DECODE_APK "system_ext" "$SYSTEMUI" || ABORT "Failed to decode $SYSTEMUI"
    LOG "- Restoring the in-display fingerprint lock screen margins in SystemUI"
    python3 - "$APKTOOL_DIR/system_ext/$SYSTEMUI" << 'PYEOF' || ABORT "Failed to patch the SystemUI fingerprint margins"
import glob, sys

def one(pattern):
    hits = glob.glob(sys.argv[1] + "/smali*/" + pattern)
    assert len(hits) == 1, pattern
    return hits[0]

# DeviceState.getInDisplayFingerprintHeight(): compute the sensor geometry on first use
f = one("com/android/systemui/util/DeviceState.smali")
s = open(f).read()
if ":cond_unica_fp_height" not in s:
    old = """.method public static getInDisplayFingerprintHeight()I
    .locals 1

    sget v0, Lcom/android/systemui/util/DeviceState;->sInDisplayFingerprintHeight:I

    return v0
.end method"""
    assert s.count(old) == 1, "getInDisplayFingerprintHeight"
    s = s.replace(old, """.method public static getInDisplayFingerprintHeight()I
    .locals 1

    sget v0, Lcom/android/systemui/util/DeviceState;->sInDisplayFingerprintHeight:I

    if-nez v0, :cond_unica_fp_height

    invoke-static {}, Landroid/content/res/Resources;->getSystem()Landroid/content/res/Resources;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object v0

    invoke-static {v0}, Lcom/android/systemui/util/DeviceState;->setInDisplayFingerprintSensorPosition(Landroid/util/DisplayMetrics;)V

    sget v0, Lcom/android/systemui/util/DeviceState;->sInDisplayFingerprintHeight:I

    :cond_unica_fp_height
    return v0
.end method""")
    open(f, "w").write(s)

# KeyguardSecBottomAreaView.updateIndicationDimensions(): stock in-display margin for the indication area
f = one("com/android/systemui/statusbar/phone/KeyguardSecBottomAreaView.smali")
s = open(f).read()
if ":cond_unica_fp_indication" not in s:
    anchor = """    const v8, 0x7e0705bb

    invoke-virtual {v2, v8}, Landroid/content/res/Resources;->getDimensionPixelSize(I)I

    move-result v8

    add-int/2addr v8, v4

    iput v8, v1, Lcom/android/systemui/statusbar/phone/KeyguardSecBottomAreaView$ConfigurationBasedDimensions;->indicationAreaBottomMargin:I
"""
    assert s.count(anchor) == 1, "indicationAreaBottomMargin"
    s = s.replace(anchor, anchor + """
    const-class v10, Lcom/android/keyguard/KeyguardUpdateMonitor;

    sget-object v11, Lcom/android/systemui/Dependency;->sDependency:Lcom/android/systemui/Dependency;

    invoke-virtual {v11, v10}, Lcom/android/systemui/Dependency;->getDependencyInner(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v10

    check-cast v10, Lcom/android/keyguard/KeyguardSecUpdateMonitor;

    invoke-interface {v10}, Lcom/android/keyguard/KeyguardSecUpdateMonitor;->isFingerprintOptionEnabled()Z

    move-result v10

    if-eqz v10, :cond_unica_fp_indication

    invoke-static {}, Lcom/android/systemui/util/DeviceState;->getInDisplayFingerprintHeight()I

    move-result v10

    if-eqz v10, :cond_unica_fp_indication

    invoke-static {}, Lcom/android/systemui/util/DeviceState;->isInDisplayFpSensorPositionHigh()Z

    move-result v11

    if-nez v11, :cond_unica_fp_indication

    iget-boolean v11, v0, Lcom/android/systemui/statusbar/phone/KeyguardSecBottomAreaView;->isNowBarVisible:Z

    if-eqz v11, :cond_unica_fp_nowbar

    const v11, 0x7e0705b3

    goto :goto_unica_fp_dimen

    :cond_unica_fp_nowbar
    const v11, 0x7e0705b2

    :goto_unica_fp_dimen
    invoke-virtual {v2, v11}, Landroid/content/res/Resources;->getDimensionPixelSize(I)I

    move-result v11

    add-int/2addr v10, v11

    if-le v10, v8, :cond_unica_fp_indication

    iput v10, v1, Lcom/android/systemui/statusbar/phone/KeyguardSecBottomAreaView$ConfigurationBasedDimensions;->indicationAreaBottomMargin:I

    :cond_unica_fp_indication
""")
    open(f, "w").write(s)

# KeyguardSecSecurityContainerController.updateLayoutMargins(int): bouncer bottom padding = sensor height
f = one("com/android/keyguard/KeyguardSecSecurityContainerController.smali")
s = open(f).read()
if ":cond_unica_fp_bouncer" not in s:
    anchor = """    :cond_12
    iget p1, p0, Lcom/android/keyguard/KeyguardSecSecurityContainerController;->mNavigationBarHeight:I
"""
    assert s.count(anchor) == 1, "mNavigationBarHeight"
    s = s.replace(anchor, anchor + """
    invoke-interface {v5}, Lcom/android/keyguard/KeyguardSecUpdateMonitor;->isFingerprintOptionEnabled()Z

    move-result v6

    if-eqz v6, :cond_unica_fp_bouncer

    invoke-static {}, Lcom/android/systemui/util/DeviceState;->getInDisplayFingerprintHeight()I

    move-result v6

    invoke-static {}, Lcom/android/systemui/util/DeviceState;->isInDisplayFpSensorPositionHigh()Z

    move-result v7

    if-nez v7, :cond_unica_fp_bouncer

    if-le v6, p1, :cond_unica_fp_bouncer

    move p1, v6

    :cond_unica_fp_bouncer
""")
    open(f, "w").write(s)
PYEOF
    SMALI_PATCH "system_ext" "$SYSTEMUI" \
        "smali_classes4/com/android/systemui/util/DeviceType.smali" "return" \
        "isInDisplayFingerprintSupported()Z" "true"
fi

# libui's Gralloc4 descriptor check rejects every usage bit outside the AOSP/vendor ranges, including Samsung's
# private fingerprint bit 34 ("buffer descriptor contains invalid usage bits 0x400000000"); stock optical
# devices ship a libui that allows it. Clear bit 34 from both invalid-bit masks
# (movk x8, #0xffff, lsl #32 -> #0xfffb; movk x9, #0xfffc, lsl #32 -> #0xfff8).
LIBUI="$WORK_DIR/system/system/lib64/libui.so"
if [ -f "$LIBUI" ]; then
    LOG "- Allowing gralloc usage bit 34 in libui"
    python3 - "$LIBUI" << 'PYEOF' || ABORT "Failed to patch libui.so"
import struct, sys
p = sys.argv[1]
d = bytearray(open(p, "rb").read())
words = lambda *w: b"".join(struct.pack("<I", x) for x in w)
old = words(0xd2a00508, 0xd2a00509, 0x7200001f, 0xf2dfffe8, 0xf2dfff89)
new = words(0xd2a00508, 0xd2a00509, 0x7200001f, 0xf2dfff68, 0xf2dfff09)
if d.count(new) == 1 and d.count(old) == 0:
    sys.exit(0)
assert d.count(old) == 1, "Gralloc4 usage mask"
i = d.find(old)
d[i:i + len(old)] = new
open(p, "wb").write(d)
PYEOF
fi

unset OLD_POS NEW_POS SPEC PART FILE DIR SMALI BSS SYSTEMUI LIBUI
