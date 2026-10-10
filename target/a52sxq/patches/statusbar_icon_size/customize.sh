# SystemUI IndicatorScaleGardener scales the status bar by min(smallestWidth / 411, maxRatio). On the A52s that is
# min(384 / 411 = 0.93, (88px bar - 33px camera top margin = 55px) / 24dp (68px) + 0.05 = 0.86) = 0.86, and the clock,
# the battery meter and the status icon slots all use it. Only the Fold8 (q8q*) product name bypassed it with 1.0.
# Make the icons a little larger without changing the ratio, so the clock and the other text keep their size:
# - battery meter: samsung_status_bar_battery_icon_* x 15.5/14 (33px -> 38px tall). The drawable geometry uses all of
#   these dimens, so they stay proportional.
# - Wi-Fi / mobile signal / network type: their 14dp (39px) vector drawables are capped by the icon slot height
#   (IconManager.mIconSize = status_bar_system_icon_size x ratio = 36px). Raise only that slot height by 9/8 (40px) so
#   they draw at their native 14dp. status_bar_system_icon_size itself is left alone: ScaleModel.iconSize is also the
#   carrier label text size on the lock screen and in the shade header.
DECODE_APK "system_ext" "priv-app/SystemUI/SystemUI.apk"
python3 - "$APKTOOL_DIR/system_ext/priv-app/SystemUI/SystemUI.apk" << 'PYEOF' || ABORT "Failed to enlarge the status bar icons"
import glob, re, sys
A = sys.argv[1]

f = A + "/res/values/dimens.xml"
s = open(f).read()
SCALE = 15.5 / 14.0
for n in ("height", "width", "width_extended", "max_width", "max_width_extended", "additional_width", "gap"):
    m = re.search(r'(<dimen name="samsung_status_bar_battery_icon_%s">)([0-9.]+)dp(</dimen>)' % n, s)
    assert m, "samsung_status_bar_battery_icon_" + n
    v = ("%.2f" % (float(m.group(2)) * SCALE)).rstrip("0").rstrip(".")
    s = s[:m.start()] + m.group(1) + v + "dp" + m.group(3) + s[m.end():]
open(f, "w").write(s)

f = glob.glob(A + "/smali*/com/android/systemui/statusbar/phone/ui/StatusBarIconControllerImpl.smali")
assert len(f) == 1, "StatusBarIconControllerImpl"; f = f[0]
s = open(f).read()
pat = re.compile(r"( +)iget (\w+), \w+, Lcom/android/systemui/statusbar/phone/IndicatorScaleGardener\$ScaleModel;->iconSize:I\n\n"
                 r"(?= +iput \2, \w+, Lcom/android/systemui/statusbar/phone/ui/IconManager;->mIconSize:I\n)")
hits = list(pat.finditer(s))
assert len(hits) == 1, "IconManager.mIconSize from ScaleModel.iconSize: %d" % len(hits)
m = hits[0]
ind, reg = m.group(1), m.group(2)
s = s[:m.end()] + "%smul-int/lit8 %s, %s, 0x9\n\n%sdiv-int/lit8 %s, %s, 0x8\n\n" % (ind, reg, reg, ind, reg, reg) + s[m.end():]
open(f, "w").write(s)
PYEOF
LOG "- Status bar battery icon x15.5/14, status icon slot height x9/8"
