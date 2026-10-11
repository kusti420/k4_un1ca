# See module.prop.
#
# Enforcement already exists in services.jar (verified on device): HdrBrightnessModifier$HdrSettingsObserver watches
# Settings.Secure hdr_brightness_enabled (default 1) and recalculateMode() returns NO_HDR while it is 0, so the panel
# keeps the SDR brightness and SurfaceFlinger tone maps HDR content at an HDR/SDR ratio of 1.
#
# Settings side: the stock com.android.settings.display.HdrBrightnessPreferenceController is a plain
# TogglePreferenceController on that key (unset reads as on), but HdrBrightnessUtils.getAvailabilityStatus() also needs
# Display.isHdrSdrRatioAvailable(), which is false on this panel. That util is shared with the AOSP "Enhanced HDR
# brightness" page (intensity slider, preview, catalyst screen), which Samsung's Display page does not link and which
# stays hidden; only this row gets a subclass whose availability is "the default display is HDR".
#
# sec_display_settings.xml is also edited by unica/mods/settings (Screen resolution row after sec_screen_size, runs
# after target patches) - different lines, either order works.
SECSETTINGS="system/priv-app/SecSettings/SecSettings.apk"
DECODE_APK "system" "$SECSETTINGS" || ABORT "Failed to decode $SECSETTINGS"
LOG "- Adding the \"Brighten screen for HDR\" switch to Display settings"
python3 - "$APKTOOL_DIR/system/${SECSETTINGS//system\//}" << 'PYEOF' || ABORT "Failed to add the HDR brightness switch"
import glob, os, re, sys
root = sys.argv[1]

PARENT = "Lcom/android/settings/display/HdrBrightnessPreferenceController;"
OURS = "Lcom/k4/settings/display/K4HdrBrightnessPreferenceController;"
KEY = "k4_hdr_brightness"
STRINGS = (
    ("k4_hdr_brightness_title", "Brighten screen for HDR"),
    ("k4_hdr_brightness_summary",
     "Raise the screen brightness while HDR videos and photos are shown. Turn off to keep your normal brightness."),
)

def one(rel):
    hits = glob.glob(root + "/smali*/" + rel)
    assert len(hits) == 1, "%s: %d" % (rel, len(hits))
    return hits[0]

# 1. The stock controller must still be the toggle on Settings.Secure hdr_brightness_enabled this patch relies on
p = open(one("com/android/settings/display/HdrBrightnessPreferenceController.smali")).read()
head = p.split("\n", 1)[0]
assert head.startswith(".class public ") and " final " not in head and head.endswith(PARENT), "parent class: " + head
assert "\n.super Lcom/android/settings/core/TogglePreferenceController;\n" in p, "parent is not a TogglePreferenceController"
assert "\n.method public constructor <init>(Landroid/content/Context;Ljava/lang/String;)V\n" in p, "parent constructor"
assert "\n.method public getAvailabilityStatus()I\n" in p, "parent getAvailabilityStatus() is not overridable"
def body(sig):
    m = re.search(r"^\.method public " + re.escape(sig) + r"\n.*?^\.end method\n", p, re.M | re.S)
    assert m, sig
    return m.group(0)
checked = body("isChecked()Z")
assert re.search(r'const-string v0, "hdr_brightness_enabled"\n\n    const/4 v1, 0x1\n\n'
                 r'    invoke-static \{p0, v0, v1\}, Landroid/provider/Settings\$Secure;->getInt\(', checked), \
    "isChecked() no longer reads Settings.Secure hdr_brightness_enabled with default 1"
assert re.search(r'const-string v0, "hdr_brightness_enabled"\n\n'
                 r'    invoke-static \{p0, v0, p1\}, Landroid/provider/Settings\$Secure;->putInt\(', body("setChecked(Z)Z")), \
    "setChecked() no longer writes Settings.Secure hdr_brightness_enabled"
ctx = open(one("com/android/settingslib/core/AbstractPreferenceController.smali")).read()
assert re.search(r"^\.field protected (final )?mContext:Landroid/content/Context;$", ctx, re.M), "AbstractPreferenceController.mContext"

# 2. Our controller: same toggle, available whenever the default display is an HDR display
dst = root + "/smali_classes3"
assert os.path.isdir(dst), "smali_classes3"
stale = [f for f in glob.glob(root + "/smali*/com/k4/settings/display/K4HdrBrightnessPreferenceController.smali")
         if not f.startswith(dst + "/")]
assert not stale, "stale controller copies: %s" % stale
os.makedirs(dst + "/com/k4/settings/display", exist_ok=True)
open(dst + "/com/k4/settings/display/K4HdrBrightnessPreferenceController.smali", "w").write("""\
.class public %(OURS)s
.super %(PARENT)s
.source "K4HdrBrightnessPreferenceController.java"


# Settings > Display > "Brighten screen for HDR" (a52sxq hdr_brightness_toggle patch). The parent is the stock toggle
# on Settings.Secure hdr_brightness_enabled; its availability (HdrBrightnessUtils) also requires
# Display.isHdrSdrRatioAvailable(), which this panel does not report although HdrBrightnessModifier boosts it.

# direct methods
.method public constructor <init>(Landroid/content/Context;Ljava/lang/String;)V
    .locals 0

    invoke-direct {p0, p1, p2}, %(PARENT)s-><init>(Landroid/content/Context;Ljava/lang/String;)V

    return-void
.end method


# virtual methods
.method public getAvailabilityStatus()I
    .locals 2

    iget-object v0, p0, Lcom/android/settingslib/core/AbstractPreferenceController;->mContext:Landroid/content/Context;

    const-class v1, Landroid/hardware/display/DisplayManager;

    invoke-virtual {v0, v1}, Landroid/content/Context;->getSystemService(Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/hardware/display/DisplayManager;

    if-eqz v0, :cond_unsupported

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Landroid/hardware/display/DisplayManager;->getDisplay(I)Landroid/view/Display;

    move-result-object v0

    if-eqz v0, :cond_unsupported

    invoke-virtual {v0}, Landroid/view/Display;->isHdr()Z

    move-result v0

    if-eqz v0, :cond_unsupported

    const/4 v0, 0x0

    return v0

    :cond_unsupported
    const/4 v0, 0x3

    return v0
.end method
""" % dict(OURS=OURS, PARENT=PARENT))
print("  - controller %s" % OURS[1:-1].replace("/", "."))

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

# 4. The row, in the brightness group of Samsung's Display page: after Outdoor mode (and its caption), before the
#    inset that starts the next group
xf = root + "/res/xml/sec_display_settings.xml"
x = open(xf).read()
if 'android:key="%s"' % KEY in x:
    print("  - Display settings row already present")
else:
    for tag, where in (("SecSwitchPreference", root + "/res/xml"),):
        assert any(("<" + tag + " ") in open(f).read() for f in glob.glob(where + "/*.xml")), tag + " is not used by this SecSettings"
    lines = x.split("\n")
    hits = [i for i, l in enumerate(lines) if 'android:key="outdoor_mode_caption"' in l]
    assert len(hits) == 1, "outdoor_mode_caption anchor: %d" % len(hits)
    i = hits[0]
    assert lines[i].lstrip().startswith("<SeslPreferenceCaption ") and lines[i].rstrip().endswith("/>"), "anchor is not a single-line caption"
    assert 'xmlns:settings="http://schemas.android.com/apk/res-auto"' in x, "settings namespace"
    indent = lines[i][:len(lines[i]) - len(lines[i].lstrip())]
    row = (indent + '<SecSwitchPreference android:title="@string/k4_hdr_brightness_title" android:key="%s" '
           'android:summary="@string/k4_hdr_brightness_summary" '
           'settings:controller="%s" />') % (KEY, OURS[1:-1].replace("/", "."))
    lines.insert(i + 1, row)
    open(xf, "w").write("\n".join(lines))
    print("  - row after outdoor_mode_caption in sec_display_settings.xml")
PYEOF
unset SECSETTINGS
