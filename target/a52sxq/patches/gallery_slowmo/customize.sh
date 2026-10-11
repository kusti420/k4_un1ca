# See module.prop.
#
# Gallery (S948B 9.0 base, com.sec.android.gallery3d) side, unmodified:
#   Features.SUPPORT_INSTANT_SLOW_MO = SemFloatingFeature.getBoolean("SEC_FLOATING_FEATURE_CAMERA_SUPPORT_AIFRC")
#   InstantSlowMoUtils$Limitation    = SemFloatingFeature.getString("SEC_FLOATING_FEATURE_CAMERA_CONFIG_AIFRC_SPEC")
#   long press on a playing 1x video -> Sec160MediaPlayerCompat.beginInstantSlowMoPlay() = setVideoFrc(4, 0.25f, false)
#   release                          -> endInstantSlowMoPlay()                           = setVideoFrc(1, 1.0f, false)
# Its own fallback for a throwing setVideoFrc() (setSpeedWithPlaybackParam) is an empty method in this build, so the
# speed change has to happen inside SemMediaPlayer.setVideoFrc() itself.
#
# The SemFloatingFeature hooks go in front of everything else in getBoolean(String)/getString(String) and leave
# ".locals 1" and the mFeatureList line alone: unica/mods/settings patches both methods after this patch has run.
FRAMEWORK="system/framework/framework.jar"
DECODE_APK "system" "$FRAMEWORK" || ABORT "Failed to decode $FRAMEWORK"

LOG "- Gallery Instant Slow-mo without AI frame interpolation (plain 0.25x playback while a video is held)"
python3 - "$APKTOOL_DIR/system/${FRAMEWORK//system\//}" \
    "$SRC_DIR/target/a52sxq/patches/gallery_slowmo/K4SlowMo.smali" << 'PYEOF' || ABORT "Failed to apply the Gallery slow motion patch"
import glob, os, re, shutil, sys

d, helper_src = sys.argv[1], sys.argv[2]
HELPER = "Lcom/k4/media/K4SlowMo;"


def one(pattern):
    m = glob.glob(os.path.join(d, pattern))
    assert len(m) == 1, "expected exactly one %s, found %d" % (pattern, len(m))
    return m[0]


def method(src, name):
    """Return (start, end) of the single method whose .method line ends with ' name'."""
    m = re.findall(r"^\.method [^\n]* %s\n" % re.escape(name), src, re.M)
    assert len(m) == 1, "expected exactly one method %s, found %d" % (name, len(m))
    start = src.index(m[0])
    end = src.index("\n.end method\n", start) + len("\n.end method\n")
    return start, end


# 1. SemMediaPlayer.setVideoFrc(IFZ)V: plain playback speed instead of the native AI FRC request
player = one("smali*/com/samsung/android/media/SemMediaPlayer.smali")
src = open(player).read()
start, end = method(src, "setVideoFrc(IFZ)V")
body = src[start:end]
NATIVE = "    invoke-direct {p0, p1, p2, p3}, Lcom/samsung/android/media/SemMediaPlayer;->_setVideoFrc(IFZ)V\n"
OURS = "    invoke-static {p0, p1, p2}, " + HELPER + "->setVideoFrc(Lcom/samsung/android/media/SemMediaPlayer;IF)V\n"
if OURS in body:
    print("SemMediaPlayer.setVideoFrc: already patched")
else:
    assert body.count(NATIVE) == 1, "SemMediaPlayer.setVideoFrc(IFZ)V no longer is a plain wrapper of _setVideoFrc"
    assert re.search(r"^\.method public (?:[\w-]+ )*setVideoFrc\(IFZ\)V$", body.split("\n", 1)[0]), "setVideoFrc is not a public instance method"
    assert " static " not in body.split("\n", 1)[0], "setVideoFrc became static"
    # the helper needs these two exactly as declared in this class
    assert len(re.findall(r"^\.method public (?:[\w-]+ )*native (?:[\w-]+ )*getPlaybackParams\(\)Landroid/media/PlaybackParams;$", src, re.M)) == 1, \
        "SemMediaPlayer.getPlaybackParams() not found"
    assert len(re.findall(r"^\.method public (?:[\w-]+ )*native (?:[\w-]+ )*setPlaybackParams\(Landroid/media/PlaybackParams;\)V$", src, re.M)) == 1, \
        "SemMediaPlayer.setPlaybackParams(PlaybackParams) not found"
    src = src[:start] + body.replace(NATIVE, OURS) + src[end:]
    open(player, "w").write(src)
    print("SemMediaPlayer.setVideoFrc: -> K4SlowMo.setVideoFrc")

# 2. SemFloatingFeature: Gallery-only answers for the two Instant Slow-mo keys
ff = one("smali*/com/samsung/android/feature/SemFloatingFeature.smali")
src = open(ff).read()
HOOKS = (
    ("getBoolean(Ljava/lang/String;)Z",
     "    invoke-static {p1}, " + HELPER + "->featureBoolean(Ljava/lang/String;)Z\n\n"
     "    move-result v0\n\n"
     "    if-eqz v0, :k4_slowmo_bool\n\n"
     "    return v0\n\n"
     "    :k4_slowmo_bool\n"),
    ("getString(Ljava/lang/String;)Ljava/lang/String;",
     "    invoke-static {p1}, " + HELPER + "->featureString(Ljava/lang/String;)Ljava/lang/String;\n\n"
     "    move-result-object v0\n\n"
     "    if-eqz v0, :k4_slowmo_string\n\n"
     "    return-object v0\n\n"
     "    :k4_slowmo_string\n"),
)
changed = False
for name, hook in HOOKS:
    start, end = method(src, name)
    body = src[start:end]
    if hook in body:
        print("SemFloatingFeature.%s: already patched" % name)
        continue
    assert HELPER not in body, "SemFloatingFeature.%s has a different K4SlowMo hook" % name
    head = re.match(r"\.method public (?:[\w-]+ )*%s\n    \.locals (\d+)\n" % re.escape(name), body)
    assert head, "SemFloatingFeature.%s: unexpected method header" % name
    assert " static " not in body.split("\n", 1)[0], "SemFloatingFeature.%s became static" % name
    assert int(head.group(1)) >= 1, "SemFloatingFeature.%s has no local register for the hook" % name
    # v0 must be dead on entry for the original code (it is: both methods start by loading their default into v0)
    rest = body[head.end():].lstrip("\n")
    first = next(l.strip() for l in rest.split("\n") if l.strip() and not l.strip().startswith(".line"))
    assert re.match(r"(const/4 v0, 0x0|const-string v0, \"\")$", first), \
        "SemFloatingFeature.%s no longer starts by loading its default into v0: %s" % (name, first)
    src = src[:start] + body[:head.end()] + "\n" + hook + rest + src[end:]
    changed = True
    print("SemFloatingFeature.%s: hooked" % name)
if changed:
    open(ff, "w").write(src)
# the two-argument overloads must still funnel into the hooked ones
for name, callee in (("getBoolean(Ljava/lang/String;Z)Z", "->getBoolean(Ljava/lang/String;)Z"),
                     ("getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;",
                      "->getString(Ljava/lang/String;)Ljava/lang/String;")):
    start, end = method(src, name)
    assert callee in src[start:end], "SemFloatingFeature.%s no longer delegates to the one-argument method" % name

# 3. The helper class, next to SemMediaPlayer (same dex)
assert re.search(r"^\.method public static (?:[\w-]+ )*currentPackageName\(\)Ljava/lang/String;$",
                 open(one("smali*/android/app/ActivityThread.smali")).read(), re.M), \
    "ActivityThread.currentPackageName() not found"
dst = os.path.join(player[:player.index("/com/samsung/android/media/SemMediaPlayer.smali")], "com/k4/media")
os.makedirs(dst, exist_ok=True)
shutil.copyfile(helper_src, os.path.join(dst, "K4SlowMo.smali"))
stale = [p for p in glob.glob(os.path.join(d, "smali*/com/k4/media/K4SlowMo.smali")) if os.path.dirname(p) != dst]
assert not stale, "stale K4SlowMo.smali copies: %s" % stale
print("K4SlowMo.smali ->", os.path.relpath(dst, d))
PYEOF
unset FRAMEWORK
