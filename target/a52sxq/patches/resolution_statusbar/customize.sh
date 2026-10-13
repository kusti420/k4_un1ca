# From the resolution audit of 2026-10-13 (/mnt/B1/OneUi9/scratch/resaudit; python part dry-run and the patched smali assembled with proposed/dryrun.sh)
# Covers items A (notification icon slot), B (shade header battery height), C (keyguard message area margin).
#
# ---------------------------------------------------------------------------------------------------------------
# A, variant 1 (recommended, no smali): framework overlay value, target/a52sxq/overlay/values/dimens.xml
#
#     <!-- k4: IndicatorScaleGardener.getLatestScaleModel() takes this ratio as is when it is >= 0.75 and then no
#          longer calls getMaxRatio(), which reads IndicatorGardenPresenter.cachedGardenModel. That model is half
#          updated while a resolution switch is delivered (new status bar height, old camera top margin), so
#          callers that sample the ratio at that moment keep a wrong one (status bar notification icons: 0.75 at
#          HD+ / 540p, 0.934 back at FHD+). 0.8588 = (88 - 33) / 68 + 0.05, the settled FHD+ value. -->
#     <dimen name="status_bar_scale_garden_fixed_ratio">0.8588</dimen>
#
#   notification icon slot = (int)(px(18dp) * 0.8588): 43 / 29 / 21 px (FHD+ / HD+ / 540p) = 43 / 43.5 / 42 native px
#   status icon slot (15dp, * 9/8 from statusbar_icon_size): 40 / 27 / 20 px (540p was 19)
#   FHD+ clock / battery / system icons: unchanged (0.8588 is what they use today once settled)
#   FHD+ notification icons: 47 -> 43 px (today's 47 is itself the transient value, ratio 0.934)
#
# A, variant 2 (only if the 47 px FHD+ look must stay): keep variant 1 out and make the slot width independent of
# the garden model: ratio = clamp(smallestWidth / 411, 0.75, 1.0) = 0.934 in every mode -> 47 / 31 / 23 px.
# ---------------------------------------------------------------------------------------------------------------
DECODE_APK "system_ext" "priv-app/SystemUI/SystemUI.apk"
python3 - "$APKTOOL_DIR/system_ext/priv-app/SystemUI/SystemUI.apk" << 'PYEOF' || ABORT "Failed to patch SystemUI (resolution: status bar)"
import glob, re, sys
A = sys.argv[1]
A_VARIANT_2 = False          # see the header

def one(rel):
    f = glob.glob(A + "/smali*/" + rel)
    assert len(f) == 1, "%s: %d" % (rel, len(f))
    return f[0]

def res_id(kind, name):
    m = re.search(r'<public type="%s" name="%s" id="(0x[0-9a-f]+)" />' % (kind, name), open(A + "/res/values/public.xml").read())
    assert m, "%s/%s" % (kind, name)
    return m.group(1)

# --- A variant 2: NotificationIconContainerViewBinder$bindIcons$3$layoutParams$1.invokeSuspend ---------------------
# width = (int)(I$0 * getLatestScaleModel(view.context).ratio). Replace the ratio by clamp(sw / 411, 0.75, 1.0) taken
# from the same ScaleModel (currentSmallestWidth is the 5th constructor argument = Configuration.smallestScreenWidthDp).
if A_VARIANT_2:
    f = one("com/android/systemui/statusbar/notification/icon/ui/viewbinder/NotificationIconContainerViewBinder$bindIcons$3$layoutParams$1.smali")
    s = open(f).read()
    SM = r"Lcom/android/systemui/statusbar/phone/IndicatorScaleGardener\$ScaleModel;"
    pat = re.compile(r"( +)iget p0, p0, " + SM + r"->ratio:F\n\n(?= +int-to-float p1, v0\n\n +mul-float/2addr p1, p0\n\n +float-to-int v0, p1\n)")
    hits = list(pat.finditer(s))
    assert len(hits) == 1, "layoutParams ratio: %d" % len(hits)
    m = hits[0]; i = m.group(1)
    assert re.search(r"^    \.locals 3$", s[:m.start()][s[:m.start()].rindex(".method"):], re.M), "locals"   # v2 is free here
    new = (i + "iget p0, p0, Lcom/android/systemui/statusbar/phone/IndicatorScaleGardener$ScaleModel;->currentSmallestWidth:I\n\n"
           + i + "int-to-float p0, p0\n\n"
           + i + "const p1, 0x43cd8000    # 411.0f\n\n"
           + i + "div-float/2addr p0, p1\n\n"
           + i + "const/high16 p1, 0x3f400000    # 0.75f\n\n"
           + i + "const/high16 v2, 0x3f800000    # 1.0f\n\n"
           + i + "invoke-static {p0, p1, v2}, Lkotlin/ranges/RangesKt___RangesKt;->coerceIn(FFF)F\n\n"
           + i + "move-result p0\n\n")
    s = s[:m.start()] + new + s[m.end():]
    open(f, "w").write(s)

# --- B: SamsungBatteryViewModel.Companion.getStatusBarBatteryHeight() -------------------------------------------------
# returns (13 * status_bar_icon_scale_factor * DisplayMetrics.density) packed as SP; the composables then run toDp() and
# Modifier.height(), so the density is applied twice (px = 13 * density^2 * font scale): 103 / 47 / 27 px. The 24dp
# header row (68 / 45 / 34 px) cuts the first two, at 225 dpi the value is below the row. Use the FHD+ density as a
# constant: 36.6sp -> 103 / 69 / 51 px, cut by the row (and by the status bar content height) in every mode, exactly as
# at FHD+ today.
f = one("com/android/systemui/battery/SamsungBatteryViewModel$Companion.smali")
s = open(f).read()
m = re.search(r"^\.method public static getStatusBarBatteryHeight-\w+\(Landroid/content/Context;\)J\n.*?^\.end method\n", s, re.M | re.S)
assert m, "getStatusBarBatteryHeight"
body = m.group(0)
old = "    iget p0, p0, Landroid/util/DisplayMetrics;->density:F\n\n    mul-float/2addr v0, p0\n"
assert body.count(old) == 1, "density multiply"
assert "Landroidx/compose/ui/unit/TextUnitType;->Sp:J" in body, "no longer packed as sp"
body = body.replace(old, "    const p0, 0x40340000    # 2.8125f = 450 dpi / 160\n\n    mul-float/2addr v0, p0\n")
s = s[:m.start()] + body + s[m.end():]
open(f, "w").write(s)

# --- C: KeyguardMessageArea: restore the AOSP margin update on configuration changes ----------------------------------
# super_notification_shade.xml gives keyguard_message_area_container layout_marginTop="@dimen/status_bar_height" and
# the AuthKeyguardMessageArea in it layout_marginTop="@dimen/keyguard_lock_padding" (20dp). Both are resolved once when
# the shade window is inflated. AOSP's KeyguardMessageArea.onConfigChanged() rewrites the container margin; in this
# build KeyguardMessageAreaController$2.onConfigChanged()/onDensityOrFontScaleChanged() are empty.
SBH = res_id("dimen", "status_bar_height")
PAD = res_id("dimen", "keyguard_lock_padding")
KMA = "Lcom/android/keyguard/KeyguardMessageArea;"
MLP = "Landroid/view/ViewGroup$MarginLayoutParams;"
f = one("com/android/keyguard/KeyguardMessageArea.smali")
s = open(f).read()
assert s.count(".field public mContainer:Landroid/view/ViewGroup;\n") == 1, "mContainer"
assert "k4UpdateMargins" not in s
s = s.rstrip("\n") + """

.method public final k4UpdateMargins()V
    .locals 5

    iget-object v0, p0, %(KMA)s->mContainer:Landroid/view/ViewGroup;

    if-eqz v0, :cond_done

    invoke-virtual {p0}, Landroid/view/View;->getResources()Landroid/content/res/Resources;

    move-result-object v1

    invoke-virtual {v0}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;

    move-result-object v2

    instance-of v3, v2, %(MLP)s

    if-eqz v3, :cond_own

    check-cast v2, %(MLP)s

    const v3, %(SBH)s

    invoke-virtual {v1, v3}, Landroid/content/res/Resources;->getDimensionPixelSize(I)I

    move-result v3

    iget v4, v2, %(MLP)s->topMargin:I

    if-eq v3, v4, :cond_own

    iput v3, v2, %(MLP)s->topMargin:I

    invoke-virtual {v0, v2}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    :cond_own
    invoke-virtual {p0}, Landroid/view/View;->getParent()Landroid/view/ViewParent;

    move-result-object v2

    if-ne v2, v0, :cond_done

    invoke-virtual {p0}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;

    move-result-object v2

    instance-of v3, v2, %(MLP)s

    if-eqz v3, :cond_done

    check-cast v2, %(MLP)s

    const v3, %(PAD)s

    invoke-virtual {v1, v3}, Landroid/content/res/Resources;->getDimensionPixelSize(I)I

    move-result v3

    iget v4, v2, %(MLP)s->topMargin:I

    if-eq v3, v4, :cond_done

    iput v3, v2, %(MLP)s->topMargin:I

    invoke-virtual {p0, v2}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    :cond_done
    return-void
.end method
""" % dict(KMA=KMA, MLP=MLP, SBH=SBH, PAD=PAD)
open(f, "w").write(s)

f = one("com/android/keyguard/KeyguardMessageAreaController$2.smali")
s = open(f).read()
m = re.search(r"^\.method public final onConfigChanged\(Landroid/content/res/Configuration;\)V\n.*?^\.end method\n", s, re.M | re.S)
assert m, "KeyguardMessageAreaController$2.onConfigChanged"
body = m.group(0)
old = "    check-cast p0, %s\n\n    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;\n\n    return-void\n" % KMA
assert body.count(old) == 1, "onConfigChanged body is no longer the empty stub"
body = body.replace(old, "    check-cast p0, %s\n\n    invoke-virtual {p0}, %s->k4UpdateMargins()V\n\n    return-void\n" % (KMA, KMA))
s = s[:m.start()] + body + s[m.end():]
open(f, "w").write(s)
PYEOF
LOG "- Status bar / shade header / keyguard message area follow the screen resolution"
