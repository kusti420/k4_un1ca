SKIPUNZIP=1

# GPU driver selector (Settings > K4_UN1CA > UI > GPU driver). The stock A52s Adreno V@0530 stays in /vendor untouched:
# it is what every fallback goes to and stays selectable, and V@0849 is the default (GPU_DEFAULT: what a phone with no
# selection gets, see below). The built-in sets are every v<id>/ directory of this patch (v849 = V@0849, v863 =
# V@0863.1, v530_55 = V@0530.55: the id is the version with "." as "_"), pinned by v<id>/SHA256SUMS, installed as
# complete sets under /vendor/k4gpu/v<id>/; /system/etc/init/k4_gpu_driver.rc puts the selected one in place at early-boot:
#   - its egl directory bound over /vendor/lib64/egl (the stock one holds only the six Adreno libraries; the set's
#     libraries that stock has no counterpart for, e.g. libadreno_app_profiles.so, live in that egl directory, which is
#     on the sphal and vendor linker search paths, so they are never visible while V@0530 is active: the stock GL/Vulkan
#     libraries dlopen libadreno_app_profiles.so when it exists),
#   - its other libraries bound one by one over their stock counterparts in /vendor/lib64 and /vendor/lib64/hw (an
#     overlay of all of /vendor/lib64 does not work: overlayfs checks every lower file with init's credentials, so
#     SurfaceFlinger could no longer load the gralloc mapper - 9.3.64 test),
#   - its a660 SQE microcode, if the set has one, bound over /vendor/firmware/a660_sqe.fw (kgsl reads it on the first
#     /dev/kgsl-3d0 open, by the camera provider / SurfaceFlinger at boot, i.e. after early-boot),
#   - for V@07xx and newer builds, android.hardware.vulkan.version 1.3 bound over the vendor's 1.1 feature file (the flag
#     must match the driver: V@0530 builds report Vulkan 1.1, V@0849 / V@0863 1.3).
# Selection: persist.sys.k4.gpu_driver = 530 | <id> | m_<module> | u_<added>. Unset (a new install, a Format Data):
# k4-gpu-driver boot selects the default (ro.k4.gpu_default = GPU_DEFAULT) on that boot with a trial boot, exactly like
# a user-selected driver - init.rc's own post-fs-data block loads the persistent properties before this patch's
# post-fs-data exec runs, so the selection is stored. An existing selection is never changed: a phone that ran
# 9.3.105 or older has 530 stored (written by the user in Settings or by k4-gpu-driver when nothing was selected -
# the two cannot be told apart), so it stays on the stock driver until its user picks V@0849 in Settings.
# Failsafe: Settings sets persist.sys.k4.gpu_trial=pending; the rc turns it into "testing" for that boot; k4-gpu-driver
# settle turns it into "ok" only after 150 s past boot_completed with no system_server restart; "testing" still set at
# the next boot means that boot never settled (a bootloop, or a crash/reboot inside the window), so the stock V@0530
# is used and stored as the selection (also when the default was on trial: no second trial of it on the next boot),
# persist.sys.k4.gpu_failed records the driver and the trial is set to "failed". sys.k4.gpu_active reports what this
# boot actually uses. Escapes that need no root: persist.sys.safemode=1 (Android safe mode) runs the stock driver for
# that boot; `setprop persist.sys.k4.gpu_reset 1` (settable from adb shell) resets to the stock driver next boot.
# History: V@0849 was the default from 9.1.25 (2026-10-09) to 9.3.63; the stock V@0530 from 9.3.64 (2026-10-21, at
# the testers' request) to 9.3.105; V@0849 again since 9.3.106 (owner decision after the 2026-10-20 benchmarks and the
# 2026-11-04 battery review: +5 % GL / +8 % Vulkan graphics, -8 % light-load scroll power, same clocks and heat).
#
# Drivers the user brings (k4-gpu-driver, run by the rc at post-fs-data in its own SELinux domain k4gpu): KernelSU /
# Magisk driver modules and drivers added in Settings ("Add driver") are kept in /data/k4gpu/store and bound the same
# way, at post-fs-data (before zygote-start). A module already mounted over /vendor by the root manager (metamodule,
# magic mount, Mountify) is left alone and reported as active. See k4-gpu-driver for the details.
# the stock driver's id (nothing to mount; the failsafe, the reset and safe mode go to it) and the default for a phone
# with no selection (the stock id, or one of the built-in sets below)
GPU_STOCK_ID="530"
GPU_DEFAULT="849"
VK13=4206592

# The stock driver must still be the one in /vendor (an older build of this patch replaced it in place). Exact
# version: "V@0530." alone would also match the V@0530.55 set. k4-gpu-driver gets it to tell a driver flashed into
# /vendor from the stock one.
GPU_STOCK_VER="V@0530.0"
GPU_STOCK="$(grep -a -o -m 1 -E 'V@[0-9]{3,4}\.[0-9]+(\.[0-9]+)?' "$WORK_DIR/vendor/lib64/egl/libGLESv2_adreno.so" | head -n 1)"
[ "$GPU_STOCK" = "$GPU_STOCK_VER" ] || \
    ABORT "adreno_driver: /vendor/lib64/egl/libGLESv2_adreno.so is not the stock $GPU_STOCK_VER ($GPU_STOCK)"

GPU_SETS=""
for d in "$MODPATH"/v*/; do
    v="${d%/}"
    v="${v##*/v}"
    [[ "$v" =~ ^[0-9]+(_[0-9]+)*$ ]] || ABORT "adreno_driver: unexpected set directory v$v (v<version with _ for .>)"
    [ "$v" != "$GPU_STOCK_ID" ] || ABORT "adreno_driver: v$GPU_STOCK_ID would shadow the stock driver"
    GPU_SETS+="${GPU_SETS:+ }$v"
done
[ -n "$GPU_SETS" ] || ABORT "adreno_driver: no driver set"
case " $GPU_STOCK_ID $GPU_SETS " in
    *" $GPU_DEFAULT "*) ;;
    *) ABORT "adreno_driver: the default v$GPU_DEFAULT is neither the stock driver nor a built-in set" ;;
esac

SET_METADATA "vendor" "k4gpu" 0 2000 755 "u:object_r:vendor_file:s0"
for v in $GPU_SETS; do
    SRC="$MODPATH/v$v/vendor"
    VER="V@0${v//_/.}."  # v530_55 -> "V@0530.55."
    [ -f "$SRC/lib64/egl/libGLESv2_adreno.so" ] || ABORT "adreno_driver: no driver set v$v"
    # pinned: every file of the set exactly as reviewed (v$v/SHA256SUMS), and nothing else
    [ -f "$MODPATH/v$v/SHA256SUMS" ] || ABORT "adreno_driver: v$v has no SHA256SUMS"
    (cd "$MODPATH/v$v" && sha256sum --quiet --strict -c SHA256SUMS) || ABORT "adreno_driver: v$v does not match v$v/SHA256SUMS"
    [ "$(cd "$MODPATH/v$v" && find vendor -type f | LC_ALL=C sort)" = "$(sed 's/^[0-9a-f]*  //' "$MODPATH/v$v/SHA256SUMS" | LC_ALL=C sort)" ] || \
        ABORT "adreno_driver: v$v has files that are not in v$v/SHA256SUMS"
    grep -q -a -F "$VER" "$SRC/lib64/egl/libGLESv2_adreno.so" || ABORT "adreno_driver: v$v/libGLESv2_adreno.so is not $VER*"
    for f in lib64/egl/libEGL_adreno.so lib64/egl/libGLESv1_CM_adreno.so lib64/hw/vulkan.adreno.so; do
        [ -f "$SRC/$f" ] || ABORT "adreno_driver: v$v has no $f"
    done
    DST="$WORK_DIR/vendor/k4gpu/v$v"
    EVAL "rm -rf \"$DST\" && mkdir -p \"$DST/egl\""
    BINDS=""
    while IFS= read -r f; do
        case "$f" in
            lib64/egl/*) t="egl/${f#lib64/egl/}" ;;
            firmware/*) t="$f" ;;
            *) if [ -f "$WORK_DIR/vendor/$f" ]; then t="$f"; BINDS+=" $f"; else t="egl/$(basename "$f")"; fi ;;
        esac
        EVAL "mkdir -p \"$(dirname "$DST/$t")\" && cp -a \"$SRC/$f\" \"$DST/$t\""
        # same label as the stock file it covers (libkcl, libkernelmanager, libgpu_tonemapper are vendor_file on stock)
        case "$t" in
            firmware/*) LABEL="u:object_r:vendor_firmware_file:s0" ;;
            egl/*) LABEL="u:object_r:same_process_hal_file:s0" ;;
            *) LABEL="$(K="/vendor/$(_HANDLE_SPECIAL_CHARS "$f")" awk '$1 == ENVIRON["K"] { print $2; exit }' "$WORK_DIR/configs/file_context-vendor")"
               [ -n "$LABEL" ] || LABEL="u:object_r:same_process_hal_file:s0" ;;
        esac
        SET_METADATA "vendor" "k4gpu/v$v/$t" 0 0 644 "$LABEL"
    done < <(cd "$SRC" && find . -type f | sed "s|^\./||" | LC_ALL=C sort)
    while IFS= read -r d; do
        LABEL="u:object_r:vendor_file:s0"; [ "$d" = "egl" ] && LABEL="u:object_r:same_process_hal_file:s0"
        SET_METADATA "vendor" "k4gpu/v$v/$d" 0 2000 755 "$LABEL"
    done < <(cd "$DST" && find . -mindepth 1 -type d | sed "s|^\./||" | LC_ALL=C sort)
    eval "GPU_BINDS_$v=\"$BINDS\""
    # the microcode is optional (without one the stock a660 SQE stays); V@07xx+ report Vulkan 1.3, V@0530 builds
    # (stock and V@0530.55) Vulkan 1.1. Only a660_sqe.fw is ever bound: the unsigned command-processor microcode.
    # Signed firmware (zap shader, GMU) is never shipped or bound.
    [ -z "$(cd "$SRC" && find . -path "./firmware/*" ! -name a660_sqe.fw)" ] || ABORT "adreno_driver: v$v ships firmware other than a660_sqe.fw"
    if [ -f "$SRC/firmware/a660_sqe.fw" ]; then eval "GPU_SQE_$v=1"; else LOG "- adreno_driver: v$v has no a660_sqe.fw, the stock one stays"; fi
    [ "${v%%_*}" -ge 700 ] && eval "GPU_VK_$v=1"
    SET_METADATA "vendor" "k4gpu/v$v" 0 2000 755 "u:object_r:vendor_file:s0"
done

VKXML="$WORK_DIR/vendor/etc/permissions/android.hardware.vulkan.version-1_1.xml"
grep -q 'name="android.hardware.vulkan.version" version="4198400"' "$VKXML" || \
    ABORT "adreno_driver: ${VKXML//$WORK_DIR/} is not the stock Vulkan 1.1 feature file"
EVAL "sed 's|version=\"4198400\"|version=\"$VK13\"|' \"$VKXML\" > \"$WORK_DIR/vendor/k4gpu/vulkan.version-1_3.xml\""
grep -q "version=\"$VK13\"" "$WORK_DIR/vendor/k4gpu/vulkan.version-1_3.xml" || ABORT "adreno_driver: Vulkan 1.3 feature file"
SET_METADATA "vendor" "k4gpu/vulkan.version-1_3.xml" 0 0 644 "u:object_r:vendor_configs_file:s0"

# user drivers: the boot-time part (modules, "Add driver" imports, failsafe for them, mounts)
EVAL "cp -f \"$MODPATH/k4-gpu-driver\" \"$WORK_DIR/system/system/bin/k4-gpu-driver\""
SET_METADATA "system" "system/bin/k4-gpu-driver" 0 2000 755 "u:object_r:system_file:s0"

RC="$WORK_DIR/system/system/etc/init/k4_gpu_driver.rc"
{
    echo "# GPU driver selector (target/a52sxq/patches/adreno_driver). V@0$GPU_STOCK_ID = stock, nothing to mount; it is"
    echo "# what the failsafe below falls back to. A phone with no selection gets V@0$GPU_DEFAULT (ro.k4.gpu_default),"
    echo "# selected by k4-gpu-driver boot with a trial boot like any newly selected driver."
    echo "# User drivers (driver modules, Settings > Add driver): k4-gpu-driver, after the root manager's post-fs-data"
    echo "# (KernelSU / Magisk run theirs from init.rc, which comes first) and before zygote-start. It also does the"
    echo "# failsafe below first, for every driver, and selects a newly installed driver module with a trial boot."
    echo "# The import is bounded by a 180 s timeout (init waits for it) so a bad / huge module cannot hang the boot."
    echo "on post-fs-data"
    echo "    mkdir /data/k4gpu 0751 root system"
    echo "    mkdir /data/k4gpu/store 0755 root root"
    echo "    mkdir /data/k4gpu/incoming 0770 system system"
    echo "    exec u:r:k4gpu:s0 root system -- /system/bin/timeout 180 /system/bin/sh /system/bin/k4-gpu-driver boot $GPU_STOCK"
    echo
    echo "# A newly selected user driver is on trial: the trial becomes ok only once the device has run 150 s past"
    echo "# boot_completed with no system_server restart (k4-gpu-driver settle). A reboot or a system_server crash"
    echo "# inside that window leaves the trial = testing, so the next boot reverts to the stock driver (failsafe)."
    echo "# This recovers a user driver that boots but then breaks SystemUI / the launcher, not only one that bootloops."
    echo "service k4_gpu_settle /system/bin/timeout 200 /system/bin/sh /system/bin/k4-gpu-driver settle 150"
    echo "    user system"
    echo "    group system"
    echo "    seclabel u:r:k4gpu:s0"
    echo "    oneshot"
    echo "    disabled"
    echo
    echo "on property:sys.boot_completed=1 && property:persist.sys.k4.gpu_trial=testing"
    echo "    start k4_gpu_settle"
    echo
    echo "on early-boot"
    echo "    setprop sys.k4.gpu_active \${sys.k4.gpu_user_active:-$GPU_STOCK_ID}"
    echo
    echo "# The previous boot with a newly selected driver never reached boot_completed: back to the stock driver, stored"
    echo "# as the selection (so a failed trial of the default is not retried on every boot)."
    echo "on early-boot && property:persist.sys.k4.gpu_trial=testing"
    echo "    setprop persist.sys.k4.gpu_failed \${persist.sys.k4.gpu_driver}"
    echo "    setprop persist.sys.k4.gpu_driver $GPU_STOCK_ID"
    echo "    setprop persist.sys.k4.gpu_trial failed"
    echo
    echo "on early-boot && property:persist.sys.k4.gpu_trial=pending"
    echo "    setprop persist.sys.k4.gpu_trial testing"
    for v in $GPU_SETS; do
        for t in pending ok; do
            echo
            echo "on early-boot && property:persist.sys.k4.gpu_driver=$v && property:persist.sys.k4.gpu_trial=$t"
            echo "    mount none /vendor/k4gpu/v$v/egl /vendor/lib64/egl bind"
            eval "B=\"\$GPU_BINDS_$v\""
            for f in $B; do
                echo "    mount none /vendor/k4gpu/v$v/$f /vendor/$f bind"
            done
            eval "[ -n \"\${GPU_SQE_$v:-}\" ]" && \
                echo "    mount none /vendor/k4gpu/v$v/firmware/a660_sqe.fw /vendor/firmware/a660_sqe.fw bind"
            eval "[ -n \"\${GPU_VK_$v:-}\" ]" && \
                echo "    mount none /vendor/k4gpu/vulkan.version-1_3.xml /vendor/etc/permissions/android.hardware.vulkan.version-1_1.xml bind"
            echo "    setprop sys.k4.gpu_active $v"
        done
    done
} > "$RC"
SET_METADATA "system" "system/etc/init/k4_gpu_driver.rc" 0 0 644 "u:object_r:system_file:s0"

# KernelSU: no metamodule (meta-overlayfs, Mountify, ...) may mount a driver module - mounted with KernelSU's default
# label vendor_file it bootloops the phone (SurfaceFlinger abort, 9.3.81) and skips the failsafe above. `k4-gpu-driver
# guard` gives every driver module a skip_mount file; it must run before ksud's post-fs-data, where the metamodule
# mounts. KernelSU's kernel appends its "on post-fs-data / exec u:r:ksu:s0 root -- /data/adb/ksud post-fs-data" to
# init.rc when init reads it (at EOF: kernel/runtime/ksud_integration.c read_proxy), and init runs the actions of one
# trigger in the order it parsed them: init.rc first (its own post-fs-data block with installkey /data comes earlier
# in the file), then its imports and /system/etc/init. So an action at the end of init.rc is the last one before
# ksud's. It runs in KernelSU's own domain, like ksud's line right after it (and like the k4_metamod service): without
# KernelSU that domain does not exist, the exec's child cannot set it and exits, init logs it and goes on.
# k4-metamodule also writes the same guard into ksud's post-fs-data.d (covers later boots if a KernelSU build ever
# put its part first). Bounded: the guard only looks at module directories.
INIT_RC="$WORK_DIR/system/system/etc/init/hw/init.rc"
[ -f "$INIT_RC" ] || ABORT "adreno_driver: no /system/etc/init/hw/init.rc"
if ! grep -q "k4-gpu-driver guard" "$INIT_RC"; then
    grep -q "^on post-fs-data$" "$INIT_RC" || ABORT "adreno_driver: no post-fs-data action in init.rc"
    grep -q "^ *installkey /data$" "$INIT_RC" || ABORT "adreno_driver: init.rc does not install the /data key at post-fs-data"
    [ -z "$(tail -c 1 "$INIT_RC")" ] || echo >> "$INIT_RC"
    cat >> "$INIT_RC" << 'EOF'

# K4: KernelSU metamodules never mount an Adreno GPU driver module: skip_mount for each, right before ksud's
# post-fs-data (KernelSU appends it after this line); the GPU driver selector imports them (target/a52sxq/patches/
# adreno_driver, /system/bin/k4-gpu-driver). Without KernelSU the domain does not exist and this does nothing.
on post-fs-data
    exec u:r:ksu:s0 root root -- /system/bin/timeout 20 /system/bin/sh /system/bin/k4-gpu-driver guard
EOF
fi
[ "$(grep -c "k4-gpu-driver guard" "$INIT_RC")" = 1 ] && [ "$(tail -n 1 "$INIT_RC")" = \
    "    exec u:r:ksu:s0 root root -- /system/bin/timeout 20 /system/bin/sh /system/bin/k4-gpu-driver guard" ] || \
    ABORT "adreno_driver: the guard action is not the last one of init.rc"

# init mounts the sets (bind mounts only: the files keep their own labels, init only needs mounton on the targets).
PLAT_CIL="$WORK_DIR/system/system/etc/selinux/plat_sepolicy.cil"
if ! grep -q "^; k4 gpu driver selector" "$PLAT_CIL"; then
    {
        echo "; k4 gpu driver selector (target/a52sxq/patches/adreno_driver): init binds the selected set at early-boot"
        echo "(allow init same_process_hal_file (dir (mounton)))"
        echo "(allow init same_process_hal_file (file (mounton)))"
        echo "(allow init vendor_file (file (mounton)))"
        echo "(allow init vendor_firmware_file (file (mounton)))"
        echo "(allow init vendor_configs_file (file (mounton)))"
    } >> "$PLAT_CIL"
fi

# User drivers: the k4gpu domain (k4-gpu-driver), the /data/k4gpu types and the selector's own property type
# (persist.sys.k4.gpu_* and sys.k4.gpu_*, set by Settings, k4-gpu-driver and init; they were system_prop before).
# init compiles the split policy at boot, so a rule naming a type that does not exist would stop the boot: check
# every type first.
PLAT_FC="$WORK_DIR/system/system/etc/selinux/plat_file_contexts"
PLAT_PC="$WORK_DIR/system/system/etc/selinux/plat_property_contexts"
if ! grep -q -x -F "(type k4gpu)" "$PLAT_CIL"; then
    for t in init shell_exec toolbox_exec system_file kmsg_device system_data_root_file adb_data_file \
        same_process_hal_file vendor_file vendor_hal_file vendor_configs_file labeledfs \
        property_socket default_prop system_prop safemode_prop boot_status_prop last_boot_reason_prop system_app shell; do
        grep -q -x -F "(type $t)" "$PLAT_CIL" || ABORT "adreno_driver: type $t not in plat_sepolicy.cil, review sepolicy.cil"
    done
    # the SQE label is the vendor's own type (Qualcomm vendor_sepolicy.cil), like the early-boot rule above uses it
    grep -q -x -F "(type vendor_firmware_file)" "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil" || \
        ABORT "adreno_driver: type vendor_firmware_file not in vendor_sepolicy.cil, review sepolicy.cil"
    # secilc rejects a second typeattributeset for an attribute, so extend the existing ones
    for a in "domain k4gpu" "file_type k4_gpu_data_file k4_gpu_incoming_file" \
        "data_file_type k4_gpu_data_file k4_gpu_incoming_file" "core_data_file_type k4_gpu_data_file k4_gpu_incoming_file" \
        "property_type k4_gpu_prop k4_gpu_reset_prop" "system_property_type k4_gpu_prop k4_gpu_reset_prop"; do
        n="${a%% *}"
        [ "$(grep -c "^(typeattributeset $n (" "$PLAT_CIL")" = 1 ] || ABORT "adreno_driver: no single $n attribute set in plat_sepolicy.cil"
        sed -i "s/^(typeattributeset $n (/(typeattributeset $n (${a#* } /" "$PLAT_CIL"
        grep -q "^(typeattributeset $n (${a#* } " "$PLAT_CIL" || ABORT "adreno_driver: failed to extend $n"
    done
    [ -z "$(tail -c 1 "$PLAT_CIL")" ] || echo >> "$PLAT_CIL"
    echo "; k4 gpu user drivers (target/a52sxq/patches/adreno_driver/sepolicy.cil)" >> "$PLAT_CIL"
    cat "$MODPATH/sepolicy.cil" >> "$PLAT_CIL"

    grep -q "^/data/k4gpu" "$PLAT_FC" && ABORT "adreno_driver: /data/k4gpu already in plat_file_contexts"
    [ -z "$(tail -c 1 "$PLAT_FC")" ] || echo >> "$PLAT_FC"
    {
        echo "/data/k4gpu(/.*)?                                 u:object_r:k4_gpu_data_file:s0"
        echo "/data/k4gpu/incoming(/.*)?                        u:object_r:k4_gpu_incoming_file:s0"
        echo "/data/k4gpu/store/[^/]+/(egl|lib64)(/.*)?         u:object_r:same_process_hal_file:s0"
        echo "/data/k4gpu/store/[^/]+/firmware(/.*)?            u:object_r:vendor_firmware_file:s0"
    } >> "$PLAT_FC"

    grep -q -E "^(persist\.)?sys\.k4\.gpu" "$PLAT_PC" && ABORT "adreno_driver: sys.k4.gpu already in plat_property_contexts"
    [ -z "$(tail -c 1 "$PLAT_PC")" ] || echo >> "$PLAT_PC"
    {
        echo "persist.sys.k4.gpu_      u:object_r:k4_gpu_prop:s0"
        echo "sys.k4.gpu_              u:object_r:k4_gpu_prop:s0"
        echo "persist.sys.k4.gpu_reset u:object_r:k4_gpu_reset_prop:s0"
    } >> "$PLAT_PC"
fi
grep -q -x -F "(allow system_app k4_gpu_prop (property_service (set)))" "$PLAT_CIL" || \
    ABORT "adreno_driver: k4gpu rules missing from plat_sepolicy.cil"

# read by Settings (GpuDriverModel) and k4-gpu-driver: system props (init does not load ro.k4.* from the vendor
# build.prop). gpu_drivers = "<stock> <set>..." (the stock driver first), gpu_default = the selection a phone with none
# gets.
SET_PROP "system" "ro.k4.gpu_drivers" "$GPU_STOCK_ID $GPU_SETS"
SET_PROP "system" "ro.k4.gpu_default" "$GPU_DEFAULT"
LOG "- GPU driver selector: V@0${GPU_DEFAULT//_/.} default (stock $GPU_STOCK the fallback), $(sed "s/_/./g; s/^/V@0/; s/ /, V@0/g" <<< "$GPU_SETS") built in, user drivers via k4-gpu-driver"
for v in $GPU_SETS; do unset "GPU_BINDS_$v" "GPU_SQE_$v" "GPU_VK_$v"; done
unset GPU_STOCK_ID GPU_DEFAULT GPU_SETS GPU_STOCK GPU_STOCK_VER VK13 SRC DST VER BINDS B LABEL VKXML RC INIT_RC PLAT_CIL PLAT_FC PLAT_PC v t d f n a
