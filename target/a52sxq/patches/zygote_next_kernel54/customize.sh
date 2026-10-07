# zygote_next (Android 17 native zygote) child: zygote::child_process::re_initialize builds
#   to_drop = 0x1ffffffffff (capabilities 0..40) & ~keep
# and for each cap calls cap::cap_within_bound() -> prctl(PR_CAPBSET_READ, cap), unwrapping the result. Kernel 5.4
# (A52s) only has capabilities 0..37 (CAP_PERFMON 38 / CAP_BPF 39 are 5.8, CAP_CHECKPOINT_RESTORE 40 is 5.9), so the
# read of cap 38 returns EINVAL, unwrap_failed panics and the child aborts with no message (stderr is /dev/null):
# "Fatal signal 6 ... (zygote-child)", system_server then waits in startNativeChildZygote until the watchdog kills it.
# Fix: mov x9, #0x1ffffffffff -> mov x9, #0x3fffffffff (caps 0..37) at 0x29e00. Caps 38..40 do not exist on this kernel.
LIB="$WORK_DIR/system/system/lib64/libzygote.dylib.so"
[ -f "$LIB" ] || ABORT "zygote_next_kernel54: $LIB not found"
python3 - "$LIB" << 'PYEOF' || ABORT "Failed to patch libzygote.dylib.so"
import sys
p = sys.argv[1]
d = bytearray(open(p, "rb").read())
assert len(d) == 321880, "file size"
# mov x8,[x8+..] context / mov x9,#0x1ffffffffff / mov x21,xzr / mov w20,wzr  (file offset == vaddr, first LOAD)
assert d[0x29DFC:0x29E0C] == bytes.fromhex("e81b40f9" "e9a340b2" "f5031faa" "f4031f2a"), "re_initialize capability mask"
d[0x29E00:0x29E04] = bytes.fromhex("e99740b2")   # mov x9, #0x3fffffffff
open(p, "wb").write(d)
PYEOF
LOG "- zygote_next child only drops capabilities kernel 5.4 knows (0-37)"
unset LIB
