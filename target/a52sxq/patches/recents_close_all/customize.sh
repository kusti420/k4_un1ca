# Recents "Close all" on 8 GB A52s units: the Fold8 launcher (TouchWizHome_2017) chooses its RecentTaskRemoveService with
#   ActivityManagerWrapper.getMaxLongLiveApps() > 0 ? dedicatedRecentTaskRemoveService : internalRecentTaskRemoveService
# getMaxLongLiveApps() is non-zero only when CoreRune.FW_DEDICATED_MEMORY (Process.getTotalMemory() > 6144 MB), so the 8 GB
# model gets the "dedicated" remover. For Close all it removes only desktop-divider tasks itself and leaves the rest to
# DesktopModeSource.removeAllVisibleRecentTasks() -> WMShell IDesktopMode, which is not available because this port
# disables desktop windowing (sff.sh). Nothing was removed and the cards came back. 6 GB units use the internal remover
# (ActivityManagerWrapper.removeTask() per task) and work, so make the selector always see 0.
DECODE_APK "system" "system/priv-app/TouchWizHome_2017/TouchWizHome_2017.apk"
python3 - "$APKTOOL_DIR/system/priv-app/TouchWizHome_2017/TouchWizHome_2017.apk" << 'PYEOF' || ABORT "Failed to apply the Recents close all patch"
import glob, re, sys
hits = 0
for f in glob.glob(sys.argv[1] + "/smali*/**/*.smali", recursive=True):
    s = open(f).read()
    if "dedicatedRecentTaskRemoveService" not in s or "getMaxLongLiveApps()I" not in s:
        continue
    def fix(m):
        body = m.group(0)
        if "dedicatedRecentTaskRemoveService" not in body or "internalRecentTaskRemoveService" not in body:
            return body
        new, n = re.subn(r"(invoke-virtual \{(\w+)\}, Lcom/android/systemui/shared/system/ActivityManagerWrapper;->getMaxLongLiveApps\(\)I\n\n?    move-result (\w+)\n)(?!\n?    const/4 \3, 0x0\n)",
                         lambda k: k.group(1) + "\n    const/4 " + k.group(3) + ", 0x0\n", body)
        assert n == 1, "getMaxLongLiveApps call in selector: %d" % n
        return new
    s2 = re.sub(r"\.method [^\n]*\n(?:.*\n)*?\.end method", fix, s)
    if s2 != s:
        open(f, "w").write(s2)
        hits += 1
assert hits == 1, "remover selector found in %d files" % hits
PYEOF
LOG "- Recents Close all always uses the per-task remover"
