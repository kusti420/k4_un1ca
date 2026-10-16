# From the phone sweep of 2026-10-16 (P6, /mnt/B1/OneUi9/scratch/deepdive_1016/phone_sweep/settings_search.png)
#
# Evidence (search_index.db + shared_prefs pulled read-only from the phone running 9.3.41):
#   meta_index.build = S948BXXS4BZIG, indexing_manager.xml:
#     <boolean name="samsung/m3qxeea/m3q:17/CP2A.260605.016/S948BXXS4BZIG:user/release-keys" value="true" />
#     <long name="com.android.settings" value="37" />, init_boot_date / indexing_properties from 2026-10-09 22:45
#   prefs_index: no unica_screen_resolution row at all (the entry in sec_display_settings.xml arrived on 2026-10-10,
#   commit 38687034), screen_resolution (stock, disabled) and sec_high_refresh_rate with data_keywords_ex
#   "|Motion smoothness|Motionsmoothness" only.
# IndexDatabaseHelper.isFullIndex() / setIndexed() key the full re-index on Build.FINGERPRINT, which is the S26U's
# on every build of this ROM, and SecSettings' versionCode (37) never changes either, so a new build never
# triggers a full index and XML changes of later builds never reach the index.
# 1. Key it on Build.DISPLAY (ro.build.display.id = a52sxq_OneUI<ver>.k4<timestamp> ...) instead: once per build.
# 2. English keywords for Motion smoothness: + "Refresh rate, Hz" (the keyword string is only used by
#    sec_display_settings.xml as settings:keywords).
SSI="system/priv-app/SecSettingsIntelligence/SecSettingsIntelligence.apk"
DECODE_APK "system" "$SSI"
DECODE_APK "system" "system/priv-app/SecSettings/SecSettings.apk"
python3 - "$APKTOOL_DIR/$SSI" "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk" << 'PYEOF' || ABORT "Failed to patch the Settings search re-index check"
import glob, os, re, sys
SSI, SS = sys.argv[1], sys.argv[2]

# 1. IndexDatabaseHelper.isFullIndex / setIndexed: Build.FINGERPRINT -> Build.DISPLAY
f = glob.glob(SSI + "/smali*/com/android/settings/intelligence/search/indexing/IndexDatabaseHelper.smali")
assert len(f) == 1, "IndexDatabaseHelper: %d" % len(f)
f = f[0]
s = open(f).read()
FP = "    sget-object v0, Landroid/os/Build;->FINGERPRINT:Ljava/lang/String;\n"
DP = "    sget-object v0, Landroid/os/Build;->DISPLAY:Ljava/lang/String;\n"
for sig in (".method public static isFullIndex(Landroid/content/Context;Ljava/util/List;Ljava/lang/String;)Z",
            ".method public static setIndexed(Landroid/content/Context;Ljava/util/List;Ljava/lang/String;Ljava/lang/String;)V"):
    m = re.search("^" + re.escape(sig) + r"\n    \.locals \d+\n\n(.*?)^\.end method\n", s, re.M | re.S)
    assert m, sig
    head = m.group(1)
    if head.startswith(DP):
        continue
    assert head.startswith(FP), "%s: first instruction changed" % sig
    assert head.count("Landroid/os/Build;->") == 1, "%s: more Build reads" % sig
    s = s[:m.start(1)] + DP + s[m.start(1) + len(FP):]
assert s.count("Landroid/os/Build;->FINGERPRINT:") == 0, "FINGERPRINT still read in IndexDatabaseHelper"
assert s.count(DP) == 2, "DISPLAY reads: %d" % s.count(DP)
open(f, "w").write(s)

# 2. English search keywords of Display > Motion smoothness
OLD = '<string name="keywords_sec_high_refresh_rate">Motion smoothness</string>'
NEW = '<string name="keywords_sec_high_refresh_rate">Motion smoothness, Refresh rate, Hz</string>'
files = [SS + "/res/values/strings.xml"] + sorted(glob.glob(SS + "/res/values-en*/strings.xml"))
hit = 0
for p in files:
    t = open(p).read()
    n_old, n_new = t.count(OLD), t.count(NEW)
    assert n_old + n_new <= 1, "%s: %d/%d" % (p, n_old, n_new)
    if n_old:
        open(p, "w").write(t.replace(OLD, NEW))
    hit += n_old + n_new
assert hit >= 2, "keywords_sec_high_refresh_rate: only %d English definitions" % hit
assert NEW in open(SS + "/res/values/strings.xml").read(), "default keywords not patched"
PYEOF
LOG "- Settings search: full re-index once per build (Build.DISPLAY), Motion smoothness also found by \"refresh\""
