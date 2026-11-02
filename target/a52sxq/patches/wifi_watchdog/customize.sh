SKIPUNZIP=1

EVAL "cp -f \"$MODPATH/k4-wifiwatch\" \"$WORK_DIR/system/system/bin/k4-wifiwatch\""
SET_METADATA "system" "system/bin/k4-wifiwatch" 0 2000 755 "u:object_r:system_file:s0"
cat > "$WORK_DIR/system/system/etc/init/k4_wifiwatch.rc" << 'EOF2'
# Wi-Fi data-path watchdog (target/a52sxq/patches/wifi_watchdog). Root in the shell domain like init's console
# service: ip/netlink, /proc/net, binder for cmd/svc.
on property:sys.boot_completed=1
    start k4_wifiwatch

service k4_wifiwatch /system/bin/sh /system/bin/k4-wifiwatch
    user root
    group root
    seclabel u:r:shell:s0
    disabled
EOF2
SET_METADATA "system" "system/etc/init/k4_wifiwatch.rc" 0 0 644 "u:object_r:system_file:s0"
PLAT_PC="$WORK_DIR/system/system/etc/selinux/plat_property_contexts"
if ! grep -q "^sys\.k4\.wifiwatch " "$PLAT_PC"; then
    grep -q "k4_metamod_status_prop" "$PLAT_PC" || ABORT "wifi_watchdog: k4_metamod_status_prop not in plat_property_contexts (needs ksu_metamodule)"
    [ -z "$(tail -c 1 "$PLAT_PC")" ] || echo >> "$PLAT_PC"
    echo "sys.k4.wifiwatch            u:object_r:k4_metamod_status_prop:s0" >> "$PLAT_PC"
    echo "persist.sys.k4.wifiwatch    u:object_r:k4_metamod_prop:s0 exact string" >> "$PLAT_PC"
fi
PLAT_CIL="$WORK_DIR/system/system/etc/selinux/plat_sepolicy.cil"
grep -q -x -F "(allow shell k4_metamod_status_prop (property_service (set)))" "$PLAT_CIL" || {
    [ -z "$(tail -c 1 "$PLAT_CIL")" ] || echo >> "$PLAT_CIL"
    echo "(allow shell k4_metamod_status_prop (property_service (set)))" >> "$PLAT_CIL"
}
# `ip route show table all` looks up table names in /data/misc/net/rt_tables, which shell may not search: harmless (it
# prints numbers) but it was 3 kernel audit lines per 5 s tick, ~1000 per hour of Wi-Fi. Silence that one lookup.
grep -q -x -F "(type net_data_file)" "$PLAT_CIL" || ABORT "wifi_watchdog: type net_data_file not in plat_sepolicy.cil"
grep -q -x -F "(dontaudit shell net_data_file (dir (search)))" "$PLAT_CIL" || \
    echo "(dontaudit shell net_data_file (dir (search)))" >> "$PLAT_CIL"
LOG "- Wi-Fi data-path watchdog: /system/bin/k4-wifiwatch (k4_wifiwatch.rc)"
unset PLAT_PC PLAT_CIL
