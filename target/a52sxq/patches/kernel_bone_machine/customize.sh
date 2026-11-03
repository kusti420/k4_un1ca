# Swap the stock A528BXXU5FWK4 kernel (5.4.233, Nov 2023) for bone-machine's One UI kernel 5.4.302 (see module.prop).
# The release zip ships boot.img, vendor_boot.img and dtbo.img meant to be flashed over stock One UI 6 on the A528B:
# - boot.img: only its kernel Image is used. Our boot.img keeps its ramdisk, cmdline and header, including the
#   2023-11 OS patch level that Keymaster 4 binds keys to (raising it is a one-way key upgrade).
# - vendor_boot.img: used as is. Its first-stage fstab is identical to ours (erofs system/vendor/product/odm); its
#   ramdisk carries the 84 vendor modules rebuilt for this kernel (first-stage modules.load, wlan.ko included), so the
#   stale 5.4.233 copies in /vendor/lib/modules are never needed (their symbol CRCs do not match this kernel).
# - dtbo.img: used as is (target/a52sxq/installer/customize.sh skips the A528N dtbo while this patch is enabled).
# AVB footers are added later by the normal packaging step (images are unsigned here).
# NOTE 2026-11-01: the k4 0017 build (bone-machine_k4btf_ringbuf_su_pt_uvc8_dm_a52sxq.zip, sha256 d23e294f...) reset the
# phone at 7.5 s on its first boot, in the middle of apexd's dm-verity activation (console-ramoops: no panic text), so
# the dm uevent fix is NOT shipped; back on the 10-17 build until it is understood (scratch/bootloop_9395/).
# NOTE 2026-11-03: bone-machine_k4btf_ringbuf_su_pt_uvc8_susfs_a52sxq.zip = the uvc8_test kernel (k4-patches 0001-0016, 0017
# still parked) plus SUSFS v2.3.0 (k4-patches/0018-susfs-v2.3.0-for-5.4.patch, KSU_SUSFS=y with ReSukiSU's inline hook, see
# prebuilts/kernel/bone-machine/k4-source/susfs/). Same uname, boot.img byte-size identical (avb padding). Owner asked for
# SUSFS so root-hiding/SELinux checks pass; ReSukiSU's own selinux_hide stays the SELinux sanitizer.
KZIP="$SRC_DIR/prebuilts/kernel/bone-machine/bone-machine_k4btf_ringbuf_su_pt_uvc8_susfs_a52sxq.zip"
KSHA="6db9ab9ab13f5db84871f60a76b8f9ab79738396a673dab0a06a322fa99eb956"
KVER="5.4.302-bone-machine-qgki"
[ -f "$KZIP" ] || ABORT "kernel_bone_machine: $KZIP not found"
[ "$(sha256sum "$KZIP" | cut -d " " -f 1)" = "$KSHA" ] || ABORT "kernel_bone_machine: sha256 mismatch for $KZIP"
for f in boot.img vendor_boot.img dtbo.img; do
    [ -f "$WORK_DIR/kernel/$f" ] || ABORT "kernel_bone_machine: $WORK_DIR/kernel/$f not found"
done

KTMP="$TMP_DIR/kernel_bone_machine"
[ -d "$KTMP" ] && rm -rf "$KTMP"
mkdir -p "$KTMP"
EVAL "unzip -q -o \"$KZIP\" images/boot.img images/vendor_boot.img images/dtbo.img -d \"$KTMP\"" || ABORT "kernel_bone_machine: unzip failed"

LOG "- Extracting the $KVER kernel"
EVAL "unpack_bootimg --boot_img \"$KTMP/images/boot.img\" --out \"$KTMP/new\"" || ABORT "kernel_bone_machine: cannot unpack the release boot.img"
[[ "$(LC_ALL=C file -b "$KTMP/new/kernel")" == "Linux kernel ARM64"* ]] || ABORT "kernel_bone_machine: release kernel is not an ARM64 Image"
strings -n 20 "$KTMP/new/kernel" | grep -q "Linux version $KVER " || ABORT "kernel_bone_machine: unexpected kernel version"

LOG "- Repacking boot.img with the $KVER kernel (keeping our ramdisk, cmdline and OS patch level)"
KARGS="$(unpack_bootimg --boot_img "$WORK_DIR/kernel/boot.img" --out "$KTMP/ours" --format mkbootimg 2>&1)"
[ -f "$KTMP/ours/kernel" ] || ABORT "kernel_bone_machine: cannot unpack our boot.img\n\n$KARGS"
EVAL "cp -f \"$KTMP/new/kernel\" \"$KTMP/ours/kernel\""
EVAL "cd \"$KTMP\" && mkbootimg $KARGS -o \"$KTMP/boot.img\"" || ABORT "kernel_bone_machine: mkbootimg failed"
if $TARGET_BOOT_SEANDROID_MAGIC; then
    echo -n "SEANDROIDENFORCE" >> "$KTMP/boot.img"
else
    head -c 16 /dev/zero >> "$KTMP/boot.img"
fi
EVAL "mv -f \"$KTMP/boot.img\" \"$WORK_DIR/kernel/boot.img\""

LOG "- Using the release vendor_boot.img (modules rebuilt for $KVER) and dtbo.img"
EVAL "cp -f \"$KTMP/images/vendor_boot.img\" \"$WORK_DIR/kernel/vendor_boot.img\""
EVAL "cp -f \"$KTMP/images/dtbo.img\" \"$WORK_DIR/kernel/dtbo.img\""

rm -rf "$KTMP"
LOG "- Kernel: Linux $KVER"
unset KZIP KSHA KVER KTMP KARGS f
