# All shipped binaries are generated from the SOURCE firmware's com.google.android.tethering APEX by regen.py: since
# 2026-10-09 the Galaxy S25 / S26 Ultra Tethering 371021120 (Fold8 370547200 before). The source system also ships a
# precompiled odex for that APEX's service-connectivity.jar, so the APEX must match the source exactly (guard below).
# netbpfload_a52 = /apex/com.android.tethering/bin/netbpfload from com.google.android.tethering 371021120
# Also: the "/apex/com.android.tethering/etc/bpf/mainline/netd.o" string is redirected to /system/etc/bpf/a52_netd.o,
# a copy of Google's netd.o whose ingress/egress_stats_5_4_25q2 programs get max_api_level 3610 -> 65536: Google ships
# no 5.4 stats variant for API >= 3610, so nothing got pinned and netd aborts (IchthysOS fixed the same gap in source).
# Also: the b.ne at 0x98c4 (object file st_dev != /proc/self/exe st_dev -> abort) is a nop, since we run from /system
# while the objects live in the APEX.
# (sha256 775d705134ac47146a536d31e76af3d439d0e29d48087bc6c64d04c102c4bed6) with the TBZ at 0xa5a4 (25Q4 >= 5.10) and 0xa5cc (26Q3 >= 5.15) turned into B past the error;
# netd.o max_api_level words at 0x2917c/0x29884. netd path string at 0x308e.
#
# Two modes (TARGET_TETHERING_RESIGN_APEX, scripts/internal/gen_config_file.sh):
# - false (default): Google's ORIGINAL, Google-signed com.google.android.tethering_compressed.apex stays untouched, so
#   Google Play system update trains can update Tethering. Needs a kernel with BPF_MAP_TYPE_RINGBUF (bone-machine k4
#   patch 0006, checked below): /system/etc/bpf/a52_netd.o is netd_a52rb.o, i.e. the netd.o above plus
#   * the maps only the Play train Tethering 372038420's netd.o defines (regen.py extra input, bpf_union.py; programs
#     untouched), so that train's userspace finds its pins too - it aborts system_server without
#       /sys/fs/bpf/netd_shared/map_netd_loopback_permission_enabled_map   ARRAY u32->bool  root:net_bw_acct 0460
#     (netd_readonly create location -> fs_bpf_netd_readonly, like the factory loopback_checks_enabled_map it replaces),
#     while the factory userspace keeps its five maps that 372038420 dropped (uid_permission_map, uid_migration_enabled,
#     permission_propagation_enabled, local_net_blocked_uid, loopback_checks_enabled). Under the train's userspace the
#     factory programs take their legacy branches: INTERNET-permission / local-network / loopback checks fail open;
#   * all ringbuf maps' min_kver lowered 5.10 -> 5.4 (see regen.py). The loader then creates and pins them itself like
#     on a 5.10 device, before bpf.progs_loaded=1 and therefore before netd/system_server start:
#     /sys/fs/bpf/netd_shared/map_netd_packet_trace_ringbuf       32 KiB  root:system          0060
#     /sys/fs/bpf/netd_shared/map_netd_local_net_note_op_ringbuf   4 KiB  root:net_bw_acct     0060
#     /sys/fs/bpf/netd_shared/map_netd_loopback_access_ringbuf     8 KiB  root:system          0060
#     /sys/fs/bpf/netd_shared/map_netd_tcp_metrics_ringbuf         8 KiB  root:system          0060  (372038420)
#     /sys/fs/bpf/netd_shared/map_netd_test_ringbuf                4 KiB  root:network_stack   0060  (372038420)
#   all created as /sys/fs/bpf/net_shared/tmp and renamed, so labelled u:object_r:fs_bpf_net_shared:s0 (plat policy
#   already allows bpfloader to create/rename and system_server to read/write those; no sepolicy change). Nothing else
#   creates these pins, so the loader's "pin already exists" failure path cannot trigger. Only the 5.10+ program
#   variants write to the rings and those still do not load on 5.4, so system_server's LocalNetEventListener /
#   LoopbackEventHandler and libnetworkstats' packet tracing just never receive events.
# - true (rollback, kernels without ringbuf): ship our re-signed APEX with libservice-connectivity.so's ringbuf users
#   stubbed (below) and the plain netd_a52.o. Play system updates then fail with INSTALL_FAILED_VERIFICATION_FAILURE
#   ("APK container signature ... is not compatible") for Tethering.
#
# Known risk of the default mode: our loader (netbpfload 371021120 from /system) and a52_netd.o are FROZEN. After a
# Play train updates Tethering, the new APEX's own netbpfload/netd.o are not used (offload.o, clatd.o, dscpPolicy.o
# are still read from the live APEX), while its new libservice-connectivity.so/libnetd_updatable.so may expect maps or
# programs that only a newer netd.o defines -> netd/system_server abort -> bootloop (bpfloader and netd have
# reboot_on_failure). Covered up to Tethering 372038420 (map union above); a later train that adds maps again needs
# regen.py rerun with that train's APEX as an extra input. Reading the live APEX netd.o instead is not done on purpose: the 5.4 stats max_api relaxation is
# name-specific (a newer netd.o may rename the variants or add its own 5.4 ones, which would then collide on the same
# pin path) and a newer object may need a newer loader (bpfloader_min_ver). After every Tethering train: check
# `logcat -b all | grep -iE "netbpfload|LibBpfLoader|bpf map|ringbuf"` and the stats/maps pins; when Google's netd.o
# changes, rerun regen.py on the updated APEX (pull it from /data/apex/active) and rebuild.
# Recovery if a Tethering train breaks boot (init normally reverts a crashing staged APEX session by itself; if it
# does not): boot TWRP, mount /data, then
#     rm -rf /data/apex/active/com.android.tethering* /data/apex/active/com.google.android.tethering* \
#            /data/apex/sessions/* /data/apex/backup/com.*tethering*
#     rm -rf /data/app-staging/session_*      # optional: drops every staged Play train
# and reboot: apexd falls back to the pre-installed /system Tethering APEX that matches our loader and a52_netd.o.
TETH_RESIGN="${TARGET_TETHERING_RESIGN_APEX:-false}"
TETH_SRC="$FW_DIR/$SOURCE_FIRMWARE_PATH/system/system/apex/com.google.android.tethering_compressed.apex"
[ "$(sha256sum "$TETH_SRC" | cut -d " " -f 1)" = "540ee27099939f2d1e698228ced265b2505dca1f82af2d785c43b37e0c2b652d" ] || \
    ABORT "tethering: source Tethering APEX changed - regenerate netbpfload_a52*, lib*B.so, netd_a52*.o and the re-signed APEX from it"
unset TETH_SRC
EVAL "cp -a \"$SRC_DIR/target/a52sxq/patches/tethering/netbpfload_a52\" \"$WORK_DIR/system/system/bin/netbpfload_a52\""
SET_METADATA "system" "system/bin/netbpfload_a52" 0 2000 755 "u:object_r:bpfloader_exec:s0"
# netbpfload_a52b: same binary, but linked against the APEX's own libbase/libc++/libbpf shipped under renamed
# sonames (libbasB/libcBB/libbpB), in case the system libbase/libc++ is what made netbpfload_a52 abort at exec.
for f in bin/netbpfload_a52b lib64/libbasB.so lib64/libcBB.so lib64/libbpB.so; do
    EVAL "cp -a \"$SRC_DIR/target/a52sxq/patches/tethering/$(basename $f)\" \"$WORK_DIR/system/system/$f\""
done
SET_METADATA "system" "system/bin/netbpfload_a52b" 0 2000 755 "u:object_r:bpfloader_exec:s0"
SET_METADATA "system" "system/lib64/libbasB.so" 0 0 644 "u:object_r:system_lib_file:s0"
SET_METADATA "system" "system/lib64/libcBB.so" 0 0 644 "u:object_r:system_lib_file:s0"
SET_METADATA "system" "system/lib64/libbpB.so" 0 0 644 "u:object_r:system_lib_file:s0"
# netbpfload links libbpf.so, which only the APEX ships (its libbase/libc++/libz needs resolve against /system)
EVAL "cp -a \"$SRC_DIR/target/a52sxq/patches/tethering/libbpf.so\" \"$WORK_DIR/system/system/lib64/libbpf.so\""
SET_METADATA "system" "system/lib64/libbpf.so" 0 0 644 "u:object_r:system_lib_file:s0"
if $TETH_RESIGN; then
    NETD_O="netd_a52.o"
else
    # netd.o is critical: a ringbuf map the kernel cannot create fails the whole load -> reboot,bpfloader-failed loop.
    # The kernel_bone_machine patch runs before this one; k4 patch 0006's BTF names bpf_ringbuf_map (the Image is
    # stored uncompressed in boot.img).
    strings -n 15 "$WORK_DIR/kernel/boot.img" | grep -qx "bpf_ringbuf_map" || \
        ABORT "tethering: kernel in boot.img lacks BPF_MAP_TYPE_RINGBUF (bone-machine k4 patch 0006); use the ringbuf kernel or set TARGET_TETHERING_RESIGN_APEX=true"
    NETD_O="netd_a52rb.o"
fi
EVAL "cp -a \"$SRC_DIR/target/a52sxq/patches/tethering/$NETD_O\" \"$WORK_DIR/system/system/etc/bpf/a52_netd.o\""
SET_METADATA "system" "system/etc/bpf/a52_netd.o" 0 0 644 "u:object_r:system_file:s0"
unset NETD_O

LOG "- Pointing bpfloader/mdnsd_netbpfload at /system/bin/netbpfload_a52"
# netbpfload parses the first line ("# YYYY Q A B C # ...") of this file in a static initializer and abort()s
# without it: keep the stock header.
NB_RC="$WORK_DIR/system/system/etc/init/netbpfload.rc"
NB_HDR="$(head -n 1 "$NB_RC")"
[[ "$NB_HDR" == "# "*" #"* ]] || ABORT "Unexpected netbpfload.rc header: $NB_HDR"
{ echo "$NB_HDR"; echo; cat << 'EOF'
on load-bpf-programs
    write /proc/sys/kernel/kptr_restrict 1
    exec_start bpfloader
    wait_for_prop bpf.progs_loaded 1
    write /proc/sys/kernel/kptr_restrict 2
    exec_start netd1shot
    start netd

# Not updatable on purpose: the Tethering APEX's own definitions (stock netbpfload, kernel >= 5.10 gate) must not win.
service bpfloader /system/bin/netbpfload_a52b
    disabled # started on demand via trigger
    capabilities CHOWN SYS_ADMIN NET_ADMIN SYSLOG
    group root graphics network_stack net_admin net_bw_acct net_bw_stats net_raw system
    user root
    file /dev/kmsg w
    rlimit memlock 1073741824 1073741824
    oneshot
    reboot_on_failure reboot,bpfloader-failed

service mdnsd_netbpfload /system/bin/netbpfload_a52b
    disabled # started on demand by netd
    capabilities CHOWN SYS_ADMIN NET_ADMIN
    group system root graphics network_stack net_admin net_bw_acct net_bw_stats net_raw
    user system
    rlimit memlock 1073741824 1073741824
    oneshot
    reboot_on_failure reboot,netbpfload-failed
EOF
} > "$NB_RC"
unset NB_RC NB_HDR

if $TETH_RESIGN; then
    # LocalNetEventHandler::GetRingbuf() abort()s when the BPF ringbuf map is missing (kernel < 5.8), killing
    # system_server in ConnectivityService.<init>. Ship Google's Tethering APEX (371021120) re-signed with keys/
    # (payload: RSA4096 AVB hashtree, container: keys/container.*), uncompressed, with libservice-connectivity.so's
    # nativeGetLocalNetAccessRingbufFd (+0xdeec) replaced by "mov x0, xzr; ret" -> null FD; the listener is only used
    # when local-net metrics/note-ops are enabled. Also LoopbackEventHandler::GetPoller (+0x11ea8) -> return nullptr
    # (Start/Stop handle it; it aborted in ConnectivityService.systemReady), and since Start() inlines that logic:
    # Start (+0x12110) -> return false, Stop (+0x12394) -> ret. Inner APKs stay Google-signed (PRESIGNED). Same module
    # name, so apexd treats it as the pre-installed com.android.tethering.
    LOG "- Shipping the re-signed Tethering APEX (TARGET_TETHERING_RESIGN_APEX=true)"
    DELETE_FROM_WORK_DIR "system" "system/apex/com.google.android.tethering_compressed.apex"
    EVAL "cp -a \"$SRC_DIR/target/a52sxq/patches/tethering/com.google.android.tethering.apex\" \"$WORK_DIR/system/system/apex/com.google.android.tethering.apex\""
    SET_METADATA "system" "system/apex/com.google.android.tethering.apex" 0 0 644 "u:object_r:system_file:s0"
else
    LOG "- Keeping Google's original Tethering APEX (BPF ringbuf maps created by our loader)"
    [ "$(sha256sum "$WORK_DIR/system/system/apex/com.google.android.tethering_compressed.apex" 2> /dev/null | cut -d " " -f 1)" = \
        "540ee27099939f2d1e698228ced265b2505dca1f82af2d785c43b37e0c2b652d" ] || \
        ABORT "tethering: system/apex/com.google.android.tethering_compressed.apex in the work dir is missing or not the source's"
fi
unset TETH_RESIGN
