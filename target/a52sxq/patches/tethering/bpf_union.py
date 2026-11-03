#!/usr/bin/env python3
# Add to a netd.o every map that only a newer (or older) netd.o defines, so one object satisfies the userspace of
# several Tethering APEX versions. Used by regen.py; standalone:  bpf_union.py <base.o> <out.o> <donor.o>...
#
# The PROGRAMS stay the base object's, byte for byte; only map definitions are added. A map lives in four places of
# an AOSP bpf object and each is copied from the donor:
#   .android_maps   struct bpf_map_def (what netbpfload reads: kver/api window, uid/gid/mode, pins); two layouts:
#                   192 bytes up to Tethering 26Q3 (v1: type key_size value_size max_entries map_flags uid gid mode
#                   min_api max_api min_kver max_kver create[70] pin[70] name_idx) and 180 bytes since the 26Q4 train
#                   373041100 (v2: the same without key_size/value_size/max_entries, which libbpf takes from .maps).
#                   Records are converted to the base object's layout (sizes from the donor's BTF .maps definition).
#   .maps           libbpf BTF-defined map (bpf_object__find_map_by_name must find it, or the loader fails)
#   .maps.<name>    ____btf_map_<name> {key; value} (key/value BTF type ids for the non-libbpf loader path)
#   .BTF            VAR + DATASEC entry for each of the three, plus the types they use; ELF symbols for each VAR
#                   (libbpf resolves DATASEC var offsets via ELF symbols); .rel.BTF relocs for those DATASEC entries
# New BTF types are appended (existing type ids and string offsets, which .BTF.ext refers to, stay unchanged) and
# deduplicated against the base's types. A map that both objects define must have an identical bpf_map_def
# (layout-independent fields, key/value size and max_entries compared).
import struct, sys

SHT_SYMTAB, SHT_REL = 2, 9
BTF_KINDS_REF = {2, 8, 9, 10, 11, 12, 13, 14, 17, 18}   # kinds whose size_or_type field is a type id
KIND_VAR, KIND_DATASEC = 14, 15
M_SZ, M_SZ_V2 = 192, 180             # struct bpf_map_def v1 (<= 26Q3, the loader's internal layout) / v2 (26Q4+)
MAP_LAYOUTS = (M_SZ, M_SZ_V2)
# field offsets per layout (common fields; v1 has key_size@4 value_size@8 max_entries@12 in front of map_flags)
M_OFF = {M_SZ: dict(flags=16, uid=20, api=32, kver=40, create=48, pin=118, name_idx=188),
         M_SZ_V2: dict(flags=4, uid=8, api=20, kver=28, create=36, pin=106, name_idx=176)}


def extra_len(kind, vlen):
    return {1: 4, 3: 12, 4: 12 * vlen, 5: 12 * vlen, 6: 8 * vlen, 13: 8 * vlen, 14: 4, 15: 12 * vlen, 17: 4,
            19: 12 * vlen}.get(kind, 0)


class Btf:
    def __init__(self, data):
        magic, ver, flags, hlen, toff, tlen, soff, slen = struct.unpack_from("<HBBIIIII", data)
        assert magic == 0xEB9F and ver == 1 and hlen == 24, "BTF header"
        self.hdr = data[:hlen]
        self.strs = bytearray(data[hlen + soff:hlen + soff + slen])
        self.types = [None]                              # [kind, name, info, st, extra(list of tuples), old_off]
        t, p, end = data[hlen + toff:hlen + toff + tlen], 0, tlen
        while p < end:
            name_off, info, st = struct.unpack_from("<III", t, p)
            kind, vlen = (info >> 24) & 0x1F, info & 0xFFFF
            n = extra_len(kind, vlen); assert kind in range(1, 20), ("BTF kind", kind)
            raw = t[p + 12:p + 12 + n]
            if kind == 1 or kind == 14 or kind == 17: ex = [struct.unpack("<I", raw)]
            elif kind == 3: ex = [struct.unpack("<III", raw)]
            elif kind in (4, 5, 15, 19): ex = [struct.unpack_from("<III", raw, 12 * i) for i in range(vlen)]
            elif kind in (6, 13): ex = [struct.unpack_from("<Ii", raw, 8 * i) for i in range(vlen)]
            else: ex = []
            self.types.append([kind, self.s(name_off), info, st, ex, p, name_off])
            p += 12 + n
        assert p == end

    def s(self, off):
        return self.strs[off:self.strs.index(0, off)].decode()

    def add_str(self, s):
        if not s: return 0
        b = s.encode() + b"\0"
        i = self.strs.find(b"\0" + b)
        if i >= 0: return i + 1
        off = len(self.strs); self.strs += b; return off

    def key(self, tid, src=None):
        """structural key of type tid (ids as they are in self), names as strings."""
        src = src or self
        kind, name, info, st, ex = src.types[tid][:5]
        if kind in (4, 5): ex = tuple((src.s(m[0]), m[1], m[2]) for m in ex)
        elif kind in (6, 19): ex = tuple((src.s(e[0]),) + tuple(e[1:]) for e in ex)
        elif kind == 13: ex = tuple((src.s(e[0]), e[1]) for e in ex)
        else: ex = tuple(ex)
        return (kind, name, info, st, ex)

    def find(self, kind, name):
        r = [i for i, t in enumerate(self.types) if t and t[0] == kind and t[1] == name]
        assert len(r) <= 1, (kind, name, r); return r[0] if r else None

    def size(self, tid):
        """sizeof the C type tid (like btf__resolve_size)"""
        if tid == 0: return 0
        kind, name, info, st, ex = self.types[tid][:5]
        if kind in (1, 4, 5, 6, 16, 19): return st           # INT STRUCT UNION ENUM FLOAT ENUM64
        if kind == 2: return 8                               # PTR
        if kind == 3: return self.size(ex[0][0]) * ex[0][2]  # ARRAY: elem type, index type, nelems
        if kind in (8, 9, 10, 11, 14, 18): return self.size(st)   # TYPEDEF VOLATILE CONST RESTRICT VAR TYPE_TAG
        raise AssertionError(("BTF size of kind", kind, name))

    def libbpf_map_sizes(self):
        """name -> (key_size, value_size, max_entries) from the libbpf-style .maps definitions (DEFINE_LIBBPF_MAP:
        __type(key/value) are pointers to the types, __uint(max_entries) is a pointer to int[N]); what libbpf, and
        the 26Q4 loader, create the map with"""
        ds = self.find(KIND_DATASEC, ".maps"); assert ds, ".maps DATASEC"
        out = {}
        for vid, _, _ in self.types[ds][4]:
            v = self.types[vid]; assert v[0] == KIND_VAR, v[:2]
            st = self.types[v[3]]; assert st[0] == 4, (v[1], "libbpf map def is not a struct")
            m = {self.s(x[0]): x[1] for x in st[4]}
            def ptr(tid):
                t = self.types[tid]; assert t[0] == 2, (v[1], "not a pointer"); return t[3]
            def nelems(tid):
                t = self.types[ptr(tid)]; assert t[0] == 3, (v[1], "not an array"); return t[4][0][2]
            out[v[1]] = (self.size(ptr(m["key"])) if "key" in m else 0,
                         self.size(ptr(m["value"])) if "value" in m else 0,
                         nelems(m["max_entries"]) if "max_entries" in m else 0)
        return out

    def serialize(self):
        out, offs = bytearray(), [None]
        for t in self.types[1:]:
            kind, name, info, st, ex = t[:5]
            offs.append(len(out))
            out += struct.pack("<III", t[6] if len(t) > 6 else self.add_str(name), info, st)
            for e in ex: out += struct.pack("<I" + ("i" if kind in (6, 13) and len(e) == 2 else "I") * (len(e) - 1), *e)
        hdr = bytearray(self.hdr); struct.pack_into("<IIII", hdr, 8, 0, len(out), len(out), len(self.strs))
        return bytes(hdr) + bytes(out) + bytes(self.strs), offs


class Importer:
    """deep-copies donor BTF types into base, reusing structurally identical base types."""
    def __init__(self, base, donor):
        self.b, self.d, self.memo, self.busy = base, donor, {0: 0}, set()
        self.index = {}
        for i in range(1, len(base.types)): self.index.setdefault(base.key(i), i)

    def copy(self, did):
        if did in self.memo: return self.memo[did]
        assert did not in self.busy, ("recursive BTF type, not supported", did); self.busy.add(did)
        kind, name, info, st, ex = self.d.types[did][:5]
        m = self.copy
        if kind in BTF_KINDS_REF: st = m(st)
        if kind == 3: ex = [(m(ex[0][0]), m(ex[0][1]), ex[0][2])]
        elif kind in (4, 5): ex = [(self.b.add_str(self.d.s(n)), m(t), o) for n, t, o in ex]
        elif kind in (6, 19): ex = [(self.b.add_str(self.d.s(e[0])),) + tuple(e[1:]) for e in ex]
        elif kind == 13: ex = [(self.b.add_str(self.d.s(n)), m(t)) for n, t in ex]
        elif kind == 15: raise AssertionError("DATASEC is not imported implicitly")
        self.b.types.append([kind, name, info, st, list(ex), None])
        new = len(self.b.types) - 1; k = self.b.key(new)
        if k in self.index: self.b.types.pop(); new = self.index[k]
        else: self.index[k] = new
        self.busy.discard(did); self.memo[did] = new
        return new


class Elf:
    def __init__(self, data):
        self.data = data
        assert data[:4] == b"\x7fELF" and data[4] == 2 and data[5] == 1, "ELF64 LE"
        self.ehdr = bytearray(data[:64])
        shoff, = struct.unpack_from("<Q", data, 0x28)
        shentsize, shnum, self.shstrndx = struct.unpack_from("<HHH", data, 0x3A)
        assert shentsize == 64 and struct.unpack_from("<H", data, 0x10)[0] == 1, "relocatable"
        self.sh = []
        for i in range(shnum):
            name, typ, flags, addr, off, size, link, info, align, ent = struct.unpack_from("<IIQQQQIIQQ", data, shoff + 64 * i)
            self.sh.append(dict(name=name, type=typ, flags=flags, addr=addr, off=off, size=size, link=link, info=info,
                                align=align, ent=ent, data=bytearray(data[off:off + size]) if typ != 8 else b""))
        self.names = [self.secname(i) for i in range(shnum)]
        self.symtab = next(i for i, s in enumerate(self.sh) if s["type"] == SHT_SYMTAB)
        self.strtab = self.sh[self.symtab]["link"]

    def secname(self, i):
        d = self.sh[self.shstrndx]["data"]; o = self.sh[i]["name"]; return d[o:d.index(0, o)].decode()

    def idx(self, name):
        r = [i for i, n in enumerate(self.names) if n == name]; assert len(r) == 1, (name, r); return r[0]

    def has(self, name): return name in self.names

    def syms(self):
        d = self.sh[self.symtab]["data"]; st = self.sh[self.strtab]["data"]
        for i in range(len(d) // 24):
            nm, info, other, shndx, val, size = struct.unpack_from("<IBBHQQ", d, 24 * i)
            yield i, st[nm:st.index(0, nm)].decode(), info, other, shndx, val, size

    def sym(self, name, shndx):
        r = [s for s in self.syms() if s[1] == name and s[4] == shndx]; assert len(r) == 1, (name, r); return r[0]

    def add_str(self, s, sec):
        d = self.sh[sec]["data"]; off = len(d); d += s.encode() + b"\0"; self.sh[sec]["size"] = len(d); return off

    def add_sym(self, name, info, other, shndx, val, size):
        d = self.sh[self.symtab]["data"]
        d += struct.pack("<IBBHQQ", self.add_str(name, self.strtab), info, other, shndx, val, size)
        self.sh[self.symtab]["size"] = len(d); return len(d) // 24 - 1

    def set(self, i, data):
        self.sh[i]["data"] = bytearray(data); self.sh[i]["size"] = len(data)

    def add_section(self, name, like, data):
        s = dict(like); s["name"] = self.add_str(name, self.shstrndx); s["data"] = bytearray(data); s["size"] = len(data)
        self.sh.append(s); self.names.append(name); return len(self.sh) - 1

    def rels_for(self, target):
        return [i for i, s in enumerate(self.sh) if s["type"] == SHT_REL and s["info"] == target]

    def write(self):
        n0 = getattr(self, "nsh0", len(self.sh))      # sections added later go after all original ones
        order = sorted(range(1, len(self.sh)), key=lambda i: (self.sh[i]["off"] if i < n0 else 1 << 62, i))
        out = bytearray(self.ehdr)
        for i in order:
            s = self.sh[i]; a = max(s["align"], 1)
            out += b"\0" * (-len(out) % a); s["off"] = len(out)
            if s["type"] != 8: out += s["data"]
        out += b"\0" * (-len(out) % 8); shoff = len(out)
        for s in self.sh:
            out += struct.pack("<IIQQQQIIQQ", s["name"], s["type"], s["flags"], s["addr"], s["off"] if s["type"] else 0,
                               s["size"], s["link"], s["info"], s["align"], s["ent"])
        struct.pack_into("<Q", out, 0x28, shoff); struct.pack_into("<H", out, 0x3C, len(self.sh))
        return bytes(out)


def map_rec_size(e):
    """sizeof(struct bpf_map_def) an object was built with: the st_size of its *_def symbols in .android_maps (what
    the loader derives it from too), else the only layout the section size is a multiple of."""
    si = e.idx(".android_maps"); n = len(e.sh[si]["data"])
    sizes = {s[6] for s in e.syms() if s[4] == si and s[6]}
    if len(sizes) == 1 and sizes <= set(MAP_LAYOUTS) and n % next(iter(sizes)) == 0: return next(iter(sizes))
    fits = [m for m in MAP_LAYOUTS if n % m == 0]
    assert not sizes and len(fits) == 1, ("struct bpf_map_def layout", sizes, n)
    return fits[0]


class MapDef:
    """one .android_maps record of either layout; key/val/max are the record's own (v1) or None (v2) until set"""
    def __init__(self, raw):
        self.raw, self.size = bytes(raw), len(raw); o = M_OFF[self.size]
        self.type, = struct.unpack_from("<I", raw, 0)
        self.key, self.val, self.max = struct.unpack_from("<3I", raw, 4) if self.size == M_SZ else (None, None, None)
        self.flags, = struct.unpack_from("<I", raw, o["flags"])
        self.uid, self.gid, self.mode = struct.unpack_from("<3I", raw, o["uid"])
        self.min_api, self.max_api = struct.unpack_from("<2i", raw, o["api"])
        self.min_kver, self.max_kver = struct.unpack_from("<2I", raw, o["kver"])
        self.create = bytes(raw[o["create"]:o["create"] + 70])
        self.pin = bytes(raw[o["pin"]:o["pin"] + 70])
        self.name_idx, = struct.unpack_from("<I", raw, o["name_idx"])
        self.name = self.pin.split(b"\0")[0].decode()[self.name_idx:]

    @property
    def pin_path(self): return self.pin.split(b"\0")[0].decode()

    @property
    def create_path(self): return self.create.split(b"\0")[0].decode()

    def canon(self):
        """the layout-independent fields as a v2 record (byte-comparable across layouts)"""
        return struct.pack("<5I2i2I", self.type, self.flags, self.uid, self.gid, self.mode, self.min_api, self.max_api,
                           self.min_kver, self.max_kver) + self.create + self.pin + struct.pack("<I", self.name_idx)

    @property
    def sizes(self): return (self.key, self.val, self.max)

    def to(self, size):
        """the record in layout `size` (v1 needs key/val/max known)"""
        if size == M_SZ_V2: return self.canon()
        assert size == M_SZ and None not in self.sizes, (self.name, "key/value/max_entries unknown")
        c = self.canon()
        return c[:4] + struct.pack("<3I", self.key, self.val, self.max) + c[4:]

    def with_sizes(self, kvm):
        self.key, self.val, self.max = kvm; return self


def map_defs(e, btf=None):
    """name -> (offset in .android_maps, MapDef), from the records' own name_idx. key/value/max_entries of v2 records
    come from the object's BTF .maps definitions (btf: a parsed Btf of e, else parsed here)."""
    d = e.sh[e.idx(".android_maps")]["data"]; sz = map_rec_size(e)
    out = {}
    for o in range(0, len(d), sz):
        m = MapDef(d[o:o + sz]); out[m.name] = (o, m)
    if sz != M_SZ:
        btf = btf or Btf(bytes(e.sh[e.idx(".BTF")]["data"])); lb = btf.libbpf_map_sizes()
        for name, (_, m) in out.items():
            assert name in lb, (name, "no libbpf .maps definition"); m.with_sizes(lb[name])
    return out


def datasec_entries(btf, sec):
    i = btf.find(KIND_DATASEC, sec); assert i, sec
    return i, {btf.types[v[0]][1]: k for k, v in enumerate(btf.types[i][4])}


def union(base_bytes, donors, log=print):
    b = Elf(base_bytes); b.nsh0 = len(b.sh); bsz = map_rec_size(b)
    bbtf = Btf(bytes(b.sh[b.idx(".BTF")]["data"]))
    bdef_struct = bbtf.find(4, "bpf_map_def"); assert bdef_struct and bbtf.types[bdef_struct][3] == bsz, "base bpf_map_def BTF"
    rel_btf = b.rels_for(b.idx(".BTF")); assert len(rel_btf) == 1, rel_btf
    # .rel.BTF entries point at DATASEC var offset fields: remember which (datasec id, entry) each one is
    hdr = 24 + struct.unpack_from("<I", bbtf.hdr, 8)[0]
    field = {}
    for tid, t in enumerate(bbtf.types):
        if t and t[0] == KIND_DATASEC:
            for k in range(len(t[4])): field[hdr + t[5] + 12 + 12 * k + 4] = (tid, k)
    rd = b.sh[rel_btf[0]]["data"]
    old_rels = [struct.unpack_from("<QQ", rd, 16 * i) for i in range(len(rd) // 16)]
    assert all(o in field for o, _ in old_rels), "unexpected .rel.BTF target"
    old_rels = [(field[o], info) for o, info in old_rels]
    new_rels = []
    bdefs = map_defs(b, bbtf)
    added = []
    for dpath, dbytes in donors:
        d = Elf(dbytes); dbtf = Btf(bytes(d.sh[d.idx(".BTF")]["data"])); imp = Importer(bbtf, dbtf); dsz = map_rec_size(d)
        # the donor's struct bpf_map_def is the base's, whatever its layout (records are converted below)
        ddef_struct = dbtf.find(4, "bpf_map_def"); assert ddef_struct and dbtf.types[ddef_struct][3] == dsz, (dpath, "bpf_map_def BTF")
        imp.memo[ddef_struct] = bdef_struct
        if dsz != bsz: log(f"bpf_union: {dpath}: struct bpf_map_def is {dsz} bytes, converting to the base's {bsz}")
        dhdr = 24 + struct.unpack_from("<I", dbtf.hdr, 8)[0]
        drd = d.sh[d.rels_for(d.idx(".BTF"))[0]]["data"]
        drel = {struct.unpack_from("<Q", drd, 16 * i)[0]: struct.unpack_from("<Q", drd, 16 * i + 8)[0] for i in range(len(drd) // 16)}
        dsyms = list(d.syms())
        for name, (doff, dm) in map_defs(d, dbtf).items():
            if name in bdefs:
                bm = bdefs[name][1]
                if bm.canon() != dm.canon() or bm.sizes != dm.sizes:
                    # only tolerated for maps neither side creates below 5.10 (sk_storage: BTF value grew)
                    assert dm.min_kver >= 0x050A0000 and bm.min_kver >= 0x050A0000 and dm.type != 27, \
                        (dpath, name, "bpf_map_def differs")
                    log(f"bpf_union: {name}: definition differs in {dpath}, kept base (kver >= 5.10 only)")
                continue
            rec = dm.to(bsz)
            # 1. .android_maps record + <name>_def symbol
            am = b.idx(".android_maps"); ad = b.sh[am]["data"]; aoff = len(ad); b.set(am, bytes(ad) + rec)
            _, _, info, other, _, _, size = next(s for s in dsyms if s[1] == name + "_def" and s[4] == d.idx(".android_maps"))
            assert size == dsz
            s_def = b.add_sym(name + "_def", info, other, am, aoff, bsz)
            # 2. libbpf .maps definition + <name> symbol
            mp = b.idx(".maps"); md = b.sh[mp]["data"]
            _, _, info, other, _, _, size = next(s for s in dsyms if s[1] == name and s[4] == d.idx(".maps"))
            moff = len(md) + (-len(md) % 8); b.set(mp, bytes(md) + b"\0" * (moff - len(md) + size))
            s_map = b.add_sym(name, info, other, mp, moff, size)
            # 3. KV-pair section (not for ringbufs)
            kv = ".maps." + name; s_kv = None
            if d.has(kv):
                ds = d.sh[d.idx(kv)]; ksec = b.add_section(kv, ds, ds["data"])
                _, _, info, other, _, _, size = next(s for s in dsyms if s[1] == "____btf_map_" + name and s[4] == d.idx(kv))
                s_kv = b.add_sym("____btf_map_" + name, info, other, ksec, 0, size)
            # 4. BTF: VARs (+ their types) and DATASEC entries; .rel.BTF like the donor's
            def add_var(var, sec, sym, newsec=False, size=None):
                dsid, dent = datasec_entries(dbtf, sec); k = dent[var]
                dv, _, dsize = dbtf.types[dsid][4][k]; assert dbtf.types[dv][0] == KIND_VAR
                if size is not None: assert dsize == dsz, (var, dsize); dsize = size
                nv = imp.copy(dv)
                if newsec:
                    assert bbtf.find(KIND_DATASEC, sec) is None, sec
                    bbtf.types.append([KIND_DATASEC, sec, KIND_DATASEC << 24, 0, [], None]); bsid = len(bbtf.types) - 1
                else:
                    bsid = bbtf.find(KIND_DATASEC, sec)
                t = bbtf.types[bsid]; t[4].append((nv, 0, dsize)); t[2] += 1
                assert t[3] == 0 and all(o == 0 for _, o, _ in t[4]), (sec, "clang-style DATASEC expected")
                dinfo = drel.get(dhdr + dbtf.types[dsid][5] + 12 + 12 * k + 4)
                if dinfo is not None: new_rels.append(((bsid, len(t[4]) - 1), (sym << 32) | (dinfo & 0xFFFFFFFF)))
            add_var(name + "_def", ".android_maps", s_def, size=bsz)
            add_var(name, ".maps", s_map)
            if s_kv is not None: add_var("____btf_map_" + name, kv, s_kv, newsec=True)
            bdefs[name] = (aoff, MapDef(rec).with_sizes(dm.sizes)); added.append(name)
            log(f"bpf_union: + {name} (from {dpath})")
    if not added: return base_bytes, added
    blob, offs = bbtf.serialize()
    b.set(b.idx(".BTF"), blob)
    pos = lambda tid, k: 24 + offs[tid] + 12 + 12 * k + 4
    b.set(rel_btf[0], b"".join(struct.pack("<QQ", pos(*f), info) for f, info in old_rels + new_rels))
    out = b.write()
    # self-check: the base's sections are unchanged (programs, their relocations, .BTF.ext, ...) or only appended to
    o, a = Elf(out), Elf(base_bytes); Btf(bytes(o.sh[o.idx(".BTF")]["data"]))
    assert o.names[:len(a.names)] == a.names
    for i, n in enumerate(a.names):
        x, y = bytes(a.sh[i]["data"]), bytes(o.sh[i]["data"])
        assert x == y or (n in (".BTF", ".rel.BTF") and len(y) > len(x)) or \
            (n in (".android_maps", ".maps", ".symtab", ".strtab") and y.startswith(x)), ("section changed", n)
    return out, added


if __name__ == "__main__":
    base, out, donors = sys.argv[1], sys.argv[2], sys.argv[3:]
    data, added = union(open(base, "rb").read(), [(p, open(p, "rb").read()) for p in donors])
    open(out, "wb").write(data)
    print("added:", added)
