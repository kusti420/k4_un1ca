# From the resolution audit of 2026-10-13 (/mnt/B1/OneUi9/scratch/resaudit; dry-run with proposed/dryrun.sh)
# See module.prop. vn/s.v(): touch width = max(touch_minimum_width, touch_width_in_phone_thin/medium (16dp/20dp));
# CocktailBarService / ho/i / kn/d: window width = window_width_on_trigger.
# 80 px and 41 px at 450 dpi (2.8125 px/dp), +0.02 px so rounding and truncation both give the stock count at FHD+:
#   window_width_on_trigger 28.452dp -> 80 / 53 / 40 px      touch_minimum_width 14.585dp -> 41 / 27 / 21 px
LAUNCHER="priv-app/TouchWizHome_2017/TouchWizHome_2017.apk"
DECODE_APK "system" "$LAUNCHER" || ABORT "Failed to decode $LAUNCHER"
python3 - "$APKTOOL_DIR/system/$LAUNCHER" << 'PYEOF' || ABORT "Failed to patch the edge handle dimens"
import re, sys
f = sys.argv[1] + "/res/values/dimens.xml"
s = open(f).read()
for name, px, dp in (("window_width_on_trigger", "80.0", "28.452"), ("touch_minimum_width", "41.0", "14.585")):
    old = '<dimen name="%s">%spx</dimen>' % (name, px)
    new = '<dimen name="%s">%sdp</dimen>' % (name, dp)
    if new in s:
        print("  - %s already in dp" % name)
        continue
    assert s.count(old) == 1, "%s is no longer %spx" % (name, px)
    s = s.replace(old, new)
    print("  - %s %spx -> %sdp" % (name, px, dp))
# no other configuration may carry these names (a qualified value would win over values/)
import glob, os
for g in glob.glob(os.path.dirname(os.path.dirname(f)) + "/values-*/dimens.xml"):
    t = open(g).read()
    assert 'name="window_width_on_trigger"' not in t and 'name="touch_minimum_width"' not in t, g
open(f, "w").write(s)
PYEOF
LOG "- Edge panel handle window width and minimum touch width in dp"
unset LAUNCHER
