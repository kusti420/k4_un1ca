#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Rebuilds system/etc/boot-image.prof against the final boot classpath jars.
#
# The preopted boot image is debloated, so odrefresh compiles the boot classpath on device with the
# speed-profile filter. Binary boot profiles key every dex file by its checksum: once patches rebuild
# framework.jar & co., dex2oat silently drops all of their entries and the boot image ends up with almost
# no framework code compiled (everything then runs in the interpreter/JIT). Converting the source profile
# to text against the source jars and back against the final jars keeps Samsung's method list intact.
#
# Needs a host profman: PROFMAN=/path/to/profman, or profman in PATH. Skipped (with a warning) otherwise.

# [
source "$SRC_DIR/scripts/utils/build_utils.sh" || exit 1

SOURCE_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$SOURCE_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$SOURCE_FIRMWARE")"

# EXTRACT_APEX_JAVALIB <apex> <output dir>
EXTRACT_APEX_JAVALIB()
{
    local APEX="$1"
    local OUT="$2"
    local PAYLOAD="$TMP/payload.img"

    mkdir -p "$OUT"
    if unzip -l "$APEX" "original_apex" &> /dev/null; then
        unzip -p "$APEX" "original_apex" > "$TMP/original_apex" || return 1
        APEX="$TMP/original_apex"
    fi
    unzip -p "$APEX" "apex_payload.img" > "$PAYLOAD" || return 1

    if [[ "$(xxd -p -s 1024 -l 4 "$PAYLOAD")" == "e2e1f5e0" ]]; then
        extract.erofs -i "$PAYLOAD" -x -T"$(nproc)" -o "$TMP/erofs" &> /dev/null || return 1
        cp -a "$TMP/erofs/javalib/." "$OUT" || return 1
        rm -rf "$TMP/erofs"
    else
        debugfs -R "rdump /javalib $TMP" "$PAYLOAD" &> /dev/null || return 1
        cp -a "$TMP/javalib/." "$OUT" || return 1
        rm -rf "$TMP/javalib"
    fi
    rm -f "$PAYLOAD" "$TMP/original_apex"
}

# BCP_ARGS <system dir>
# Prints one --apk/--dex-location pair per line for every jar keyed in the source profile.
BCP_ARGS()
{
    local SYSTEM="$1"
    local KEY
    while IFS= read -r KEY; do
        if [ -f "$TMP/art/$KEY" ]; then
            echo "--apk=$TMP/art/$KEY"
            echo "--dex-location=/apex/com.android.art/javalib/$KEY"
        elif [ -f "$TMP/i18n/$KEY" ]; then
            echo "--apk=$TMP/i18n/$KEY"
            echo "--dex-location=/apex/com.android.i18n/javalib/$KEY"
        elif [ -f "$SYSTEM/framework/$KEY" ]; then
            echo "--apk=$SYSTEM/framework/$KEY"
            echo "--dex-location=/system/framework/$KEY"
        else
            LOGW "Boot profile entry $KEY not found, its methods are dropped"
        fi
    done < <(sed -n -E 's/^([^ !]+\.jar)(![^ ]+)? \[index=.*/\1/p' "$TMP/keys.txt" | sort -u)
}
# ]

PROFILE="$WORK_DIR/system/system/etc/boot-image.prof"
SOURCE_PROFILE="$FW_DIR/$SOURCE_FIRMWARE_PATH/system/system/etc/boot-image.prof"
[ -f "$PROFILE" ] && [ -f "$SOURCE_PROFILE" ] || exit 0

PROFMAN="${PROFMAN:-$(command -v profman)}"
if [ ! -x "$PROFMAN" ]; then
    LOGW "profman not found (set PROFMAN), keeping the source boot image profile"
    exit 0
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

EXTRACT_APEX_JAVALIB "$(ls "$WORK_DIR/system/system/apex/"*.android.art*.apex | head -n 1)" "$TMP/art" \
    || ABORT "Failed to extract the ART module boot jars"
EXTRACT_APEX_JAVALIB "$(ls "$WORK_DIR/system/system/apex/"*.android.i18n*.apex | head -n 1)" "$TMP/i18n" \
    || ABORT "Failed to extract the i18n module boot jars"

"$PROFMAN" --dump-only --profile-file="$SOURCE_PROFILE" > "$TMP/keys.txt" 2> /dev/null

mapfile -t SOURCE_ARGS < <(BCP_ARGS "$FW_DIR/$SOURCE_FIRMWARE_PATH/system/system")
mapfile -t TARGET_ARGS < <(BCP_ARGS "$WORK_DIR/system/system")

EVAL "\"$PROFMAN\" --dump-classes-and-methods --profile-file=\"$SOURCE_PROFILE\" ${SOURCE_ARGS[*]} > \"$TMP/profile.txt\"" \
    || ABORT "Failed to dump the source boot image profile"
SOURCE_METHODS="$(grep -c -- "->" "$TMP/profile.txt")"

EVAL "\"$PROFMAN\" --create-profile-from=\"$TMP/profile.txt\" --output-profile-type=boot ${TARGET_ARGS[*]} --reference-profile-file=\"$TMP/boot-image.prof\"" \
    || ABORT "Failed to create the boot image profile"
"$PROFMAN" --dump-classes-and-methods --profile-file="$TMP/boot-image.prof" "${TARGET_ARGS[@]}" > "$TMP/check.txt" 2> /dev/null
TARGET_METHODS="$(grep -c -- "->" "$TMP/check.txt")"

cp -f "$TMP/boot-image.prof" "$PROFILE"
LOG "- Regenerated boot-image.prof ($TARGET_METHODS/$SOURCE_METHODS methods)"

exit 0
