#!/usr/bin/env bash
# Host test of k4-tethering-gate: the real script against real BPF objects (the shipped a52_netd.o candidates in
# ../../tethering and the known trains in ../known), a fake apex-updated-list.xml, kmsg and properties in files.
# Nothing here is shipped. Usage: run.sh [-v]   K4TG_TEST_SH=<shell> runs the gate with another shell (phone: mksh).
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="$HERE/../k4-tethering-gate"
SH="${K4TG_TEST_SH:-bash}"
VERBOSE=false
[ "${1:-}" = -v ] && VERBOSE=true
T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT
PASS=0; FAIL=0
ok() { PASS=$((PASS + 1)); }
bad() { FAIL=$((FAIL + 1)); echo "FAIL [$CASE]: $*"; }
eq() { [ "$2" = "$3" ] && ok || bad "$1: expected '$3', got '$2'"; }
has() { grep -q -F -- "$2" "$3" && ok || bad "$1: '$2' not in $(basename "$3"): $(cat "$3")"; }
prop() { awk -v k="$1" 'index($0, k "=") == 1 { v = substr($0, length(k) + 2) } END { print v }' "$T/props"; }

TRAIN="$HERE/../known/372038420_train_netd.o"
FACTORY="$HERE/../known/371021120_factory_netd.o"
UNION="$HERE/../../tethering/netd_a52rb_train.o"   # what the ROM ships as a52_netd.o (TARGET_TETHERING_RESIGN_APEX=false)
OLD="$HERE/../../tethering/netd_a52.o"             # the pre-train frozen object (the 2026-10-10 failure)
for f in "$TRAIN" "$FACTORY" "$UNION" "$OLD"; do [ -f "$f" ] || { echo "missing $f"; exit 1; }; done
with_teth='<apex-info-list><apex-info moduleName="com.android.tethering" modulePath="/dev/block/dm-60" versionCode="372038420" isActive="true"/></apex-info-list>'
without_teth='<apex-info-list><apex-info moduleName="com.android.tzdata" modulePath="/dev/block/dm-61" versionCode="372000000" isActive="true"/></apex-info-list>'

run() { # live ours updated-xml
    : > "$T/props"; : > "$T/kmsg"; printf '%s\n' "$3" > "$T/updated.xml"
    K4TG_LIVE="$1" K4TG_OURS="$2" K4TG_UPDATED="$T/updated.xml" K4TG_KMSG="$T/kmsg" K4TG_PROPFILE="$T/props" \
        "$SH" "$SCRIPT" > "$T/out" 2>&1
    eq "exit status" "$?" 0
    [ -s "$T/out" ] && bad "printed: $(head -c 300 "$T/out")"
    $VERBOSE && { echo "--- [$CASE] kmsg"; cat "$T/kmsg"; echo "--- props"; cat "$T/props"; }
    return 0
}

CASE="shipped union a52_netd.o covers the 372038420 train: no gap, no property"
run "$TRAIN" "$UNION" "$with_teth"
has "kmsg" "updated Tethering: every map pin is in a52_netd.o" "$T/kmsg"
eq "no property" "$(prop sys.k4.tethering_gap)" ""

CASE="the pre-train object (netd_a52.o) under the train: the 2026-10-10 gap is reported and the revert requested"
run "$TRAIN" "$OLD" "$with_teth"
has "kmsg names the map" "netd_loopback_permission_enabled_map" "$T/kmsg"
has "kmsg asks for the revert" "asking apexd to revert this update" "$T/kmsg"
case "$(prop sys.k4.tethering_gap)" in *netd_loopback_permission_enabled_map*) ok ;; *) bad "property: '$(prop sys.k4.tethering_gap)'" ;; esac
[ "$(prop sys.k4.tethering_gap | wc -c)" -le 92 ] && ok || bad "property longer than 91 chars"

CASE="factory Tethering re-activated (rollback boot) under the union object: covered"
run "$FACTORY" "$UNION" "$with_teth"
has "kmsg" "every map pin is in a52_netd.o" "$T/kmsg"
eq "no property" "$(prop sys.k4.tethering_gap)" ""

CASE="a gap exists but Tethering was not part of this update boot: no verdict"
run "$TRAIN" "$OLD" "$without_teth"
has "kmsg" "Tethering not updated in this boot" "$T/kmsg"
eq "no property" "$(prop sys.k4.tethering_gap)" ""

CASE="unreadable live object: no verdict, no property"
run "$T/nonexistent.o" "$UNION" "$with_teth"
has "kmsg" "no verdict" "$T/kmsg"
eq "no property" "$(prop sys.k4.tethering_gap)" ""

CASE="an object without pin strings (empty file): no verdict"
: > "$T/empty.o"
run "$T/empty.o" "$UNION" "$with_teth"
has "kmsg" "no map pin list" "$T/kmsg"
eq "no property" "$(prop sys.k4.tethering_gap)" ""

CASE="same object on both sides: never a gap"
run "$TRAIN" "$TRAIN" "$with_teth"
eq "no property" "$(prop sys.k4.tethering_gap)" ""

echo "$PASS passed, $FAIL failed"
[ "$FAIL" = 0 ]
