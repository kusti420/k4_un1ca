#!/usr/bin/env python3
# Does our BPF loader + our netd.o objects load what every Tethering version we know about needs?
#
#   check_netd.py <a52_netd.o> <known netd.o>...    exit 0: all covered; 1: something missing (printed)
#       a52_netd.<versionCode>.o files next to a52_netd.o are the version-specific objects the loader prefers for
#       that Tethering version (NetBpfLoad.cpp netdObjectPath()); each known train is checked against the object the
#       loader would pick for it, and every such object gets the program/loadability checks too.
#   check_netd.py --list <known netd.o>...          prints the /system/etc/bpf/a52_netd.known lines:
#       "<set sha256> <netd.o sha256> Tethering <versionCode> (<label>)", set sha256 = sha256 of the five lines
#       "<sha256 of X.o>\n" for X = netd offload test clatd dscpPolicy (k4-mainline-diag computes the same on the phone,
#       so a train that only changes offload.o is not mistaken for a verified one)
#
# Our loader (netbpfload_a52b) never loads the APEX's own netd.o but /system/etc/bpf/a52_netd.<active version>.o, or
# /system/etc/bpf/a52_netd.o when there is none, whatever Tethering APEX is active. The APEX's userspace
# (libservice-connectivity.so in system_server, libnetd_updatable.so in netd) opens the map and program pins its own
# netd.o defines and abort()s when one is missing or sized differently -> crash loop -> apexd reverts the update (a
# staged boot) or, after a ROM flash under an already active train, a real boot loop. So the object chosen for a
# version must define:
#   * every map of that netd.o with an identical bpf_map_def (layout-independent fields plus key/value size and
#     max_entries - struct bpf_map_def is 192 bytes up to 26Q3 and 180 since the 26Q4 train 373041100, bpf_union.py;
#     ringbuf maps: min_kver may be lowered to 5.4, regen.py does that on purpose; maps both sides only create on
#     >= 5.10, e.g. sk_storage, may differ), and
#   * every program pin that netd.o would pin on this kernel at API 37.
# Known objects live in known/ as <versionCode>_<label>_netd.o (the factory one and each Play train's, pulled from
# /apex/com.android.tethering/etc/bpf/mainline/netd.o or /cache/k4_mainline/failed_staged_tethering_netd.o).
#
# The other objects the frozen loader loads come from the ACTIVE APEX itself (loadAllObjects in netbpfload 371021120,
# same order: offload.o test.o clatd.o dscpPolicy.o netd.o; the @funcs.o variants only on >= 6.6.118 kernels). Each
# is critical: a map the kernel cannot create or a non-optional program the kernel rejects fails the whole load ->
# bpfloader reboot_on_failure -> reboot,bpfloader-failed loop. So every known entry also needs its
# <versionCode>_<label>_<obj>.o for each of those objects, and for each of them the loader's own rules are replayed
# for 5.4.302 at API 37 (kver/api windows of every map and program), plus what this kernel can execute:
#   * every map it would create has a map type this kernel build registers (MAP_TYPES below),
#   * every program it would load has a program type this build registers and only 5.4 instructions/helpers (no kfuncs, no cpu v4 /
#     5.12+ atomics; helpers: only those its program type's get_func_proto chain returns in this build, PROG_HELPERS
#     below - e.g. tc programs get no get_current_pid_tgid (14); overall only 1..110 and the backported 125
#     ktime_get_boot_ns exist, 111..124 are only named in the uapi enum),
#     else the load fails - except for an optional program in offload.o, the only object the frozen loader loads
#     without libbpf on 5.4 (loadObject(offload.o, libbpf = kernel >= 5.10)), which is skipped and stays unpinned,
#   * no in-window program of a libbpf-loaded object (test/clatd/dscpPolicy.o, a52_netd.o) is optional: the frozen
#     loader's libbpf path refuses those ("Optional program cannot be loaded by libbpf") and fails the object,
#   * no in-window program calls a kfunc/extern (src 1 call relocated to an undefined symbol) and, for offload.o, no
#     bpf-to-bpf call at all (the legacy loader links no subprograms); in libbpf objects the called .text
#     subprograms get the same instruction and map checks,
#   * no CO-RE relocations (.BTF.ext core_relo_len): libbpf resolves them against the running kernel's BTF, which
#     this check cannot replay (the legacy path does not apply them at all), so they are refused until reviewed,
#   * every relocation of an in-window program (and of the .text sub-programs it calls) is one its loader path
#     handles: ld_imm64 into .maps for a map created on 5.4.302 (else libbpf autocreate off / legacy fd -1 -> the
#     verifier rejects it), .rodata/.data/.bss only for libbpf objects (the legacy applyMapRelo ignores them),
#     no extern variables (__ksym needs BTF ids, 5.10), no sub-program addresses; calls only into .text, with a
#     relocation from a program section (libbpf 1.4 bpf_program__record_reloc / reloc_code) - checked before, and
#     independent of, the tolerated.txt pin filter below,
#   * every map/program pin it defines for API 37 (on any kernel) is created on 5.4.302 - unless the factory object
#     of the same name does not create it on 5.4.302 either (the factory userspace runs without it: e.g. dscpPolicy's
#     5.15+ program) or known/tolerated.txt lists it ("<obj> <pin>  # why", for a reviewed 5.10+-only addition).
#   * every map it creates and every program it loads pins (pin_location, and create_location when set) into a bpffs
#     directory the frozen loader creates: it mkdirs exactly LOADER_DIRS (netbpfload_a52b: the six createDir() calls
#     at 0xaac4..0xab24 into the mkdir() wrapper at 0xf1e8) and bpfFdPin()/renameat2() create no parent, so any other
#     directory is ENOENT (load fails) - a newer loader that adds a directory (as T added net_shared, U loader) and
#     a train pinning into it would loop on ours,
#   * struct bpf_map_def is one of the two layouts the loader reads (192/180, by the _def symbols' st_size) and
#     struct bpf_prog_def is 180 bytes, a license section exists.
# The same instruction checks also run on the programs a52_netd.o itself loads.
# Also refused: a code section name with a second '/' (readCodeSections abort()s), a libbpf object whose .android_maps
# entry has no .maps map ("bpf_object does not contain map") or whose .maps map has no .android_maps entry (created
# unchecked), legacy (offload.o) relocations not in the section right after their code (loadProg reads only i + 1),
# may_goto (6.9).
# Necessary, not sufficient - not modelled: map flags other than MMAPABLE (e.g. BPF_F_INNER_MAP is 5.10), helpers a
# program type only gets for some attach types (counted as available), verifier complexity limits, pin collisions
# between objects, a legacy-path object without .BTF or a libbpf object without .android_maps. None occurs in the
# known objects; the factory objects running on the phone are the real proof, a new train still needs its first
# update boot watched (k4-mainline-diag).
import hashlib, os, re, struct, sys
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "tethering"))
from bpf_union import Elf, Btf, map_defs, map_rec_size, MAP_LAYOUTS, M_SZ

KV = lambda a, b, c: (a << 24) | (b << 16) | c
KERNEL = KV(5, 4, 302)          # bone-machine 5.4.302
API = 3700                      # Android 17 (sdk_full 37.0 -> netbpfload api 3700)
P_SZ = 180                      # struct bpf_prog_def (struct bpf_map_def: bpf_union.MAP_LAYOUTS)
RINGBUF = 27
LOADER_OBJS = ("offload", "test", "clatd", "dscpPolicy")   # loaded from the active APEX's etc/bpf/mainline/
NON_LIBBPF = {"offload"}        # loadObject(offload.o, libbpf=false): BTF only sanitized by sanitizeBtf()
# What this kernel build (bone-machine 5.4.302 + its .config, as running on the phone) registers: map types and program
# types from include/linux/bpf_types.h under that .config (e.g. no SOCKMAP/SOCKHASH: CONFIG_BPF_STREAM_PARSER is off;
# no LIRC_MODE2; STRUCT_OPS 26 is only an enum placeholder of the k4 ringbuf backport; RINGBUF 27 is registered).
# Regenerate with gen_kernel_bpf.py after a kernel or .config change.
# --- generated by gen_kernel_bpf.py (kernel 302, .config sha256 d911857299e72f2d...) ---
MAP_TYPES = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 19, 20, 21, 22, 23, 24, 25, 27}
PROG_HELPERS = {   # program type -> helper ids its get_func_proto chain returns
    1: {1, 2, 3, 5, 6, 7, 8, 12, 25, 26, 42, 46, 47, 68, 87, 88, 89, 93, 94, 125},   # BPF_PROG_TYPE_SOCKET_FILTER (sk_filter_func_proto); attach-type/condition dependent: []
    2: {1, 2, 3, 4, 5, 6, 7, 8, 12, 14, 15, 16, 22, 25, 27, 35, 36, 37, 42, 45, 55, 67, 80, 87, 88, 89, 109, 125},   # BPF_PROG_TYPE_KPROBE (kprobe_prog_func_proto); attach-type/condition dependent: []
    3: {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 17, 18, 19, 20, 21, 23, 24, 25, 26, 28, 29, 30, 31, 32, 33, 34, 38, 39, 40, 41, 42, 43, 46, 47, 48, 50, 66, 68, 69, 79, 83, 84, 85, 86, 87, 88, 89, 93, 94, 95, 96, 97, 98, 99, 100, 107, 108, 110, 125},   # BPF_PROG_TYPE_SCHED_CLS (tc_cls_act_func_proto); attach-type/condition dependent: []
    4: {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 17, 18, 19, 20, 21, 23, 24, 25, 26, 28, 29, 30, 31, 32, 33, 34, 38, 39, 40, 41, 42, 43, 46, 47, 48, 50, 66, 68, 69, 79, 83, 84, 85, 86, 87, 88, 89, 93, 94, 95, 96, 97, 98, 99, 100, 107, 108, 110, 125},   # BPF_PROG_TYPE_SCHED_ACT (tc_cls_act_func_proto); attach-type/condition dependent: []
    5: {1, 2, 3, 4, 5, 6, 7, 8, 12, 14, 15, 16, 22, 25, 27, 35, 36, 37, 42, 45, 67, 80, 87, 88, 89, 109, 125},   # BPF_PROG_TYPE_TRACEPOINT (tp_prog_func_proto); attach-type/condition dependent: []
    6: {1, 2, 3, 5, 6, 7, 8, 12, 23, 25, 28, 42, 44, 51, 54, 65, 69, 84, 85, 86, 87, 88, 89, 93, 94, 99, 100, 110, 125},   # BPF_PROG_TYPE_XDP (xdp_func_proto); attach-type/condition dependent: []
    7: {1, 2, 3, 4, 5, 6, 7, 8, 12, 14, 15, 16, 22, 25, 27, 35, 36, 37, 42, 45, 56, 67, 80, 87, 88, 89, 109, 125},   # BPF_PROG_TYPE_PERF_EVENT (pe_prog_func_proto); attach-type/condition dependent: []
    8: {1, 2, 3, 5, 6, 7, 8, 12, 25, 26, 42, 46, 47, 68, 79, 81, 87, 88, 89, 93, 94, 95, 96, 97, 98, 107, 108, 125},   # BPF_PROG_TYPE_CGROUP_SKB (cg_skb_func_proto); attach-type/condition dependent: []
    9: {1, 2, 3, 5, 6, 7, 8, 42, 12, 15, 81, 125, 87, 88, 89, 93, 94},   # BPF_PROG_TYPE_CGROUP_SOCK (sock_filter_func_proto); attach-type/condition dependent: []
    10: {1, 2, 3, 5, 6, 7, 8, 12, 17, 24, 25, 26, 28, 33, 34, 39, 42, 73, 87, 88, 89, 93, 94, 125},   # BPF_PROG_TYPE_LWT_IN (lwt_in_func_proto); attach-type/condition dependent: []
    11: {1, 2, 3, 5, 6, 7, 8, 12, 17, 24, 25, 26, 28, 33, 34, 39, 42, 87, 88, 89, 93, 94, 125},   # BPF_PROG_TYPE_LWT_OUT (lwt_out_func_proto); attach-type/condition dependent: []
    12: {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 17, 20, 21, 23, 24, 25, 26, 28, 29, 30, 33, 34, 38, 39, 40, 41, 42, 43, 73, 87, 88, 89, 93, 94, 125},   # BPF_PROG_TYPE_LWT_XMIT (lwt_xmit_func_proto); attach-type/condition dependent: []
    13: {1, 2, 3, 5, 6, 7, 8, 12, 25, 42, 46, 49, 53, 57, 59, 70, 81, 87, 88, 89, 93, 94, 96, 107, 108, 125},   # BPF_PROG_TYPE_SOCK_OPS (sock_ops_func_proto); attach-type/condition dependent: []
    14: {1, 2, 3, 5, 6, 7, 8, 9, 12, 25, 26, 38, 39, 42, 43, 46, 47, 52, 72, 84, 85, 86, 87, 88, 89, 93, 94, 99, 125},   # BPF_PROG_TYPE_SK_SKB (sk_skb_func_proto); attach-type/condition dependent: []
    15: {1, 2, 3, 6, 15, 80, 81, 87, 88, 89},   # BPF_PROG_TYPE_CGROUP_DEVICE (cgroup_dev_func_proto); attach-type/condition dependent: [6]
    16: {1, 2, 3, 5, 6, 7, 8, 12, 42, 60, 61, 62, 63, 71, 87, 88, 89, 90, 91, 93, 94, 125},   # BPF_PROG_TYPE_SK_MSG (sk_msg_func_proto); attach-type/condition dependent: []
    17: {1, 2, 3, 4, 5, 6, 7, 8, 12, 14, 15, 16, 22, 25, 27, 35, 36, 37, 42, 45, 67, 80, 87, 88, 89, 109, 125},   # BPF_PROG_TYPE_RAW_TRACEPOINT (raw_tp_prog_func_proto); attach-type/condition dependent: []
    18: {1, 2, 3, 5, 6, 7, 8, 12, 15, 42, 46, 64, 81, 84, 85, 86, 87, 88, 89, 93, 94, 99, 107, 108, 125},   # BPF_PROG_TYPE_CGROUP_SOCK_ADDR (sock_addr_func_proto); attach-type/condition dependent: [64]
    19: {1, 2, 3, 5, 6, 7, 8, 12, 17, 24, 25, 26, 28, 33, 34, 39, 42, 87, 88, 89, 93, 94, 125},   # BPF_PROG_TYPE_LWT_SEG6LOCAL (lwt_seg6local_func_proto); attach-type/condition dependent: []
    21: {1, 2, 3, 68, 5, 6, 7, 8, 42, 12, 82, 125, 87, 88, 89, 26, 93, 94},   # BPF_PROG_TYPE_SK_REUSEPORT (sk_reuseport_func_proto); attach-type/condition dependent: []
    22: {1, 2, 3, 5, 6, 7, 8, 42, 12, 125, 87, 88, 89, 26, 93, 94},   # BPF_PROG_TYPE_FLOW_DISSECTOR (flow_dissector_func_proto); attach-type/condition dependent: []
    23: {1, 2, 3, 101, 6, 102, 103, 104, 105, 106, 15, 80, 81, 87, 88, 89},   # BPF_PROG_TYPE_CGROUP_SYSCTL (sysctl_func_proto); attach-type/condition dependent: [6]
    24: {1, 2, 3, 4, 5, 6, 7, 8, 12, 14, 15, 16, 22, 25, 27, 35, 36, 37, 42, 45, 67, 80, 87, 88, 89, 109, 125},   # BPF_PROG_TYPE_RAW_TRACEPOINT_WRITABLE (raw_tp_prog_func_proto); attach-type/condition dependent: []
    25: {96, 1, 2, 3, 6, 107, 108, 15, 80, 81, 87, 88, 89},   # BPF_PROG_TYPE_CGROUP_SOCKOPT (cg_sockopt_func_proto); attach-type/condition dependent: [6]
}
# --- end of generated block ---
MAX_BTF_KIND = 15               # DATASEC; FLOAT/DECL_TAG/TYPE_TAG/ENUM64 are 5.13+
LOADER_DIRS = {"/sys/fs/bpf/" + d for d in ("tethering", "netd_shared", "netd_readonly", "net_shared", "net_private",
                                         "loader")}
HERE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "known")


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


def in_window(mk, xk, ma, xa): return mk <= KERNEL < xk and ma <= API < xa


def insn_problems(code, ptype):
    """features of a BPF program of type ptype that this kernel does not have (empty list: fine)"""
    bad, i = set(), 0
    while i + 8 <= len(code):
        op, regs = code[i], code[i + 1]; off, imm = struct.unpack_from("<hi", code, i + 2)
        cls, src = op & 7, regs >> 4
        if op == 0x18:                                   # ld_imm64: 2 slots; 1 map fd / 2 map value are fine
            if src not in (0, 1, 2): bad.add(f"ld_imm64 pseudo {src}")
            i += 16; continue
        if op == 0x85:
            if src == 0 and imm not in PROG_HELPERS.get(ptype, ()): bad.add(f"helper {imm} (not offered to program type {ptype})")
            elif src == 2: bad.add("kfunc call")
        elif cls == 1 and op & 0xE0 == 0x80: bad.add("sign-extending load (6.6)")
        elif cls == 3 and op & 0xE0 == 0xC0 and imm != 0: bad.add(f"atomic op {imm:#x} (5.12)")
        elif cls in (4, 7) and op & 0xF0 in (0x30, 0x90) and off: bad.add("signed div/mod (6.6)")
        elif cls in (4, 7) and op & 0xF0 == 0xB0 and off: bad.add("movsx (6.6)")
        elif op == 0xD7: bad.add("bswap (6.6)")
        elif cls == 6 and op & 0xF0 == 0: bad.add("gotol (6.6)")
        elif op == 0xE5: bad.add("may_goto (6.9)")
        i += 8
    return sorted(bad)


def pin_dirs(r, create_at, pin_at):
    """the first directory of a def record's create_location/pin_location the loader does not create, or None"""
    return bad_pin_dir(*(r[a:a + 70].split(b"\0")[0].decode() for a in (create_at, pin_at)))


def bad_pin_dir(*locs):
    for loc in locs:
        if loc and os.path.dirname(loc) not in LOADER_DIRS: return os.path.dirname(loc)
    return None


def relocs(e, syms, si):
    """insn offset -> (symbol name, symbol's section name ("" = undefined), symbol value) for code section si"""
    out = {}
    for ri in e.rels_for(si):
        d = e.sh[ri]["data"]
        for i in range(0, len(d), 16):
            off, info = struct.unpack_from("<QQ", d, i); sym = syms[info >> 32]
            out[off] = (sym[1], e.names[sym[4]] if 0 < sym[4] < len(e.names) else "", sym[5])
    return out


def code_problems(e, syms, si, typ, libbpf, maps_made, maps_all, seen=None):
    """relocations and bpf-to-bpf calls of code section si, replayed the way the object's loader path handles them
    (libbpf 1.4 bpf_program__record_reloc / bpf_object__reloc_code, or the legacy applyMapRelo), plus the
    instruction checks of every .text sub-program it reaches"""
    seen = set() if seen is None else seen; seen.add(si)
    code = bytes(e.sh[si]["data"]); rels = relocs(e, syms, si); why = []
    ti = e.idx(".text") if e.has(".text") else None
    if e.names[si] == ".text": why += [f".text: {q}" for q in insn_problems(code, typ)]
    i = 0
    while i + 8 <= len(code):
        op, src = code[i], code[i + 1] >> 4; imm, = struct.unpack_from("<i", code, i + 4)
        r = rels.get(i)
        if op == 0x85 and src == 1:                      # bpf-to-bpf (or, relocated to an undefined symbol, kfunc)
            if r and r[1] == "": why.append(f"kfunc/extern call {r[0] or '?'}")
            elif not libbpf: why.append("bpf-to-bpf call (the legacy loader links no subprograms)")
            elif r and r[1] != ".text": why.append(f"call relocated into section {r[1]} (libbpf: bad call relo)")
            else:
                # with a relocation: .text offset sym_value/8 + imm + 1; without: only valid inside .text itself
                tgt = (r[2] // 8 + imm + 1) if r else (i // 8 + imm + 1 if si == ti else None)
                tsz = e.sh[ti]["size"] // 8 if ti is not None else 0
                if tgt is None or not 0 <= tgt < tsz:
                    why.append("sub-program call without a .text target (libbpf: no .text section found yet "
                               "sub-program call exists)")
                elif ti not in seen:
                    why += code_problems(e, syms, ti, typ, libbpf, maps_made, maps_all, seen)
        elif r and op == 0x18:                           # ld_imm64 with a relocation
            name, sec, _ = r
            if sec == ".maps":
                if name not in maps_made:
                    why.append(f"uses map {name}, which " + ("is not created on 5.4.302" if name in maps_all
                                                             else "has no .android_maps definition"))
            elif sec == "": why.append(f"extern variable {name} (__ksym/__kconfig: not verified for 5.4)")
            elif re.match(r"\.(rodata|data|bss)\b", sec):
                if not libbpf: why.append(f"global data relocation into {sec} (the legacy loader ignores it)")
            elif sec == ".text": why.append("sub-program address (callback, 5.13)")
            else: why.append(f"relocation into section {sec}")
        elif r:
            why.append(f"relocation on a non-call, non-ld_imm64 instruction (libbpf: invalid relo)")
        i += 16 if op == 0x18 else 8
    return why


def parse_obj(path):
    """what the frozen loader does with this object on KERNEL at API: (problems, required pins, created pins)"""
    e = Elf(open(path, "rb").read()); probs = []
    libbpf = os.path.basename(path).rsplit("_", 1)[-1][:-2] not in NON_LIBBPF
    if not e.has("license"): probs.append("no license section (loader aborts)")
    syms = list(e.syms())
    def def_sizes(sec):
        si = e.idx(sec)
        return {s[6] for s in syms if s[4] == si and s[1].endswith("_def")}
    req, made = set(), set()
    maps_made, maps_all = set(), set()                   # map names (the .maps symbol / pin suffix)
    for n in e.names:                                    # readCodeSections: abort() on a second '/' in any code section
        if not n.startswith(".") and n.count("/") > 1: probs.append(f"section {n} has more than one '/' (loader aborts)")
    if e.has(".android_maps"):
        try:
            msz = map_rec_size(e)
        except AssertionError as x:
            return [f"struct bpf_map_def layout is none the loader knows ({'/'.join(map(str, MAP_LAYOUTS))} bytes): {x}"], req, made
        if def_sizes(".android_maps") - {msz}:
            return [f"struct bpf_map_def symbols are {def_sizes('.android_maps')} bytes, records {msz} (loader would misread every map)"], req, made
        for name, (_, m) in map_defs(e).items():    # v2 records: key/value/max_entries from the BTF .maps definition
            pin = m.pin_path
            maps_all.add(name)
            if m.min_api <= API < m.max_api: req.add(pin)
            if not in_window(m.min_kver, m.max_kver, m.min_api, m.max_api): continue
            bad_dir = bad_pin_dir(m.create_path, pin)
            if bad_dir: probs.append(f"map {pin}: pins into {bad_dir}, which the frozen loader does not create (load fails)")
            elif m.type not in MAP_TYPES: probs.append(f"map {pin}: type {m.type} is not registered in this kernel build (load fails)")
            else: made.add(pin); maps_made.add(name)
    if libbpf:                                           # prepareLoadMaps: every .android_maps entry needs its .maps map
        mi = e.idx(".maps") if e.has(".maps") else None
        in_maps = {s[1] for s in syms if mi is not None and s[4] == mi}
        for name in sorted(maps_all - in_maps):
            probs.append(f"map {name} has no .maps (libbpf) definition (\"bpf_object does not contain map\", load fails)")
        for name in sorted(in_maps - maps_all):          # libbpf would create it unchecked (type, pin) - refuse
            probs.append(f"map {name} is only in .maps, not in .android_maps (created by libbpf unchecked, not verified)")
    if e.has(".android_progs"):
        pi = e.idx(".android_progs"); d = e.sh[pi]["data"]
        if len(d) % P_SZ or def_sizes(".android_progs") - {P_SZ}:
            return probs + [f"struct bpf_prog_def is not {P_SZ} bytes (loader would misread every program)"], req, made
        defs = {s[1]: s[5] for s in syms if s[4] == pi}
        code = {}                                        # prog def offset -> code section (readCodeSections)
        for si, n in enumerate(e.names):
            if n.startswith(".") or "/" not in n or not e.sh[si]["size"]: continue
            f = [s[1] for s in syms if s[4] == si and s[2] & 0xF == 2]
            assert f and f[0] + "_def" in defs, (path, n, "no program definition")
            code[defs[f[0] + "_def"]] = (n, bytes(e.sh[si]["data"]), si)
        if not libbpf:                                   # legacy loadProg takes relocations only from section i + 1
            for si, n in enumerate(e.names):
                if n.startswith(".") or "/" not in n or not e.sh[si]["size"]: continue
                for ri in e.rels_for(si):
                    if ri != si + 1 or e.names[ri] != ".rel" + n:
                        probs.append(f"relocations of {n} are in section #{ri} {e.names[ri]}, not right after it "
                                     f"(the legacy loader would not apply them, load fails)")
        for o in range(0, len(d), P_SZ):
            r = bytes(d[o:o + P_SZ]); typ, = struct.unpack_from("<I", r, 0); opt = r[24]
            mink, maxk = struct.unpack_from("<2I", r, 16); mina, maxa = struct.unpack_from("<2i", r, 28)
            pin = r[106:176].split(b"\0")[0].decode()
            if mina <= API < maxa: req.add(pin)
            if not in_window(mink, maxk, mina, maxa) or o not in code: continue
            why = ([f"program type {typ} (not built into this kernel)"] if typ not in PROG_HELPERS else []) + insn_problems(code[o][1], typ)
            bad_dir = pin_dirs(r, 36, 106)
            if bad_dir:
                probs.append(f"program {pin}: pins into {bad_dir}, which the frozen loader does not create (load fails)")
                continue
            why += code_problems(e, syms, code[o][2], typ, libbpf, maps_made, maps_all)
            if libbpf and opt:
                probs.append(f"program {pin} ({code[o][0]}) is optional: the frozen loader's libbpf path refuses "
                             f"optional programs (load fails)")
            elif not why: made.add(pin)
            elif libbpf or not opt:
                probs.append(f"program {pin} ({code[o][0]}) would be rejected by 5.4: {', '.join(why)} (load fails)")
    if e.has(".BTF.ext"):
        x = bytes(e.sh[e.idx(".BTF.ext")]["data"]); hl, = struct.unpack_from("<I", x, 4)
        if hl >= 32 and struct.unpack_from("<I", x, 28)[0]:
            probs.append("CO-RE relocations (.BTF.ext core_relo_len > 0): resolved against the kernel BTF at load "
                         "time, not verifiable here (load not verified)")
    btf = Btf(bytes(e.sh[e.idx(".BTF")]["data"])) if e.has(".BTF") else None
    kinds = sorted({t[0] for t in btf.types[1:] if t[0] > MAX_BTF_KIND}) if btf else []
    if kinds and not libbpf:
        probs.append(f"BTF kinds {kinds} unknown to 5.4 and not sanitized on this path (load fails)")
    elif kinds:
        print(f"note: {path}: BTF kinds {kinds} (libbpf sanitizes them on 5.4)")
    return probs, req, made


if sys.argv[1] == "--list":
    sets = {}                                            # one line per distinct object set (a train may reship them)
    for k in sys.argv[2:]:
        ver, lab = label(k); d = os.path.dirname(os.path.abspath(k))
        hs = [hashlib.sha256(open(k if o == "netd" else os.path.join(d, f"{ver}_{lab}_{o}.o"), "rb").read()).hexdigest()
              for o in ("netd",) + LOADER_OBJS]
        whole = hashlib.sha256("".join(h + "\n" for h in hs).encode()).hexdigest()
        sets.setdefault((whole, hs[0]), []).append(f"Tethering {ver} ({lab})")
    for (whole, netd), labs in sets.items():
        print(whole, netd, " = ".join(labs))
    sys.exit(0)

# --- our objects: a52_netd.o and the a52_netd.<versionCode>.o next to it, each checked like the loader objects -----
OURS_DIR = os.path.dirname(os.path.abspath(sys.argv[1]))
ours = {}                                                # path -> (map defs, program pins loaded on this kernel)
bad = 0
def our_obj(path):
    if path not in ours:
        for p in parse_obj(path)[0]:
            print(f"{os.path.basename(path)}: {p}"); globals()["bad"] += 1
        e = Elf(open(path, "rb").read()); ours[path] = (map_defs(e), loaded(prog_pins(e)))
    return ours[path]
def obj_for(ver):
    """the object the loader loads while Tethering <ver> is active (NetBpfLoad.cpp netdObjectPath())"""
    v = os.path.join(OURS_DIR, f"a52_netd.{ver}.o")
    return v if os.path.exists(v) else sys.argv[1]
our_obj(sys.argv[1])
for k in sys.argv[2:]:
    ver, lab = label(k)
    opath = obj_for(ver); oname = os.path.basename(opath); om, op = our_obj(opath)
    e = Elf(open(k, "rb").read())
    km, kp = map_defs(e), loaded(prog_pins(e))
    before = bad
    for name, (_, b) in sorted(km.items()):
        if name not in om:
            print(f"Tethering {ver} ({lab}): map {name} missing from {oname}"); bad += 1; continue
        a = om[name][1]
        ac, bc = bytearray(a.canon()), bytearray(b.canon())   # layout-independent fields; min_kver at 28 there
        if b.type == RINGBUF and a.min_kver <= b.min_kver:
            ac[28:32] = bc[28:32]
        if (ac != bc or a.sizes != b.sizes) and not (a.min_kver > KERNEL and b.min_kver > KERNEL):
            diff = [i for i in range(len(ac)) if ac[i] != bc[i]]
            print(f"Tethering {ver} ({lab}): map {name} defined differently in {oname} "
                  f"(key/value/max {a.sizes} vs {b.sizes}, differing bytes {diff[:8]})"); bad += 1
    for pin in sorted(kp - op):
        print(f"Tethering {ver} ({lab}): program {pin} would not be pinned by {oname}"); bad += 1
    if bad == before:
        print(f"Tethering {ver} ({lab}): {oname}: {len(km)} maps, {len(kp)} programs covered")
for f in sorted(os.listdir(OURS_DIR)):                   # a versioned object no known train uses is a stale leftover
    m = re.fullmatch(r"a52_netd\.(\d+)\.o", f)
    if m and not any(label(k)[0] == m.group(1) for k in sys.argv[2:]):
        print(f"{f}: no known Tethering {m.group(1)} (add known/{m.group(1)}_train_*.o or drop the object)"); bad += 1

# --- the objects the loader takes from the active APEX ----------------------------------------------------------
known = {label(k): os.path.dirname(os.path.abspath(k)) for k in sys.argv[2:]}
factory = [vl for vl in known if vl[1] == "factory"]
if len(factory) != 1:
    print(f"known/: exactly one *_factory_netd.o needed as the baseline, got {len(factory)}"); bad += 1
tolerated, used = set(), set()
tol = os.path.join(os.path.dirname(os.path.abspath(sys.argv[2])) if sys.argv[2:] else HERE, "tolerated.txt")
if os.path.exists(tol):
    for line in open(tol):
        f = line.split("#", 1)[0].split()
        if not f: continue
        if len(f) != 2 or f[0] not in LOADER_OBJS or not f[1].startswith("/sys/fs/bpf/"):
            print(f"known/tolerated.txt: bad line {line.strip()!r} - format: <{'|'.join(LOADER_OBJS)}> <full pin path>  # why")
            bad += 1; continue
        tolerated.add(tuple(f))
base = {}
for ver, lab in factory + sorted(set(known) - set(factory)):
    before, n = bad, 0
    for obj in LOADER_OBJS:
        p = os.path.join(known[(ver, lab)], f"{ver}_{lab}_{obj}.o")
        if not os.path.exists(p):
            print(f"Tethering {ver} ({lab}): known/{os.path.basename(p)} missing - copy it from that APEX's "
                  f"etc/bpf/mainline/{obj}.o (or /cache/k4_mainline/failed_staged_tethering_{obj}.o)"); bad += 1; continue
        probs, req, made = parse_obj(p)
        missing = req - made
        if lab == "factory": base[obj] = missing
        for q in probs:
            print(f"Tethering {ver} ({lab}) {obj}.o: {q}"); bad += 1
        for pin in sorted(missing - base.get(obj, set())):
            if (obj, pin) in tolerated: used.add((obj, pin)); continue
            print(f"Tethering {ver} ({lab}) {obj}.o: pin gap: {pin} is defined for API {API} but not created on 5.4.302 "
                  f"(the factory one is), so that train's userspace may abort. Not a load failure: review it, and only if "
                  f"the userspace copes without it add this line to known/tolerated.txt: {obj} {pin}  # <why>"); bad += 1
        n += len(made)
    if bad == before:
        print(f"Tethering {ver} ({lab}): {', '.join(o + '.o' for o in LOADER_OBJS)} load on 5.4.302 at API {API} ({n} pins)")
for obj, pin in sorted(tolerated - used):
    print(f"note: known/tolerated.txt: '{obj} {pin}' matches no pin gap any more - remove it")
sys.exit(1 if bad else 0)
