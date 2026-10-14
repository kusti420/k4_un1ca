# UNTESTED-ON-DEVICE (settings_search proposal; dry-run with dryrun.sh). See module.prop.
# K4SearchSpeed.smali is generated from src/com/k4/settingsintelligence/K4SearchSpeed.java
# (javac --release 11 against android.jar + src/stubs, d8 --min-api 35, baksmali; stubs are not packaged).
# Verify after flashing (phone unlocked): open Settings > search, type "wifi" right away -> results without the
# ~3 s wait; logcat -d -s K4SearchSpeed SearchFragment shows "refresh start: fullIndex=false queryExistingIndex=true"
# and "refresh running: querying the existing index"; when the refresh ends onEssentialIndexingFinished requeries.
SSI="system/priv-app/SecSettingsIntelligence/SecSettingsIntelligence.apk"
DECODE_APK "system" "$SSI" || ABORT "Failed to decode $SSI"
LOG "- Settings search: query the existing index while the per-open re-index runs"
SSI_DIR="$APKTOOL_DIR/system/${SSI//system\//}"
# the helper goes into the last smali dex dir (fewest method refs)
DEX_DIR="$(find "$SSI_DIR" -mindepth 1 -maxdepth 1 -type d -name "smali_classes*" -printf "%f\n" | sort -V | tail -n 1)"
[ -n "$DEX_DIR" ] || DEX_DIR="smali"
mkdir -p "$SSI_DIR/$DEX_DIR/com/k4/settingsintelligence"
cp -f "$MODPATH/smali/com/k4/settingsintelligence/K4SearchSpeed.smali" "$SSI_DIR/$DEX_DIR/com/k4/settingsintelligence/" \
    || ABORT "Failed to copy K4SearchSpeed.smali"
python3 - "$SSI_DIR" << 'PYEOF' || ABORT "Failed to patch SecSettingsIntelligence search gate"
import glob, re, sys
root = sys.argv[1]
K4 = "Lcom/k4/settingsintelligence/K4SearchSpeed;"
DIM = "Lcom/android/settings/intelligence/search/indexing/DatabaseIndexingManager;"
SFP = "Lcom/android/settings/intelligence/search/SearchFeatureProvider;"

def one(pattern):
    hits = glob.glob(root + "/smali*/" + pattern)
    assert len(hits) == 1, "%s: %d" % (pattern, len(hits))
    return hits[0]

def method(s, sig):
    m = re.search(r"^\.method [^\n]*" + re.escape(sig) + r"\n.*?^\.end method\n", s, re.M | re.S)
    assert m, "method " + sig
    return m

def sub_once(body, old, new, what):
    assert body.count(old) == 1, "%s: %d matches" % (what, body.count(old))
    return body.replace(old, new)

# 1) SearchFragment.handleQueryText(String, boolean): typed-query gate
f = one("com/android/settings/intelligence/search/SearchFragment.smali")
s = open(f).read()
m = method(s, " handleQueryText(Ljava/lang/String;Z)Z")
body = m.group(0)
if K4 in body:
    print("  - handleQueryText already patched")
else:
    body = re.sub(r"invoke-interface \{(\w+), (\w+)\}, " + re.escape(SFP) + r"->isIndexingComplete\(Landroid/content/Context;\)Z",
                  lambda g: "invoke-static {%s, %s}, %s->isIndexingComplete(%sLandroid/content/Context;)Z" % (g.group(1), g.group(2), K4, SFP),
                  body, count=0)
    assert body.count(K4 + "->isIndexingComplete(") == 1, "handleQueryText gate: expected exactly 1 isIndexingComplete call"
    s = s[:m.start()] + body + s[m.end():]
    open(f, "w").write(s)

# 2) DatabaseIndexingManager
f = one("com/android/settings/intelligence/search/indexing/DatabaseIndexingManager.smali")
s = open(f).read()
# 2a) rebuildIndexingDataIfNeeded(isFullIndex, locale): record the refresh kind, defer the dynamic-table drop
m = method(s, " rebuildIndexingDataIfNeeded(ZLjava/lang/String;)V")
body = m.group(0)
if K4 in body:
    print("  - rebuildIndexingDataIfNeeded already patched")
else:
    loc = re.search(r"^    \.locals \d+\n", body, re.M)
    assert loc, "rebuildIndexingDataIfNeeded: .locals"
    hook = "\n    invoke-static {p0, p1}, %s->onIndexingStart(%sZ)V\n" % (K4, DIM)
    body = body[:loc.end()] + hook + body[loc.end():]
    body = sub_once(body, "invoke-virtual {p0}, %s->rebuildDynamicIndexDatabase()V" % DIM,
                    "invoke-static {p0}, %s->rebuildDynamic(%s)V" % (K4, DIM), "rebuildDynamicIndexDatabase call")
    s = s[:m.start()] + body + s[m.end():]
# 2b) updateDatabase(PreIndexData, isFullIndex, isEssential): dynamic-table refill (inside the write transaction)
m = method(s, " updateDatabase(Lcom/android/settings/intelligence/search/indexing/PreIndexData;ZZ)I")
body = m.group(0)
if K4 in body:
    print("  - updateDatabase already patched")
else:
    pat = re.compile(r"invoke-virtual \{p0, (\w+), (\w+), (\w+)\}, " + re.escape(DIM) +
                     r"->insertIndexData\(Landroid/database/sqlite/SQLiteDatabase;Ljava/util/List;Ljava/lang/String;\)V")
    hits = pat.findall(body)
    assert len(hits) == 1, "updateDatabase dynamic insert: %d" % len(hits)
    # the 3-arg insert must be the sec_dynamic_prefs_index one
    assert 'const-string %s, "sec_dynamic_prefs_index"' % hits[0][2] in body, "updateDatabase: dynamic table name"
    body = pat.sub(lambda g: "invoke-static {p0, %s, %s, %s}, %s->insertDynamic(%sLandroid/database/sqlite/SQLiteDatabase;Ljava/util/List;Ljava/lang/String;)V"
                   % (g.group(1), g.group(2), g.group(3), K4, DIM), body)
    s = s[:m.start()] + body + s[m.end():]
open(f, "w").write(s)
PYEOF
unset SSI SSI_DIR DEX_DIR
