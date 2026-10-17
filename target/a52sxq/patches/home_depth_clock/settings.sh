# Settings > UN1CA > UI settings: "Home screen depth clock" switch + "Clock position" / "Clock colour" (see module.prop).
# Sourced from target/a52sxq/post_mods.sh: unica_ui_settings.xml only exists once unica/mods/settings has run, and the
# target patches run before the mods. Controllers: settings/smali (generated from settings/src by settings/build.sh).
SECSETTINGS="system/priv-app/SecSettings/SecSettings.apk"
[ -d "$APKTOOL_DIR/system/${SECSETTINGS//system\//}" ] || ABORT "home_depth_clock: SecSettings is not decoded (unica/mods/settings did not run?)"
LOG "- Home screen depth clock switch in UN1CA UI settings"
python3 - "$APKTOOL_DIR/system/${SECSETTINGS//system\//}" "$SRC_DIR/target/a52sxq/patches/home_depth_clock/settings/smali" << 'PYEOF' || ABORT "Failed to add the home depth clock settings"
import glob, os, re, sys
root, smali = sys.argv[1], sys.argv[2]
PKG = "com/k4/settings/homeclock"
SWITCH = "L%s/HomeDepthClockSwitchController;" % PKG
CHOICE = "L%s/HomeDepthClockChoiceController;" % PKG
PARENTS = {SWITCH: "Lcom/android/settings/core/TogglePreferenceController;",
           CHOICE: "Lcom/android/settings/core/BasePreferenceController;"}

STRINGS = (
    ("k4_home_depth_clock_title", "Home screen depth clock"),
    ("k4_home_depth_clock_summary", "Big clock behind the person or object of a wallpaper made with the Gallery wallpaper editor"),
    ("k4_home_depth_clock_position_title", "Clock position"),
    ("k4_home_depth_clock_color_title", "Clock colour"),
)
# values are what the property gets; the first one is the default (property unset)
ARRAYS = (
    ("k4_home_depth_clock_position_entries", ["Automatic (behind the subject)", "Top", "Middle"]),
    ("k4_home_depth_clock_position_values", ["auto", "20", "50"]),
    ("k4_home_depth_clock_color_entries", ["White", "Theme colour"]),
    ("k4_home_depth_clock_color_values", ["white", "accent"]),
)

_cache = {}
def load(desc):
    if desc not in _cache:
        hits = glob.glob(root + "/smali*/" + desc[1:-1] + ".smali")
        assert len(hits) <= 1, "%s: %d copies" % (desc, len(hits))
        _cache[desc] = open(hits[0]).read() if hits else None
    return _cache[desc]

def supers(desc):
    seen, todo, left = [], [(desc, True)], False
    while todo:
        d, is_super = todo.pop(0)
        if d in seen:
            continue
        s = load(d)
        if s is None:
            left = left or (is_super and d != "Ljava/lang/Object;")
            continue
        seen.append(d)
        todo += [(c, is_super) for c in re.findall(r"^\.super (L[^;]+;)$", s, re.M)]
        todo += [(c, False) for c in re.findall(r"^\.implements (L[^;]+;)$", s, re.M)]
    return seen, left

def declares(desc, kind, member, text=None):
    return re.search(r"^\.%s (?:[^\n]* )?%s$" % (kind, re.escape(member)), text or load(desc), re.M)

dirs = sorted((d for d in glob.glob(root + "/smali_classes*") if re.fullmatch(r"smali_classes\d+", os.path.basename(d))),
              key=lambda d: int(os.path.basename(d)[len("smali_classes"):]))
assert dirs, "no smali_classesN"
for ours, parent in PARENTS.items():
    h = open(os.path.join(smali, ours[1:-1] + ".smali")).read()
    assert h.startswith(".class public %s\n" % ours) and re.search(r"^\.super %s$" % re.escape(parent), h, re.M), ours
    assert load(parent), parent
    # 1. every SecSettings member the class uses exists with that signature (compiled against stubs)
    checked = 0
    for owner, member in sorted(set(re.findall(r"(L(?:androidx|com/android/settings|com/android/settingslib|com/samsung)/[^;]+;|%s)->([^\s]+)" % re.escape(ours), h))):
        kind = "field" if ":" in member else "method"
        if owner == ours and declares(None, kind, member, h):
            continue
        start = parent if owner == ours else owner
        assert load(start), "%s is not in this SecSettings" % start
        chain, left = supers(start)
        assert any(declares(d, kind, member) for d in chain) or (left and kind == "method"), \
            "%s->%s not found in this SecSettings" % (owner, member)
        checked += 1
    # 2. no final method overridden, no abstract method left
    mine = set(re.findall(r"^\.method (?!.*\b(?:static|private|constructor)\b)[^\n]*? ([\w$]+\([^)]*\)\S+)$", h, re.M))
    chain, _ = supers(parent)
    abstract, concrete = set(), set()
    for d in chain:
        for flags, sig in re.findall(r"^\.method ([^\n]*? )?([\w$<>-]+\([^)]*\)\S+)$", load(d), re.M):
            flags = " " + (flags or "")
            assert not (sig in mine and " final " in flags), "%s->%s is final" % (d, sig)
            (abstract if " abstract " in flags else concrete).add(sig)
    missing = sorted(abstract - concrete - mine)
    assert not missing, "%s: base has abstract methods the class lacks: %s" % (ours, missing)
    # 3. install into the highest-numbered dex
    dst = dirs[-1] + "/" + ours[1:-1] + ".smali"
    stale = [f for f in glob.glob(root + "/smali*/" + ours[1:-1] + ".smali") if f != dst]
    assert not stale, stale
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    open(dst, "w").write(h)
    print("  - %s in %s (%d references checked)" % (ours[1:-1].split("/")[-1], os.path.basename(dirs[-1]), checked))
assert declares("Lcom/samsung/android/settings/cube/Controllable$ControllableType;", "field",
                "NO_INTERACTION:Lcom/samsung/android/settings/cube/Controllable$ControllableType;"), "ControllableType.NO_INTERACTION"
assert load("Landroidx/preference/SecPreference;") and load("Landroidx/preference/SecSwitchPreference;"), "SecPreference / SecSwitchPreference"

# 4. resources (English only)
def add(path, items, render, existing):
    s = open(path).read()
    added = []
    for item in items:
        name, want = item[0], render(item)
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
add(root + "/res/values/strings.xml", STRINGS, lambda i: '    <string name="%s">%s</string>\n' % (i[0], i[1].replace("'", "\\'")), r'<string name="%s">.*?</string>')
add(root + "/res/values/arrays.xml", ARRAYS,
    lambda i: '    <string-array name="%s">\n%s    </string-array>\n' % (i[0], "".join("        <item>%s</item>\n" % v for v in i[1])),
    r'<string-array name="%s">.*?</string-array>')
assert re.search(r'<string name="summary_placeholder">', open(root + "/res/values/strings.xml").read()), "string/summary_placeholder"

# 5. rows at the end of UN1CA UI settings
xf = root + "/res/xml/unica_ui_settings.xml"
assert os.path.exists(xf), "unica_ui_settings.xml (unica/mods/settings)"
x = open(xf).read()
if 'android:key="k4_home_depth_clock"' in x:
    print("  - UI settings rows already present")
else:
    assert x.count("</PreferenceScreen>") == 1 and 'xmlns:settings="http://schemas.android.com/apk/res-auto"' in x, "unica_ui_settings.xml layout"
    sw, ch = SWITCH[1:-1].replace("/", "."), CHOICE[1:-1].replace("/", ".")
    rows = (
        '    <com.samsung.android.settings.widget.SecInsetCategoryPreference />\n'
        '    <SecSwitchPreference android:title="@string/k4_home_depth_clock_title" android:key="k4_home_depth_clock" '
        'android:summary="@string/k4_home_depth_clock_summary" settings:controller="%s" />\n'
        '    <SecPreference android:title="@string/k4_home_depth_clock_position_title" android:key="k4_home_depth_clock_position" '
        'android:summary="@string/summary_placeholder" android:dependency="k4_home_depth_clock" settings:controller="%s" />\n'
        '    <SecPreference android:title="@string/k4_home_depth_clock_color_title" android:key="k4_home_depth_clock_color" '
        'android:summary="@string/summary_placeholder" android:dependency="k4_home_depth_clock" settings:controller="%s" />\n'
    ) % (sw, ch, ch)
    open(xf, "w").write(x.replace("</PreferenceScreen>", rows + "</PreferenceScreen>"))
    print("  - 3 rows at the end of unica_ui_settings.xml")
PYEOF
unset SECSETTINGS
