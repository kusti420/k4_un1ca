# See module.prop.
CIL="$WORK_DIR/system/system/etc/selinux/plat_sepolicy.cil"
RULE="(allow apexd dm_device (blk_file (setattr)))"
[ -f "$CIL" ] || ABORT "apexd_dm_mtime: plat_sepolicy.cil not found"
grep -q -F "(allow apexd dm_device (blk_file (" "$CIL" || ABORT "apexd_dm_mtime: no apexd dm_device blk_file rule to extend"
if ! grep -q -x -F "$RULE" "$CIL"; then
    [ -z "$(tail -c 1 "$CIL")" ] || echo >> "$CIL"
    echo "$RULE" >> "$CIL"
fi
grep -q -x -F "$RULE" "$CIL" || ABORT "apexd_dm_mtime: failed to add the rule"
LOG "- apexd may set the mtime of dm block nodes (staged APEX activation)"
unset CIL RULE
