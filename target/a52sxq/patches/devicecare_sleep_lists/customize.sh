# See module.prop. Device Care (com.samsung.android.lool) builds every sleeping-app Add list in jc/e.c(II) from the FAS
# cache that jc/e.e() loads from SemAppRestrictionManager.getAllList(); every add goes through ed/z.c(...).
# K4RestrictList.smali is generated from src/com/k4/devicecare/K4RestrictList.java (javac + d8 + baksmali, see src/).
DEVICECARE="system/priv-app/SmartManager_v5/SmartManager_v5.apk"
DECODE_APK "system" "$DEVICECARE" || ABORT "Failed to decode $DEVICECARE"
LOG "- Listing every restrictable app in the sleeping-app Add lists"
DST="$APKTOOL_DIR/system/${DEVICECARE//system\//}/smali/com/k4/devicecare"
mkdir -p "$DST"
cp -f "$SRC_DIR/target/a52sxq/patches/devicecare_sleep_lists/smali/com/k4/devicecare/K4RestrictList.smali" "$DST/"
SMALI_PATCH "system" "$DEVICECARE" \
    "smali/jc/e.smali" "replace" \
    'c(II)Ljava/util/ArrayList;' \
    'invoke-virtual {v2, p1, v5, v7}, Lcom/samsung/android/sdhms/SemAppRestrictionManager;->canRestrict(ILjava/lang/String;I)Z' \
    'invoke-static {v2, p1, v5, v7}, Lcom/k4/devicecare/K4RestrictList;->canList(Lcom/samsung/android/sdhms/SemAppRestrictionManager;ILjava/lang/String;I)Z' \
    || ABORT "Failed to patch the Add list filter"
SMALI_PATCH "system" "$DEVICECARE" \
    "smali/jc/e.smali" "replace" \
    'e()V' \
    'invoke-virtual {v0}, Lcom/samsung/android/sdhms/SemAppRestrictionManager;->getAllList()Ljava/util/List;' \
    'invoke-static {v0}, Lcom/k4/devicecare/K4RestrictList;->getAllList(Lcom/samsung/android/sdhms/SemAppRestrictionManager;)Ljava/util/List;' \
    || ABORT "Failed to patch the FAS cache loader"
python3 - "$APKTOOL_DIR/system/${DEVICECARE//system\//}" << 'PYEOF' || ABORT "Failed to hook the sleeping-app add handler"
import glob, sys
root = sys.argv[1]
# The helper reads kc.d.a (package) and kc.d.c (uid) directly, like Device Care's own code does.
d = glob.glob(root + "/smali*/kc/d.smali")
assert len(d) == 1, "kc/d.smali: %d" % len(d)
ds = open(d[0]).read()
assert ".field public a:Ljava/lang/String;" in ds and ".field public c:I" in ds, "kc.d fields changed"
f = glob.glob(root + "/smali*/ed/z.smali")
assert len(f) == 1, "ed/z.smali: %d" % len(f)
s = open(f[0]).read()
SIG = ".method public final c(Landroid/content/Context;Ljava/util/List;IZLjava/lang/String;)V\n"
HOOK = ("    invoke-static/range {p1 .. p4}, Lcom/k4/devicecare/K4RestrictList;->prepare("
        "Landroid/content/Context;Ljava/util/List;IZ)Ljava/util/List;\n\n    move-result-object p2\n\n")
start = s.index(SIG)
end = s.index(".end method", start)
body = s[start:end]
if "K4RestrictList;->prepare(" in body:
    print("ed/z.c: already hooked"); sys.exit(0)
lines = body.split("\n")
assert lines[1].strip().startswith(".locals"), "ed/z.c: no .locals line"
# insert right after ".locals N" and its blank line, before the first instruction
body = "\n".join(lines[:2]) + "\n\n" + HOOK + "\n".join(lines[2:]).lstrip("\n")
s = s[:start] + body + s[end:]
open(f[0], "w").write(s)
PYEOF
unset DEVICECARE DST
