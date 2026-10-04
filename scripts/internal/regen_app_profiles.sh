#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Rebuilds the shipped app/jar profiles (<file>.prof next to an APK or jar) of every file the build modified,
# and adds the target's own text profiles (target/<codename>/profiles/<file>.txt) to the matching APK/jar.
#
# Samsung ships cloud profiles for a few heavy packages (services.jar, semwifi-service.jar, SamsungCamera,
# SamsungContacts, HoneyBoard, ...). ART keys them by dex checksum, so once a patch rebuilds the APK/jar the
# profile matches nothing and apktool.sh drops it: ArtService/odrefresh then compile the package with an empty
# speed-profile (= verify only) and it runs in the interpreter/JIT until background dexopt has collected a
# runtime profile days later. Converting the source profile to text against the source file and back against
# the final file keeps Samsung's method list intact (same approach as regen_boot_profile.sh).
#
# Packages Samsung ships no profile for (Settings, launcher, ...) get the same verify-only treatment after
# every flash; a text profile dumped from a used device (profman --dump-classes-and-methods) placed in
# target/<codename>/profiles/<apk or jar name>.txt[.gz] is compiled in the same way. When both exist they are merged.
#
# Needs a host profman: PROFMAN=/path/to/profman, or profman in PATH. Skipped (with a warning) otherwise.

# [
source "$SRC_DIR/scripts/utils/build_utils.sh" || exit 1

SOURCE_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$SOURCE_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$SOURCE_FIRMWARE")"
SOURCE_DIR="$FW_DIR/$SOURCE_FIRMWARE_PATH"
EXTRA_DIR="$SRC_DIR/target/$TARGET_CODENAME/profiles"

# DEX_LOCATION <path relative to the firmware/work dir root>
# system/system/framework/x.jar -> /system/framework/x.jar, system/system/system_ext/.. -> /system_ext/..,
# product/.. -> /product/.., odm/.. -> /odm/..
DEX_LOCATION()
{
    local REL="$1"
    local R
    R="${REL#system/system/system_ext/}"
    [[ "$R" == "$REL" ]] || { echo "/system_ext/$R"; return; }
    R="${REL#system/system/}"
    [[ "$R" == "$REL" ]] || { echo "/system/$R"; return; }
    echo "/$REL"
}

# PARTITION_OF <relative path> -> partition name; ENTRY_OF <relative path> -> path inside that partition
PARTITION_OF() { cut -d "/" -f 1 <<< "$1"; }
ENTRY_OF() { cut -d "/" -f 2- <<< "$1"; }

# REGEN_PROFILE <relative path of the APK/jar>
REGEN_PROFILE()
{
    local REL="$1"
    local SOURCE_FILE="$SOURCE_DIR/$REL"
    local TARGET_FILE="$WORK_DIR/$REL"
    local SOURCE_PROFILE="$SOURCE_DIR/$REL.prof"
    local PROFILE="$WORK_DIR/$REL.prof"
    local EXTRA="$EXTRA_DIR/$(basename "$REL").txt"
    [ -f "$EXTRA" ] || EXTRA="$EXTRA_DIR/$(basename "$REL").txt.gz"
    local LOCATION NAME SOURCE_METHODS TARGET_METHODS HAD_PROFILE
    LOCATION="$(DEX_LOCATION "$REL")"
    NAME="$(basename "$REL")"

    [ -f "$TARGET_FILE" ] || return 0
    : > "$TMP/profile.txt"
    if [ -f "$SOURCE_PROFILE" ] && [ -f "$SOURCE_FILE" ]; then
        if ! "$PROFMAN" --dump-classes-and-methods --profile-file="$SOURCE_PROFILE" --apk="$SOURCE_FILE" \
                --dex-location="$LOCATION" >> "$TMP/profile.txt" 2> "$TMP/err.txt"; then
            LOGW "Failed to dump the source $NAME.prof ($(head -n 1 "$TMP/err.txt"))"
        fi
    fi
    if [ -f "$EXTRA" ]; then
        case "$EXTRA" in
            *.gz) zcat "$EXTRA" >> "$TMP/profile.txt" ;;
            *) cat "$EXTRA" >> "$TMP/profile.txt" ;;
        esac
    fi
    SOURCE_METHODS="$(grep -c -- "->" "$TMP/profile.txt")"
    [ "$SOURCE_METHODS" -gt 0 ] || return 0

    rm -f "$TMP/new.prof"
    if ! "$PROFMAN" --create-profile-from="$TMP/profile.txt" --apk="$TARGET_FILE" --dex-location="$LOCATION" \
            --reference-profile-file="$TMP/new.prof" > /dev/null 2> "$TMP/err.txt"; then
        LOGW "Failed to create $NAME.prof ($(head -n 1 "$TMP/err.txt"))"
        return 0
    fi
    "$PROFMAN" --dump-classes-and-methods --profile-file="$TMP/new.prof" --apk="$TARGET_FILE" \
        --dex-location="$LOCATION" > "$TMP/check.txt" 2> /dev/null
    TARGET_METHODS="$(grep -c -- "->" "$TMP/check.txt")"

    HAD_PROFILE=false
    [ -f "$PROFILE" ] && HAD_PROFILE=true
    cp -f "$TMP/new.prof" "$PROFILE"
    $HAD_PROFILE || SET_METADATA "$(PARTITION_OF "$REL")" "$(ENTRY_OF "$REL").prof" 0 0 644 "u:object_r:system_file:s0"
    LOG "- $( $HAD_PROFILE && echo Regenerated || echo Created ) $NAME.prof ($TARGET_METHODS/$SOURCE_METHODS methods)"
    REGENERATED=$((REGENERATED + 1))
}
# ]

PROFMAN="${PROFMAN:-$(command -v profman)}"
if [ ! -x "$PROFMAN" ]; then
    LOGW "profman not found (set PROFMAN), keeping the source app profiles"
    exit 0
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
REGENERATED=0

# 1. Source profiles whose APK/jar was modified by the build (apktool.sh deleted the stale .prof)
while IFS= read -r SOURCE_PROFILE; do
    REL="${SOURCE_PROFILE#$SOURCE_DIR/}"
    REL="${REL%.prof}"
    [[ "$REL" == *.apk || "$REL" == *.jar ]] || continue
    [ -f "$SOURCE_DIR/$REL" ] && [ -f "$WORK_DIR/$REL" ] || continue
    cmp -s "$SOURCE_DIR/$REL" "$WORK_DIR/$REL" && continue
    REGEN_PROFILE "$REL"
done < <(find "$SOURCE_DIR/system" "$SOURCE_DIR/product" "$SOURCE_DIR/odm" -name "*.prof" ! -name "boot-image.prof" 2> /dev/null | sort)

# 2. The target's own text profiles, for APKs/jars not handled above
if [ -d "$EXTRA_DIR" ]; then
    while IFS= read -r EXTRA; do
        NAME="$(basename "$EXTRA")"
        NAME="${NAME%.gz}"
        NAME="${NAME%.txt}"
        TARGET_FILE="$(find "$WORK_DIR/system" "$WORK_DIR/product" "$WORK_DIR/odm" -name "$NAME" -type f 2> /dev/null | head -n 1)"
        if [ ! -f "$TARGET_FILE" ]; then
            LOGW "No $NAME in the work dir for $(basename "$EXTRA"), skipping"
            continue
        fi
        REL="${TARGET_FILE#$WORK_DIR/}"
        # already merged in step 1 if the source profile was regenerated for a modified file
        [ -f "$SOURCE_DIR/$REL.prof" ] && [ -f "$SOURCE_DIR/$REL" ] && ! cmp -s "$SOURCE_DIR/$REL" "$TARGET_FILE" && continue
        REGEN_PROFILE "$REL"
    done < <(find "$EXTRA_DIR" -name "*.txt" -o -name "*.txt.gz" 2> /dev/null | sort)
fi

[ "$REGENERATED" -eq 0 ] && LOG "- Nothing to regenerate"
exit 0
