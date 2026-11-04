#!/usr/bin/env bash
# Host test of codec_av1_sw_off: the override xml is well-formed and carries exactly the two AV1 decoder update entries
# (the parser semantics these rely on: update="true" needs an existing codec and a type, enabled="false" disables),
# and customize.sh against a fake work dir: installs into product/etc with the system_file label, refuses to shadow a
# media_codecs_c2.xml / media_codecs_performance_c2.xml of another partition. Nothing here is shipped.
# Usage: run.sh
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
XML="$HERE/../media_codecs_c2.xml"
T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT
PASS=0; FAIL=0
ok() { PASS=$((PASS + 1)); }
bad() { FAIL=$((FAIL + 1)); echo "FAIL [$CASE]: $*"; }
eq() { [ "$2" = "$3" ] && ok || bad "$1: expected '$3', got '$2'"; }

CASE="xml"
python3 -I - "$XML" > "$T/xml.out" 2>&1 << 'PY'
import sys, xml.etree.ElementTree as ET
root = ET.parse(sys.argv[1]).getroot()
assert root.tag == "MediaCodecs", root.tag
sections = [c.tag for c in root]
assert sections == ["Decoders"], sections
codecs = list(root[0])
assert len(codecs) == 2, len(codecs)
names = []
for c in codecs:
    assert c.tag == "MediaCodec", c.tag
    assert set(c.attrib) == {"name", "type", "update", "enabled"}, c.attrib
    assert c.attrib["type"] == "video/av01", c.attrib
    assert c.attrib["update"] == "true" and c.attrib["enabled"] == "false", c.attrib
    assert len(list(c)) == 0, "no children expected"
    names.append(c.attrib["name"])
assert sorted(names) == ["c2.android.av1-dav1d.decoder", "c2.android.av1.decoder"], names
print("ok")
PY
eq "well-formed, exactly the two AV1 update entries" "$(cat "$T/xml.out")" "ok"
grep -q "codec_av1_sw_off" "$XML" && ok || bad "the ownership marker customize.sh greps for is missing"

# customize.sh against a fake work dir with the helpers it uses recorded in files
fake_env() {
    WORK_DIR="$T/work"; MODPATH="$HERE/.."
    rm -rf "$WORK_DIR"; mkdir -p "$WORK_DIR/product/etc" "$WORK_DIR/system/system/apex" "$WORK_DIR/vendor/etc" \
        "$WORK_DIR/odm/etc" "$WORK_DIR/system/system/etc"
    : > "$WORK_DIR/system/system/apex/com.google.android.media.swcodec_compressed.apex"
    : > "$T/meta"; : > "$T/log"; : > "$T/abort"
}
LOG() { echo "$1" >> "$T/log"; }
ABORT() { echo "$1" >> "$T/abort"; return 1; }
EVAL() { eval "$1"; }
SET_METADATA() { echo "$1 $2 $3 $4 $5 $6" >> "$T/meta"; }
run_customize() { ( set -e; . "$HERE/../customize.sh" ) > "$T/out" 2>&1; echo $?; }   # apply_modules.sh runs under set -e

CASE="fresh work dir: installed into product/etc as system_file"
fake_env
eq "exit status" "$(run_customize)" 0
eq "no abort" "$(cat "$T/abort")" ""
cmp -s "$XML" "$WORK_DIR/product/etc/media_codecs_c2.xml" && ok || bad "product/etc/media_codecs_c2.xml not installed"
eq "metadata" "$(cat "$T/meta")" "product etc/media_codecs_c2.xml 0 0 644 u:object_r:system_file:s0"
grep -q "media_codecs_c2.xml" "$T/log" && ok || bad "no LOG line"

CASE="re-run on a work dir that already has our file: still fine"
eq "exit status" "$(run_customize)" 0
eq "no abort" "$(cat "$T/abort")" ""

CASE="vendor ships media_codecs_c2.xml: refuse to shadow it"
fake_env; : > "$WORK_DIR/vendor/etc/media_codecs_c2.xml"
eq "exit status" "$(run_customize)" 1
grep -q "vendor/etc/media_codecs_c2.xml exists" "$T/abort" && ok || bad "abort text: $(cat "$T/abort")"
[ -e "$WORK_DIR/product/etc/media_codecs_c2.xml" ] && bad "installed anyway" || ok

CASE="odm ships media_codecs_performance_c2.xml: refuse"
fake_env; : > "$WORK_DIR/odm/etc/media_codecs_performance_c2.xml"
eq "exit status" "$(run_customize)" 1

CASE="a foreign product/etc/media_codecs_c2.xml: refuse"
fake_env; echo "<MediaCodecs/>" > "$WORK_DIR/product/etc/media_codecs_c2.xml"
eq "exit status" "$(run_customize)" 1
grep -q "not ours" "$T/abort" && ok || bad "abort text: $(cat "$T/abort")"

CASE="no Google swcodec APEX: refuse"
fake_env; rm -f "$WORK_DIR"/system/system/apex/*
eq "exit status" "$(run_customize)" 1
grep -q "swcodec APEX" "$T/abort" && ok || bad "abort text: $(cat "$T/abort")"

echo "codec_av1_sw_off: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
