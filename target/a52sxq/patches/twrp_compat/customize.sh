cat > "$WORK_DIR/system/system/etc/init/a52sxq_twrp_compat.rc" << 'EOF'
on post-fs-data
    chown system system /data/system/locksettings.db
    chmod 0660 /data/system/locksettings.db
EOF
SET_METADATA "system" "system/etc/init/a52sxq_twrp_compat.rc" 0 0 644 "u:object_r:system_file:s0"
