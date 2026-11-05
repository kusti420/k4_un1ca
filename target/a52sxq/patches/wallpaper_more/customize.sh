# More built-in wallpapers for the A52s: still images and Samsung "Interactive" clips from other Galaxy sets, added to
# /system/priv-app/wallpaper-res/wallpaper-res.apk (com.samsung.android.wallpaper.res) next to the S26U stills and the
# S24U interactive set (patches/wallpaper_interactive, which this patch follows under LC_ALL=C sort: "wallpaper_interactive"
# < "wallpaper_more"). The sets live in prebuilts/wallpapers/<set>/ (README.txt in each: source build, transcode, budget):
#   s24u_stills  Galaxy S24 Ultra   8 stills (lock/home pairs, 3120 -> 2400x2400)
#   s26u         Galaxy S26 Ultra   6 interactive clips (the source's own clips, re-encoded; patches/wallpaper strips the originals)
#   s26          Galaxy S26         6 stills (different images from the S26U ones already shipped)
#   s25          Galaxy S25        10 stills (lock/home pairs) + 5 interactive clips
#   fold8        Galaxy Z Fold8     4 main-screen stills + 4 unfold clips recast as interactive clips (centre crop 9:20)
#   a52s         Galaxy A52s 5G    11 stock One UI 6 stills (native 2400x2400)
#   s7edge       Galaxy S7 edge     8 stock 2016 stills (framework-res of G935FXXU8EVG2, 2240x2240 square)
# New resources need new resource ids, so the APK goes through the ROM's standard apktool flow: DECODE_APK here, files
# dropped into the decoded tree, and make_rom rebuilds it (apktool b keeps the original ids via public.xml and appends
# the new raw/drawable entries; the clips stay zip-STORED through apktool.yml doNotCompress, SpriteWallpaper opens them
# with Resources.openRawResourceFd) and signs it with the platform key (scripts/apktool.sh). The json entries follow the
# 2.8.78 schema (deep copies of the S26U entries, see prebuilts/wallpapers/<set>/resources_info_more.json; DressRoom
# resolves "filename" as android.resource://<pkg>/drawable|raw/<name before the first dot>, desc_str_id through
# getIdentifier(..., "string") with the generic "preset wallpaper" title as fallback). Every new file is named wpm_*, so a
# re-run first drops the wpm_ entries again: idempotent. isDefault stays false everywhere: the default wallpaper is still
# the S26U still image.
PREBUILT="$SRC_DIR/prebuilts/wallpapers"
APK_FILE="system/priv-app/wallpaper-res/wallpaper-res.apk"
APK="$WORK_DIR/system/$APK_FILE"
WPM_SETS="s24u_stills s26u s26 s25 fold8 a52s s7edge"
WPM_REQUIRED="$WPM_SETS"

for s in $WPM_REQUIRED; do
    [ -f "$PREBUILT/$s/resources_info_more.json" ] || ABORT "wallpaper_more: $PREBUILT/$s/resources_info_more.json is missing"
done
[ -f "$APK" ] || ABORT "wallpaper_more: no wallpaper-res.apk in the work dir"
if [ ! -d "$APKTOOL_DIR/system/priv-app/wallpaper-res/wallpaper-res.apk" ]; then
    # patches/wallpaper (strips the source clips) and patches/wallpaper_interactive (S24U set) must have run on the APK first
    unzip -Z1 "$APK" > /dev/null 2>&1 || ABORT "wallpaper_more: cannot list wallpaper-res.apk"
    unzip -p "$APK" "res/raw/resources_info.json" | grep -q -F '"content_type": "infinity"' \
        || ABORT "wallpaper_more: wallpaper-res.apk has no S24U interactive entries, patches/wallpaper_interactive did not run"
fi

DECODE_APK "system" "$APK_FILE" || ABORT "wallpaper_more: failed to decode wallpaper-res.apk"
WPM_DIR="$APKTOOL_DIR/system/priv-app/wallpaper-res/wallpaper-res.apk"
[ -f "$WPM_DIR/res/raw/resources_info.json" ] || ABORT "wallpaper_more: decoded wallpaper-res.apk has no res/raw/resources_info.json"
mkdir -p "$WPM_DIR/res/raw" "$WPM_DIR/res/drawable-nodpi-v4"

# Stale wpm_ files of an earlier run (a set may have shrunk) go first, the json is rebuilt from scratch below
find "$WPM_DIR/res/raw" "$WPM_DIR/res/drawable-nodpi-v4" -maxdepth 1 -type f -name "wpm_*" -delete

WPM_COPY="$(python3 - "$WPM_DIR/res/raw/resources_info.json" "$PREBUILT" "$WPM_SETS" << 'EOF2'
import json, os, sys

path, prebuilt, sets = sys.argv[1], sys.argv[2], sys.argv[3].split()
with open(path) as f:
    data = json.load(f)

def is_more(item):
    return item.get("filename", "").startswith("wpm_")

phone = [i for i in data["phone"] if not is_more(i)]
assert any(i.get("screen") == 0 and i.get("isDefault") and i.get("type") == 0 for i in phone), "no default (still) wallpaper"
names = {i["filename"].rsplit(".", 1)[0] for i in phone}
copies, stills, clips = [], 0, 0
for s in sets:
    frag = os.path.join(prebuilt, s, "resources_info_more.json")
    if not os.path.exists(frag):
        continue
    with open(frag) as f:
        new = json.load(f)
    for e in new:
        src = e.pop("_file")
        e.pop("_source", None)
        name = e["filename"].rsplit(".", 1)[0]
        assert name.startswith("wpm_") and "." not in name and name not in names, e["filename"]
        assert src.rsplit(".", 1)[0] == name and os.path.isfile(os.path.join(prebuilt, s, src)), src
        assert not e["isDefault"], "wallpaper_more entries must not be the default wallpaper"
        assert e.get("screen") == 0 and e.get("which") in (1, 2, 3, 7), e["filename"]
        if e["type"] == 10:
            assert src.endswith(".mp4") and e["type_params"]["content_type"] == "infinity"
            assert e["type_params"]["service_settings"]["filename"] == e["filename"]
            for line in e["type_params"]["service_settings"]["transition_frame_info"].split("\n"):
                assert len(line.split(" ")) == 9, line
            copies.append("res/raw/%s %s/%s" % (src, s, src))
            clips += 1
        else:
            assert e["type"] == 0 and src.endswith(".webp") and e["frame_no"] == -1, e["filename"]
            copies.append("res/drawable-nodpi-v4/%s %s/%s" % (src, s, src))
            stills += 1
        names.add(name)
        phone.append(e)
for n, item in enumerate(phone):
    item["index"] = n
data["phone"] = phone

with open(path, "w") as f:
    json.dump(data, f, ensure_ascii=False)
print("\n".join(copies))
print("SUMMARY %d %d" % (stills, clips), file=sys.stderr)
EOF2
)" || ABORT "wallpaper_more: failed to patch resources_info.json"
[ "$WPM_COPY" ] || ABORT "wallpaper_more: no wallpaper to add"

while read -r dst src; do
    cp -f "$PREBUILT/$src" "$WPM_DIR/$dst" || ABORT "wallpaper_more: failed to stage $src"
done <<< "$WPM_COPY"
python3 -c 'import json, sys; json.load(open(sys.argv[1]))' "$WPM_DIR/res/raw/resources_info.json" \
    || ABORT "wallpaper_more: resources_info.json is not valid json"

# apktool b must keep the clips stored (and the webp uncompressed like the source): extensions in doNotCompress
python3 - "$WPM_DIR/apktool.yml" << 'EOF3' || ABORT "wallpaper_more: failed to update apktool.yml"
import sys
path = sys.argv[1]
with open(path) as f:
    lines = f.read().split("\n")
want = ["mp4", "webp"]
try:
    i = lines.index("doNotCompress:")
except ValueError:
    while lines and lines[-1] == "":
        lines.pop()
    lines.append("doNotCompress:")
    i = len(lines) - 1
present = set()
j = i + 1
while j < len(lines) and lines[j].startswith("- "):
    present.add(lines[j][2:].strip())
    j += 1
for ext in want:
    if ext not in present:
        lines.insert(j, "- " + ext)
        j += 1
with open(path, "w") as f:
    f.write("\n".join(lines) + "\n")
EOF3

WPM_STILLS="$(find "$WPM_DIR/res/drawable-nodpi-v4" -maxdepth 1 -type f -name "wpm_*.webp" | wc -l)"
WPM_CLIPS="$(find "$WPM_DIR/res/raw" -maxdepth 1 -type f -name "wpm_*.mp4" | wc -l)"
WPM_SIZE="$(find "$WPM_DIR/res/raw" "$WPM_DIR/res/drawable-nodpi-v4" -maxdepth 1 -type f -name "wpm_*" -print0 | du -ch --files0-from=- | tail -n 1 | cut -f 1)"
LOG "- wallpaper_more: $WPM_STILLS stills and $WPM_CLIPS interactive clips staged ($WPM_SIZE), wallpaper-res.apk is rebuilt by apktool at the end of the build"

unset PREBUILT APK_FILE APK WPM_SETS WPM_REQUIRED WPM_DIR WPM_COPY WPM_STILLS WPM_CLIPS WPM_SIZE
