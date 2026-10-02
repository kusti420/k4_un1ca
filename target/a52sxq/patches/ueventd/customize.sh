UEVENTD_RC="$WORK_DIR/system/system/etc/ueventd.rc"

if [ -f "$WORK_DIR/vendor/ueventd.rc" ] && [ ! -f "$WORK_DIR/vendor/etc/ueventd.rc" ] && \
        ! grep -q "^import /vendor/ueventd.rc" "$UEVENTD_RC"; then
    LOG "- Importing /vendor/ueventd.rc in /system/etc/ueventd.rc"
    EVAL "sed -i \"s|^import /vendor/etc/ueventd.rc$|&\\nimport /vendor/ueventd.rc|\" \"$UEVENTD_RC\""
    grep -q "^import /vendor/ueventd.rc$" "$UEVENTD_RC" || ABORT "Failed to patch ${UEVENTD_RC//$WORK_DIR/}"
fi

unset UEVENTD_RC
