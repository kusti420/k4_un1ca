# See module.prop. Diagnostics and evidence capture only: nothing here changes how updates are installed.
SYS="$WORK_DIR/system/system"

# Tester diagnostic: `adb shell k4-mainline-diag [-v|-s]`
EVAL "cp -f \"$MODPATH/k4-mainline-diag\" \"$SYS/bin/k4-mainline-diag\"" || ABORT "play_system_updates: diag copy failed"
SET_METADATA "system" "system/bin/k4-mainline-diag" 0 2000 755 "u:object_r:system_file:s0"

# Evidence of an update boot that apexd/vold roll back, kept in /cache (init builtins only, no new SELinux domain).
# The rc keys on apexd.packages.updated and runs at load-bpf-programs; check both still exist in this base, otherwise
# the capture silently never fires.
grep -q -a -F "apexd.packages.updated" "$SYS/bin/apexd" || \
    LOGW "play_system_updates: apexd no longer sets apexd.packages.updated - the update-boot capture will never run"
grep -q "^ *trigger load-bpf-programs" "$SYS/etc/init/hw/init.rc" || \
    LOGW "play_system_updates: init.rc no longer triggers load-bpf-programs - the update-boot capture will never run"
EVAL "cp -f \"$MODPATH/a52sxq_mainline.rc\" \"$SYS/etc/init/a52sxq_mainline.rc\"" || ABORT "play_system_updates: rc copy failed"
SET_METADATA "system" "system/etc/init/a52sxq_mainline.rc" 0 0 644 "u:object_r:system_file:s0"
# init parses /system/etc/init alphabetically; the load-bpf-programs capture must queue before netbpfload.rc's loader
[[ "a52sxq_mainline.rc" < "netbpfload.rc" ]] || ABORT "play_system_updates: rc must sort before netbpfload.rc"

LOG "- Added k4-mainline-diag and the update-boot evidence capture (/cache/k4_mainline)"
unset SYS
