# See module.prop. Edge-to-edge opt-out list for apps whose SDK-36 edge-to-edge looks broken (Instagram).
# smali/com/k4/e2e/K4E2E.smali is generated from src/com/k4/e2e/K4E2E.java by src/build.sh.
SERVICES="system/framework/services.jar"
DECODE_APK "system" "$SERVICES" || ABORT "Failed to decode $SERVICES"
mkdir -p "$WORK_DIR/system/system/etc/k4"
EVAL "cp -f \"$MODPATH/force_opt_out_e2e.txt\" \"$WORK_DIR/system/system/etc/k4/force_opt_out_e2e.txt\""
SET_METADATA "system" "system/etc/k4/force_opt_out_e2e.txt" 0 0 644 "u:object_r:system_file:s0"
python3 - "$APKTOOL_DIR/system/${SERVICES//system\//}" "$MODPATH/smali/com/k4/e2e/K4E2E.smali" << 'PYEOF' || ABORT "Failed to apply the edge-to-edge opt-out list"
import glob, os, re, shutil, sys
root, helper = sys.argv[1], sys.argv[2]
EXT = "Lcom/android/server/wm/ActivityTaskManagerServiceExt;->mForceOptOutEdgeToEdge:Ljava/util/List;"
K4 = "invoke-static {%s, %s}, Lcom/k4/e2e/K4E2E;->contains(Ljava/util/List;Ljava/lang/Object;)Z"
def one(pattern):
    hits = glob.glob(root + "/smali*/" + pattern)
    assert len(hits) == 1, "%s: %d" % (pattern, len(hits))
    return hits[0]
def method(s, sig):
    m = re.search(r"^\.method [^\n]*" + re.escape(sig) + r"\n.*?^\.end method\n", s, re.M | re.S)
    assert m, "method " + sig
    return m
# the list read followed by List.contains(pkg) -> K4E2E.contains(list, pkg); exactly once per reader
PAT = re.compile(r"(iget-object (\w+), \w+, " + re.escape(EXT) + r"\n(?:\s*\n)*)\s*invoke-interface \{(\w+), (\w+)\}, Ljava/util/List;->contains\(Ljava/lang/Object;\)Z")
for cls, sig in (("com/android/server/wm/WindowManagerService.smali", " isEdgeToEdgeDisabled(Ljava/lang/String;)Z"),
                 ("com/android/server/wm/ActivityRecord.smali", " constructor <init>(Lcom/android/server/wm/ActivityTaskManagerService;Lcom/android/server/wm/WindowProcessController;IILjava/lang/String;Ljava/lang/String;Landroid/content/Intent;Ljava/lang/String;Landroid/content/pm/ActivityInfo;Landroid/content/res/Configuration;Lcom/android/server/wm/ActivityRecord;Ljava/lang/String;IZZLcom/android/server/wm/ActivityTaskSupervisor;Landroid/app/ActivityOptions;Lcom/android/server/wm/ActivityRecord;Landroid/os/PersistableBundle;Landroid/app/ActivityManager$TaskDescription;J)V")):
    f = one(cls)
    s = open(f).read()
    m = method(s, sig)
    body = m.group(0)
    if "Lcom/k4/e2e/K4E2E;->contains" in body:
        print("  - %s already patched" % os.path.basename(f))
        continue
    hits = [h for h in PAT.finditer(body) if h.group(2) == h.group(3)]
    assert len(hits) == 1, "%s: %d opt-out list reads" % (os.path.basename(f), len(hits))
    h = hits[0]
    body = body[:h.start()] + h.group(1) + "    " + K4 % (h.group(3), h.group(4)) + body[h.end():]
    s = s[:m.start()] + body + s[m.end():]
    open(f, "w").write(s)
    print("  - %s: opt-out list read -> K4E2E.contains" % os.path.basename(f))
dirs = sorted((d for d in glob.glob(root + "/smali_classes*") if re.fullmatch(r"smali_classes\d+", os.path.basename(d))),
              key=lambda d: int(os.path.basename(d)[len("smali_classes"):]))
for old in glob.glob(root + "/smali*/com/k4/e2e/K4E2E.smali"):
    os.remove(old)
dst = os.path.join(dirs[-1] if dirs else root + "/smali", "com/k4/e2e")
os.makedirs(dst, exist_ok=True)
shutil.copyfile(helper, os.path.join(dst, "K4E2E.smali"))
PYEOF
LOG "- Edge-to-edge opt-out list: $(grep -c -v -E '^\s*(#|$)' "$MODPATH/force_opt_out_e2e.txt") package(s) (Instagram), read by the window manager"
unset SERVICES
