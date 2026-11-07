# See module.prop. One call site in PackageInstallerService.restoreAndApplyStagedSessionIfNeeded() is wrapped; the helper
# class is copied next to it. Anchored, aborts on mismatch, skipped when already applied.
DECODE_APK "system" "system/framework/services.jar"
python3 - "$APKTOOL_DIR/system/framework/services.jar" "$SRC_DIR/target/$TARGET_CODENAME/patches/staged_updates_keep/K4StagedSessionPolicy.smali" << 'PYEOF' || ABORT "Failed to keep staged sessions across ROM-only updates"
import glob, os, shutil, sys
J, HELPER = sys.argv[1], sys.argv[2]
f = glob.glob(J + "/smali*/com/android/server/pm/PackageInstallerService.smali")
assert len(f) == 1, "PackageInstallerService.smali"
f = f[0]
s = open(f).read()
sig = ".method public final restoreAndApplyStagedSessionIfNeeded()V\n"
assert s.count(sig) == 1, sig
a = s.index(sig); b = s.index(".end method", a)
body = s[a:b]
CALL = "Lcom/android/server/pm/K4StagedSessionPolicy;->failStagedOnUpgrade(Z)Z"
if CALL in body:
    print("  - staged session restore: already patched")
else:
    old = ("    invoke-virtual {v0}, Lcom/android/server/pm/PackageManagerService;->isDeviceUpgrading()Z\n\n"
           "    move-result v0\n")
    if body.count(old) != 1:
        old = old.replace("\n\n", "\n")
    assert body.count(old) == 1, "isDeviceUpgrading() call in restoreAndApplyStagedSessionIfNeeded"
    assert body.count('"Build fingerprint has changed"') == 1, "fingerprint failure"
    new = old + "\n    invoke-static {v0}, " + CALL + "\n\n    move-result v0\n"
    s = s[:a] + body.replace(old, new) + s[b:]
    open(f, "w").write(s)
    print("  - staged session restore: fails sessions only when ro.build.fingerprint changed")
dst = os.path.join(os.path.dirname(f), "K4StagedSessionPolicy.smali")
shutil.copyfile(HELPER, dst)
PYEOF
