# Settings > Lock screen and AOD > "AOD brightness": Automatic (default) / Automatic, brighter / Lowest / Low / Medium.
#
# Why here and not in AODService: the One UI 9 AODService has no brightness preference any more (its own slider moved
# to Good Lock's LockStar), patching the APK breaks its Samsung signature (Galaxy Store updates, see patches/
# aod_brightness) and the test phone already runs a Galaxy Store copy from /data that would shadow a patched system
# APK anyway. Every AOD brightness AODService computes - index mode and platform-brightness mode alike - reaches
# SystemUI through PluginAOD.Callback.onUpdateDozeBrightness -> AODMachine -> AODScreenBrightness.updateDozeBrightness
# (mode, index, brightness), which turns it into the float for DreamService.semSetDozeScreenBrightness. That one
# method is hooked: K4AodBrightness.apply(level) returns the level to use (persist.sys.k4.aod_brightness, see the
# helper). The backlight level picks the S6E3FC3 HLPM step in the kernel (samsung,aod_candela_map_table: 0-11 = 2 nit,
# 12-31 = 10, 32-54 = 30, 55-255 = 60), so there are exactly four real levels on this panel - hence a 4-step choice
# like the stock A52s slider (aod_brightness_value 0-3), not a continuous one.
# A new value applies the next time AODService pushes a brightness (next AOD start or light change).

AOD_BRIGHTNESS_PROP="persist.sys.k4.aod_brightness"
SYSTEMUI="priv-app/SystemUI/SystemUI.apk"
SECSETTINGS="system/priv-app/SecSettings/SecSettings.apk"

LOG "- AOD brightness choice (Settings > Lock screen and AOD)"

DECODE_APK "system_ext" "$SYSTEMUI" || ABORT "Failed to decode $SYSTEMUI"
python3 - "$APKTOOL_DIR/system_ext/$SYSTEMUI" "$MODPATH/K4AodBrightness.smali" "$AOD_BRIGHTNESS_PROP" << 'PYEOF' || ABORT "Failed to hook AODScreenBrightness"
import glob, os, re, sys
root, helper_src, prop = sys.argv[1:4]
LITERAL = "persist.sys.k4.aod_brightness"
CALL = "    invoke-static {p3}, Lcom/k4/aod/K4AodBrightness;->apply(I)I\n\n    move-result p3\n\n"

hits = glob.glob(root + "/smali*/com/android/systemui/doze/AODScreenBrightness.smali")
assert len(hits) == 1, hits
s = open(hits[0]).read()
m = re.search(r"^\.method public final updateDozeBrightness\(III\)V\n.*?^\.end method\n", s, re.M | re.S)
assert m, "AODScreenBrightness.updateDozeBrightness(III)V"
body = m.group(0)
if "Lcom/k4/aod/K4AodBrightness;->apply(I)I" in body:
    print("  - AODScreenBrightness already hooked")
else:
    # p1 = -1 here; p3 = the resolved backlight level (explicit value, or brightnessValues[index]) or -1.
    # The hook goes right at the merge point, before "if (level == -1) f = -1.0f else f = (level - min) / (max - min)".
    anchor = re.compile(r"(\n    :cond_\w+\n    :goto_\w+\n)(    const/4 v1, 0x0\n\n    if-ne p3, p1, :cond_\w+\n\n    const/high16 p1, -0x40800000)")
    assert len(anchor.findall(body)) == 1, "merge point before the float conversion not found"
    assert "    const/4 p1, -0x1\n\n    if-ne p3, p1, :cond_" in body, "p1 is no longer the -1 constant"
    new = anchor.sub(lambda g: g.group(1) + CALL + g.group(2), body)
    open(hits[0], "w").write(s.replace(body, new))
    print("  - hooked %s" % os.path.relpath(hits[0], root))

h = open(helper_src).read()
assert h.count('"%s"' % LITERAL) == 1 and "\n.class public final Lcom/k4/aod/K4AodBrightness;\n" in h
dirs = sorted((d for d in glob.glob(root + "/smali_classes*") if re.fullmatch(r"smali_classes\d+", os.path.basename(d))),
              key=lambda d: int(os.path.basename(d)[len("smali_classes"):]))
assert dirs, "no smali_classesN"
dst = dirs[-1] + "/com/k4/aod/K4AodBrightness.smali"
stale = [f for f in glob.glob(root + "/smali*/com/k4/aod/K4AodBrightness.smali") if f != dst]
assert not stale, stale
os.makedirs(os.path.dirname(dst), exist_ok=True)
open(dst, "w").write(h.replace('"%s"' % LITERAL, '"%s"' % prop))
print("  - helper in %s" % os.path.basename(dirs[-1]))
PYEOF

DECODE_APK "system" "$SECSETTINGS" || ABORT "Failed to decode $SECSETTINGS"
python3 - "$APKTOOL_DIR/system/${SECSETTINGS//system\//}" "$MODPATH/K4AodBrightnessPreferenceController.smali" \
    "$AOD_BRIGHTNESS_PROP" << 'PYEOF' || ABORT "Failed to add the AOD brightness setting"
import glob, os, re, sys
root, helper_src, prop = sys.argv[1:4]
OURS = "Lcom/k4/settings/lockscreen/K4AodBrightnessPreferenceController;"
KEY = "k4_aod_brightness"
LITERAL = "persist.sys.k4.aod_brightness"

# value written to the property, label (order = order in the dialog)
# The labels carry no nit figures on purpose: the four fixed levels are the panel driver's nominal low-power steps
# (2 / 10 / 30 / 60 nit) while the panel is in its low-power mode, but in "tap to show" AOD the screen is briefly in
# normal mode at the same backlight level, and none of it has been measured with a light meter. "Highest" is the
# level stock only reaches above 100 lux; indoors it looks far too bright (owner's verdict, 2026-10-13), so the fixed
# top level (property value 4, still understood by K4AodBrightness) is not offered. Automatic and "Automatic,
# brighter" can still reach it in bright surroundings.
CHOICES = (
    (0, "Automatic"),
    (5, "Automatic, brighter"),
    (1, "Lowest"),
    (2, "Low"),
    (3, "Medium"),
)
# NOTE: the controller picks the entry whose VALUE is nearest to the stored one (K4AdaptiveDelay's nearest()); with
# the exact values written by this dialog that is always the right entry. The value array need not be sorted.
STRINGS = (("k4_aod_brightness_title", "AOD brightness"),)
ARRAYS = (
    ("string-array", "k4_aod_brightness_entries", [c[1] for c in CHOICES]),
    ("integer-array", "k4_aod_brightness_values", [str(c[0]) for c in CHOICES]),
)
INTEGERS = (("k4_aod_brightness_default", "0"),)

h = open(helper_src).read()
assert h.count(LITERAL) >= 3 and ("\n.class public %s\n" % OURS) in h, "unexpected controller source"
# The controller is K4AdaptiveDelayPreferenceController (patches/hfr) renamed, so everything it references in
# SecSettings is what that patch already asserts on every build. If this patch can run without hfr, copy hfr's
# reference / abstract-method checks (its python steps 1 and 2) here.
for cls in sorted(set(re.findall(r"L(?:androidx|com/android/settings|com/android/settingslib|com/samsung)/[^;]+;", h))):
    assert glob.glob(root + "/smali*/" + cls[1:-1] + ".smali"), "%s is not in this SecSettings" % cls

dirs = sorted((d for d in glob.glob(root + "/smali_classes*") if re.fullmatch(r"smali_classes\d+", os.path.basename(d))),
              key=lambda d: int(os.path.basename(d)[len("smali_classes"):]))
assert dirs, "no smali_classesN"
dst = dirs[-1] + "/" + OURS[1:-1] + ".smali"
stale = [f for f in glob.glob(root + "/smali*/" + OURS[1:-1] + ".smali") if f != dst]
assert not stale, stale
os.makedirs(os.path.dirname(dst), exist_ok=True)
open(dst, "w").write(h.replace(LITERAL, prop))
print("  - controller in %s" % os.path.basename(dirs[-1]))

def add(path, items, render, existing):
    s = open(path).read()
    added = []
    for item in items:
        name = item[-2] if len(item) == 3 else item[0]
        want = render(item)
        m = re.search(existing % re.escape(name), s, re.S)
        if m:
            assert re.sub(r"\s+", "", m.group(0)) == re.sub(r"\s+", "", want), "%s already exists with other content" % name
            continue
        assert s.count("</resources>") == 1, path + ": </resources>"
        s = s.replace("</resources>", want + "</resources>")
        added.append(name)
    if added:
        open(path, "w").write(s)
        print("  - %s: %s" % (os.path.basename(path), ", ".join(added)))

add(root + "/res/values/strings.xml", STRINGS, lambda i: '    <string name="%s">%s</string>\n' % i,
    r'<string name="%s">.*?</string>')
add(root + "/res/values/arrays.xml", ARRAYS,
    lambda i: '    <%s name="%s">\n%s    </%s>\n' % (i[0], i[1], "".join("        <item>%s</item>\n" % v for v in i[2]), i[0]),
    r'<(?:string|integer)-array name="%s">.*?</(?:string|integer)-array>')
add(root + "/res/values/integers.xml", INTEGERS, lambda i: '    <integer name="%s">%s</integer>\n' % i,
    r'<integer name="%s">.*?</integer>')
assert re.search(r'<string name="summary_placeholder">', open(root + "/res/values/strings.xml").read()), "string/summary_placeholder"

# The row: inside always_on_screen_category, right under the "Always On Display" row
xf = root + "/res/xml/sec_lockscreen_settings.xml"
x = open(xf).read()
if 'android:key="%s"' % KEY in x:
    print("  - Lock screen settings row already present")
else:
    assert glob.glob(root + "/smali*/androidx/preference/SecPreference.smali"), "androidx.preference.SecPreference"
    assert 'xmlns:settings="http://schemas.android.com/apk/res-auto"' in x, "settings namespace"
    lines = x.split("\n")
    start = [i for i, l in enumerate(lines) if 'android:key="always_on_screen"' in l]
    assert len(start) == 1, "always_on_screen anchor: %d" % len(start)
    i = start[0]
    tag = re.match(r"\s*<([\w.]+) ", lines[i]).group(1)
    assert not lines[i].rstrip().endswith("/>"), "always_on_screen is expected to have an <intent> child"
    end = next(j for j in range(i + 1, len(lines)) if lines[j].strip() == "</%s>" % tag)
    indent = lines[i][:len(lines[i]) - len(lines[i].lstrip())]
    lines.insert(end + 1, indent + '<SecPreference android:title="@string/k4_aod_brightness_title" android:key="%s" '
                 'android:summary="@string/summary_placeholder" settings:controller="%s" />' % (KEY, OURS[1:-1].replace("/", ".")))
    open(xf, "w").write("\n".join(lines))
    print("  - row under always_on_screen in sec_lockscreen_settings.xml")
PYEOF

unset AOD_BRIGHTNESS_PROP SYSTEMUI SECSETTINGS
