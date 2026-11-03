#!/bin/bash
# Build netbpfload_a52 / netbpfload_a52b (the ROM's Tethering BPF loader) from the IchthysOS source tree and
# copy them with the three libraries they are linked against into this directory. Not run by the ROM build: run
# it by hand after changing NetBpfLoad.cpp, then `sha256sum ... > SHA256SUMS` (see customize.sh).
#
#   build_netbpfload.sh [<ichthys tree, default ~/git/android>]
#
# Provenance: AOSP packages/modules/Connectivity bpf/loader/NetBpfLoad.cpp of the IchthysOS tree (26Q2 release,
# the a52sxq bringup already relaxes the 25Q4 5.10 and 26Q4 5.15 kernel floors to 5.4 in source) plus
# netbpfload_a52.patch from this directory (kept as the diff against that tree):
#   * struct bpf_map_def of either layout: 192 bytes (<= 26Q3) or 180 bytes (the 26Q4 train 373041100 dropped
#     key_size/value_size/max_entries, libbpf takes them from the BTF .maps definition); the layout is taken from
#     the st_size of the object's *_def symbols, v2 records are widened to v1 with the sizes from libbpf's view of
#     the same object (readMapDefs), so offload/test/clatd/dscpPolicy.o of either generation load;
#   * an unknown layout is a logged load failure (-> bpfloader exit 38) instead of the silent SIGABRT of
#     getSectionByIdx() that caused the 2026-11-02 bpfloader-failed reboots;
#   * netd.o comes from /system: /system/etc/bpf/a52_netd.<active Tethering versionCode>.o when the ROM ships it,
#     else /system/etc/bpf/a52_netd.o (netdObjectPath(); the version is the one logApexVersion() already parses
#     from /proc/mounts), see regen.py for why one object cannot serve every train's userspace;
#   * the "object on another device than /proc/self/exe" check is a warning (we run from /system, the objects
#     live in the APEX).
# The binary is the module's own apex31 variant (cc_binary netbpfload, min_sdk 31, __ANDROID_APEX__), built as the
# explicit ninja output so no Android.bp change (and no soong re-analysis) is needed; it links libbase.so, libbpf.so,
# libc++.so and liblog.so. netbpfload_a52b is the same binary with the first three NEEDED names changed to
# libbasB.so / libbpB.so / libcBB.so (same-length names, patched in place), shipped together with the tree's own
# apex31 builds of those libraries under the new names, so the loader runs against the libraries it was built with
# whatever the ROM's /system/lib64 copies are (liblog's C ABI is stable). netbpfload_a52 (unrenamed) is kept for
# diagnostics only and is not installed.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
TREE="${1:-$HOME/git/android}"
V=android_arm64_armv8-a_apex31
BIN_REL="out/soong/.intermediates/packages/modules/Connectivity/bpf/loader/netbpfload/$V/netbpfload"   # ninja wants it relative
BIN="$TREE/$BIN_REL"
LIBBASE="$TREE/out/soong/.intermediates/system/libbase/libbase/android_arm64_armv8-a_shared_apex31/libbase.so"
LIBBPF="$TREE/out/soong/.intermediates/external/libbpf/libbpf/android_arm64_armv8-a_shared_apex31/libbpf.so"
LIBCXX="$TREE/out/target/product/a52sxq/apex/com.android.tethering/lib64/libc++.so"
cd "$TREE"
git -C packages/modules/Connectivity diff --quiet HEAD -- bpf/loader/NetBpfLoad.cpp && \
    echo "note: NetBpfLoad.cpp is unmodified in $TREE - apply $HERE/netbpfload_a52.patch first?" >&2
# the build wrapper (systemd scope, log .buildlogs/psu-netbpfload.log) - synchronous here
.buildlogs/build_ichthys.sh netbpfload "$BIN_REL"
grep -q '^EXIT=0$' .buildlogs/netbpfload.log || { echo "build failed, see $TREE/.buildlogs/netbpfload.log" >&2; exit 1; }
for f in "$BIN" "$LIBBASE" "$LIBBPF" "$LIBCXX"; do [ -f "$f" ] || { echo "missing $f" >&2; exit 1; }; done
cp -f "$BIN" "$HERE/netbpfload_a52"
python3 - "$HERE" "$BIN" "$LIBBASE" "$LIBBPF" "$LIBCXX" <<'PY'
import sys, os
here, binp, libbase, libbpf, libcxx = sys.argv[1:]
def rename(src, dst, pairs):
    b = open(src, "rb").read()
    for o, n in pairs:
        assert len(o) == len(n) and b.count(o) == 1, (src, o, b.count(o)); b = b.replace(o, n)
    open(os.path.join(here, dst), "wb").write(b); os.chmod(os.path.join(here, dst), 0o644)
rename(binp, "netbpfload_a52b", [(b"libbase.so\0", b"libbasB.so\0"), (b"libbpf.so\0", b"libbpB.so\0"), (b"libc++.so\0", b"libcBB.so\0")])
rename(libbase, "libbasB.so", [(b"libbase.so\0", b"libbasB.so\0"), (b"libc++.so\0", b"libcBB.so\0")])
rename(libbpf, "libbpB.so", [(b"libbpf.so\0", b"libbpB.so\0"), (b"libc++.so\0", b"libcBB.so\0")])
rename(libcxx, "libcBB.so", [(b"libc++.so\0", b"libcBB.so\0")])
print("wrote netbpfload_a52, netbpfload_a52b, libbasB.so, libbpB.so, libcBB.so")
PY
git -C packages/modules/Connectivity diff HEAD -- bpf/loader/NetBpfLoad.cpp > "$HERE/netbpfload_a52.patch"
echo "patch: $HERE/netbpfload_a52.patch ($(git -C packages/modules/Connectivity rev-parse --short HEAD) + $(wc -l < "$HERE/netbpfload_a52.patch") lines)"
echo "now: cd $HERE && sha256sum netbpfload_a52 netbpfload_a52b libbpf.so libbasB.so libcBB.so libbpB.so netd_a52*.o com.google.android.tethering.apex > SHA256SUMS"
