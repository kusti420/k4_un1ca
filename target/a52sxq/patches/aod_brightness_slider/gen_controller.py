#!/usr/bin/env python3
# UNTESTED helper. Derives K4AodBrightnessPreferenceController.smali from the proven
# target/a52sxq/patches/hfr/K4AdaptiveDelayPreferenceController.smali (same "row opens a single-choice dialog and
# writes a system property" controller) by renaming the class / property / resources and making isAdaptive()
# (the "only while Motion smoothness is Adaptive" gate) always true.
#
#   python3 gen_controller.py <hfr K4AdaptiveDelayPreferenceController.smali> <output .smali>
import re
import sys

src, dst = sys.argv[1], sys.argv[2]
s = open(src).read()

OLD_CLASS = "com/k4/settings/display/K4AdaptiveDelayPreferenceController"
NEW_CLASS = "com/k4/settings/lockscreen/K4AodBrightnessPreferenceController"
for old, new, least in (
    (OLD_CLASS, NEW_CLASS, 10),
    ("K4AdaptiveDelayPreferenceController.java", "K4AodBrightnessPreferenceController.java", 1),
    ("persist.sys.k4.adaptive_idle_ms", "persist.sys.k4.aod_brightness", 3),
    ('"K4AdaptiveDelay"', '"K4AodBrightness"', 2),
    ("k4_adaptive_delay_", "k4_aod_brightness_", 6),
):
    assert s.count(old) >= least, (old, s.count(old))
    s = s.replace(old, new)

# isAdaptive(): the row is always usable
m = re.search(r"^\.method private isAdaptive\(\)Z\n.*?^\.end method\n", s, re.M | re.S)
assert m and "getIntRefreshRate" in m.group(0), "isAdaptive() not found"
s = s.replace(m.group(0), ".method private isAdaptive()Z\n    .locals 0\n\n    const/4 p0, 0x1\n\n    return p0\n.end method\n")
assert "SecDisplayUtils" not in s, "SecDisplayUtils is still referenced"

# currentIndex(): the stored value 0 (Automatic) is a real choice here, the original treats <= 0 as "unset".
# With k4_aod_brightness_default = 0 both readings give the same index, so the code can stay as it is.

open(dst, "w").write(s)
print("wrote", dst)
