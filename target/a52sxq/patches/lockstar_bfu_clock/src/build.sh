#!/usr/bin/env bash
# Regenerates ../smali/com/k4/lockscreen/*.smali from the Java source here (javac + d8 + baksmali).
# stubs/ only declares the hidden framework methods the helper calls (ActivityThread.currentApplication,
# SystemProperties.getInt); they are not shipped - the helper lives in framework.jar itself.
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
# framework.jar is decoded with hidden-API flags; like the other framework helpers (UN1CA's, gallery_slowmo's) every
# member gets one. "blacklist" is fine: only framework code (ContentResolver) calls into the helper.
python3 - "$HERE/../smali" << 'PYEOF'
import glob, re, sys
for f in glob.glob(sys.argv[1] + "/**/*.smali", recursive=True):
    s = open(f).read()
    s = re.sub(r"^(\.method (?:[a-z-]+ )*?)(?!(?:public|private|protected|static|final|synthetic|bridge|varargs|constructor|abstract|native|declared-synchronized|blacklist) )(\S+\()", r"\1blacklist \2", s, flags=re.M)
    s = re.sub(r"^(\.field (?:[a-z-]+ )*?)(?!(?:public|private|protected|static|final|synthetic|volatile|transient|blacklist) )(\S+:)", r"\1blacklist \2", s, flags=re.M)
    open(f, "w").write(s)
PYEOF
find "$HERE/../smali" -name '*.smali' | sort
