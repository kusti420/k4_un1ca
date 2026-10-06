# DIAGNOSTIC: make the native zygote's fatal error visible. See module.prop. Keep a `disable` file here for releases.
RC="$WORK_DIR/system/system/etc/init/zygote_next.rc"
[ -f "$RC" ] || ABORT "zygote_next_fix: $RC not found"
python3 - "$RC" << 'PYEOF' || ABORT "Failed to patch zygote_next.rc"
import re, sys
p = sys.argv[1]
s = open(p).read()
s, n = re.subn(r"--log-level INFO\b", "--log-level TRACE", s)
assert n == 1, "log level"
s, n = re.subn(r"(service zygote_next [^\n]*\n)", r"\1    stdio_to_kmsg\n", s, count=1)
assert n == 1, "service line"
open(p, "w").write(s)
PYEOF
LOG "- zygote_next: stderr to kmsg, log level TRACE (diagnostic)"
unset RC
