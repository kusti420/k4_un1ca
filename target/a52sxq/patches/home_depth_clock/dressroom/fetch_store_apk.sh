#!/usr/bin/env bash
# Puts the Galaxy Store DressRoom build that dressroom.sh patches (3.0.10.38, sha256 in DressRoom.apk.sha256) next to
# this script, pulled from a phone that runs it. The APK is Samsung's and is not kept in git.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SERIAL="${1:?usage: $0 <adb serial>}"
P="$(adb -s "$SERIAL" shell pm path com.samsung.android.app.dressroom | grep /data/app/ | head -1 | cut -d: -f2 | tr -d '\r')"
[ -n "$P" ] || { echo "no Store (/data/app) DressRoom on $SERIAL" >&2; exit 1; }
adb -s "$SERIAL" pull "$P" "$HERE/DressRoom.apk"
(cd "$HERE" && echo "$(cat DressRoom.apk.sha256)  DressRoom.apk" | sha256sum -c -)
