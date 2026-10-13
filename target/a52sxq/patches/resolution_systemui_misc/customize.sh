# From the resolution audit of 2026-10-13 (/mnt/B1/OneUi9/scratch/resaudit; dry-run with proposed/dryrun.sh). See module.prop.
SYSTEMUI="priv-app/SystemUI/SystemUI.apk"
DECODE_APK "system_ext" "$SYSTEMUI" || ABORT "Failed to decode $SYSTEMUI"
python3 - "$APKTOOL_DIR/system_ext/$SYSTEMUI" << 'PYEOF' || ABORT "Failed to patch SystemUI pixel constants"
import glob, os, re, sys
A = sys.argv[1]

def one(rel):
    f = glob.glob(A + "/smali*/" + rel)
    assert len(f) == 1, "%s: %d" % (rel, len(f))
    return f[0]

# ---- 1. camera protection ring -------------------------------------------------------------------------------
# 37 px on the 409.432 dpi panel = 2.2966 mm (37.02 px: rounds and truncates to 37 at FHD+; 25 px at HD+, 19 at 540p)
f = A + "/res/values/dimens.xml"
s = open(f).read()
old, new = '<dimen name="camera_protection_stroke_width">37.0px</dimen>', '<dimen name="camera_protection_stroke_width">2.2966mm</dimen>'
if new not in s:
    assert s.count(old) == 1, "camera_protection_stroke_width is no longer 37.0px"
    s = s.replace(old, new)
    open(f, "w").write(s)
for g in glob.glob(A + "/res/values-*/dimens.xml"):
    assert 'name="camera_protection_stroke_width"' not in open(g).read(), g
# CutoutDecorProviderFactory reads the dimen once for the life of SystemUI and hands it to every cutout view through
# CutoutDecorProviderImpl.inflateView(). Each DisplayCutoutBaseView constructor has just read the same dimen from its
# own (current) Resources: keep that value instead of overwriting it with the cached one.
f = one("com/android/systemui/decor/CutoutDecorProviderImpl.smali")
s = open(f).read()
BASE = "Lcom/android/systemui/DisplayCutoutBaseView;"
b = one("com/android/systemui/DisplayCutoutBaseView.smali")
bs = open(b).read()
assert re.search(r"iput \w+, p0, %s->cameraProtectionStrokeWidth:I" % re.escape(BASE), bs), "DisplayCutoutBaseView no longer reads the stroke width itself"
pat = re.compile(r"( +)iget p0, p0, Lcom/android/systemui/decor/CutoutDecorProviderImpl;->cameraProtectionStrokeWidth:I\n\n"
                 r" +iput p0, v0, %s->cameraProtectionStrokeWidth:I\n" % re.escape(BASE))
keep = "iget p0, v0, %s->cameraProtectionStrokeWidth:I\n" % BASE
if keep not in s:
    assert len(pat.findall(s)) == 1, "CutoutDecorProviderImpl.inflateView stroke width hand-over"
    s = pat.sub(lambda m: m.group(1) + keep, s)
    open(f, "w").write(s)
print("  - camera protection stroke: 37px -> 2.2966mm, read per cutout view")

# ---- 2. power-key light reveal centre ------------------------------------------------------------------------
f = one("com/android/systemui/statusbar/PowerButtonReveal.smali")
s = open(f).read()
PBR = "Lcom/android/systemui/statusbar/PowerButtonReveal;"
K4 = "Lcom/android/systemui/statusbar/K4PowerKeyY;"
m = re.search(r"^\.method public final setRevealAmountOnScrim\(FLcom/android/systemui/statusbar/LightRevealScrim;\)V\n.*?^\.end method\n", s, re.M | re.S)
assert m, "setRevealAmountOnScrim"
body = m.group(0)
read = "    iget p0, p0, %s->powerButtonY:F\n" % PBR
hook = read + "\n    invoke-static {p2, p0}, %s->y(Landroid/view/View;F)F\n\n    move-result p0\n" % K4
if K4 not in body:
    assert body.count(read) == 1, "powerButtonY read"
    loc = re.search(r"^    \.locals (\d+)$", body, re.M)
    assert loc and int(loc.group(1)) + 3 <= 16, "p0/p2 no longer 4-bit registers"
    s = s[:m.start()] + body.replace(read, hook, 1) + s[m.end():]
    open(f, "w").write(s)
open(os.path.join(os.path.dirname(f), "K4PowerKeyY.smali"), "w").write("""\
.class public final %(K4)s
.super Ljava/lang/Object;
.source "K4PowerKeyY.java"


# a52sxq resolution_systemui_misc patch: the Y of the power key for the light reveal, in the pixels the scrim is
# laid out in. android:dimen/physical_power_button_center_screen_location_y is in panel pixels (Samsung's
# LightRevealScrimRepositoryImpl divides it by native / current width, but only once, in its constructor).

# direct methods
.method private constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

# scrim: the full-screen LightRevealScrim; fallback: the value computed when SystemUI started
.method public static y(Landroid/view/View;F)F
    .locals 6

    :try_start_0
    invoke-virtual {p0}, Landroid/view/View;->getDisplay()Landroid/view/Display;

    move-result-object v0

    if-eqz v0, :cond_fallback

    invoke-virtual {v0}, Landroid/view/Display;->getMode()Landroid/view/Display$Mode;

    move-result-object v0

    invoke-virtual {v0}, Landroid/view/Display$Mode;->getPhysicalWidth()I

    move-result v1

    invoke-virtual {v0}, Landroid/view/Display$Mode;->getPhysicalHeight()I

    move-result v0

    invoke-static {v1, v0}, Ljava/lang/Math;->min(II)I

    move-result v0

    invoke-virtual {p0}, Landroid/view/View;->getWidth()I

    move-result v1

    invoke-virtual {p0}, Landroid/view/View;->getHeight()I

    move-result v2

    invoke-static {v1, v2}, Ljava/lang/Math;->min(II)I

    move-result v1

    if-lez v0, :cond_fallback

    if-lez v1, :cond_fallback

    invoke-virtual {p0}, Landroid/view/View;->getResources()Landroid/content/res/Resources;

    move-result-object v2

    const-string v3, "physical_power_button_center_screen_location_y"

    const-string v4, "dimen"

    const-string v5, "android"

    invoke-virtual {v2, v3, v4, v5}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I

    move-result v3

    if-eqz v3, :cond_fallback

    invoke-virtual {v2, v3}, Landroid/content/res/Resources;->getDimensionPixelSize(I)I

    move-result v2

    if-lez v2, :cond_fallback

    mul-int/2addr v2, v1

    int-to-float v2, v2

    int-to-float v0, v0

    div-float/2addr v2, v0
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return v2

    :catch_0
    move-exception v0

    :cond_fallback
    return p1
.end method
""" % dict(K4=K4))
print("  - power-key reveal centre computed from the current scrim size")

# ---- 3. edge lighting corner radius --------------------------------------------------------------------------
f = one("com/android/systemui/edgelighting/effect/view/DrawEdgeLayout.smali")
s = open(f).read()
pat = re.compile(r"(?P<i> +)cmpg-float v4, v4, v10\n\n"
                 r" +if-gez v4, (?P<skip>:cond_\w+)\n\n"
                 r" +const v4, 0x3f2aacda    # 0\.6667f\n\n"
                 r"(?P<tail> +goto (?P<mul>:goto_\w+)\n)")
new_marker = "    div-float/2addr v4, v10\n"
if "0x3f2aacda" in s:
    hits = list(pat.finditer(s))
    assert len(hits) == 1, "edge lighting 2/3 factor: %d" % len(hits)
    m = hits[0]
    # v4 = (float) short side, v10 = 1080f (set just above), v11 = scratch of the preceding cmpl-float
    pre = s[max(0, m.start() - 400):m.start()]
    assert "const/high16 v10, 0x44870000    # 1080.0f" in pre and "cmpl-float v11, v4, v10" in pre, "registers around the factor"
    assert re.search(r"^ +%s\n +mul-float/2addr v7, v4\n" % re.escape(m.group("mul")), s, re.M), "multiply target"
    s = s[:m.start()] + ("%(i)scmpg-float v11, v4, v10\n\n%(i)sif-gez v11, %(skip)s\n\n%(i)sdiv-float/2addr v4, v10\n\n" % m.groupdict()) + m.group("tail") + s[m.end():]
    open(f, "w").write(s)
    print("  - edge lighting radius factor: short side / 1080 instead of the constant 2/3")
else:
    assert new_marker in s, "edge lighting factor not found"
PYEOF
LOG "- SystemUI: camera protection ring, power-key reveal centre and edge lighting radius follow the resolution"
unset SYSTEMUI
