PLAT_FC="$WORK_DIR/system/system/etc/selinux/plat_file_contexts"

if ! grep -q "^/dev/ion[[:space:]]" "$PLAT_FC"; then
    LOG "- Labeling /dev/ion as ion_device in /system/etc/selinux/plat_file_contexts"
    EVAL "echo \"/dev/ion		u:object_r:ion_device:s0\" >> \"$PLAT_FC\""
fi

unset PLAT_FC
