# See module.prop. Only the "on charger" trigger is touched, so normal boots are unaffected.
INIT_RC="$WORK_DIR/system/system/etc/init/hw/init.rc"

if grep -A1 "^on charger$" "$INIT_RC" | grep -q "^    class_start charger$"; then
    LOG "- Removing \"on charger: class_start charger\" from /system/etc/init/hw/init.rc"
    python3 - "$INIT_RC" << 'PYEOF' || ABORT "Failed to patch ${INIT_RC//$WORK_DIR/}"
import sys
p = sys.argv[1]
s = open(p).read()
old = "on charger\n    class_start charger\n"
assert s.count(old) == 1, "on charger stanza: %d" % s.count(old)
s = s.replace(old, "on charger\n    # k4: stock A52s runs only class sec-charger (Samsung lpm) in power-off charging\n")
open(p, "w").write(s)
PYEOF
fi
if grep -A1 "^on charger$" "$INIT_RC" | grep -q "class_start charger"; then
    ABORT "class_start charger still in ${INIT_RC//$WORK_DIR/}"
fi

unset INIT_RC
