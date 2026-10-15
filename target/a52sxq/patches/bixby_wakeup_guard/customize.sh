# See module.prop. K4WakeupGuard.smali is generated from src/ (javac + d8 + baksmali, stubs in src/stubs).
SERVICES="system/framework/services.jar"
DECODE_APK "system" "$SERVICES" || ABORT "Failed to decode $SERVICES"
LOG "- Samsung voice wake-up: A52s keyword models only (the S26 Ultra ones crash the A52s ADSP)"
# /system/etc/k4wakeup/<mode>/<locale>/<file>.bin = the A52s stock app's keyword models (extracted from the target
# firmware at build time; Samsung's models are not kept in git). K4WakeupGuard finds which asset of the installed app
# is being loaded and swaps in the A52s model of the same name.
A52S_APP="$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/app/BixbyWakeup/BixbyWakeup.apk"
[ -f "$A52S_APP" ] || ABORT "bixby_wakeup_guard: target firmware has no app/BixbyWakeup/BixbyWakeup.apk"
EVAL "rm -rf \"$WORK_DIR/system/system/etc/k4wakeup\" && mkdir -p \"$WORK_DIR/system/system/etc/k4wakeup\""
K4W_FILES="$(python3 - "$A52S_APP" "$WORK_DIR/system/system/etc/k4wakeup" << 'PYEOF'
import os, sys, zipfile
apk, out = sys.argv[1:]
P = "assets/kwdModel/"
n = 0
with zipfile.ZipFile(apk) as z:
    for e in z.namelist():
        if e.startswith(P) and e.endswith(".bin"):
            rel = e[len(P):]
            os.makedirs(os.path.join(out, os.path.dirname(rel)), exist_ok=True)
            open(os.path.join(out, rel), "wb").write(z.read(e))
            print(rel); n += 1
assert n, "no keyword models in the A52s app"
PYEOF
)" || ABORT "bixby_wakeup_guard: failed to extract the A52s keyword models"
for d in $(cd "$WORK_DIR/system/system/etc" && find k4wakeup -type d); do
    SET_METADATA "system" "system/etc/$d" 0 0 755 "u:object_r:system_file:s0"
done
for f in $K4W_FILES; do
    SET_METADATA "system" "system/etc/k4wakeup/$f" 0 0 644 "u:object_r:system_file:s0"
done
LOG "  - $(wc -w <<< "$K4W_FILES") A52s keyword models in /system/etc/k4wakeup"
unset A52S_APP K4W_FILES d f
python3 - "$APKTOOL_DIR/system/${SERVICES//system\//}" "$SRC_DIR/target/a52sxq/patches/bixby_wakeup_guard/K4WakeupGuard.smali" << 'PYEOF' || ABORT "Failed to apply the Bixby wake-up guard"
import glob, os, re, shutil, sys
root, helper = sys.argv[1], sys.argv[2]
hits = glob.glob(root + "/smali*/com/android/server/soundtrigger_middleware/SoundTriggerModule$Session.smali")
assert len(hits) == 1, "SoundTriggerModule$Session: %d" % len(hits)
s = open(hits[0]).read()
sig = ".method public final loadPhraseModel(Landroid/media/soundtrigger/PhraseSoundModel;)I\n"
assert s.count(sig) == 1, "loadPhraseModel signature changed"
call = "    invoke-static {p1}, Lcom/k4/soundtrigger/K4WakeupGuard;->check(Landroid/media/soundtrigger/PhraseSoundModel;)V\n\n"
i = s.index(sig) + len(sig)
m = re.match(r"(    \.(?:locals|registers) \d+\n\n)", s[i:])
assert m, "loadPhraseModel: no .locals line"
j = i + len(m.group(1))
if not s[j:].startswith(call):
    s = s[:j] + call + s[j:]
    open(hits[0], "w").write(s)
    print("  - SoundTriggerModule$Session.loadPhraseModel -> K4WakeupGuard.check first")
else:
    print("  - loadPhraseModel already guarded")
assert glob.glob(root + "/smali*/com/android/server/soundtrigger_middleware/RecoverableException.smali"), "RecoverableException missing"
dirs = sorted((d for d in glob.glob(root + "/smali_classes*") if re.fullmatch(r"smali_classes\d+", os.path.basename(d))),
              key=lambda d: int(os.path.basename(d)[len("smali_classes"):]))
dst = os.path.join(dirs[-1] if dirs else root + "/smali", "com/k4/soundtrigger")
for old in glob.glob(root + "/smali*/com/k4/soundtrigger/K4WakeupGuard.smali"):
    os.remove(old)
os.makedirs(dst, exist_ok=True)
shutil.copyfile(helper, os.path.join(dst, "K4WakeupGuard.smali"))
print("  - K4WakeupGuard.smali -> %s" % os.path.relpath(dst, root))
PYEOF
unset SERVICES
