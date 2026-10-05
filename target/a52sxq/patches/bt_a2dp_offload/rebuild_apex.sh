#!/bin/bash
# Rebuild com.android.bt.apex with the A2DP offload patch. Usage: rebuild_apex.sh <stock com.android.bt.apex> <out apex>
# Needs: out/tools/bin (fuse2fs, apktool.jar, signapk.jar), e2fsprogs (e2fsck, resize2fs, dumpe2fs), ~/git/android host avbtool/zipalign/apksigner.
set -e
SRC="$1"; OUT="$2"; HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/../../../.." && pwd)"
T="$ROOT/out/tools/bin"; H=~/git/android/out/host/linux-x86/bin; K="$HERE/../tethering/keys"; J21=~/git/android/prebuilts/jdk/jdk21/linux-x86
export JAVA_HOME=$J21 PATH=$J21/bin:$PATH
W="$(mktemp -d)"; trap 'mountpoint -q "$W/mnt" && fusermount3 -u "$W/mnt"; rm -rf "$W"' EXIT
unzip -q "$SRC" apex_payload.img -d "$W"; mkdir -p "$W/mnt"
"$T/fuse2fs" -o ro,fakeroot "$W/apex_payload.img" "$W/mnt"; APK="$(find "$W/mnt/app" -name Bluetooth.apk)"; REL="${APK#$W/mnt/}"; cp "$APK" "$W/Bluetooth.apk"; fusermount3 -u "$W/mnt"
java -Xmx6g -jar "$T/apktool.jar" d -r -f -o "$W/dec" "$W/Bluetooth.apk" >/dev/null
python3 - "$(ls "$W"/dec/smali*/com/android/bluetooth/a2dp/A2dpService.smali)" <<'PY'
import re,sys
p=sys.argv[1]; s=open(p).read()
m=re.search(r"\.method public isOffloadSupportedCodec\(I\)Z\n(\s+\.locals (\d+)\n)", s); assert m and int(m.group(2))>=1
guard="""
    # unica: offload SBC/AAC/aptX/aptX HD/LDAC (codec types 0..4) like the A14 stack; others keep the stock prop logic
    const/4 v0, 0x4

    if-gt p1, v0, :unica_orig

    if-ltz p1, :unica_orig

    const/4 p0, 0x1

    return p0

    :unica_orig
"""
open(p,"w").write(s[:m.end()]+guard+s[m.end():])
PY
java -Xmx6g -jar "$T/apktool.jar" b -o "$W/unsigned.apk" "$W/dec" >/dev/null
"$H/zipalign" -p -f 4 "$W/unsigned.apk" "$W/aligned.apk"
java -jar "$T/signapk.jar" "$ROOT/security/aosp_platform.x509.pem" "$ROOT/security/aosp_platform.pk8" "$W/aligned.apk" "$W/Bluetooth_patched.apk"
"$H/avbtool" erase_footer --image "$W/apex_payload.img"
e2fsck -fy -E unshare_blocks "$W/apex_payload.img" >/dev/null || true
resize2fs "$W/apex_payload.img" 40M >/dev/null
"$T/fuse2fs" -o rw,fakeroot "$W/apex_payload.img" "$W/mnt"; cat "$W/Bluetooth_patched.apk" > "$W/mnt/$REL"; fusermount3 -u "$W/mnt"
e2fsck -fy "$W/apex_payload.img" >/dev/null || true
"$H/avbtool" add_hashtree_footer --image "$W/apex_payload.img" --key "$K/payload.pem" --algorithm SHA256_RSA4096 --hash_algorithm sha256 --do_not_generate_fec --partition_name com.android.bt
"$H/avbtool" extract_public_key --key "$K/payload.pem" --output "$W/apex_pubkey"
cp "$SRC" "$W/unsigned.apex"; (cd "$W" && zip -q -d unsigned.apex "META-INF/*" && zip -q -X -0 unsigned.apex apex_payload.img apex_pubkey)
java -jar "$T/signapk.jar" "$K/container.x509.pem" "$K/container.pk8" "$W/unsigned.apex" "$OUT"
echo "wrote $OUT"
