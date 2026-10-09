# One UI 9's AudioPolicyManager::broadcastDeviceConnectionState() builds the HAL device connection parameters with
# Samsung's renamed keys (l_device_connect / l_device_disconnect, plus l_a2dp_format for A2DP devices). The A52s A14
# audio HAL (audio.primary.lahaina, sec_set_parameters) only parses the AOSP keys connect / disconnect / format: on
# "connect=128;format=<0x200000 set>" it sets its bt_offload flag, and start_output_stream refuses A2DP while that flag
# is false ("A2DP profile is not ready, return error"). AudioFlinger only accepts those keys from audioserver itself,
# so the fix has to be in the policy. Each renamed string ends with the plain key ("l_device_" + "connect",
# "l_a2dp_" + "format"), so only the ADD immediates of the ADRP+ADD pairs that point at them change (no new data).
#
# AudioFlinger's Samsung layer (SecAudioParamFlinger) matches the policy's device connection message by the key
# l_device_connect: for A2DP devices it records the connect time ("connection mConnectedDevice[%x]") and notifies its
# registered listeners (e.g. AVRCP absolute volume handling). With the policy now sending "connect", point that key at
# the "connect" tail of its own "l_device_connect" string too (its only reference), so this keeps working.
#
# Nothing here uses fixed offsets: each string is looked up by content (must exist exactly once as a whole C string)
# and its single ADRP+ADD reference is found by decoding the executable segments. Each key must have exactly one
# reference, or the build aborts. Sites: Fold8 F976B policy 0x62178/0x62198/0x62234, flinger 0x83ae4;
# S25 S931B policy 0x61e1c/0x61e3c/0x61ed8, flinger 0x83ae4.
PYCODE=$(cat << 'PYEOF'
import struct, sys
from array import array

def segments(d):
    assert d[:4] == b"\x7fELF" and d[4] == 2, "not an ELF64"
    phoff = struct.unpack_from("<Q", d, 0x20)[0]
    phentsize, phnum = struct.unpack_from("<HH", d, 0x36)
    for i in range(phnum):
        p_type, p_flags, off, va, _, filesz, _, _ = struct.unpack_from("<IIQQQQQQ", d, phoff + i * phentsize)
        if p_type == 1:  # PT_LOAD
            yield p_flags, off, va, filesz

def off2va(d, o):
    for _, off, va, fs in segments(d):
        if off <= o < off + fs:
            return o - off + va
    raise AssertionError("offset 0x%x not in a PT_LOAD segment" % o)

def cstr(d, name):
    hits, i = [], -1
    while True:
        i = d.find(name + b"\0", i + 1)
        if i < 0:
            break
        if i == 0 or d[i - 1] == 0:
            hits.append(i)
    assert len(hits) == 1, "string %s: %d copies" % (name.decode(), len(hits))
    return hits[0]

def add_xrefs(d, targets, window=64):
    """ADD (immediate, 64-bit) instructions completing an ADRP to one of the target vaddrs -> {target: [file offsets]}"""
    res = {t: [] for t in targets}
    pages = {t & ~0xFFF for t in targets}
    for flags, off, va, fs in segments(d):
        if not flags & 1:  # PF_X
            continue
        n = fs // 4
        w = array("I", bytes(d[off:off + n * 4]))
        if sys.byteorder != "little":
            w.byteswap()
        for i in range(n):
            x = w[i]
            if x & 0x9F000000 != 0x90000000:  # ADRP
                continue
            rd = x & 31
            imm = ((x >> 29) & 3) | (((x >> 5) & 0x7FFFF) << 2)
            if imm & (1 << 20):
                imm -= 1 << 21
            page = ((va + 4 * i) & ~0xFFF) + (imm << 12)
            if page not in pages:
                continue
            for k in range(i + 1, min(n, i + window)):
                y = w[k]
                if y & 0xFFC00000 == 0x91000000 and (y >> 5) & 31 == rd:  # ADD Xd, Xrd, #imm12 (no shift)
                    t = page + ((y >> 10) & 0xFFF)
                    if t in res:
                        res[t].append(off + 4 * k)
                if y & 0x9F00001F == 0x90000000 | rd:  # register reloaded by another ADRP
                    break
    return {t: sorted(set(v)) for t, v in res.items()}

def patch(path, keys):
    d = bytearray(open(path, "rb").read())
    sites = []
    for name, plain in keys:
        so = cstr(d, name)
        skip = len(name) - len(plain)
        assert name.endswith(plain) and bytes(d[so + skip:so + len(name) + 1]) == plain + b"\0", "tail " + plain.decode()
        sites.append((name, plain, so, skip, off2va(d, so)))
    refs = add_xrefs(d, [s[4] for s in sites])
    for name, plain, so, skip, sva in sites:
        r = refs[sva]
        assert len(r) == 1, "%s (0x%x): %d ADRP+ADD references %s" % (name.decode(), so, len(r), [hex(x) for x in r])
        assert (sva & ~0xFFF) == ((sva + skip) & ~0xFFF), "%s: tail crosses a page" % name.decode()
        insn = r[0]
        w = struct.unpack_from("<I", d, insn)[0]
        assert (w >> 10) & 0xFFF == sva & 0xFFF
        struct.pack_into("<I", d, insn, (w & ~(0xFFF << 10)) | (((sva + skip) & 0xFFF) << 10))
        print("%s: ADD at 0x%x now -> 0x%x \"%s\"" % (path.rsplit("/", 1)[-1], insn, sva + skip, plain.decode()))
    open(path, "wb").write(d)

which = sys.argv[1]
if which == "policy":
    patch(sys.argv[2], [(b"l_device_disconnect", b"disconnect"),
                        (b"l_device_connect", b"connect"),
                        (b"l_a2dp_format", b"format")])
elif which == "flinger":
    patch(sys.argv[2], [(b"l_device_connect", b"connect")])
else:
    sys.exit("unknown target " + which)
PYEOF
)

LIB="$WORK_DIR/system/system/lib64/libaudiopolicymanagerdefault.so"
[ -f "$LIB" ] || ABORT "audio_policy_legacy_keys: $LIB not found"
python3 -c "$PYCODE" "policy" "$LIB" || ABORT "Failed to patch libaudiopolicymanagerdefault.so"
LOG "- AudioPolicyManager sends connect/disconnect/format to the HAL again"

LIB="$WORK_DIR/system/system/lib64/libaudioflinger.so"
[ -f "$LIB" ] || ABORT "audio_policy_legacy_keys: $LIB not found"
python3 -c "$PYCODE" "flinger" "$LIB" || ABORT "Failed to patch libaudioflinger.so"
LOG "- AudioFlinger tracks A2DP connections by the connect key"
unset LIB PYCODE
