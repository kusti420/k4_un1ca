#!/usr/bin/env python3
# Regenerate the tethering module's binaries from a source firmware's com.google.android.tethering APEX.
# Every patch site is located by pattern (strings / symbols / JNI table / BPF prog defs), never by fixed offsets,
# and every edit asserts the original instruction shape first. Not run by the build: run it by hand after a base
# switch, then update TETH_SRC's sha256 in customize.sh.
#
#   regen.py <tethering_compressed.apex> <out_dir> <keys_dir> <android_host_out> [--train-progs]
#            [<train tethering .apex | netd.o>...]
#
# Produces in out_dir: netbpfload_a52, netbpfload_a52b, libbpf.so, libbasB.so, libbpB.so, libcBB.so, netd_a52.o,
# netd_a52rb.o (default build: + ringbuf maps on 5.4, + the maps of every extra Tethering APEX given, see below),
# com.google.android.tethering.apex (re-signed with keys_dir, inner APKs PRESIGNED; only shipped with
# TARGET_TETHERING_RESIGN_APEX=true).
#
# The extra arguments are Google Play train Tethering APEXes (as pulled from /data/apex/active, or their
# etc/bpf/mainline/netd.o). Their userspace must find every map pin it opens, but our loader only ever loads our
# frozen a52_netd.o: bpf_union.py adds each map that a train's netd.o defines and ours does not (programs untouched).
# --train-progs also writes netd_a52rb_train.o: the reverse union (newest train's programs + maps, + the factory's).
# Current shipped netd_a52rb.o: + com.google.android.tethering 372038420
#   (apex sha256 6e1d70ee4d41b8537245c13564eb7f43c9948115a7aae9e5edf7527d29c480f4,
#    netd.o sha256 44151790d74e159bc7c3bc3c06a1219a993a153ff4cd7d44d7da7998193bccf2)
import hashlib, io, os, re, struct, subprocess, sys, tempfile, zipfile
from elftools.elf.elffile import ELFFile
from elftools.elf.relocation import RelocationSection
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM
from capstone.arm64 import ARM64_OP_IMM
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bpf_union import union

SRC, OUT, KEYS, HOST = sys.argv[1:5]
TRAIN_PROGS = "--train-progs" in sys.argv[5:]
TRAINS = [a for a in sys.argv[5:] if a != "--train-progs"]
assert TRAINS or not TRAIN_PROGS, "--train-progs needs a train APEX"
os.makedirs(OUT, exist_ok=True)
W = tempfile.mkdtemp(prefix="teth-regen-", dir=OUT)
md = Cs(CS_ARCH_ARM64, CS_MODE_ARM); md.detail = True
B_NOP = bytes.fromhex("1f2003d5")
MOVX_RET = bytes.fromhex("e0031faac0035fd6")   # mov x0, xzr; ret
MOVW_RET = bytes.fromhex("e0031f2ac0035fd6")   # mov w0, wzr; ret
RET_RET = bytes.fromhex("c0035fd6c0035fd6")

def sh(*a, **k): return subprocess.run(a, check=True, capture_output=True, text=True, **k).stdout

def text_insns(path):
    with open(path, "rb") as f:
        e = ELFFile(f)
        for s in e.iter_sections():
            if s["sh_flags"] & 4 and s["sh_type"] == "SHT_PROGBITS":
                yield from md.disasm(s.data(), s["sh_addr"])

def vaddr_to_off(path, va):
    with open(path, "rb") as f:
        for seg in ELFFile(f).iter_segments():
            if seg["p_type"] == "PT_LOAD" and seg["p_vaddr"] <= va < seg["p_vaddr"] + seg["p_filesz"]:
                return va - seg["p_vaddr"] + seg["p_offset"]
    raise KeyError(hex(va))

def str_start(data, needle):
    i = data.find(needle); assert i >= 0 and data.find(needle, i + 1) < 0, needle
    while i > 0 and data[i - 1] != 0: i -= 1
    return i

def xrefs(insns, target):
    """adrp+add pairs that materialise `target` (vaddr); returns address of the adrp."""
    out, pages = [], {}
    for ins in insns:
        if ins.mnemonic == "adrp":
            pages[ins.operands[0].reg] = (ins.operands[1].imm, ins.address)
        elif ins.mnemonic == "add" and len(ins.operands) == 3 and ins.operands[2].type == ARM64_OP_IMM:
            p = pages.get(ins.operands[1].reg)
            if p and p[0] + ins.operands[2].imm == target: out.append(p[1])
    return out

def patch(path, out, edits):
    b = bytearray(open(path, "rb").read())
    for off, old, new in edits:
        assert len(old) == len(new) and bytes(b[off:off + len(old)]) == old, (path, hex(off))
        b[off:off + len(new)] = new
    open(out, "wb").write(b)

def b_to(frm, to):
    imm = (to - frm) >> 2; assert -(1 << 25) <= imm < (1 << 25)
    return struct.pack("<I", 0x14000000 | (imm & 0x3ffffff))

# --- unpack the APEX ---------------------------------------------------------------------------------------------
zipfile.ZipFile(SRC).extract("original_apex", W)
orig = os.path.join(W, "original_apex")
zipfile.ZipFile(orig).extract("apex_payload.img", W)
img = os.path.join(W, "apex_payload.img")
def dbg(cmd, image=img): return subprocess.run(["debugfs", "-R", cmd, image], capture_output=True, text=True).stdout
for p in ["bin/netbpfload", "lib64/libbpf.so", "lib64/libbase.so", "lib64/libc++.so", "etc/bpf/mainline/netd.o",
          "lib64/libservice-connectivity.so"]:
    dbg(f"dump /{p} {os.path.join(W, os.path.basename(p))}")
J = lambda n: os.path.join(W, n)

# --- netbpfload: kernel gates, st_dev check, netd.o path -----------------------------------------------------------
nb = J("netbpfload"); data = open(nb, "rb").read(); insns = list(text_insns(nb))
edits = []
for msg in (b"requires kernel 5.10", b"requires kernel 5.15"):
    s = str_start(data, msg); refs = xrefs(insns, s)
    assert len(refs) == 1, (msg, refs)
    # the gate: nearest conditional branch before the error block's string load that jumps past it
    cond = [i for i in insns if refs[0] - 0x40 <= i.address < refs[0]
            and (i.mnemonic in ("tbz", "tbnz", "cbz", "cbnz") or i.mnemonic.startswith("b."))
            and i.operands[-1].imm > refs[0]]
    assert cond, (msg, hex(refs[0]))
    prev = max(cond, key=lambda i: i.address)
    tgt = prev.operands[-1].imm
    edits.append((vaddr_to_off(nb, prev.address), bytes(prev.bytes), b_to(prev.address, tgt)))
    print(f"netbpfload: {msg.decode()} gate {prev.address:#x} {prev.mnemonic} -> b {tgt:#x}")
s = str_start(data, b"is on device"); ref = xrefs(insns, s); assert len(ref) == 1, ref
cands = [i for i in insns if i.mnemonic == "b.ne" and 0 <= ref[0] - i.operands[0].imm <= 0x40]
assert len(cands) == 1, [hex(c.address) for c in cands]
c = cands[0]; prv = [i for i in insns if i.address == c.address - 4][0]
assert prv.mnemonic == "cmp", prv.mnemonic
edits.append((vaddr_to_off(nb, c.address), bytes(c.bytes), B_NOP))
print(f"netbpfload: st_dev check b.ne {c.address:#x} -> nop")
old = b"/apex/com.android.tethering/etc/bpf/mainline/netd.o\0"; i = data.find(old)
assert i >= 0 and data.find(old, i + 1) < 0
edits.append((i, old, b"/system/etc/bpf/a52_netd.o".ljust(len(old), b"\0")))
patch(nb, os.path.join(OUT, "netbpfload_a52"), edits)
b2 = bytearray(open(os.path.join(OUT, "netbpfload_a52"), "rb").read())
for o, n in [(b"libbase.so\0", b"libbasB.so\0"), (b"libbpf.so\0", b"libbpB.so\0"), (b"libc++.so\0", b"libcBB.so\0")]:
    assert b2.count(o) == 1, o; k = b2.find(o); b2[k:k + len(o)] = n
open(os.path.join(OUT, "netbpfload_a52b"), "wb").write(b2)

def rename(src, dst, pairs):
    b = open(J(src), "rb").read()
    for o, n in pairs: assert o in b, (src, o); b = b.replace(o, n)
    open(os.path.join(OUT, dst), "wb").write(b)
rename("libbase.so", "libbasB.so", [(b"libbase.so\0", b"libbasB.so\0"), (b"libc++.so\0", b"libcBB.so\0")])
rename("libbpf.so", "libbpB.so", [(b"libbpf.so\0", b"libbpB.so\0"), (b"libc++.so\0", b"libcBB.so\0")])
rename("libc++.so", "libcBB.so", [(b"libc++.so\0", b"libcBB.so\0")])
open(os.path.join(OUT, "libbpf.so"), "wb").write(open(J("libbpf.so"), "rb").read())

# --- netd.o: let the 5.4 25q2 stats programs load at any API level -------------------------------------------------
P_SZ = 180
nd = bytearray(open(J("netd.o"), "rb").read())
with open(J("netd.o"), "rb") as f:
    e = ELFFile(f); s = e.get_section_by_name(".android_progs"); base = s["sh_offset"]
    idx = [k for k, x in enumerate(e.iter_sections()) if x.name == ".android_progs"][0]
    want = {sym["st_value"]: sym.name for sym in e.get_section_by_name(".symtab").iter_symbols()
            if sym["st_shndx"] == idx and sym["st_size"] == P_SZ and re.fullmatch(r"(in|e)gress_stats_5_4_25q2_def", sym.name)}
assert len(want) == 2, want
for v, name in want.items():
    off = base + v + 32; mina, maxa = struct.unpack_from("<2i", nd, off - 4)
    assert maxa < 65536, (name, maxa); struct.pack_into("<i", nd, off, 65536)
    print(f"netd.o: {name} max_api {maxa} -> 65536 @ {off:#x}")
open(os.path.join(OUT, "netd_a52.o"), "wb").write(nd)

# --- netd_a52rb.o: same, plus the maps newer Tethering trains need, plus the ringbuf maps created on our 5.4 kernel ---
# Union: the default build keeps Google's original Tethering APEX, so a Play train replaces system_server's / netd's
# BPF users while our loader keeps loading this one object. 372038420 e.g. opens map_netd_loopback_permission_enabled_map
# (abort -> system_server crash loop without it) and no longer the five permission-migration maps the factory code
# needs; one object with both sets serves both. The programs stay the factory's. Their permission checks are gated by
# flag maps only the factory userspace sets (it sets uid_migration_enabled, permission_propagation_enabled and
# loopback_checks_enabled to 1 on our system: permission_map_uid_migration is a READ_ONLY ENABLED aconfig flag compiled
# to `return true`, the android.permission.flags ones are forced true for SDK >= 37). Under a train's userspace those
# maps stay 0, so the factory programs take their legacy branches (uid_permission_map / local_net_blocked_uid_map,
# both never written) = INTERNET-permission and local-network checks fail open. See netd_a52rb_train.o below for the
# alternative. Maps both define must be identical (bpf_union asserts; only 5.10+ ones such as sk_storage may differ).
def train_netd(path):
    with open(path, "rb") as f: head = f.read(4)
    if head == b"\x7fELF": return open(path, "rb").read()
    d = tempfile.mkdtemp(dir=W); z = zipfile.ZipFile(path)
    if "original_apex" in z.namelist():
        z.extract("original_apex", d); z = zipfile.ZipFile(os.path.join(d, "original_apex"))
    z.extract("apex_payload.img", d)
    dbg("dump /etc/bpf/mainline/netd.o " + os.path.join(d, "netd.o"), os.path.join(d, "apex_payload.img"))
    return open(os.path.join(d, "netd.o"), "rb").read()
donors = []
for t in TRAINS:
    b = train_netd(t); donors.append((os.path.basename(t), b))
    print(f"netd.o: union input {t} (netd.o sha256 {hashlib.sha256(b).hexdigest()})")
nd, added = union(bytes(nd), donors, log=print)
nd = bytearray(nd)
# AOSP's DEFINE_BPF_RINGBUF_EXT hard-codes min_kver KVER_5_10, so netbpfload (prepareLoadMaps) sets autocreate=false
# for them on 5.4 and system_server's libservice-connectivity.so later abort()s opening the missing pins. Our kernel
# backports the map type (k4-patches/0006: create/mmap/poll; no BPF-side helpers), so lower min_kver to 5.4.0: the
# loader itself then creates, pins (create_location /sys/fs/bpf/net_shared/tmp -> rename to the netd_shared pin, i.e.
# label fs_bpf_net_shared), chmods and chowns them exactly as on a 5.10 device. Only the 5.10+ program variants
# reference these maps (and they still are not loaded on 5.4), so the rings stay empty - consumers just never get
# events. struct bpf_map_def: type@0 ... uid@20 gid@24 mode@28 min_api@32 max_api@36 min_kver@40 max_kver@44.
M_SZ, KV = 192, lambda a, b, c: (a << 24) | (b << 16) | c
def relax_ringbufs(nd):
    with io.BytesIO(bytes(nd)) as f:
        e = ELFFile(f); s = e.get_section_by_name(".android_maps"); base = s["sh_offset"]
        idx = [k for k, x in enumerate(e.iter_sections()) if x.name == ".android_maps"][0]
        rbs = {sym["st_value"]: sym.name for sym in e.get_section_by_name(".symtab").iter_symbols()
               if sym["st_shndx"] == idx and sym["st_size"] == M_SZ and struct.unpack_from("<I", nd, base + sym["st_value"])[0] == 27}
    assert len(rbs) >= 2, rbs
    for v, name in sorted(rbs.items()):
        off = base + v; uid, gid, mode, mina, maxa, mink, maxk = struct.unpack_from("<3I2i2I", nd, off + 20)
        assert mink == KV(5, 10, 0), (name, hex(mink)); struct.pack_into("<I", nd, off + 40, KV(5, 4, 0))
        pin = nd[off + 118:off + 188].split(b"\0")[0].decode()
        print(f"netd.o: {name} min_kver 5.10 -> 5.4 ({pin} {uid}:{gid} {mode:04o} api {mina}-{maxa})")
    return nd
open(os.path.join(OUT, "netd_a52rb.o"), "wb").write(relax_ringbufs(nd))

# --- netd_a52rb_train.o (--train-progs; not installed by customize.sh): the reverse union -------------------------
# The newest train's netd.o, programs included, + every map only the factory netd.o (and older trains) define, so
# the factory userspace still finds its five permission-migration maps. 5.4 relaxations: ringbufs as above, and per
# stats program pin the min_kver-5.4 variant with the largest max_api gets max_api 65536 (372038420: *_stats_5_4_t,
# api 3300-3610; Google ships no 5.4 stats program for api >= 3610 any more). That variant is the T-era program: it
# references no local_net_* map, i.e. on 5.4 these programs do no local-network-protection filtering at all.
# INTERNET permission (cgroupsock/inet_create$4_14_t) reads only uid_permission_chunk_map, which both userspaces fill
# with the same UidPermissionChunk layout (NO_INTERNET bit), so it is enforced under either. Loopback checks only
# exist in 5.10+ programs (sk_storage), on 5.4 neither object has them.
def relax_stats_5_4(nd):
    P_SZ = 180
    with io.BytesIO(bytes(nd)) as f:
        e = ELFFile(f); s = e.get_section_by_name(".android_progs"); base = s["sh_offset"]
        idx = [k for k, x in enumerate(e.iter_sections()) if x.name == ".android_progs"][0]
        defs = [(sym.name, base + sym["st_value"]) for sym in e.get_section_by_name(".symtab").iter_symbols()
                if sym["st_shndx"] == idx and sym["st_size"] == P_SZ]
    pins = {}
    for name, off in defs:
        mink, maxk = struct.unpack_from("<2I", nd, off + 16); mina, maxa = struct.unpack_from("<2i", nd, off + 28)
        pin = nd[off + 106:off + 176].split(b"\0")[0].decode()
        if pin.endswith(("/prog_netd_ingress_stats", "/prog_netd_egress_stats")) and mink == KV(5, 4, 0):
            pins.setdefault(pin, []).append((maxa, name, off, mina, maxk))
    assert sorted(p.rsplit("/", 1)[1] for p in pins) == ["prog_netd_egress_stats", "prog_netd_ingress_stats"], pins
    for pin, c in sorted(pins.items()):
        maxa, name, off, mina, maxk = max(c)
        assert [x[0] for x in c].count(maxa) == 1 and maxk > KV(5, 4, 302) and maxa < 65536, (pin, c)
        struct.pack_into("<i", nd, off + 32, 65536)
        print(f"netd.o (train): {name} max_api {maxa} -> 65536 (api {mina}-, pin {pin})")
    return nd
if TRAIN_PROGS:
    tb_name, tb = donors[-1]
    rdonors = [("factory netd.o", open(J("netd.o"), "rb").read())] + donors[:-1]
    print(f"netd.o (train): base {tb_name}")
    tnd, _ = union(tb, rdonors, log=print)
    tnd = relax_ringbufs(relax_stats_5_4(bytearray(tnd)))
    open(os.path.join(OUT, "netd_a52rb_train.o"), "wb").write(tnd)

# --- libservice-connectivity.so: no BPF ringbuf on 5.4 ------------------------------------------------------------
lsc = J("libservice-connectivity.so"); ldata = open(lsc, "rb").read(); ledits = []
with open(lsc, "rb") as f:
    e = ELFFile(f)
    syms = {s.name: s["st_value"] for s in e.get_section_by_name(".dynsym").iter_symbols() if s["st_value"]}
    def one(pat):
        m = [v for k, v in syms.items() if re.search(pat, k)]; assert len(set(m)) == 1, (pat, m); return m[0]
    targets = [(one(r"LoopbackEventHandler\w*GetPoller"), MOVX_RET, "LoopbackEventHandler::GetPoller"),
               (one(r"LoopbackEventHandler\d*Start"), MOVW_RET, "LoopbackEventHandler::Start"),
               (one(r"LoopbackEventHandler\d*Stop"), RET_RET, "LoopbackEventHandler::Stop")]
    # nativeGetLocalNetAccessRingbufFd (JNI, not exported): the only function that logs
    # "Failed to get local net event ring buffer." -> walk back from that string load to its paciasp entry
    ldata0 = open(lsc, "rb").read()
    msg_va = None
    for sg in e.iter_segments():
        if sg["p_type"] == "PT_LOAD":
            k = sg.data().find(b"\0Failed to get local net event ring buffer.\0")
            if k >= 0: msg_va = sg["p_vaddr"] + k + 1
    assert msg_va, "ringbuf error string"
    li = list(text_insns(lsc)); refs = xrefs(li, msg_va); assert len(refs) == 1, refs
    entries = [ins.address for ins in li if ins.mnemonic == "paciasp" and ins.address < refs[0]]
    fn = max(entries); assert refs[0] - fn < 0x400, (hex(fn), hex(refs[0]))
    targets.insert(0, (fn, MOVX_RET, "nativeGetLocalNetAccessRingbufFd"))
for va, new, nm in targets:
    off = vaddr_to_off(lsc, va); first = next(md.disasm(ldata[off:off + 4], va))
    assert first.mnemonic in ("paciasp", "bti", "sub", "stp", "str"), (nm, first.mnemonic)
    ledits.append((off, ldata[off:off + 8], new)); print(f"libservice-connectivity: {nm} @ {va:#x} ({first.mnemonic}) stubbed")
patch(lsc, J("lsc.patched.so"), ledits)

# --- write the patched library into the ext4 payload in place (exclusively owned blocks only) ----------------------
files, owner = [], {}
def walk(d):
    for line in dbg(f"ls -p {d}").splitlines():
        p = line.split("/")
        if len(p) < 7 or p[5] in (".", "..", ""): continue
        full = d.rstrip("/") + "/" + p[5]
        (walk(full) if p[2].startswith("04") else files.append(full) if p[2].startswith("10") else None)
walk("/")
for fpath in files:
    for blk in dbg(f"blocks {fpath}").split(): owner.setdefault(int(blk), []).append(fpath)
tgt = "/lib64/libservice-connectivity.so"; lmap = {}
for m in re.finditer(r"(\d+)\s*-\s*(\d+)\s+(\d+)\s*-\s*(\d+)\s+(\d+)", dbg(f"ex {tgt}")):
    l0, l1, p0 = int(m.group(1)), int(m.group(2)), int(m.group(3))
    for k in range(l1 - l0 + 1): lmap[l0 + k] = p0 + k
old_b, new_b = ldata, open(J("lsc.patched.so"), "rb").read()
with open(img, "r+b") as fh:
    for lb in sorted({o // 4096 for o in range(len(old_b)) if old_b[o] != new_b[o]}):
        pb = lmap[lb]; assert owner.get(pb) == [tgt], (lb, pb, owner.get(pb))
        fh.seek(pb * 4096); assert fh.read(len(old_b[lb * 4096:(lb + 1) * 4096])) == old_b[lb * 4096:(lb + 1) * 4096]
        fh.seek(pb * 4096); fh.write(new_b[lb * 4096:(lb + 1) * 4096])
dbg(f"dump {tgt} {J('chk.so')}"); assert open(J("chk.so"), "rb").read() == new_b, "payload readback"
sh("e2fsck", "-fn", img)

# --- repack (no META-INF) and sign ----------------------------------------------------------------------------------
src = zipfile.ZipFile(orig); unsigned = J("unsigned.apex")
with zipfile.ZipFile(unsigned, "w") as out:
    for i in src.infolist():
        if i.filename.startswith("META-INF/"): continue
        zi = zipfile.ZipInfo(i.filename, date_time=i.date_time); zi.compress_type = i.compress_type
        zi.external_attr = i.external_attr
        out.writestr(zi, open(img, "rb").read() if i.filename == "apex_payload.img" else src.read(i))
apks = [p.split("/")[-1] for p in files if p.endswith(".apk")]
cmd = [os.path.join(HOST, "bin/sign_apex"), "-p", HOST, "--avbtool", os.path.join(HOST, "bin/avbtool"),
       "--container_key", os.path.join(KEYS, "container"), "--payload_key", os.path.join(KEYS, "payload.pem")]
for a in apks: cmd += ["-e", f"{a}=PRESIGNED"]
env = dict(os.environ, TMPDIR=W, PATH=os.path.join(HOST, "bin") + ":" + os.environ["PATH"])
subprocess.run(cmd + [unsigned, os.path.join(OUT, "com.google.android.tethering.apex")], check=True, env=env,
               capture_output=True)
print("signed:", os.path.join(OUT, "com.google.android.tethering.apex"), "inner APKs presigned:", apks)
