# From the resolution audit of 2026-10-13 (/mnt/B1/OneUi9/scratch/resaudit; python part dry-run and the patched smali assembled with proposed/dryrun.sh)
#
# 1. SystemUI's "scaling adjustment" (AOSP communal DensityUtils, reused by the One UI 9 Compose quick panel) is
#    IWindowManager.getInitialDisplayDensity(0) / getBaseDisplayDensity(0): it is meant to cancel Screen zoom, but a
#    forced display size also lowers the base density (450 -> 300 -> 225) while the initial density stays 450, so it
#    reads 1.0 / 1.5 / 2.0. Consumers:
#      - SecQuickSettingScene: LocalScaleAdjustment = coerceIn(ratio, 0.95, 1.21) -> QuickTile bar/large tile icon
#        (48dp x 1.21 = 58.08dp: 135 px native, 109 px instead of 90 at HD+, 82 px instead of 68 at 540p), the tile
#        box scene height, the available-tiles grid cell (+2dp x ratio), detail popups, SoundCraft
#      - SpannableGridTileKt.GRID_BORDER = 1dp x ratio (unclamped, evaluated once at class init): the outline of
#        tiles, bars and the media card
#      - QuickTile image tiles: padding 1dp x ratio (unclamped)
#      - SecQSPanelResourceNormalPicker/WalletPicker.getPanelEditSidePadding (landscape): 405dp x ratio (unclamped)
#    Fix at the source: ratio = (initialDensity * baseWidth) / (baseDensity * initialWidth), i.e. relative to the
#    default density of the current resolution. 1.0 in all three modes (450*720 = 300*1080, 450*540 = 225*1080) and
#    Screen zoom is still cancelled as before.
# 2. IconTextTile places the label of every bar tile that is not 2x1 at (width - 50px, height - 50px): raw pixels.
#    50 px at the native density is 17.78dp.
# 3. QuickSettingTileGrid slides the rows in with translationY = (row + 1) * 20 px * fraction: raw pixels
#    (animation only). 20 px at the native density, scaled with the current one.
DECODE_APK "system_ext" "priv-app/SystemUI/SystemUI.apk"
python3 - "$APKTOOL_DIR/system_ext/priv-app/SystemUI/SystemUI.apk" << 'PYEOF' || ABORT "Failed to make the quick panel resolution independent"
import glob, re, sys
A = sys.argv[1]

def one(rel):
    f = glob.glob(A + "/smali*/" + rel)
    assert len(f) == 1, "%s: %d" % (rel, len(f))
    return f[0]

def body(text):
    return [l.strip() for l in text.split("\n") if l.strip()]

# 1. DensityUtils.Companion.getScalingAdjustment()
f = one("com/android/systemui/communal/util/DensityUtils$Companion.smali")
s = open(f).read()
WM = "Landroid/view/IWindowManager;"
PT = "Landroid/graphics/Point;"
DU = "Lcom/android/systemui/communal/util/DensityUtils;"
m = re.search(r"^\.method public static getScalingAdjustment\(\)F\n.*?^\.end method\n", s, re.M | re.S)
assert m, "getScalingAdjustment"
assert body(m.group(0)) == [
    ".method public static getScalingAdjustment()F", ".locals 3",
    "sget-object v0, %s->windowManagerService:%s" % (DU, WM),
    "if-eqz v0, :cond_0", "const/4 v1, 0x0",
    "invoke-interface {v0, v1}, %s->getInitialDisplayDensity(I)I" % WM, "move-result v2", "int-to-float v2, v2",
    "invoke-interface {v0, v1}, %s->getBaseDisplayDensity(I)I" % WM, "move-result v0", "int-to-float v0, v0",
    "div-float/2addr v2, v0", "return v2",
    ":cond_0", "const/high16 v0, 0x3f800000    # 1.0f", "return v0", ".end method"], "getScalingAdjustment body changed"
new = """\
.method public static getScalingAdjustment()F
    .locals 6

    sget-object v0, %(DU)s->windowManagerService:%(WM)s

    if-eqz v0, :cond_0

    const/4 v1, 0x0

    invoke-interface {v0, v1}, %(WM)s->getInitialDisplayDensity(I)I

    move-result v2

    invoke-interface {v0, v1}, %(WM)s->getBaseDisplayDensity(I)I

    move-result v3

    new-instance v4, %(PT)s

    invoke-direct {v4}, %(PT)s-><init>()V

    invoke-interface {v0, v1, v4}, %(WM)s->getInitialDisplaySize(I%(PT)s)V

    iget v5, v4, %(PT)s->x:I

    invoke-interface {v0, v1, v4}, %(WM)s->getBaseDisplaySize(I%(PT)s)V

    iget v4, v4, %(PT)s->x:I

    if-lez v5, :cond_1

    if-lez v4, :cond_1

    mul-int/2addr v2, v4

    mul-int/2addr v3, v5

    :cond_1
    int-to-float v2, v2

    int-to-float v0, v3

    div-float/2addr v2, v0

    return v2

    :cond_0
    const/high16 v0, 0x3f800000    # 1.0f

    return v0
.end method
""" % {"DU": DU, "WM": WM, "PT": PT}
s = s[:m.start()] + new + s[m.end():]
open(f, "w").write(s)

# 2. IconTextTile: label inset of the non-2x1 bar tiles, 50 px -> 17.78dp
f = one("com/android/systemui/samsung/quicksetting/ui/tiles/IconTextTileKt$IconTextTile$5$1$$ExternalSyntheticLambda0.smali")
s = open(f).read()
assert "check-cast v0, Landroidx/compose/ui/layout/Placeable$PlacementScope;" in s, "placement scope register"
pat = re.compile(r"( +)sub-int/2addr v1, v2\n\n +add-int/lit8 (v14|v15), v1, -0x32\n")
hits = pat.findall(s)
assert [h[1] for h in hits] == ["v14", "v15"], "50 px label insets: %s" % hits
s = pat.sub(lambda m: "%(i)ssub-int/2addr v1, v2\n\n"
                      "%(i)sconst v2, 0x418e38e4    # 17.777779f (50 px at 450 dpi)\n\n"
                      "%(i)sinvoke-interface {v0, v2}, Landroidx/compose/ui/unit/Density;->roundToPx-0680j_4(F)I\n\n"
                      "%(i)smove-result v2\n\n"
                      "%(i)ssub-int %(r)s, v1, v2\n" % {"i": m.group(1), "r": m.group(2)}, s)
open(f, "w").write(s)

# 3. QuickSettingTileGrid: row slide-in offset, 20 px -> 20 px at 450 dpi
f = one("com/android/systemui/samsung/quicksetting/ui/panel/QuickSettingTileGridKt$$ExternalSyntheticLambda15.smali")
s = open(f).read()
assert s.count("check-cast p1, Landroidx/compose/ui/graphics/GraphicsLayerScope;") == 1, "graphics layer scope"
pat = re.compile(r"( +)mul-int/lit8 v0, v0, 0x14\n\n +int-to-float v0, v0\n")
assert len(pat.findall(s)) == 1, "20 px row offset"
assert s.index("check-cast p1, Landroidx/compose/ui/graphics/GraphicsLayerScope;") < pat.search(s).start() \
    < s.index("check-cast p1, Landroidx/compose/ui/graphics/ReusableGraphicsLayerScope;"), "scope cast order"
s = pat.sub(lambda m: m.group(0) + "\n"
                      "%(i)sinvoke-interface {p1}, Landroidx/compose/ui/unit/Density;->getDensity()F\n\n"
                      "%(i)smove-result v2\n\n"
                      "%(i)smul-float/2addr v0, v2\n\n"
                      "%(i)sconst v2, 0x40340000    # 2.8125f (450 dpi)\n\n"
                      "%(i)sdiv-float/2addr v0, v2\n" % {"i": m.group(1)}, s)
open(f, "w").write(s)
PYEOF
LOG "- Quick panel: scaling adjustment relative to the forced resolution, pixel insets converted to dp"
