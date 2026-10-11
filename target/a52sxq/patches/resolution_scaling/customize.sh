# See module.prop.
#
# What already follows a forced size (Display > Screen resolution, "wm size"), checked on the S948B framework:
#   - dp: the density is scaled with the width (450 -> 300 -> 225)
#   - camera cutout and rounded corners: DisplayContent.updateBaseDisplayMetrics() reloads them through
#     DisplayCutout.fromResourcesRectApproximation()/RoundedCorners.fromResources() with the physical and the
#     forced size (physicalPixelDisplaySizeRatio)
# What did not: the physical dpi. setForcedSize()/setForcedSizeDensity()/DisplayWindowSettings pass the current
# mBaseDisplayPhysicalXDpi/YDpi back in, so DisplayInfo.physicalXDpi stays at the native 409.432 x 406.4 and every
# mm -> px conversion (TypedValue COMPLEX_UNIT_MM/PT/IN: value * metrics.xdpi) keeps producing native pixels.
#
# updateBaseDisplayMetrics(width, height, density, xDpi, yDpi) is the single place that stores the base dpi, and
# every caller sets mIsSizeForced first. The helper replaces the two dpi arguments:
#   forced size:      mInitialPhysicalXDpi * width / mInitialDisplayWidth (same for Y with the heights)
#   not forced:       mInitialPhysicalXDpi (what every caller passes anyway; also drops a scaled value that a
#                     caller hands back after the override is gone)
#   before the initial values exist (constructor): the argument unchanged
# mInitial* always hold the real panel values: the constructor and DeferredDisplayUpdater take them from the
# non-override DisplayInfo, and DeferredDisplayUpdater stores them before it calls updateBaseDisplayMetrics().
SERVICES="system/framework/services.jar"
DECODE_APK "system" "$SERVICES" || ABORT "Failed to decode $SERVICES"
LOG "- Scaling the display's physical dpi with a forced display size (DisplayContent.updateBaseDisplayMetrics)"
python3 - "$APKTOOL_DIR/system/${SERVICES//system\//}" << 'PYEOF' || ABORT "Failed to patch DisplayContent"
import glob, os, re, sys
root = sys.argv[1]
hits = glob.glob(root + "/smali*/com/android/server/wm/DisplayContent.smali")
assert len(hits) == 1, "DisplayContent: %d" % len(hits)
f = hits[0]
s = open(f).read()
DC = "Lcom/android/server/wm/DisplayContent;"
K4 = "Lcom/android/server/wm/K4ForcedSizeDpi;"
dst = os.path.join(os.path.dirname(f), "K4ForcedSizeDpi.smali")
stale = [p for p in glob.glob(root + "/smali*/com/android/server/wm/K4ForcedSizeDpi.smali") if p != dst]
assert not stale, "stale helper copies: %s" % stale

# the fields the helper reads, with the types it assumes
for need in (".field public mIsSizeForced:Z", ".field public mInitialDisplayWidth:I", ".field public mInitialDisplayHeight:I",
             ".field public mInitialPhysicalXDpi:F", ".field public mInitialPhysicalYDpi:F",
             ".field public mBaseDisplayPhysicalXDpi:F", ".field public mBaseDisplayPhysicalYDpi:F"):
    assert s.count(need + "\n") == 1, need

m = re.search(r"^\.method public final updateBaseDisplayMetrics\(IIIFF\)V\n.*?^\.end method\n", s, re.M | re.S)
assert m, "updateBaseDisplayMetrics(IIIFF)V"
body = m.group(0)
# p4/p5 (the dpi arguments) are stored first thing and then reused as scratch registers
head = ("    iput p4, p0, %s->mBaseDisplayPhysicalXDpi:F\n\n"
        "    iput p5, p0, %s->mBaseDisplayPhysicalYDpi:F\n" % (DC, DC))
assert body.count(head) == 1, "dpi stores"
assert body.index(head) < body.index("->mIsSizeForced:Z"), "dpi stores are no longer ahead of the forced-size branch"
loc = re.search(r"^    \.locals (\d+)$", body, re.M)
assert loc and int(loc.group(1)) + 6 <= 16, "p0..p5 no longer fit 4-bit registers"   # invoke-static {p0, p1, p4}
hook = ("    invoke-static {p0, p1, p4}, %s->x(%sIF)F\n\n"
        "    move-result p4\n\n"
        "    invoke-static {p0, p2, p5}, %s->y(%sIF)F\n\n"
        "    move-result p5\n\n" % (K4, DC, K4, DC))
if hook + head in body:
    print("  - updateBaseDisplayMetrics already patched")
else:
    assert K4 not in body, "different K4ForcedSizeDpi hook present"
    # nothing between the method start and the stores may have written p1/p2/p4/p5
    pre = body[:body.index(head)]
    assert not re.search(r"\b(move|const|iget|sget|invoke|move-result)\S* (p1|p2|p4|p5)\b", pre), "arguments overwritten before the stores"
    s = s[:m.start()] + body.replace(head, hook + head, 1) + s[m.end():]
    open(f, "w").write(s)
    print("  - updateBaseDisplayMetrics: dpi arguments through K4ForcedSizeDpi")

open(dst, "w").write("""\
.class public final %(K4)s
.super Ljava/lang/Object;
.source "K4ForcedSizeDpi.java"


# a52sxq resolution_scaling patch: the physical dpi DisplayContent.updateBaseDisplayMetrics() stores for a display.
# With a forced size (Display > Screen resolution, "wm size") it is the real panel dpi scaled by forced / native
# size, so DisplayMetrics.xdpi/ydpi describe the pixels apps actually lay out in and mm -> px conversions keep
# their physical size. Without a forced size it is the real panel dpi.

# direct methods
.method private constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

# forced: mIsSizeForced; base/initial: forced and native size along one axis; initialDpi: real panel dpi of that
# axis; passed: the caller's argument, kept while the display's initial values are not known yet
.method public static scale(ZIIFF)F
    .locals 2

    const/4 v0, 0x0

    cmpl-float v1, p3, v0

    if-lez v1, :cond_passed

    if-lez p2, :cond_passed

    if-nez p0, :cond_forced

    return p3

    :cond_forced
    if-lez p1, :cond_passed

    int-to-float v0, p1

    mul-float/2addr v0, p3

    int-to-float v1, p2

    div-float/2addr v0, v1

    return v0

    :cond_passed
    return p4
.end method

.method public static x(%(DC)sIF)F
    .locals 3

    iget-boolean v0, p0, %(DC)s->mIsSizeForced:Z

    iget v1, p0, %(DC)s->mInitialDisplayWidth:I

    iget v2, p0, %(DC)s->mInitialPhysicalXDpi:F

    invoke-static {v0, p1, v1, v2, p2}, %(K4)s->scale(ZIIFF)F

    move-result v0

    return v0
.end method

.method public static y(%(DC)sIF)F
    .locals 3

    iget-boolean v0, p0, %(DC)s->mIsSizeForced:Z

    iget v1, p0, %(DC)s->mInitialDisplayHeight:I

    iget v2, p0, %(DC)s->mInitialPhysicalYDpi:F

    invoke-static {v0, p1, v1, v2, p2}, %(K4)s->scale(ZIIFF)F

    move-result v0

    return v0
.end method
""" % dict(K4=K4, DC=DC))
print("  - helper %s" % os.path.relpath(dst, root))
PYEOF
unset SERVICES
