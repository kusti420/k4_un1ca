# See module.prop.
#
# Gallery (S948B 9.0 base, com.sec.android.gallery3d) side, unmodified:
#   Features.SUPPORT_INSTANT_SLOW_MO = SemFloatingFeature.getBoolean("SEC_FLOATING_FEATURE_CAMERA_SUPPORT_AIFRC")
#   InstantSlowMoUtils$Limitation    = SemFloatingFeature.getString("SEC_FLOATING_FEATURE_CAMERA_CONFIG_AIFRC_SPEC")
#   long press on a playing 1x video -> Sec160MediaPlayerCompat.beginInstantSlowMoPlay() = setVideoFrc(4, 0.25f, false)
#   release                          -> endInstantSlowMoPlay()                           = setVideoFrc(1, 1.0f, false)
# Its own fallback for a throwing setVideoFrc() (setSpeedWithPlaybackParam) is an empty method in this build, so the
# fallback speed change has to happen inside SemMediaPlayer.setVideoFrc() itself.
# The same Gallery flag also enables "Save slow-mo clip" (SemMediaCapture/VEKit, works without the AI FRC pipe) and the
# motion photo view modes Boomerang/Slow-mo (libaplayer dynamic viewing, dropped natively without AI FRC): K4SlowMo
# turns those two view modes off again inside the Gallery process, see K4SlowMo.smali.
#
# Part 1 (framework.jar): SemMediaPlayer.setVideoFrc() and SemFloatingFeature go through K4SlowMo.
# Part 2 (libaplayer.so, libimageconverter.so): the S26 Ultra player's Instant Slow-mo path (the "AI FRC" post
# generator) runs on the A52s vendor's own frame rate conversion pipe (MPP HAL V1 type 3: libmppfrc + libFrucDYNVLib,
# OpenCL, exact x2, 8-bit NV12 up to 1920x1088 at 30 fps). Measured on 9.3.17/9.3.18 with a test player on the phone:
# 1080p30 held at 0.5x shows 28-30 frames per second (plain 0.5x: 15), every second one interpolated.
#
# The SemFloatingFeature hooks go in front of everything else in getBoolean(String)/getString(String) and leave
# ".locals 1" and the mFeatureList line alone: unica/mods/settings patches both methods after this patch has run.
FRAMEWORK="system/framework/framework.jar"
DECODE_APK "system" "$FRAMEWORK" || ABORT "Failed to decode $FRAMEWORK"

LOG "- Gallery Instant Slow-mo: SemMediaPlayer.setVideoFrc() and the Gallery-only feature flag go through K4SlowMo"
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


# 1. SemMediaPlayer
player = one("smali*/com/samsung/android/media/SemMediaPlayer.smali")
src = open(player).read()
PLAYER = "Lcom/samsung/android/media/SemMediaPlayer;"
NATIVE = "    invoke-direct {p0, p1, p2, p3}, " + PLAYER + "->_setVideoFrc(IFZ)V\n"
OLD = "    invoke-static {p0, p1, p2}, " + HELPER + "->setVideoFrc(" + PLAYER + "IF)V\n"   # this patch up to 9.3.18
OURS = "    invoke-static {p0, p1, p2, p3}, " + HELPER + "->setVideoFrc(" + PLAYER + "IFZ)V\n"
ACCESSOR = (".method public blacklist k4NativeVideoFrc(IFZ)V\n"
            "    .locals 0\n\n" + NATIVE + "\n"
            "    return-void\n"
            ".end method\n")
changed = False

# a) setVideoFrc(IFZ)V: K4SlowMo decides (frame rate conversion or plain speed) instead of the native AI FRC request
start, end = method(src, "setVideoFrc(IFZ)V")
body = src[start:end]
if OURS in body:
    print("SemMediaPlayer.setVideoFrc: already patched")
else:
    was = OLD if OLD in body else NATIVE
    assert body.count(was) == 1 and (was is OLD or OLD not in body), \
        "SemMediaPlayer.setVideoFrc(IFZ)V no longer is a plain wrapper of _setVideoFrc"
    assert re.search(r"^\.method public (?:[\w-]+ )*setVideoFrc\(IFZ\)V$", body.split("\n", 1)[0]), "setVideoFrc is not a public instance method"
    assert " static " not in body.split("\n", 1)[0], "setVideoFrc became static"
    # the helper needs these two exactly as declared in this class
    assert len(re.findall(r"^\.method public (?:[\w-]+ )*native (?:[\w-]+ )*getPlaybackParams\(\)Landroid/media/PlaybackParams;$", src, re.M)) == 1, \
        "SemMediaPlayer.getPlaybackParams() not found"
    assert len(re.findall(r"^\.method public (?:[\w-]+ )*native (?:[\w-]+ )*setPlaybackParams\(Landroid/media/PlaybackParams;\)V$", src, re.M)) == 1, \
        "SemMediaPlayer.setPlaybackParams(PlaybackParams) not found"
    src = src[:start] + body.replace(was, OURS) + src[end:]
    changed = True
    print("SemMediaPlayer.setVideoFrc: -> K4SlowMo.setVideoFrc")

# b) k4NativeVideoFrc(IFZ)V: the way back to the private native method, right behind setVideoFrc()
if ACCESSOR in src:
    print("SemMediaPlayer.k4NativeVideoFrc: already there")
else:
    assert "k4NativeVideoFrc" not in src, "SemMediaPlayer has a different k4NativeVideoFrc"
    assert len(re.findall(r"^\.method private (?:[\w-]+ )*native (?:[\w-]+ )*_setVideoFrc\(IFZ\)V$", src, re.M)) == 1, \
        "SemMediaPlayer._setVideoFrc(IFZ)V is not a private native instance method"
    start, end = method(src, "setVideoFrc(IFZ)V")
    src = src[:end] + "\n" + ACCESSOR + src[end:]
    changed = True
    print("SemMediaPlayer.k4NativeVideoFrc: added")

# c) init(FileDescriptor, long, long): every local source ends up here (paths, content URIs, AssetFileDescriptors);
#    K4SlowMo looks at the video format before the native player takes the file
PROBE = "    invoke-static/range {p0 .. p5}, " + HELPER + "->sourceOpened(" + PLAYER + "Ljava/io/FileDescriptor;JJ)V\n\n"
INIT = "    invoke-direct/range {p0 .. p5}, " + PLAYER + "->_init(Ljava/io/FileDescriptor;JJ)V\n"
start, end = method(src, "init(Ljava/io/FileDescriptor;JJ)V")
body = src[start:end]
if PROBE + INIT in body:
    print("SemMediaPlayer.init(FileDescriptor, long, long): already hooked")
else:
    assert HELPER not in body, "SemMediaPlayer.init(FileDescriptor, long, long) has a different K4SlowMo hook"
    assert body.count(INIT) == 1 and src.count(INIT) == 1, "SemMediaPlayer: _init(FileDescriptor, long, long) is not called from exactly one place"
    assert " static " not in body.split("\n", 1)[0], "init(FileDescriptor, long, long) became static"
    src = src[:start] + body.replace(INIT, PROBE + INIT) + src[end:]
    changed = True
    print("SemMediaPlayer.init(FileDescriptor, long, long): -> K4SlowMo.sourceOpened first")
if changed:
    open(player, "w").write(src)

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
helper = open(helper_src).read()
for needs, where in (("->k4NativeVideoFrc(IFZ)V", "the SemMediaPlayer accessor"),
                     (".method public static blacklist setVideoFrc(" + PLAYER + "IFZ)V", "setVideoFrc"),
                     (".method public static blacklist sourceOpened(" + PLAYER + "Ljava/io/FileDescriptor;JJ)V", "sourceOpened"),
                     (".method public static blacklist featureBoolean(Ljava/lang/String;)Z", "featureBoolean"),
                     (".method public static blacklist featureString(Ljava/lang/String;)Ljava/lang/String;", "featureString")):
    assert needs in helper, "K4SlowMo.smali does not match this script (%s)" % where
assert re.search(r"^\.method public static (?:[\w-]+ )*getInt\(Ljava/lang/String;I\)I$",
                 open(one("smali*/android/os/SystemProperties.smali")).read(), re.M), "SystemProperties.getInt(String, int) not found"
dst = os.path.join(player[:player.index("/com/samsung/android/media/SemMediaPlayer.smali")], "com/k4/media")
os.makedirs(dst, exist_ok=True)
shutil.copyfile(helper_src, os.path.join(dst, "K4SlowMo.smali"))
stale = [p for p in glob.glob(os.path.join(d, "smali*/com/k4/media/K4SlowMo.smali")) if os.path.dirname(p) != dst]
assert not stale, "stale K4SlowMo.smali copies: %s" % stale
print("K4SlowMo.smali ->", os.path.relpath(dst, d))
PYEOF
# Part 2: the native player. Every patch below is located by its instruction/data pattern, must match exactly once,
# and is skipped when the patched bytes are already there. libmppclient.so (HAL V5 client) is used as it is: against
# the V1 service its create/init/setParameter/setBuffer/emptyBuffer/fillBuffer calls are the V1 ones.
APLAYER="$WORK_DIR/system/system/lib64/libaplayer.so"
IMAGECONVERTER="$WORK_DIR/system/system/lib64/libimageconverter.so"
[ -f "$APLAYER" ] || ABORT "gallery_slowmo: $APLAYER not found"
[ -f "$IMAGECONVERTER" ] || ABORT "gallery_slowmo: $IMAGECONVERTER not found"
LOG "- Instant Slow-mo plays through the A52s frame rate conversion pipe (libaplayer.so, libimageconverter.so)"
python3 - "$APLAYER" "$IMAGECONVERTER" << 'PYEOF' || ABORT "Failed to patch libaplayer.so/libimageconverter.so for the Gallery slow motion patch"
import struct, sys


def words(*w):
    return b"".join(struct.pack("<I", x) for x in w)


def dynsym(d, name):
    """Value of a .dynsym symbol of an ELF64 little-endian file."""
    assert d[:6] == b"\x7fELF\x02\x01", "not an ELF64 LE file"
    shoff, = struct.unpack_from("<Q", d, 0x28)
    shentsize, shnum = struct.unpack_from("<HH", d, 0x3A)
    sh = [struct.unpack_from("<IIQQQQIIQQ", d, shoff + i * shentsize) for i in range(shnum)]
    for s in sh:
        if s[1] != 11:  # SHT_DYNSYM
            continue
        stroff = sh[s[6]][4]
        for o in range(s[4], s[4] + s[5], 24):
            st_name, _, _, _, st_value, _ = struct.unpack_from("<IBBHQQ", d, o)
            e = d.index(b"\0", stroff + st_name)
            if d[stroff + st_name:e] == name:
                return st_value
    raise AssertionError("symbol %s not found" % name.decode())


def bl(at, target):
    off = target - at
    assert off % 4 == 0 and -(1 << 27) <= off < (1 << 27), "bl out of range"
    return 0x94000000 | ((off >> 2) & 0x3FFFFFF)


def patch(d, what, old, new):
    """Replace the single occurrence of old by new."""
    assert len(old) == len(new)
    n_old = d.count(old)
    if n_old == 0:
        # already patched? the new bytes must then be there exactly once
        if d.count(new) == 1:
            print("  already patched: " + what)
            return False
        raise AssertionError("pattern not found: " + what)
    assert n_old == 1, "pattern found %d times: %s" % (n_old, what)
    i = d.find(old)
    d[i:i + len(old)] = new
    print("  patched 0x%x: %s" % (i, what))
    return True


def aplayer(path):
    d = bytearray(open(path, "rb").read())
    changed = False

    # 1. APlayer::isAIFRCSupported(int, float): ask "is the classic FRC pipe (MPP type 3) there for this size/fps"
    #    instead of the AI FRC one (type 7). isFrcSupported() is the unused twin of isAiFrcSupported() in this
    #    library; everything else that asks for AI FRC (motion photo dynamic viewing, temporal zoom) keeps "no".
    frc = dynsym(d, b"_ZN7android14isFrcSupportedEiiii")
    ai_plt_call = words(0xB9416A60, 0xB9416E61, 0xB9419663)  # ldr w0,[x19,#0x168]; ldr w1,[x19,#0x16c]; ldr w3,[x19,#0x194]
    tail = words(0x36000060, 0x52800020)                    # tbz w0,#0,+0xc; mov w0,#1
    hits = [i for i in range(0, len(d) - 24, 4) if d[i:i + 12] == ai_plt_call and d[i + 16:i + 24] == tail]
    assert len(hits) == 1, "APlayer::isAIFRCSupported call site found %d times" % len(hits)
    at = hits[0] + 12
    cur, = struct.unpack_from("<I", d, at)
    assert cur >> 26 == 0x25, "APlayer::isAIFRCSupported: not a bl"
    want = bl(at, frc)
    if cur == want:
        print("  already patched: isAIFRCSupported -> isFrcSupported")
    else:
        ai = dynsym(d, b"_ZN7android16isAiFrcSupportedEiiii")
        # the original call goes through the PLT; make sure it is the isAiFrcSupported one before replacing it
        plt = at + (((cur & 0x3FFFFFF) ^ 0x2000000) - 0x2000000) * 4
        assert plt not in (frc, ai) and ai != frc, "unexpected call target"
        struct.pack_into("<I", d, at, want)
        changed = True
        print("  patched 0x%x: APlayer::isAIFRCSupported asks isFrcSupported (MPP type 3)" % at)

    # 2. MppGenerator::onInit(): generator type (1..5) -> MPP type table (DEFLICKER 2, FRC 3, FILTER 6, AI FRC 7,
    #    COLOR GRADE 9): the AI FRC generator (type 4) opens the classic FRC pipe
    changed |= patch(d, "MppGenerator type table: AI FRC generator -> MPP type 3",
                     words(2, 3, 6, 7, 9), words(2, 3, 6, 3, 9))

    # 3. MppGenerator::getConfiguration(): on Qualcomm the output format becomes UBWC, which the A52s mppserver
    #    converts with C2D (crashes with the current Adreno libs). The vendor test (always "Qualcomm" here) becomes
    #    "is this the AI FRC generator": that one keeps linear NV12, every other generator behaves as before.
    #    bl getVendorName; cmp w0,#1; b.ne skip   ->   ldr w0,[x20,#0x1a8]; cmp w0,#4; b.eq skip
    pre = words(0xB40009AA)                                  # cbz x10, skip
    post = words(0xF0000888, 0x911CA108)                     # adrp x8,...; add x8,x8,#0x728
    old_tail = words(0x7100041F, 0x54000941)
    new3 = words(0xB941AA80, 0x7100101F, 0x54000940)
    hits = [i for i in range(0, len(d) - 24, 4) if d[i:i + 4] == pre and d[i + 8:i + 16] == old_tail and d[i + 16:i + 24] == post]
    done = [i for i in range(0, len(d) - 24, 4) if d[i:i + 4] == pre and d[i + 4:i + 16] == new3 and d[i + 16:i + 24] == post]
    if len(hits) == 0 and len(done) == 1:
        print("  already patched: getConfiguration output format")
    else:
        assert len(hits) == 1 and not done, "MppGenerator::getConfiguration vendor test found %d times" % len(hits)
        i = hits[0] + 4
        assert struct.unpack_from("<I", d, i)[0] >> 26 == 0x25, "getConfiguration: not a bl"
        d[i:i + 12] = new3
        changed = True
        print("  patched 0x%x: getConfiguration keeps linear NV12 output for the AI FRC generator" % i)

    # 4. APlayer::setupVideo(): only COLOR GRADE still asks for the MPP input surface; AI FRC decodes into byte
    #    buffers (the input surface path needs ISehMpp.queueInput(), which the V1 HAL does not have). Without the
    #    "useInputSurface" key the AI FRC generator creates no input surface and the decoder is asked for NV12.
    #    tst w8,#0x60 -> tst w8,#0x40 in front of "tbz w24,#0 ; ... useInputSurface"
    changed |= patch(d, "setupVideo: no MPP input surface for AI FRC",
                     words(0x721B051F, 0x54000800, 0x36000258),
                     words(0x721A011F, 0x54000800, 0x36000258))

    # 5. MppGenerator::onHandleAnOutputBuffer(): the AI FRC pipe ends with an output that repeats the previous
    #    time stamp, which this code turns into the end-of-stream marker (time -1). The classic pipe flags its last
    #    real frame instead (and sends one more frame after it), so the renderer never saw the end and a video held
    #    to its last frame never completed. For the AI FRC generator every end-flagged output is the marker now.
    #    ldr w8,[x19,#0x1a8]; cmp w8,#4; b.ne; ldr x8,[x19,#0x250]; ldur x9,[x29,#-8]; cmp x8,x9; b.ne -> nop
    eos = (0xB941AA68, 0x7100111F, 0x540001C1, 0xF9412A68, 0xF85F83A9, 0xEB09011F)
    changed |= patch(d, "MppGenerator: end-flagged FRC output is the end-of-stream marker",
                     words(*eos, 0x54000141), words(*eos, 0xD503201F))
    if changed:
        open(path, "wb").write(d)


def imageconverter(path):
    d = bytearray(open(path, "rb").read())
    changed = False
    # The classic FRC pipe hands back plain NV12 (HAL_PIXEL_FORMAT_YCbCr_420_SP, 0x109), which SecImageConverter
    # does not know; 0x105 (an Exynos-only NV12 flavour, never seen on this SoC) gives its slot to 0x109.
    # a) source format table {0x105, 0x123, 0x125, 0x36}
    changed |= patch(d, "SecImageConverter source formats: 0x105 -> 0x109",
                     words(0x105, 0x123, 0x125, 0x36), words(0x109, 0x123, 0x125, 0x36))
    # b) ColorTypeFactory::Create(): cmp w3,#0x105; b.eq <SLSI NV12>  ->  cmp w3,#0x109; b.eq <YUVSemiPlanar>
    changed |= patch(d, "ColorTypeFactory: 0x109 -> YUVSemiPlanarType",
                     words(0x7104147F, 0x54000060), words(0x7104247F, 0x54000140))
    if changed:
        open(path, "wb").write(d)


print("libaplayer.so:")
aplayer(sys.argv[1])
print("libimageconverter.so:")
imageconverter(sys.argv[2])
PYEOF
unset FRAMEWORK APLAYER IMAGECONVERTER
