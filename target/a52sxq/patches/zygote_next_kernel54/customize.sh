# zygote_next (Android 17 native zygote) child: zygote::child_process::re_initialize builds
#   to_drop = 0x1ffffffffff (capabilities 0..40) & ~keep
# and for each cap calls cap::cap_within_bound() -> prctl(PR_CAPBSET_READ, cap), unwrapping the result. Kernel 5.4
# (A52s) only has capabilities 0..37 (CAP_PERFMON 38 / CAP_BPF 39 are 5.8, CAP_CHECKPOINT_RESTORE 40 is 5.9), so the
# read of cap 38 returns EINVAL, unwrap_failed panics and the child aborts with no message (stderr is /dev/null):
# "Fatal signal 6 ... (zygote-child)", system_server then waits in startNativeChildZygote until the watchdog kills it.
# Fix: mov x9, #0x1ffffffffff -> mov x9, #0x3fffffffff (caps 0..37). Caps 38..40 do not exist on this kernel.
# Located by pattern, not offset (Fold8 F976B: 0x29e00, S25 S931B: 0x2a110): the library's only
# `mov Xn, #0x1ffffffffff`, which must be followed within a few instructions by `bic Xd, Xn, Xm` (mask & ~keep).
LIB="$WORK_DIR/system/system/lib64/libzygote.dylib.so"
[ -f "$LIB" ] || ABORT "zygote_next_kernel54: $LIB not found"
python3 - "$LIB" << 'PYEOF' || ABORT "Failed to patch libzygote.dylib.so"
import struct, sys
p = sys.argv[1]
d = bytearray(open(p, "rb").read())
W = lambda o: struct.unpack_from("<I", d, o)[0]
CAP40 = 0xB240A3E0   # orr Xn, xzr, #0x1ffffffffff (N=1 immr=0 imms=40), Rd in bits 0-4
CAP37 = 0xB24097E0   # orr Xn, xzr, #0x3fffffffff  (N=1 immr=0 imms=37)
def find(base):
    return [o for o in range(0, len(d) - 3, 4) if W(o) & 0xFFFFFFE0 == base]
def bic_follows(o):
    n = W(o) & 31
    # BIC (shifted register, 64-bit): sf=1 opc=00 01010 shift N=1 -> 0x8a200000 under mask 0xff200000; Rn bits 5-9
    return any(W(o + 4 * k) & 0xFF200000 == 0x8A200000 and (W(o + 4 * k) >> 5) & 31 == n for k in range(1, 12))
old, new = find(CAP40), find(CAP37)
if not old and len(new) == 1 and bic_follows(new[0]):
    print("already patched at 0x%x" % new[0])
    sys.exit(0)
assert len(old) == 1, "mov Xn, #0x1ffffffffff: %d matches %s" % (len(old), [hex(o) for o in old])
assert not new, "mov Xn, #0x3fffffffff already present at %s" % [hex(o) for o in new]
off = old[0]
assert bic_follows(off), "no bic using the capability mask after 0x%x" % off
struct.pack_into("<I", d, off, CAP37 | (W(off) & 31))
open(p, "wb").write(d)
print("mov x%d, #0x3fffffffff at 0x%x" % (W(off) & 31, off))
PYEOF
LOG "- zygote_next child only drops capabilities kernel 5.4 knows (0-37)"
unset LIB
