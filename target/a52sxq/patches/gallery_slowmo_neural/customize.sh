# See module.prop. Installs the neural frame rate conversion front (k4neuralmpp) next to the stock MPP store and
# points the system MPP client at it. Part of every release build (there is no `disable` marker): from then on ALL
# system MPP traffic goes through k4neuralmpp, which serves the FRC pipe itself and forwards everything else to the
# stock store, so the daemon must stay up and responsive for any video playback that uses MPP.
#
# Third-party files are NOT in git: the Qualcomm AI Runtime (QAIRT) SDK runtime libraries are taken from
# prebuilts/qairt/2.46.0/ and the model from prebuilts/k4neural/ (both in .git/info/exclude). The SDK's NOTICE.txt
# is installed next to the libraries.
SRC="$SRC_DIR/target/a52sxq/patches/gallery_slowmo_neural"
QAIRT="$SRC_DIR/prebuilts/qairt/2.46.0"
MODEL="$SRC_DIR/prebuilts/k4neural/k4n_v3_htp.dlc"
FILM_MODEL="$SRC_DIR/prebuilts/k4neural/k4n_film256_htp.dlc"
MPP_STORE="vendor.samsung.hardware.media.mpp.ISehMppStore"

[ ! -f "$SRC_DIR/target/a52sxq/patches/gallery_slowmo/disable" ] || \
    ABORT "gallery_slowmo_neural needs the gallery_slowmo patch (player-side FRC patches), which is disabled"
for f in prebuilt/k4neuralmpp k4neuralmpp.rc k4neuralmpp.xml; do
    [ -f "$SRC/$f" ] || ABORT "gallery_slowmo_neural: $f missing from the patch dir"
done
for f in libSNPE.so libSnpeHtpV68Stub.so libSnpeHtpV68Skel.so NOTICE.txt; do
    [ -f "$QAIRT/$f" ] || ABORT "gallery_slowmo_neural: prebuilts/qairt/2.46.0/$f is missing. Copy it from your own Qualcomm AI Runtime SDK 2.46.0 download (lib/aarch64-android/libSNPE.so, lib/aarch64-android/libSnpeHtpV68Stub.so, lib/hexagon-v68/unsigned/libSnpeHtpV68Skel.so, NOTICE.txt); these files are not kept in git"
done
[ -f "$MODEL" ] || ABORT "gallery_slowmo_neural: prebuilts/k4neural/k4n_v3_htp.dlc is missing (not kept in git)"
[ -f "$WORK_DIR/vendor/bin/hw/mppserver" ] || ABORT "gallery_slowmo_neural: the vendor has no stock MPP store (mppserver)"
grep -q -F "ISehMppStore/default" "$WORK_DIR/vendor/etc/vintf/manifest/mppserver.xml" 2> /dev/null || \
    ABORT "gallery_slowmo_neural: the stock VINTF manifest does not declare ISehMppStore/default"
[ -d "$WORK_DIR/vendor/lib/rfsa/adsp" ] || ABORT "gallery_slowmo_neural: /vendor/lib/rfsa/adsp (Hexagon skel dir) not found"

LOG_STEP_IN "- Installing the neural frame rate conversion front (k4neuralmpp)"

# K4N_INSTALL <source file> <path under /vendor> <uid> <gid> <mode> <label>
K4N_INSTALL()
{
    EVAL "mkdir -p \"$(dirname "$WORK_DIR/vendor/$2")\"" || ABORT "gallery_slowmo_neural: mkdir for $2 failed"
    EVAL "cp -f \"$1\" \"$WORK_DIR/vendor/$2\"" || ABORT "gallery_slowmo_neural: failed to install $2"
    SET_METADATA "vendor" "$2" "$3" "$4" "$5" "$6"
}

EVAL "mkdir -p \"$WORK_DIR/vendor/etc/k4neural\" \"$WORK_DIR/vendor/lib64/k4neural\""
SET_METADATA "vendor" "etc/k4neural" 0 2000 755 "u:object_r:vendor_configs_file:s0"
SET_METADATA "vendor" "lib64/k4neural" 0 2000 755 "u:object_r:vendor_file:s0"
K4N_INSTALL "$SRC/prebuilt/k4neuralmpp" "bin/hw/k4neuralmpp" 0 2000 755 "u:object_r:hal_mpp_default_exec:s0"
K4N_INSTALL "$SRC/k4neuralmpp.rc" "etc/init/k4neuralmpp.rc" 0 0 644 "u:object_r:vendor_configs_file:s0"
K4N_INSTALL "$SRC/k4neuralmpp.xml" "etc/vintf/manifest/k4neuralmpp.xml" 0 0 644 "u:object_r:vendor_configs_file:s0"
K4N_INSTALL "$MODEL" "etc/k4neural/k4n_v3_htp.dlc" 0 0 644 "u:object_r:vendor_configs_file:s0"
# FILM (Google film_net, Apache-2.0; A16W8, prepared for the SM7325 HTP) for the offline "Save slow-mo clip" (config A,
# K4SlowMoExport). Optional: without it the daemon refuses the render session and the save records the neural playback.
if [ -f "$FILM_MODEL" ]; then
    K4N_INSTALL "$FILM_MODEL" "etc/k4neural/k4n_film256_htp.dlc" 0 0 644 "u:object_r:vendor_configs_file:s0"
else
    LOG "  (prebuilts/k4neural/k4n_film256_htp.dlc not found: Save slow-mo clip stays on the real-time recording)"
fi
K4N_INSTALL "$QAIRT/libSNPE.so" "lib64/k4neural/libSNPE.so" 0 0 644 "u:object_r:vendor_file:s0"
K4N_INSTALL "$QAIRT/libSnpeHtpV68Stub.so" "lib64/k4neural/libSnpeHtpV68Stub.so" 0 0 644 "u:object_r:vendor_file:s0"
K4N_INSTALL "$QAIRT/NOTICE.txt" "lib64/k4neural/NOTICE.txt" 0 0 644 "u:object_r:vendor_file:s0"
K4N_INSTALL "$QAIRT/libSnpeHtpV68Skel.so" "lib/rfsa/adsp/libSnpeHtpV68Skel.so" 0 0 644 "u:object_r:vendor_file:s0"

# SELinux: the daemon runs in the stock store's own domain (exec label), serves a second instance of the same
# interface, and needs the non-secure fastrpc node + fastrpc properties for an unsigned PD on the cDSP (the stock
# SNPE user snap_hidl has the same rules), binder calls to the stock store (same domain) and the persist.sys switch.
# Compiled with the device's own secilc (init's argument list) before shipping.
SEPOL="$WORK_DIR/vendor/etc/selinux"
for f in vendor_service_contexts vendor_file_contexts vendor_sepolicy.cil; do
    [ -f "$SEPOL/$f" ] || ABORT "gallery_slowmo_neural: /vendor/etc/selinux/$f not found"
done
grep -q "hal_mpp_default_exec" "$SEPOL/vendor_file_contexts" || ABORT "gallery_slowmo_neural: vendor policy has no hal_mpp_default_exec"
grep -q "hal_mpp_service" "$SEPOL/vendor_service_contexts" || ABORT "gallery_slowmo_neural: vendor policy has no hal_mpp_service"

# K4N_APPEND_LINE <file> <exact line>
K4N_APPEND_LINE()
{
    if ! grep -q -x -F -- "$2" "$1"; then
        [ -z "$(tail -c 1 "$1")" ] || echo >> "$1"
        printf '%s\n' "$2" >> "$1"
    fi
    grep -q -x -F -- "$2" "$1" || ABORT "gallery_slowmo_neural: failed to add a line to ${1//$WORK_DIR/}"
}

K4N_APPEND_LINE "$SEPOL/vendor_service_contexts" "$MPP_STORE/k4front		u:object_r:hal_mpp_service:s0"
K4N_APPEND_LINE "$SEPOL/vendor_file_contexts" "/vendor/bin/hw/k4neuralmpp		u:object_r:hal_mpp_default_exec:s0"
K4N_APPEND_LINE "$SEPOL/vendor_sepolicy.cil" "(allow hal_mpp_default hal_mpp_default (binder (call transfer)))"
K4N_APPEND_LINE "$SEPOL/vendor_sepolicy.cil" "(allow hal_mpp_default vendor_qdsp_device (chr_file (ioctl read getattr lock map open)))"
K4N_APPEND_LINE "$SEPOL/vendor_sepolicy.cil" "(allow hal_mpp_default vendor_adsprpc_prop (file (read getattr map open)))"
K4N_APPEND_LINE "$SEPOL/vendor_sepolicy.cil" "(allow hal_mpp_default system_prop_30_0 (file (read getattr map open)))"
LOG "- hal_mpp_default: second store instance k4front, unsigned PD on the cDSP"

# The system MPP client asks servicemanager for ".../default"; point it at our front, which forwards everything
# that is not the neural FRC pipe to the stock store. One NUL-terminated string, same length.
MPPCLIENT="$WORK_DIR/system/system/lib64/libmppclient.so"
[ -f "$MPPCLIENT" ] || ABORT "gallery_slowmo_neural: /system/lib64/libmppclient.so not found"
python3 - "$MPPCLIENT" "$MPP_STORE" << 'PYEOF' || ABORT "Failed to patch libmppclient.so"
import sys
p, store = sys.argv[1], sys.argv[2].encode()
old, new = store + b"/default\0", store + b"/k4front\0"
assert len(old) == len(new)
d = open(p, "rb").read()
n_old, n_new = d.count(old), d.count(new)
if n_old == 0 and n_new == 1:
    print("  - libmppclient.so already asks for k4front")
else:
    assert n_old == 1 and n_new == 0, "instance string: %d default / %d k4front" % (n_old, n_new)
    o = d.index(old)
    open(p, "wb").write(d[:o] + new + d[o + len(old):])
    print("  - libmppclient.so: ISehMppStore/default -> ISehMppStore/k4front at 0x%x" % o)
PYEOF

LOG_STEP_OUT
unset SRC QAIRT MODEL MPP_STORE SEPOL MPPCLIENT f
unset -f K4N_INSTALL K4N_APPEND_LINE
