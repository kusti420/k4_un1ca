# See module.prop. Three parts:
#
# 1. Models. Device patches run BEFORE unica/patches, and unica/patches/legacy deletes /vendor/etc/midas and installs
#    the portable a73xqxx set (no .dlc), so installing here would be wiped. This step only checks the sources (fail
#    early, before the long ROM patch stage); install.sh does the work from target/a52sxq/post_mods.sh, which
#    unica/mods/zz_target runs after every unica patch and mod. Third-party files are NOT in git: they are taken from
#    the extracted firmwares in out/fw.
#
# 2. Denoise size cap (PhotoRemasterService smali, src/clarity_denoise_enhance.smali). The APK is not touched by
#    unica/patches/legacy, so it is patched here; unica/patches/saiv later edits other classes of the same decoded APK.
REMASTER_MODELS_DIR="$SRC_DIR/target/a52sxq/patches/remaster_models"
# shellcheck source=/dev/null
source "$REMASTER_MODELS_DIR/install.sh"

REMASTER_MODELS_CHECK_SOURCES

PRS_APK="system/priv-app/PhotoRemasterService/PhotoRemasterService.apk"
[ -f "$WORK_DIR/system/$PRS_APK" ] || ABORT "remaster_models: /$PRS_APK not found"
DECODE_APK "system" "$PRS_APK" || ABORT "remaster_models: failed to decode $PRS_APK"
LOG "- PhotoRemasterService: Denoise runs AI clarity on at most persist.sys.k4.remaster_dn_kpx (default 4000) kpx"
python3 - "$APKTOOL_DIR/system/${PRS_APK//system\//}" "$REMASTER_MODELS_DIR/src/clarity_denoise_enhance.smali" << 'PYEOF' || ABORT "remaster_models: failed to patch VSWClarity2xDownscaledTo1xEnhancer"
import glob, re, sys
root, new_method = sys.argv[1], open(sys.argv[2]).read()
CLS = "com/samsung/android/photoremaster/engine/enhancer/VSWClarity2xDownscaledTo1xEnhancer.smali"
hits = glob.glob(root + "/smali*/" + CLS)
assert len(hits) == 1, "%s: %d" % (CLS, len(hits))
f = hits[0]
s = open(f).read()
ms = list(re.finditer(r"^\.method public enhance\(\[B\[BIII\)Z\n.*?^\.end method\n", s, re.M | re.S))
assert len(ms) == 1, "enhance([B[BIII)Z: %d" % len(ms)
body = ms[0].group(0)
if "k4_remaster_dn" in body:
    assert body == new_method, "enhance([B[BIII)Z carries an older k4_remaster_dn version"
    print("  - enhance([B[BIII)Z already patched")
    sys.exit(0)
# the method being replaced must still be the stock one: full-size runClarity2xEnhancerDownscaledTo1x, nothing else
calls = re.findall(r"invoke-\S+ \{[^}]*\}, (\S+)", body)
assert calls == [
    "Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I",
    "Lcom/samsung/android/photoremaster/engine/nativeInterface/VSWEngineNativeInterface;->printLibraryVersion()V",
    "Lcom/samsung/android/photoremaster/engine/nativeInterface/VSWEngineNativeInterface;->runClarity2xEnhancerDownscaledTo1x([B[BII)Z",
    "LE/l;->p(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ZLjava/lang/String;)V",
], "unexpected stock enhance([B[BIII)Z: %s" % calls
# every callee the new body uses must exist with that exact signature
for sig, decl in [
        ("Lcom/samsung/android/photoremaster/JNI;", r"^\.method public static native resize3ch\(\[B\[BIIIII\)V$"),
        ("Lcom/samsung/android/photoremaster/engine/nativeInterface/VSWEngineNativeInterface;",
         r"^\.method public static native runClarityEnhancer\(\[B\[BIII\)Z$"),
        ("LE/l;", r"^\.method public static p\(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ZLjava/lang/String;\)V$")]:
    cf = glob.glob(root + "/smali*/" + sig[1:-1] + ".smali")
    assert len(cf) == 1 and re.search(decl, open(cf[0]).read(), re.M), "missing %s %s" % (sig, decl)
s = s[:ms[0].start()] + new_method + s[ms[0].end():]
open(f, "w").write(s)
print("  - VSWClarity2xDownscaledTo1xEnhancer.enhance([B[BIII)Z: AI clarity on a <= cap downscale, 2x back")
PYEOF

# 3. Denoise brightness (libmidas_DNNInterface, S26 Ultra system lib). One UI 9's AIclarity_1x blends the clarity
#    output as a full picture, (1 - strength) * upscaled input + strength * output (strength 0.7). The only clarity
#    model SM7325 resolves (default GPU entry, SRIBMidas_aiCLARITY2.0_2X_V200_FP32.caffemodel) is a residual network
#    whose output is detail to add (older libmidas: upscaled input + strength * output), so every Denoise came out
#    at ~30 % brightness before Remaster's residual merge (measured: grey patches 100 -> 30, Remaster results -55..-66 %).
#    Two instructions make the blend upscaled input + strength * output; FP16 vs FP32 makes no difference.
MIDAS_DNN="$WORK_DIR/system/system/lib64/libmidas_DNNInterface.camera.samsung.so"
[ -f "$MIDAS_DNN" ] || ABORT "remaster_models: $MIDAS_DNN not found"
LOG "- libmidas_DNNInterface: AI clarity (Denoise) adds its residual instead of blending it as a picture"
python3 - "$MIDAS_DNN" << 'PYEOF' || ABORT "remaster_models: failed to patch libmidas_DNNInterface.camera.samsung.so"
import struct, sys


def words(*w):
    return b"".join(struct.pack("<I", x) for x in w)


def elf(d):
    assert d[:6] == b"\x7fELF\x02\x01" and struct.unpack_from("<H", d, 0x12)[0] == 183, "not an AArch64 ELF64 LE file"
    shoff, = struct.unpack_from("<Q", d, 0x28)
    shentsize, shnum, shstrndx = struct.unpack_from("<HHH", d, 0x3A)
    sh = [struct.unpack_from("<IIQQQQIIQQ", d, shoff + i * shentsize) for i in range(shnum)]
    names = sh[shstrndx][4]
    return {d[names + s[0]:d.index(b"\0", names + s[0])].decode(): s for s in sh}


def plt_stub(d, sec, name):
    """Address of the PLT stub that calls the imported function `name` (via .rela.plt -> GOT slot -> stub)."""
    dynsym, rela, plt = sec[".dynsym"], sec[".rela.plt"], sec[".plt"]
    dynstr = sec[".dynstr"][4]
    got = []
    for o in range(rela[4], rela[4] + rela[5], 24):
        r_offset, r_info, _ = struct.unpack_from("<QQq", d, o)
        st_name, = struct.unpack_from("<I", d, dynsym[4] + (r_info >> 32) * 24)
        if d[dynstr + st_name:d.index(b"\0", dynstr + st_name)] == name:
            got.append(r_offset)
    assert len(got) == 1, "%s: %d PLT relocations" % (name.decode(), len(got))
    stubs = []
    for va in range(plt[3] + 32, plt[3] + plt[5], 16):  # 32-byte PLT0, then adrp x16 / ldr x17,[x16,#lo] / add / br
        o = plt[4] + va - plt[3]
        adrp, ldr = struct.unpack_from("<II", d, o)
        if adrp & 0x9F00001F != 0x90000010 or ldr & 0xFFC003FF != 0xF9400211:
            continue
        imm = ((adrp >> 29) & 3) | (((adrp >> 5) & 0x7FFFF) << 2)
        page = (va & ~0xFFF) + (((imm ^ (1 << 20)) - (1 << 20)) << 12)
        if page + ((ldr >> 10) & 0xFFF) * 8 == got[0]:
            stubs.append(va)
    assert len(stubs) == 1, "%s: %d PLT stubs" % (name.decode(), len(stubs))
    return stubs[0]


def bl_target(at, insn):
    assert insn >> 26 == 0x25, "not a bl"
    return at + ((((insn & 0x3FFFFFF) ^ 0x2000000) - 0x2000000) << 2)


def bl(at, target):
    off = target - at
    assert off % 4 == 0 and -(1 << 27) <= off < (1 << 27), "bl out of range"
    return 0x94000000 | ((off >> 2) & 0x3FFFFFF)


path = sys.argv[1]
d = bytearray(open(path, "rb").read())
sec = elf(d)
text = sec[".text"]
va_of = lambda off: off - text[4] + text[3]
sub_mm = plt_stub(d, sec, b"_ZN2cvmiERKNS_3MatES2_")   # cv::operator-(Mat const&, Mat const&)
mul_md = plt_stub(d, sec, b"_ZN2cvmlERKNS_3MatEd")     # cv::operator*(Mat const&, double)
# AIclarity_1x::Exec, scale > 1: up = resize(input, scale x, INTER_LINEAR);
#   out = (out - up) * residual_strength + up            (out = model output after PostProcess, 0..255)
# The SM7325 clarity model (SRIBMidas_aiCLARITY2.0_2X_V200_FP32.caffemodel, the default GPU entry) is a residual
# network: its output is the detail to ADD to the upscaled input (older libmidas: out = up + strength * out). Treated
# as a full picture, it becomes (1 - 0.7) * up + 0.7 * detail = 30 % of the input brightness. Here the subtraction
# becomes "out * 1.0", so the same expression is  out = out * strength + up.
#   add x8,sp,#0xd0; add x0,sp,#0x610; add x1,sp,#0x550; bl operator-(Mat,Mat); ldr s0,[x23,#0x1a0]; fcvt d0,s0
# ->add x8,sp,#0xd0; add x0,sp,#0x610; fmov d0,#1.0;      bl operator*(Mat,double); (unchanged)
pre, tail = words(0x910343E8, 0x911843E0), words(0xBD41A2E0, 0x1E22C000)
old_mid, new_mid = 0x911543E1, 0x1E6E1000
hits = [o for o in range(text[4], text[4] + text[5] - 24, 4)
        if d[o:o + 8] == pre and d[o + 16:o + 24] == tail and struct.unpack_from("<I", d, o + 8)[0] in (old_mid, new_mid)]
assert len(hits) == 1, "AIclarity_1x::Exec residual blend found %d times" % len(hits)
o = hits[0]
mid, call = struct.unpack_from("<II", d, o + 8)
target = bl_target(va_of(o + 12), call)
if mid == new_mid and target == mul_md:
    print("  already patched: AIclarity_1x residual blend")
    sys.exit(0)
assert mid == old_mid and target == sub_mm, "AIclarity_1x residual blend: unexpected code"
struct.pack_into("<II", d, o + 8, new_mid, bl(va_of(o + 12), mul_md))
open(path, "wb").write(d)
print("  patched 0x%x: AIclarity_1x adds the clarity residual to the upscaled input" % va_of(o + 8))
PYEOF

unset REMASTER_MODELS_DIR PRS_APK MIDAS_DNN
