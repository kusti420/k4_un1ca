# See module.prop. Two parts:
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

unset REMASTER_MODELS_DIR PRS_APK
