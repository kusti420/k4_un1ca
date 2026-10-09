# All shipped binaries are generated from the SOURCE firmware's com.google.android.tethering APEX: since 2026-10-09 the
# Galaxy S25 (SM-S931B S931BXXUCDZIF) Tethering 371021120 (Fold8 370547200 before). The S25 system also ships a
# precompiled odex for that APEX's service-connectivity.jar, so the APEX must match the source exactly (guard below).
# netbpfload_a52 = /apex/com.android.tethering/bin/netbpfload from com.google.android.tethering 371021120
# Also: the "/apex/com.android.tethering/etc/bpf/mainline/netd.o" string is redirected to /system/etc/bpf/a52_netd.o,
# a copy of Google's netd.o whose ingress/egress_stats_5_4_25q2 programs get max_api_level 3610 -> 65536: Google ships
# no 5.4 stats variant for API >= 3610, so nothing got pinned and netd aborts (IchthysOS fixed the same gap in source).
# Also: the b.ne at 0x98c4 (object file st_dev != /proc/self/exe st_dev -> abort) is a nop, since we run from /system
# while the objects live in the APEX.
# (sha256 775d705134ac47146a536d31e76af3d439d0e29d48087bc6c64d04c102c4bed6) with the TBZ at 0xa5a4 (25Q4 >= 5.10) and 0xa5cc (26Q3 >= 5.15) turned into B past the error;
# netd.o max_api_level words at 0x2917c/0x29884. netd path string at 0x308e.
TETH_SRC="$FW_DIR/$SOURCE_FIRMWARE_PATH/system/system/apex/com.google.android.tethering_compressed.apex"
[ "$(sha256sum "$TETH_SRC" | cut -d " " -f 1)" = "540ee27099939f2d1e698228ced265b2505dca1f82af2d785c43b37e0c2b652d" ] || \
    ABORT "tethering: source Tethering APEX changed - regenerate netbpfload_a52*, lib*B.so, netd_a52.o and the re-signed APEX from it"
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
EVAL "cp -a \"$SRC_DIR/target/a52sxq/patches/tethering/netd_a52.o\" \"$WORK_DIR/system/system/etc/bpf/a52_netd.o\""
SET_METADATA "system" "system/etc/bpf/a52_netd.o" 0 0 644 "u:object_r:system_file:s0"

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

# LocalNetEventHandler::GetRingbuf() abort()s when the BPF ringbuf map is missing (kernel < 5.8), killing system_server
# in ConnectivityService.<init>. Ship Google's Tethering APEX (371021120) re-signed with keys/ (payload: RSA4096 AVB
# hashtree, container: keys/container.*), uncompressed, with libservice-connectivity.so's
# nativeGetLocalNetAccessRingbufFd (+0xdeec) replaced by "mov x0, xzr; ret" -> null FD; the listener is only used when
# local-net metrics/note-ops are enabled. Also LoopbackEventHandler::GetPoller (+0x11ea8) -> return nullptr (Start/Stop
# handle it; it aborted in ConnectivityService.systemReady), and since Start() inlines that logic: Start (+0x12110) ->
# return false, Stop (+0x12394) -> ret. Inner APKs stay Google-signed (PRESIGNED). Same module name, so apexd treats it
# as the pre-installed com.android.tethering.
DELETE_FROM_WORK_DIR "system" "system/apex/com.google.android.tethering_compressed.apex"
EVAL "cp -a \"$SRC_DIR/target/a52sxq/patches/tethering/com.google.android.tethering.apex\" \"$WORK_DIR/system/system/apex/com.google.android.tethering.apex\""
SET_METADATA "system" "system/apex/com.google.android.tethering.apex" 0 0 644 "u:object_r:system_file:s0"
