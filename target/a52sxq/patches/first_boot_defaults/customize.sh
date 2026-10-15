# See module.prop.
SERVICES="system/framework/services.jar"
DECODE_APK "system" "$SERVICES" || ABORT "Failed to decode $SERVICES"
LOG "- Applying the ROM defaults once at boot (Reduce transparency and blur on)"
python3 - "$APKTOOL_DIR/system/${SERVICES//system\//}" "$SRC_DIR/target/a52sxq/patches/first_boot_defaults/K4Defaults.smali" << 'PYEOF' || ABORT "Failed to apply first_boot_defaults"
import glob, os, re, shutil, sys
root, helper = sys.argv[1], sys.argv[2]
hits = glob.glob(root + "/smali*/com/android/server/am/ActivityManagerService.smali")
assert len(hits) == 1, "ActivityManagerService: %d" % len(hits)
s = open(hits[0]).read()
m = re.search(r"^\.method public final finishBooting\(\)V\n    \.locals (\d+)\n\n    move-object/from16 v1, p0\n\n", s, re.M)
assert m, "finishBooting prologue changed"
assert int(m.group(1)) >= 2, "finishBooting has too few locals"
call = ("    iget-object v0, v1, Lcom/android/server/am/ActivityManagerService;->mContext:Landroid/content/Context;\n\n"
        "    invoke-static {v0}, Lcom/k4/settings/K4Defaults;->apply(Landroid/content/Context;)V\n\n")
if not s[m.end():].startswith(call):
    s = s[:m.end()] + call + s[m.end():]
    open(hits[0], "w").write(s)
    print("  - ActivityManagerService.finishBooting -> K4Defaults.apply first")
else:
    print("  - finishBooting already calls K4Defaults")
dirs = sorted((d for d in glob.glob(root + "/smali_classes*") if re.fullmatch(r"smali_classes\d+", os.path.basename(d))),
              key=lambda d: int(os.path.basename(d)[len("smali_classes"):]))
dst = os.path.join(dirs[-1] if dirs else root + "/smali", "com/k4/settings")
for old in glob.glob(root + "/smali*/com/k4/settings/K4Defaults.smali"):
    os.remove(old)
os.makedirs(dst, exist_ok=True)
shutil.copyfile(helper, os.path.join(dst, "K4Defaults.smali"))
print("  - K4Defaults.smali -> %s" % os.path.relpath(dst, root))
PYEOF
unset SERVICES
