#!/usr/bin/env python3
# Does our frozen BPF object satisfy the userspace of every Tethering version we know about?
#
#   check_netd.py <a52_netd.o> <known netd.o>...    exit 0: all covered; 1: something missing (printed)
#   check_netd.py --list <known netd.o>...          prints "<sha256> <label>" lines for /system/etc/bpf/a52_netd.known
#
# Our loader (netbpfload_a52*) only ever loads /system/etc/bpf/a52_netd.o, whatever Tethering APEX is active. The
# APEX's userspace (libservice-connectivity.so in system_server, libnetd_updatable.so in netd) opens the map and
# program pins its own netd.o defines and abort()s when one is missing -> crash loop -> apexd reverts the update (a
# staged boot) or, after a ROM flash under an already active train, a real boot loop. So a52_netd.o must define:
#   * every map of every known netd.o with an identical bpf_map_def (ringbuf maps: min_kver may be lowered to 5.4,
#     regen.py does that on purpose; maps both sides only create on >= 5.10, e.g. sk_storage, may differ), and
#   * every program pin a known netd.o would pin on this kernel at API 37.
# Known objects live in known/ as <versionCode>_<label>_netd.o (the factory one and each Play train's, pulled from
# /apex/com.android.tethering/etc/bpf/mainline/netd.o or /cache/k4_mainline/staged_tethering_netd.o).
import hashlib, os, re, struct, sys
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "tethering"))
from bpf_union import Elf, map_defs

KV = lambda a, b, c: (a << 24) | (b << 16) | c
KERNEL = KV(5, 4, 302)          # bone-machine 5.4.302
API = 3700                      # Android 17 (sdk_full 3700000 -> netbpfload api 3700)
P_SZ = 180                      # struct bpf_prog_def
RINGBUF = 27


def label(path):
    m = re.fullmatch(r"(\d+)_(.+)_netd\.o", os.path.basename(path))
    assert m, f"{path}: name it <versionCode>_<label>_netd.o"
    return m.group(1), m.group(2)


def prog_pins(e):
    """pin -> [(min_kver, max_kver, min_api, max_api)] from .android_progs"""
    d = e.sh[e.idx(".android_progs")]["data"]; assert len(d) % P_SZ == 0
    out = {}
    for o in range(0, len(d), P_SZ):
        r = bytes(d[o:o + P_SZ])
        mink, maxk = struct.unpack_from("<2I", r, 16); mina, maxa = struct.unpack_from("<2i", r, 28)
        out.setdefault(r[106:176].split(b"\0")[0].decode(), []).append((mink, maxk, mina, maxa))
    return out


def loaded(pins):
    return {p for p, v in pins.items() if any(mk <= KERNEL < xk and ma <= API < xa for mk, xk, ma, xa in v)}


if sys.argv[1] == "--list":
    for k in sys.argv[2:]:
        ver, lab = label(k)
        print(hashlib.sha256(open(k, "rb").read()).hexdigest(), f"Tethering {ver} ({lab})")
    sys.exit(0)

ours = Elf(open(sys.argv[1], "rb").read())
om, op = map_defs(ours), loaded(prog_pins(ours))
bad = 0
for k in sys.argv[2:]:
    ver, lab = label(k)
    e = Elf(open(k, "rb").read())
    km, kp = map_defs(e), loaded(prog_pins(e))
    before = bad
    for name, (_, rec) in sorted(km.items()):
        if name not in om:
            print(f"Tethering {ver} ({lab}): map {name} missing from a52_netd.o"); bad += 1; continue
        a, b = bytearray(om[name][1]), bytearray(rec)
        kv_a, kv_b = struct.unpack_from("<I", a, 40)[0], struct.unpack_from("<I", b, 40)[0]
        if struct.unpack_from("<I", b, 0)[0] == RINGBUF and kv_a <= kv_b:
            a[40:44] = b[40:44]
        if a != b and not (kv_a > KERNEL and kv_b > KERNEL):
            diff = [i for i in range(len(a)) if a[i] != b[i]]
            print(f"Tethering {ver} ({lab}): map {name} defined differently (bytes {diff[:8]})"); bad += 1
    for pin in sorted(kp - op):
        print(f"Tethering {ver} ({lab}): program {pin} would not be pinned by a52_netd.o"); bad += 1
    if bad == before:
        print(f"Tethering {ver} ({lab}): {len(km)} maps, {len(kp)} programs covered")
sys.exit(1 if bad else 0)
