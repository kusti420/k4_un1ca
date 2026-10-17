#!/usr/bin/env bash
# Regenerates ../smali/com/k4/homeclock/*.smali from the Java sources here (javac + d8 + baksmali).
# The stubs (stubs/) mirror the obfuscated SpriteWallpaper 2.8.78.0 classes the code links against; they are not shipped.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="${SRC_DIR:-$(cd "$HERE/../../../../.." && pwd)}"
SDK="${ANDROID_HOME:-$HOME/Android/Sdk}"
BT="$(ls -d "$SDK"/build-tools/* | sort -V | tail -1)"
JAR="$(ls -d "$SDK"/platforms/android-* | sort -V | tail -1)/android.jar"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/stubs" "$TMP/cls" "$TMP/dex"
javac -nowarn -source 11 -target 11 -cp "$JAR" -d "$TMP/stubs" $(find "$HERE/stubs" -name '*.java')
javac -nowarn -source 11 -target 11 -cp "$JAR:$TMP/stubs" -d "$TMP/cls" $(find "$HERE/com" -name '*.java')
"$BT/d8" --min-api 34 --lib "$JAR" --classpath "$TMP/stubs" --output "$TMP/dex" $(find "$TMP/cls" -name '*.class')
rm -rf "$HERE/../smali"
java -cp "$SRC_DIR/out/tools/bin/apktool.jar" com.android.tools.smali.baksmali.Main d -o "$HERE/../smali" "$TMP/dex/classes.dex"
find "$HERE/../smali" -name '*.smali' | sort
