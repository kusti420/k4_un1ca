# Samsung "Interactive wallpapers" (SpriteWallpaper InfinityWallpaper: an all-intra HEVC clip the engine seeks through
# by frame number, one transition per AOD->lock, AOD->home, lock->home and lock touch) on the A52s. The S26U source ships
# six 1440x3120 HEVC Main10 90 fps clips the SM7325 decoder can't run (1.04M blocks/s, see patches/wallpaper, which turns
# those entries into stills and drops the mp4s). This patch runs after it (LC_ALL=C sort: "wallpaper" < "wallpaper_interactive")
# and adds the four Galaxy S24 Ultra clips (SM-S928B S928BXXS6EZJ1, black / warm gray / violet / yellow), transcoded on
# the PC to 1080x2400 8-bit all-intra HEVC at 30 fps, with the motion table's frame numbers rescaled (module.prop and
# prebuilts/wallpapers/s24u/README.txt have the parameters and the decoder budget).
#
# resources.arsc is left untouched: the clips are stored under four of the six raw/video_00N resource ids the S26U APK
# already has (the mp4 must be zip-STORED: SpriteWallpaper opens it with Resources.openRawResourceFd), and the type-10
# entries re-enter res/raw/resources_info.json with the schema the 2.8.78 DressRoom/SpriteWallpaper parse (deep copy of
# the S26U entries, S24U service_settings). The still-image entries patches/wallpaper left behind stay as they are and
# keep isDefault, so a decoder failure can never produce a black default wallpaper. Idempotent: existing video_*.mp4
# members and type-10 entries are replaced.
PREBUILT="$SRC_DIR/prebuilts/wallpapers/s24u"
APK="$WORK_DIR/system/system/priv-app/wallpaper-res/wallpaper-res.apk"
WPI_CLIPS="video_001.mp4 video_002.mp4 video_003.mp4 video_004.mp4"

[ -f "$PREBUILT/resources_info_infinity.json" ] || ABORT "wallpaper_interactive: $PREBUILT/resources_info_infinity.json is missing"
for f in $WPI_CLIPS; do
    [ -s "$PREBUILT/$f" ] || ABORT "wallpaper_interactive: prebuilt clip $PREBUILT/$f is missing"
done
[ -f "$APK" ] || ABORT "wallpaper_interactive: no wallpaper-res.apk in the work dir"
unzip -Z1 "$APK" > /dev/null 2>&1 || ABORT "wallpaper_interactive: cannot list wallpaper-res.apk"
if unzip -Z1 "$APK" | grep -q -E "\.mp4$" && ! unzip -p "$APK" "res/raw/resources_info.json" | grep -q -F '"content_type": "infinity"'; then
    ABORT "wallpaper_interactive: wallpaper-res.apk still carries source mp4s, patches/wallpaper did not run"
fi
for f in $WPI_CLIPS; do
    unzip -Z1 "$APK" | grep -q -x "res/raw/$f" && LOG "- wallpaper_interactive: res/raw/$f already present, replacing it"
done

WPI_TMP="$(mktemp -d)"
mkdir -p "$WPI_TMP/res/raw"
unzip -q "$APK" "res/raw/resources_info.json" -d "$WPI_TMP" || ABORT "wallpaper_interactive: failed to extract resources_info.json"
python3 - "$WPI_TMP/res/raw/resources_info.json" "$PREBUILT/resources_info_infinity.json" "$WPI_CLIPS" << 'EOF2' || ABORT "wallpaper_interactive: failed to patch resources_info.json"
import json, sys

path, fragment, clips = sys.argv[1], sys.argv[2], sys.argv[3].split()
with open(path) as f:
    data = json.load(f)
with open(fragment) as f:
    new = json.load(f)

assert [e["filename"] for e in new] == clips, "fragment/clip list mismatch"
for e in new:
    e.pop("_s24u_source", None)
    assert e["type"] == 10 and e["type_params"]["content_type"] == "infinity", e["filename"]
    assert e["type_params"]["service_settings"]["filename"] == e["filename"]
    assert not e["isDefault"], "video entries must not be the default wallpaper"
    for line in e["type_params"]["service_settings"]["transition_frame_info"].split("\n"):
        assert len(line.split(" ")) == 9, line

def is_video(item):
    return item.get("type") == 10 or item.get("filename", "").endswith(".mp4")

phone = [i for i in data["phone"] if not is_video(i)]
assert any(i.get("screen") == 0 and i.get("isDefault") for i in phone), "no default (still) wallpaper left"
phone += new
for n, item in enumerate(phone):
    item["index"] = n
data["phone"] = phone
assert sum(1 for i in data["phone"] if is_video(i)) == len(clips)

with open(path, "w") as f:
    json.dump(data, f, ensure_ascii=False)
EOF2

for f in $WPI_CLIPS; do
    cp -f "$PREBUILT/$f" "$WPI_TMP/res/raw/$f" || ABORT "wallpaper_interactive: failed to stage $f"
done
# The json may be deflated, the clips must be stored (-0): openRawResourceFd needs an uncompressed member
(cd "$WPI_TMP" && zip -q "$APK" "res/raw/resources_info.json" && zip -q -0 "$APK" $(for f in $WPI_CLIPS; do echo "res/raw/$f"; done)) \
    || ABORT "wallpaper_interactive: failed to update wallpaper-res.apk"
for f in $WPI_CLIPS; do
    unzip -v "$APK" "res/raw/$f" | grep -q -E "^ *[0-9]+ +Stored " || ABORT "wallpaper_interactive: res/raw/$f is not stored"
done
unzip -p "$APK" "res/raw/resources_info.json" | python3 -c 'import json, sys; json.load(sys.stdin)' \
    || ABORT "wallpaper_interactive: resources_info.json is not valid json"

CERT_PREFIX="aosp"
$ROM_IS_OFFICIAL && CERT_PREFIX="unica"
EVAL "signapk \"$SRC_DIR/security/${CERT_PREFIX}_platform.x509.pem\" \"$SRC_DIR/security/${CERT_PREFIX}_platform.pk8\" \"$APK\" \"$WPI_TMP/signed.apk\"" \
    || ABORT "wallpaper_interactive: failed to sign wallpaper-res.apk"
mv -f "$WPI_TMP/signed.apk" "$APK"
SET_METADATA "system" "system/priv-app/wallpaper-res/wallpaper-res.apk" 0 0 644 "u:object_r:system_file:s0"
LOG "- wallpaper_interactive: $(echo $WPI_CLIPS | wc -w) S24U interactive wallpapers added ($(du -sh "$APK" | cut -f 1) wallpaper-res.apk)"

rm -rf "$WPI_TMP"
unset PREBUILT APK WPI_CLIPS WPI_TMP CERT_PREFIX
