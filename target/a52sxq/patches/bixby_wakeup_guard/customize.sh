# See module.prop and K4WakeupGuard.smali.
SERVICES="system/framework/services.jar"
DECODE_APK "system" "$SERVICES" || ABORT "Failed to decode $SERVICES"
LOG "- Refusing Samsung voice wake-up models in the sound trigger middleware (they crash the A52s ADSP)"
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
