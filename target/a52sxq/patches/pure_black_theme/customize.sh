# See module.prop.
#
# 1. The overlay. Android resolves every dark-theme surface through a small set of framework colours that exist only
#    for night mode (the *_dark variants): the Material 3 surface roles (system_background_dark, system_surface*_dark)
#    and the dark variants of the neutral palette shades DeviceDefault falls back to (background_device_default_dark ->
#    system_neutral1_900 -> night: system_neutral1_900_dark), plus the two legacy Theme.Material dark backgrounds.
#    The AOSP black-theme implementations force exactly these to #000 (ThemeOverlayController.isPitchBlackSurface():
#    surface roles + neutral1/2 700..1000). A runtime resource overlay on "android" does the same here while Samsung's
#    Colour palette is off (no fabricated palette overlay: mNeutralOverlay/mDynamicOverlay are null on this ROM by
#    default). Light mode never reads a *_dark name, so it cannot change.
#    The source framework-res declares no <overlayable>, so an overlay preinstalled on /product may replace any of
#    its resources; without an entry in an overlay config.xml it is mutable and disabled by default, which is what
#    the switch needs (/product/overlay has no config dir on this ROM).
#    It is built by the pipeline itself: a decoded-apk directory in $APKTOOL_DIR is picked up by make_rom's
#    "Building APKs/JARs" step (scripts/apktool.sh b), which links it against the source framework, signs it with the
#    ROM's platform key and moves it to $WORK_DIR/product/overlay/K4PureBlack/K4PureBlack.apk.
# 2. The switch: Settings > Display, in the dark mode card right under "Dark mode schedule".
#    K4PureBlackPreferenceController (smali next to this script) reads and switches the overlay through
#    OverlayManager (SecSettings is android.uid.system); hidden when the overlay is not installed.
OVERLAY_PACKAGE="com.k4.overlay.pureblack"
OVERLAY_DIR="overlay/K4PureBlack"
OVERLAY_APK="$OVERLAY_DIR/K4PureBlack.apk"
# Only names ending in _dark (checked below), i.e. resources no light theme uses.
PURE_BLACK_COLORS="
system_background_dark
system_surface_dark
system_surface_dim_dark
system_surface_bright_dark
system_surface_variant_dark
system_surface_container_lowest_dark
system_surface_container_low_dark
system_surface_container_dark
system_surface_container_high_dark
system_surface_container_highest_dark
system_neutral1_700_dark
system_neutral1_800_dark
system_neutral1_900_dark
system_neutral1_1000_dark
system_neutral2_700_dark
system_neutral2_800_dark
system_neutral2_900_dark
system_neutral2_1000_dark
background_material_dark
background_floating_material_dark
"

FRAMEWORK_RES="$WORK_DIR/system/system/framework/framework-res.apk"
[ -f "$FRAMEWORK_RES" ] || ABORT "pure_black_theme: ${FRAMEWORK_RES//$WORK_DIR/} not found"
SECSETTINGS="system/priv-app/SecSettings/SecSettings.apk"
# Also makes sure the source framework is installed for apktool before the overlay is built
DECODE_APK "system" "$SECSETTINGS" || ABORT "Failed to decode $SECSETTINGS"

LOG "- Creating the $OVERLAY_PACKAGE overlay (dark surface colours -> #000000)"
# shellcheck disable=SC2086
python3 - "$FRAMEWORK_RES" "$APKTOOL_DIR/product/$OVERLAY_APK" "$OVERLAY_PACKAGE" \
    "$(GET_PROP "system" "ro.build.version.incremental")" "$(GET_PROP "system" "ro.build.version.sdk")" \
    "$(GET_PROP "system" "ro.build.version.release")" $PURE_BLACK_COLORS << 'PYEOF' || ABORT "Failed to create the pure black overlay"
import os, re, sys, zipfile
framework, out, package, tag, sdk, release = sys.argv[1:7]
colors = sys.argv[7:]
assert tag and sdk.isdigit() and release, (tag, sdk, release)
assert len(colors) >= 10 and len(set(colors)) == len(colors), colors

# Every colour must still be a resource name of the framework this ROM ships (key string pool of resources.arsc,
# UTF-8: <chars><bytes><name>\0), otherwise the overlay entry would silently do nothing
arsc = zipfile.ZipFile(framework).read("resources.arsc")
for c in colors:
    assert re.fullmatch(r"[a-z0-9_]+_dark", c), "%s is not a dark-only colour name" % c
    b = c.encode()
    assert len(b) < 128 and bytes([len(b), len(b)]) + b + b"\0" in arsc, "android:color/%s no longer exists in framework-res" % c

files = {
    "apktool.yml": """\
version: v3.0.3-8-c0886b27-SNAPSHOT
apkFileName: %(apk)s
usesFramework:
  ids:
  - 1
  tag: %(tag)s
sdkInfo:
  minSdkVersion: %(sdk)s
  targetSdkVersion: %(sdk)s
versionInfo:
  versionCode: 1
  versionName: 1.0
resourcesInfo:
  packageId: 127
  compactEntries: false
  keepRawValues: false
doNotCompress:
- arsc
""" % dict(apk=os.path.basename(out), tag=tag, sdk=sdk),
    "AndroidManifest.xml": """\
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android" android:compileSdkVersion="%(sdk)s" android:compileSdkVersionCodename="%(release)s" package="%(package)s" platformBuildVersionCode="%(sdk)s" platformBuildVersionName="%(release)s">
    <application android:hasCode="false" android:label="Pure black dark mode"/>
    <overlay android:targetPackage="android"/>
</manifest>
""" % dict(sdk=sdk, release=release, package=package),
    "res/values/colors.xml": '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
        + "".join('    <color name="%s">#ff000000</color>\n' % c for c in colors) + "</resources>\n",
}
changed = False
for rel, text in files.items():
    p = os.path.join(out, rel)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    if not (os.path.exists(p) and open(p).read() == text):
        open(p, "w").write(text)
        changed = True
# scripts/apktool.sh copies original/META-INF into the build; a new package has none
os.makedirs(os.path.join(out, "original", "META-INF"), exist_ok=True)
stray = sorted(set(os.listdir(os.path.join(out, "res", "values"))) - {"colors.xml"})
assert not stray, "unexpected files in the overlay sources: %s" % stray
print("  - %s: %d colours%s" % (package, len(colors), "" if changed else " (already present)"))
PYEOF

SET_METADATA "product" "$OVERLAY_DIR" 0 0 755 "u:object_r:system_file:s0"
SET_METADATA "product" "$OVERLAY_APK" 0 0 644 "u:object_r:system_file:s0"

LOG "- Adding the \"Pure black dark mode\" switch to Display settings"
python3 - "$APKTOOL_DIR/system/${SECSETTINGS//system\//}" "$MODPATH/K4PureBlackPreferenceController.smali" \
    "$OVERLAY_PACKAGE" << 'PYEOF' || ABORT "Failed to add the pure black switch"
import glob, os, re, sys
root, helper_src, package = sys.argv[1:4]

PARENT = "Lcom/android/settings/display/HdrBrightnessPreferenceController;"
OURS = "Lcom/k4/settings/display/K4PureBlackPreferenceController;"
KEY = "k4_pure_black"
LITERAL = "com.k4.overlay.pureblack"        # the package name written in the smali source
STRINGS = (
    ("k4_pure_black_title", "Pure black dark mode"),
    ("k4_pure_black_summary",
     "Use true black instead of dark grey in apps that follow Android\\'s dark theme. "
     "One UI\\'s own cards and panels are not changed."),
)

def one(rel):
    hits = glob.glob(root + "/smali*/" + rel)
    assert len(hits) == 1, "%s: %d" % (rel, len(hits))
    return hits[0]

h = open(helper_src).read()
assert h.startswith(".class public %s\n.super %s\n" % (OURS, PARENT)) and h.count('"%s"' % LITERAL) == 2, "unexpected helper source"

# 1. What the class relies on in this SecSettings: a concrete, non-final toggle controller as parent whose
#    availability / isChecked / setChecked can be overridden, and the protected mContext
p = open(one("com/android/settings/display/HdrBrightnessPreferenceController.smali")).read()
head = p.split("\n", 1)[0]
assert head.startswith(".class public ") and " final " not in head and " abstract " not in head and head.endswith(PARENT), "parent class: " + head
assert "\n.super Lcom/android/settings/core/TogglePreferenceController;\n" in p, "parent is not a TogglePreferenceController"
for sig in ("constructor <init>(Landroid/content/Context;Ljava/lang/String;)V", "getAvailabilityStatus()I",
            "isChecked()Z", "setChecked(Z)Z"):
    assert ("\n.method public %s\n" % sig) in p, "parent %s is missing, final or no longer public" % sig
assert not re.search(r"^\.method [^\n]*\brun\(\)V$", p, re.M), "parent now has its own run()"
t = open(one("com/android/settings/core/TogglePreferenceController.smali")).read()
assert not re.search(r"^\.method [^\n]*\brun\(\)V$", t, re.M), "TogglePreferenceController now has its own run()"
ctx = open(one("com/android/settingslib/core/AbstractPreferenceController.smali")).read()
assert re.search(r"^\.field protected (final )?mContext:Landroid/content/Context;$", ctx, re.M), "AbstractPreferenceController.mContext"

# 2. Install the class: the highest-numbered dex has the most method-id headroom
dirs = sorted((d for d in glob.glob(root + "/smali_classes*") if re.fullmatch(r"smali_classes\d+", os.path.basename(d))),
              key=lambda d: int(os.path.basename(d)[len("smali_classes"):]))
assert dirs, "no smali_classesN"
dst = dirs[-1] + "/com/k4/settings/display/K4PureBlackPreferenceController.smali"
stale = [f for f in glob.glob(root + "/smali*/com/k4/settings/display/K4PureBlackPreferenceController.smali") if f != dst]
assert not stale, "stale controller copies: %s" % stale
os.makedirs(os.path.dirname(dst), exist_ok=True)
text = h.replace('"%s"' % LITERAL, '"%s"' % package)
if not (os.path.exists(dst) and open(dst).read() == text):
    open(dst, "w").write(text)
    print("  - controller %s in %s (overlay %s)" % (OURS[1:-1].replace("/", "."), os.path.basename(dirs[-1]), package))

# 3. Strings (English only; other locales fall back to it)
sf = root + "/res/values/strings.xml"
s = open(sf).read()
added = []
for name, text in STRINGS:
    m = re.search(r'<string name="%s">(.*?)</string>' % re.escape(name), s, re.S)
    if m:
        assert m.group(1) == text, "string %s already exists with another text" % name
        continue
    assert s.count("</resources>") == 1, "strings.xml: </resources>"
    s = s.replace("</resources>", '    <string name="%s">%s</string>\n</resources>' % (name, text))
    added.append(name)
if added:
    open(sf, "w").write(s)
    print("  - strings: " + ", ".join(added))

# 4. The row, in the dark mode card of Samsung's Display page: after "Dark mode schedule" (dark_mode_settings),
#    before the inset that closes the card. Other editors of this file anchor elsewhere (hdr_brightness_toggle:
#    outdoor_mode_caption, hfr: sec_high_refresh_rate, unica/mods/settings: sec_screen_size), so every order works.
xf = root + "/res/xml/sec_display_settings.xml"
x = open(xf).read()
if 'android:key="%s"' % KEY in x:
    print("  - Display settings row already present")
else:
    assert any("<SecSwitchPreference " in open(f).read() for f in glob.glob(root + "/res/xml/*.xml")), \
        "SecSwitchPreference is not used by this SecSettings"
    lines = x.split("\n")
    hits = [i for i, l in enumerate(lines) if 'android:key="dark_mode_settings"' in l]
    assert len(hits) == 1, "dark_mode_settings anchor: %d" % len(hits)
    i = hits[0]
    assert lines[i].lstrip().startswith("<") and lines[i].rstrip().endswith("/>"), "anchor is not a single-line preference"
    assert i > 0 and 'android:key="dark_mode"' in lines[i - 1], "dark_mode_settings no longer follows the dark mode selector"
    assert 'xmlns:settings="http://schemas.android.com/apk/res-auto"' in x, "settings namespace"
    indent = lines[i][:len(lines[i]) - len(lines[i].lstrip())]
    row = (indent + '<SecSwitchPreference android:title="@string/k4_pure_black_title" android:key="%s" '
           'android:summary="@string/k4_pure_black_summary" '
           'settings:controller="%s" />') % (KEY, OURS[1:-1].replace("/", "."))
    lines.insert(i + 1, row)
    open(xf, "w").write("\n".join(lines))
    print("  - row after dark_mode_settings in sec_display_settings.xml")
PYEOF

# One UI only installs packages from the system partitions that are named in
# /system/etc/sysconfig/allowed-system-preload-apps.xml (PMRune.PM_ALLOWED_SYSTEM_PRELOAD_APPS, checked in
# InstallPackageHelper.processParseResult: "Package is not in allowed list : <pkg>" and the package is skipped).
# 9.3.18's first build shipped the overlay without it: the apk was on /product, never installed, and the switch
# stayed hidden. Put the overlay package on the list.
PRELOAD_ALLOWLIST="$WORK_DIR/system/system/etc/sysconfig/allowed-system-preload-apps.xml"
if [ -f "$PRELOAD_ALLOWLIST" ]; then
    if grep -q "<allowed-system-preload package=\"$OVERLAY_PACKAGE\"" "$PRELOAD_ALLOWLIST"; then
        LOG "- $OVERLAY_PACKAGE is already an allowed system preload package"
    else
        [ "$(grep -c "^</config>" "$PRELOAD_ALLOWLIST")" = "1" ] || ABORT "pure_black_theme: unexpected ${PRELOAD_ALLOWLIST//$WORK_DIR/} layout"
        LOG "- Allowing $OVERLAY_PACKAGE as a system preload package"
        EVAL "sed -i \"s|^</config>|    <allowed-system-preload package=\\\"$OVERLAY_PACKAGE\\\"/>\n</config>|\" \"$PRELOAD_ALLOWLIST\""
        grep -q "<allowed-system-preload package=\"$OVERLAY_PACKAGE\"" "$PRELOAD_ALLOWLIST" || ABORT "pure_black_theme: failed to patch ${PRELOAD_ALLOWLIST//$WORK_DIR/}"
    fi
else
    LOG "- No allowed-system-preload-apps.xml in this source, nothing to allow"
fi
unset OVERLAY_PACKAGE OVERLAY_DIR OVERLAY_APK PURE_BLACK_COLORS FRAMEWORK_RES SECSETTINGS PRELOAD_ALLOWLIST
