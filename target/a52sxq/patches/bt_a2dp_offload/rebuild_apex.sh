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
m=re.search(r"\.method public isOffloadSupportedCodec\(I\)Z\n(?:.*\n)*?\s+iget-boolean p0, p0, Lcom/android/bluetooth/a2dp/A2dpService;->mA2dpOffloadEnabled:Z\n\n\s+if-eqz p0, :cond_\w+\n", s)
assert m, "isOffloadSupportedCodec head"
end=s.index(".end method", m.end())
t=re.search(r"(:cond_\w+)\n\s+const/4 p0, 0x1\n\s+return p0\n", s[m.end():end])
assert t, "return-true label"
yes=t.group(1)
# Samsung codec ids: SBC 0, AAC 0x2, aptX 0x8, aptX HD 0x10, LDAC 0x40, SSC 0x80, hifi 0x100. Stock only lets
# sbc/aptx/ssc/hifi offload; the A52s vendor HAL offloads AAC/aptX HD/LDAC too (persist.vendor.bt.a2dp_offload_cap).
guard="""
    # unica: AAC / aptX HD / LDAC are hardware-offloaded on this vendor (A14 behaviour); the software path can't drive them
    const/4 v0, 0x2

    if-eq p1, v0, %s

    const/16 v0, 0x10

    if-eq p1, v0, %s

    const/16 v0, 0x40

    if-eq p1, v0, %s
""" % (yes, yes, yes)
open(p,"w").write(s[:m.end()]+guard+s[m.end():])
PY
python3 - "$(ls "$W"/dec/smali*/com/android/bluetooth/a2dp/A2dpServiceHelper.smali)" <<'PY'
import re,sys
p=sys.argv[1]; s=open(p).read()
# updateBtDevToAudio(): when the device's "HQ audio" codec (LDAC / SSC UHQ) is enabled, Samsung forces the software
# ("hifi") path even for offload-capable codecs. This vendor has no software path for LDAC, so ignore the HQ state.
pat=r"(invoke-virtual \{(v\d+), p1\}, Lcom/android/bluetooth/a2dp/A2dpService;->checkHqCodecState\(Landroid/bluetooth/BluetoothDevice;\)Z\n\n\s+move-result (v\d+)\n)"
s,n=re.subn(pat, lambda m: m.group(1)+"\n    # unica: HQ codec state must not push LDAC/SSC off the hardware offload path on this vendor\n    const/4 %s, 0x0\n" % m.group(3), s)
assert n==1, "checkHqCodecState call site"
open(p,"w").write(s)
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
