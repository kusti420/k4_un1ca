# The Fold source enables the foldable wallpaper policy in WindowManager: every wallpaper token must carry the
# physical id of the display it belongs to, and WallpaperController hides tokens whose id doesn't match. The
# id is only assigned when the wallpaper Rune runs in sub display mode (WALLPAPER_STYLE contains "LID"), which
# a52sxq doesn't, so the token keeps -1 and no wallpaper (image or live) is ever laid out: black home and lock
# screen, and a grey palette extracted from it. Flat sources (S25) don't read the property at all.
if [[ "$(GET_FLOATING_FEATURE_CONFIG "$FW_DIR/$SOURCE_FIRMWARE_PATH/system/system/etc/floating_feature.xml" \
        "SEC_FLOATING_FEATURE_FRAMEWORK_SUPPORT_FOLDABLE_TYPE_FOLD")" == "TRUE" ]]; then
    SET_PROP "system" "persist.wm.fold.wallpaper_policy" "false"
fi

# The default and "Featured" wallpapers are interactive videos the SM7325 decoder can't run (its HEVC decoder tops
# out at 1044480 blocks/s = 4096x2176@30): Fold8 2504x2504 HEVC 120 fps (2.96M blocks/s, NO_MEMORY on start ->
# black), S25 1440x3120 HEVC Main10 120 fps level 6.2 (2.1M blocks/s). Turn those entries into the still image with
# the same colour (desc_str_id), drop the image entries they duplicate and the cover screen videos, and remove the
# mp4s (~370 MB on the Fold8, ~830 MB on the S25).
APK="$WORK_DIR/system/system/priv-app/wallpaper-res/wallpaper-res.apk"
if [ -f "$APK" ] && unzip -l "$APK" "res/raw/video_001.mp4" &> /dev/null; then
    WP_TMP="$(mktemp -d)"

    unzip -q "$APK" "res/raw/resources_info.json" -d "$WP_TMP" || ABORT "Failed to extract resources_info.json"
    python3 - "$WP_TMP/res/raw/resources_info.json" << 'EOF' || ABORT "Failed to patch resources_info.json"
import json, sys

path = sys.argv[1]
with open(path) as f:
    data = json.load(f)

def is_video(item):
    return item.get("filename", "").endswith(".mp4")

def is_main_image(item):
    return item.get("screen") == 0 and item.get("type") == 0 and not is_video(item)

items = data["phone"]
images = [i for i in items if is_main_image(i)]
phone, converted = [], []
for item in items:
    name = item.get("filename", "")
    if item.get("screen") == 0 and item.get("type") == 10 and name.startswith("video_"):
        # still image of the same colour; the image numbering only follows the video numbering on the Fold8
        same = [i for i in images if i.get("desc_str_id") and i.get("desc_str_id") == item.get("desc_str_id")]
        filename = same[0]["filename"] if same else "wallpaper_" + name[len("video_"):].replace(".mp4", ".png")
        item = {
            "isDefault": item["isDefault"], "index": item["index"], "which": item["which"],
            "screen": 0, "target_screen_only": True, "type": 0,
            "filename": filename, "frame_no": -1,
            "desc_str_id": item.get("desc_str_id", ""), "cmf_info": item.get("cmf_info", [""]),
            "logging_info": item.get("logging_info", {}),
        }
        converted.append(item)
    elif is_video(item):
        continue
    phone.append(item)
# the still images the converted entries now point at would show up twice
used = {c["filename"] for c in converted}
data["phone"] = [i for i in phone if any(i is c for c in converted) or not (is_main_image(i) and i["filename"] in used)]
assert converted and not any(is_video(i) for i in data["phone"]), "unexpected wallpaper list"
assert any(i.get("screen") == 0 and i.get("isDefault") for i in data["phone"]), "no default wallpaper"

for t in data["types"]:
    if t.get("type") in (8, 10):
        t["type"] = 0

with open(path, "w") as f:
    json.dump(data, f, ensure_ascii=False)
EOF

    (cd "$WP_TMP" && zip -q "$APK" "res/raw/resources_info.json") || ABORT "Failed to update wallpaper-res.apk"
    VIDEOS="$(unzip -Z1 "$APK" | grep -E "^res/raw/(sub_)?video_[0-9]+\.mp4$" || true)"
    if [ "$VIDEOS" ]; then
        # shellcheck disable=SC2086
        zip -q -d "$APK" $VIDEOS || ABORT "Failed to strip wallpaper videos"
    fi

    CERT_PREFIX="aosp"
    $ROM_IS_OFFICIAL && CERT_PREFIX="unica"
    EVAL "signapk \"$SRC_DIR/security/${CERT_PREFIX}_platform.x509.pem\" \"$SRC_DIR/security/${CERT_PREFIX}_platform.pk8\" \"$APK\" \"$WP_TMP/signed.apk\"" \
        || ABORT "Failed to sign wallpaper-res.apk"
    mv -f "$WP_TMP/signed.apk" "$APK"

    rm -rf "$WP_TMP"
    unset WP_TMP CERT_PREFIX VIDEOS
fi
unset APK
