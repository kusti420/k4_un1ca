#!/usr/bin/env bash
# Host test of k4-gpu-driver (the boot-time part of the GPU driver selector for user drivers): every scenario runs
# the real script against a fake root (K4GPU_ROOT: /data/k4gpu, /data/adb, /vendor), properties in a file
# (K4GPU_PROPFILE) and recorded instead of real bind mounts (K4GPU_FAKEMOUNT). The driver files are tiny fake ELF
# files that carry a version string like the real libraries. Nothing here is shipped.
# Usage: run.sh [-v]   (-v: print the script's log of every boot)
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="$HERE/../k4-gpu-driver"
SH="${K4GPU_TEST_SH:-bash}"
VERBOSE=false
[ "${1:-}" = -v ] && VERBOSE=true
T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT
PASS=0
FAIL=0

ok() { PASS=$((PASS + 1)); }
bad() { FAIL=$((FAIL + 1)); echo "FAIL [$CASE]: $*"; }
eq() { [ "$2" = "$3" ] && ok || bad "$1: expected '$3', got '$2'"; }
has() { grep -q -F -- "$2" "$3" && ok || bad "$1: '$2' not in $(basename "$3")"; }
hasnt() { grep -q -F -- "$2" "$3" && bad "$1: '$2' unexpectedly in $(basename "$3")" || ok; }

# the store/incoming slot name the script derives for a module id (slot_name in k4-gpu-driver)
mslot() { printf 'm_%s_%s' "$(printf '%s' "$1" | tr -c 'A-Za-z0-9._+-' '_' | cut -c 1-30)" "$(printf '%s' "$1" | sha1sum | cut -c 1-8)"; }

# fake_lib <file> <version or -> [32]: 20-byte ELF header (aarch64 or 32-bit ARM), a version string, padding
fake_lib() {
    mkdir -p "$(dirname "$1")"
    if [ "${3:-}" = 32 ]; then
        printf '\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x03\x00\x28\x00' > "$1"
    else
        printf '\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x03\x00\xb7\x00' > "$1"
    fi
    [ "$2" = - ] || printf 'Qualcomm build %s (GIT@0000000000, I0000000000, 1700000000)\n' "$2" >> "$1"
    printf '%s\n' "$(basename "$1")" >> "$1"
}

# fake_set <vendor-like root> <version> [32]: a complete set like the shipped ones
fake_set() {
    local r="$1" v="$2" b="${3:-}" d=lib64
    [ "$b" = 32 ] && d=lib
    for n in libGLESv2_adreno.so libEGL_adreno.so libGLESv1_CM_adreno.so eglSubDriverAndroid.so libq3dtools_esx.so \
        libVkLayer_ADRENO_qprofiler.so; do
        if [ "$n" = libGLESv2_adreno.so ]; then fake_lib "$r/$d/egl/$n" "$v" $b; else fake_lib "$r/$d/egl/$n" - $b; fi
    done
    fake_lib "$r/$d/hw/vulkan.adreno.so" - $b
    for n in libgsl.so libllvm-glnext.so libCB.so libkcl.so libadreno_app_profiles.so libllvm-qgl.so; do
        fake_lib "$r/$d/$n" - $b
    done
    mkdir -p "$r/firmware"
    printf 'sqe %s\n' "$v" > "$r/firmware/a660_sqe.fw"
}

# a fresh device: stock V@0530.0 in /vendor, KernelSU, nothing else
device() {
    rm -rf "$T/root" "$T/props"
    R="$T/root"
    mkdir -p "$R/data/adb/modules" "$R/data/adb/modules_update" "$R/data/adb/ksu" "$R/data/k4gpu/store" \
        "$R/data/k4gpu/incoming" "$R/vendor/etc/permissions" "$R/vendor/k4gpu" "$R/vendor/firmware"
    for n in libGLESv2_adreno.so libEGL_adreno.so libGLESv1_CM_adreno.so eglSubDriverAndroid.so libq3dtools_adreno.so \
        libq3dtools_esx.so; do
        if [ "$n" = libGLESv2_adreno.so ]; then fake_lib "$R/vendor/lib64/egl/$n" V@0530.0; else fake_lib "$R/vendor/lib64/egl/$n" -; fi
    done
    fake_lib "$R/vendor/lib64/hw/vulkan.adreno.so" -
    for n in libgsl.so libllvm-glnext.so libCB.so libkcl.so libOpenCL.so; do fake_lib "$R/vendor/lib64/$n" -; done
    printf 'stock sqe\n' > "$R/vendor/firmware/a660_sqe.fw"
    echo '<feature name="android.hardware.vulkan.version" version="4198400" />' > "$R/vendor/etc/permissions/android.hardware.vulkan.version-1_1.xml"
    echo '<feature name="android.hardware.vulkan.version" version="4206592" />' > "$R/vendor/k4gpu/vulkan.version-1_3.xml"
    echo "ro.k4.gpu_drivers=530 849 863" > "$T/props"
    echo "ro.k4.gpu_default=849" >> "$T/props"
    echo "persist.sys.k4.gpu_driver=530" >> "$T/props"
    echo "persist.sys.k4.gpu_trial=ok" >> "$T/props"
}

# a phone with no selection stored yet (a new install, a Format Data): no persist.sys.k4.gpu_* at all
fresh_device() {
    device
    grep -v '^persist\.sys\.k4\.' "$T/props" > "$T/props.n"; mv "$T/props.n" "$T/props"
}

# KernelSU 4.x layout: <id>/vendor/... + system/vendor -> ../vendor
ksu_module() {
    local dir="$1" id="$2" v="$3"
    mkdir -p "$R/data/adb/$dir/$id/system"
    printf 'id=%s\nname=%s driver\nversion=1\nversionCode=1\n' "$id" "$id" > "$R/data/adb/$dir/$id/module.prop"
    fake_set "$R/data/adb/$dir/$id/vendor" "$v" "${4:-}"
    ln -s ../vendor "$R/data/adb/$dir/$id/system/vendor"
}

# Magisk layout: <id>/system/vendor/...
magisk_module() {
    mkdir -p "$R/data/adb/modules/$1/system/vendor" "$R/data/adb/magisk"
    printf 'id=%s\n' "$1" > "$R/data/adb/modules/$1/module.prop"
    fake_set "$R/data/adb/modules/$1/system/vendor" "$2"
}

# what Settings stages for "Add driver"
staged() {
    local d="$R/data/k4gpu/incoming/$1"
    fake_set "$d" "$2"
    printf 'version=%s\nname=%s\n' "$2" "$3" > "$d/info"
    [ "${4:-}" = noready ] || : > "$d/ready"
}

prop() {
    awk -v k="$1" 'index($0, k "=") == 1 { v = substr($0, length(k) + 2) } END { print v }' "$T/props"
}

setp() { echo "$1=$2" >> "$T/props"; }

# boot: a new boot (sys.* properties are gone, persist.* stay), then the script as init runs it
boot() {
    grep -v '^sys\.' "$T/props" > "$T/props.n"; mv "$T/props.n" "$T/props"
    : > "$T/mounts"
    K4GPU_ROOT="$R" K4GPU_PROPFILE="$T/props" K4GPU_FAKEMOUNT="$T/mounts" K4GPU_NOLABEL=1 K4GPU_KMSG=/dev/null \
        "$SH" "$SCRIPT" boot V@0530.0 > "$T/out" 2>&1
    eq "exit status" "$?" 0
    $VERBOSE && { echo "--- [$CASE] boot.log"; cat "$R/data/k4gpu/boot.log"; }
    [ -s "$T/out" ] && bad "script printed: $(head -c 300 "$T/out")"
    eq "scan" "$(prop sys.k4.gpu_scan)" 1
}

# what the early-boot rc (k4_gpu_driver.rc, generated by customize.sh) and boot_completed then do. init collects every
# early-boot action whose property triggers match when the trigger fires and runs them in file order: the failsafe,
# pending -> testing, sys.k4.gpu_active, then the built-in set's binds ("driver=<set> && trial=pending|ok", judged on
# the values before this early-boot changed them), recorded here as "rcmount <set>".
rc_early_boot() {
    local d0 t0
    d0="$(prop persist.sys.k4.gpu_driver)"; t0="$(prop persist.sys.k4.gpu_trial)"
    [ "$t0" = testing ] && { setp persist.sys.k4.gpu_failed "$d0"; setp persist.sys.k4.gpu_driver 530; setp persist.sys.k4.gpu_trial failed; }
    [ "$t0" = pending ] && setp persist.sys.k4.gpu_trial testing
    a="$(prop sys.k4.gpu_user_active)"; setp sys.k4.gpu_active "${a:-530}"
    case "$d0" in
        530 | "" | m_* | u_*) ;;
        *) case " $(prop ro.k4.gpu_drivers) " in
               *" $d0 "*) case "$t0" in pending | ok) echo "rcmount $d0" >> "$M"; setp sys.k4.gpu_active "$d0" ;; esac ;;
           esac ;;
    esac
    return 0
}
boot_completed() {
    [ "$(prop persist.sys.k4.gpu_trial)" = testing ] && setp persist.sys.k4.gpu_trial ok
    return 0
}

M="$T/mounts"
L() { echo "$R/data/k4gpu/drivers"; }

CASE="nothing installed"
device; boot
eq driver "$(prop persist.sys.k4.gpu_driver)" 530
eq "no mounts" "$(wc -l < "$M")" 0
eq "empty list" "$(wc -c < "$(L)")" 0
eq root "$(prop sys.k4.gpu_root)" KernelSU
eq vendor "$(prop sys.k4.gpu_vendor)" ""

CASE="second run on the same boot"
K4GPU_ROOT="$R" K4GPU_PROPFILE="$T/props" K4GPU_FAKEMOUNT="$T/mounts" K4GPU_NOLABEL=1 "$SH" "$SCRIPT" boot V@0530.0
has log "already ran on this boot" "$R/data/k4gpu/boot.log"

CASE="built-in selected, no user driver"
device; setp persist.sys.k4.gpu_driver 849; boot
eq driver "$(prop persist.sys.k4.gpu_driver)" 849
eq "no mounts" "$(wc -l < "$M")" 0

CASE="KernelSU module, first boot (still in modules_update)"
device; setp persist.sys.k4.gpu_driver 863
ksu_module modules_update adreno_test V@0744.0
boot
S="$R/data/k4gpu/store/$(mslot adreno_test)"
eq driver "$(prop persist.sys.k4.gpu_driver)" $(mslot adreno_test)
eq trial "$(prop persist.sys.k4.gpu_trial)" pending
eq prev "$(prop persist.sys.k4.gpu_prev)" 863
eq user_active "$(prop sys.k4.gpu_user_active)" $(mslot adreno_test)
has list "$(mslot adreno_test)	module	-	V@0744.0 (module adreno_test)" "$(L)"
has egl "bind $S/egl $R/vendor/lib64/egl" "$M"
has gsl "bind $S/lib64/libgsl.so $R/vendor/lib64/libgsl.so" "$M"
has kcl "bind $S/lib64/libkcl.so $R/vendor/lib64/libkcl.so" "$M"
has vulkan "bind $S/lib64/hw/vulkan.adreno.so $R/vendor/lib64/hw/vulkan.adreno.so" "$M"
has sqe "bind $S/firmware/a660_sqe.fw $R/vendor/firmware/a660_sqe.fw" "$M"
has vk13 "bind $R/vendor/k4gpu/vulkan.version-1_3.xml" "$M"
[ -f "$S/egl/libadreno_app_profiles.so" ] && ok || bad "a library with no stock counterpart goes to egl/"
[ -f "$S/egl/libllvm-qgl.so" ] && ok || bad "libllvm-qgl.so goes to egl/"
[ -f "$S/egl/libq3dtools_adreno.so" ] && ok || bad "the stock egl library the set lacks is kept"
grep -q "V@0530" "$S/egl/libGLESv2_adreno.so" && bad "stock GLES copied over the set's" || ok
hasnt "no 530 libs bound" "libOpenCL" "$M"
rc_early_boot; boot_completed
eq "trial after boot" "$(prop persist.sys.k4.gpu_trial)" ok
eq active "$(prop sys.k4.gpu_active)" $(mslot adreno_test)

CASE="next boot: module moved to modules/, unchanged files"
mv "$R/data/adb/modules_update/adreno_test" "$R/data/adb/modules/"
boot
hasnt "no re-import" "imported" "$R/data/k4gpu/boot.log"
eq driver "$(prop persist.sys.k4.gpu_driver)" $(mslot adreno_test)
eq trial "$(prop persist.sys.k4.gpu_trial)" ok
has "mounted again" "bind $S/egl" "$M"

CASE="module updated (new files)"
fake_set "$R/data/adb/modules/adreno_test/vendor" V@0762.0
touch -d '2026-01-01' "$R/data/adb/modules/adreno_test/vendor/lib64/egl/libGLESv2_adreno.so"
setp persist.sys.k4.gpu_driver 849
boot
has "re-import" "imported V@0762.0" "$R/data/k4gpu/boot.log"
eq driver "$(prop persist.sys.k4.gpu_driver)" $(mslot adreno_test)
eq trial "$(prop persist.sys.k4.gpu_trial)" pending
eq prev "$(prop persist.sys.k4.gpu_prev)" 849
has list "V@0762.0 (module adreno_test)" "$(L)"

CASE="trial boot never completed"
rc_early_boot   # pending -> testing, then the phone hangs: no boot_completed
boot
eq driver "$(prop persist.sys.k4.gpu_driver)" 530
eq failed "$(prop persist.sys.k4.gpu_failed)" $(mslot adreno_test)
eq trial "$(prop persist.sys.k4.gpu_trial)" failed
eq "no mounts" "$(wc -l < "$M")" 0
rc_early_boot
eq "rc leaves it" "$(prop persist.sys.k4.gpu_failed)" $(mslot adreno_test)
boot
eq "not selected again" "$(prop persist.sys.k4.gpu_driver)" 530
has "still listed" "$(mslot adreno_test)" "$(L)"

CASE="user selects the module again, then uninstalls it"
setp persist.sys.k4.gpu_driver $(mslot adreno_test); setp persist.sys.k4.gpu_trial ok; setp persist.sys.k4.gpu_prev 863
boot
has mounted "bind $S/egl" "$M"
rm -rf "$R/data/adb/modules/adreno_test"
boot
eq "back to previous" "$(prop persist.sys.k4.gpu_driver)" 863
[ -d "$S" ] && bad "stored copy deleted" || ok
eq "empty list" "$(wc -c < "$(L)")" 0
eq "no mounts" "$(wc -l < "$M")" 0

CASE="module disabled"
device; ksu_module modules adreno_test V@0744.0; boot
eq driver "$(prop persist.sys.k4.gpu_driver)" $(mslot adreno_test)
: > "$R/data/adb/modules/adreno_test/disable"
boot
eq "back to previous" "$(prop persist.sys.k4.gpu_driver)" 530
eq "no mounts" "$(wc -l < "$M")" 0

CASE="module marked for removal"
device; ksu_module modules adreno_test V@0744.0; : > "$R/data/adb/modules/adreno_test/remove"; boot
eq driver "$(prop persist.sys.k4.gpu_driver)" 530
eq "empty list" "$(wc -c < "$(L)")" 0

CASE="module already mounted by a metamodule / magic mount"
device; setp persist.sys.k4.gpu_driver 849
ksu_module modules adreno_test V@0744.0
cp "$R/data/adb/modules/adreno_test/vendor/lib64/egl/libGLESv2_adreno.so" "$R/vendor/lib64/egl/libGLESv2_adreno.so"
boot
eq driver "$(prop persist.sys.k4.gpu_driver)" $(mslot adreno_test)
eq external "$(prop sys.k4.gpu_external)" $(mslot adreno_test)
eq trial "$(prop persist.sys.k4.gpu_trial)" ok
eq prev "$(prop persist.sys.k4.gpu_prev)" 849
eq "nothing mounted on top" "$(wc -l < "$M")" 0
eq user_active "$(prop sys.k4.gpu_user_active)" $(mslot adreno_test)
has list "$(mslot adreno_test)	module	external	V@0744.0 (module adreno_test)" "$(L)"
eq vendor "$(prop sys.k4.gpu_vendor)" ""
setp persist.sys.k4.gpu_driver 863   # Settings refuses this; even if it were set, the module's mount wins
boot
eq "locked" "$(prop persist.sys.k4.gpu_driver)" $(mslot adreno_test)

CASE="Magisk module"
device; magisk_module adreno_magisk V@0849.0; boot
eq root "$(prop sys.k4.gpu_root)" Magisk
eq driver "$(prop persist.sys.k4.gpu_driver)" $(mslot adreno_magisk)
has list "V@0849.0 (module adreno_magisk)" "$(L)"

CASE="module with only 32-bit libraries"
device; ksu_module modules adreno32 V@0744.0 32; boot
eq driver "$(prop persist.sys.k4.gpu_driver)" 530
eq rejected "$(prop sys.k4.gpu_rejected)" "module adreno32: only 32-bit libraries"

CASE="incomplete module"
device; ksu_module modules adreno_x V@0744.0; rm "$R/data/adb/modules/adreno_x/vendor/lib64/libgsl.so"; boot
eq driver "$(prop persist.sys.k4.gpu_driver)" 530
eq rejected "$(prop sys.k4.gpu_rejected)" "module adreno_x: missing libgsl.so"

CASE="module with a 32-bit library in lib64"
device; ksu_module modules adreno_x V@0744.0; fake_lib "$R/data/adb/modules/adreno_x/vendor/lib64/libgsl.so" - 32; boot
eq driver "$(prop persist.sys.k4.gpu_driver)" 530
eq rejected "$(prop sys.k4.gpu_rejected)" "module adreno_x: not a 64-bit ARM library: libgsl.so"

CASE="module without a version string"
device; ksu_module modules adreno_x V@0744.0; fake_lib "$R/data/adb/modules/adreno_x/vendor/lib64/egl/libGLESv2_adreno.so" -; boot
eq rejected "$(prop sys.k4.gpu_rejected)" "module adreno_x: no Adreno version string in libGLESv2_adreno.so"

CASE="not a GPU module"
device; mkdir -p "$R/data/adb/modules/other/system/bin"; boot
eq "empty list" "$(wc -c < "$(L)")" 0
eq rejected "$(prop sys.k4.gpu_rejected)" ""

CASE="driver added in Settings"
device; staged u_0849_0_abc V@0849.0 mydriver; boot
U="$R/data/k4gpu/store/u_0849_0_abc"
eq "not selected by itself" "$(prop persist.sys.k4.gpu_driver)" 530
[ -d "$R/data/k4gpu/incoming/u_0849_0_abc" ] && bad "staging dir removed" || ok
has list "u_0849_0_abc	added	-	V@0849.0 (added: mydriver)" "$(L)"
setp persist.sys.k4.gpu_driver u_0849_0_abc; setp persist.sys.k4.gpu_trial pending
boot
has mounted "bind $U/egl" "$M"
eq user_active "$(prop sys.k4.gpu_user_active)" u_0849_0_abc
rc_early_boot; boot_completed
eq trial "$(prop persist.sys.k4.gpu_trial)" ok

CASE="stored driver damaged"
f="$(ls "$U"/lib64/*.so | head -n 1)"; printf 'x' >> "$f"
boot
eq driver "$(prop persist.sys.k4.gpu_driver)" 530
eq missing "$(prop sys.k4.gpu_missing)" u_0849_0_abc
eq "no mounts" "$(wc -l < "$M")" 0

CASE="added driver selected before the restart (staged), incomplete"
device; staged u_bad V@0849.0 broken; rm "$R/data/k4gpu/incoming/u_bad/lib64/libllvm-glnext.so"
setp persist.sys.k4.gpu_driver u_bad; setp persist.sys.k4.gpu_trial pending
boot
eq driver "$(prop persist.sys.k4.gpu_driver)" 530
eq missing "$(prop sys.k4.gpu_missing)" u_bad
eq rejected "$(prop sys.k4.gpu_rejected)" "broken: missing libllvm-glnext.so"
[ -e "$R/data/k4gpu/store/u_bad" ] && bad "nothing stored" || ok

CASE="staging never finished (no ready)"
device; staged u_half V@0849.0 half noready; boot
[ -e "$R/data/k4gpu/incoming/u_half" ] && bad "half-staged dir removed" || ok
eq "empty list" "$(wc -c < "$(L)")" 0

CASE="remove an added driver"
device; staged u_a V@0849.0 a; boot
: > "$R/data/k4gpu/incoming/u_a.remove"
boot
[ -e "$R/data/k4gpu/store/u_a" ] && bad "stored files deleted" || ok
[ -e "$R/data/k4gpu/incoming/u_a.remove" ] && bad "request consumed" || ok
eq "empty list" "$(wc -c < "$(L)")" 0

CASE="hide a module"
device; ksu_module modules adreno_test V@0744.0; boot
setp persist.sys.k4.gpu_driver 530   # Settings moves the selection away when it hides the selected entry
: > "$R/data/k4gpu/incoming/$(mslot adreno_test).hide"
boot
eq "empty list" "$(wc -c < "$(L)")" 0
[ -e "$R/data/k4gpu/store/$(mslot adreno_test)" ] && bad "stored copy deleted" || ok
boot
hasnt "not imported again" "imported" "$R/data/k4gpu/boot.log"
eq driver "$(prop persist.sys.k4.gpu_driver)" 530
rm -rf "$R/data/adb/modules/adreno_test"; boot
eq "forgotten when uninstalled" "$(wc -c < "$R/data/k4gpu/hidden")" 0
ksu_module modules adreno_test V@0744.0; boot
eq "listed again after a new install" "$(prop persist.sys.k4.gpu_driver)" $(mslot adreno_test)

CASE="driver flashed into /vendor (TWRP)"
device; setp persist.sys.k4.gpu_driver 849
fake_lib "$R/vendor/lib64/egl/libGLESv2_adreno.so" V@0744.0
boot
eq vendor "$(prop sys.k4.gpu_vendor)" V@0744.0
eq driver "$(prop persist.sys.k4.gpu_driver)" 530
eq prev "$(prop persist.sys.k4.gpu_prev)" 849
setp persist.sys.k4.gpu_driver 849   # the user picks a built-in on purpose: allowed, not reset again
boot
eq driver "$(prop persist.sys.k4.gpu_driver)" 849
fake_lib "$R/vendor/lib64/egl/libGLESv2_adreno.so" V@0530.0
boot
eq "stock again" "$(prop sys.k4.gpu_vendor)" ""
eq "seen cleared" "$(prop persist.sys.k4.gpu_vendor_seen)" ""

CASE="mount fails half way"
device; ksu_module modules adreno_test V@0744.0
setp persist.sys.k4.gpu_driver $(mslot adreno_test); setp persist.sys.k4.gpu_trial ok
cat > "$T/failmount" << 'EOF'
EOF
K4GPU_FAKEMOUNT_FAIL=libgsl.so
export K4GPU_FAKEMOUNT_FAIL
boot
unset K4GPU_FAKEMOUNT_FAIL
eq driver "$(prop persist.sys.k4.gpu_driver)" 530
eq missing "$(prop sys.k4.gpu_missing)" $(mslot adreno_test)
has "undone" "umount $R/vendor/lib64/egl" "$M"
eq user_active "$(prop sys.k4.gpu_user_active)" ""

CASE="unknown selection value"
device; setp persist.sys.k4.gpu_driver 999; boot
eq driver "$(prop persist.sys.k4.gpu_driver)" 530

# ---- REVIEW1 fixes ----

CASE="M2 a module must not replace an unrelated /vendor library"
device; fake_lib "$R/vendor/lib64/libsec-ril.so" -; fake_lib "$R/vendor/lib64/libQSEEComAPI.so" -
ksu_module modules adreno_ril V@0744.0
fake_lib "$R/data/adb/modules/adreno_ril/vendor/lib64/libsec-ril.so" -
fake_lib "$R/data/adb/modules/adreno_ril/vendor/lib64/libQSEEComAPI.so" -
boot
hasnt "libsec-ril.so never bound" "/vendor/lib64/libsec-ril.so" "$M"
hasnt "libQSEEComAPI.so never bound" "/vendor/lib64/libQSEEComAPI.so" "$M"
eq "the set is rejected" "$(prop persist.sys.k4.gpu_driver)" 530
has "with an unexpected-file reason" "unexpected file:" "$R/data/k4gpu/boot.log"

CASE="M2 an unexpected library in lib64/egl is rejected too"
device; ksu_module modules adreno_e V@0744.0
fake_lib "$R/data/adb/modules/adreno_e/vendor/lib64/egl/libEGL_mali.so" -
boot
eq "rejected" "$(prop persist.sys.k4.gpu_driver)" 530
has reason "unexpected file: libEGL_mali.so" "$R/data/k4gpu/boot.log"

CASE="M2 a file in lib64/hw other than vulkan.adreno.so is rejected"
device; ksu_module modules adreno_hw V@0744.0
fake_lib "$R/data/adb/modules/adreno_hw/vendor/lib64/hw/gralloc.default.so" -
boot
eq "rejected" "$(prop persist.sys.k4.gpu_driver)" 530

CASE="M3 a library name with a space is rejected (device shell: must not break the run or re-import forever)"
device; ksu_module modules adreno_sp V@0744.0
fake_lib "$R/data/adb/modules/adreno_sp/vendor/lib64/lib extra.so" -
boot
eq "run still finishes" "$(prop sys.k4.gpu_scan)" 1
eq "rejected, stock stays" "$(prop persist.sys.k4.gpu_driver)" 530
[ -z "$(ls "$R/data/k4gpu/store" 2> /dev/null)" ] && ok || bad "a set with a whitespace name must not be stored"
boot
eq "no re-import loop (second boot clean)" "$(prop sys.k4.gpu_scan)" 1

CASE="M3 check_set fails closed (a glob character in a name is rejected, not accepted)"
device; ksu_module modules adreno_g V@0744.0
fake_lib "$R/data/adb/modules/adreno_g/vendor/lib64/lib*.so" -
boot
eq "rejected" "$(prop persist.sys.k4.gpu_driver)" 530

CASE="M3 the reviewer's bypass: a 32-bit libgsl with no version and a spaced name is NOT stored"
device; ksu_module modules adreno_bp V@0744.0
fake_lib "$R/data/adb/modules/adreno_bp/vendor/lib64/libgsl.so" - 32
fake_lib "$R/data/adb/modules/adreno_bp/vendor/lib64/egl/libGLESv2_adreno.so" -
fake_lib "$R/data/adb/modules/adreno_bp/vendor/lib64/lib x.so" -
boot
[ -z "$(ls "$R/data/k4gpu/store" 2> /dev/null)" ] && ok || bad "the poisoned set was stored"
eq "stock stays" "$(prop persist.sys.k4.gpu_driver)" 530

CASE="L7 a module that ships the stock driver (vendor symlinked to /vendor) is ignored, not auto-selected"
device; mkdir -p "$R/data/adb/modules/evil"; ln -s "$R/vendor" "$R/data/adb/modules/evil/vendor"
boot
eq "not auto-selected" "$(prop persist.sys.k4.gpu_driver)" 530
eq "nothing stored" "$(ls "$R/data/k4gpu/store" 2> /dev/null | wc -l)" 0
eq "empty list" "$(wc -c < "$(L)")" 0

CASE="L5 two ids sharing the first 30 characters get distinct slots (the hash disambiguates), no overwrite/churn"
id1="adreno.driver.very.long.name.aaa"; id2="adreno.driver.very.long.name.bbb"
device; ksu_module modules "$id1" V@0744.0; ksu_module modules "$id2" V@0762.0
boot
eq "two entries" "$(wc -l < "$(L)")" 2
n1="$(mslot "$id1")"; n2="$(mslot "$id2")"
[ "$n1" != "$n2" ] && ok || bad "slot collision"
has "slot for id1" "$n1" "$(L)"
has "slot for id2" "$n2" "$(L)"
boot
eq "no re-import on an unchanged second boot" "$(grep -c imported "$R/data/k4gpu/boot.log")" 0

CASE="L5 a hand-made module directory with an odd id (space) is skipped cleanly"
device; ksu_module modules 'drv a' V@0744.0; boot
eq "not listed" "$(wc -c < "$(L)")" 0
eq "nothing stored" "$(ls "$R/data/k4gpu/store" 2> /dev/null | wc -l)" 0

CASE="L6 a module id with a newline cannot inject lines into the drivers list (skipped, nothing stored)"
device; ksu_module modules "$(printf 'nl\nsig=x')" V@0744.0
boot
eq "run finishes" "$(prop sys.k4.gpu_scan)" 1
eq "nothing listed (no injection)" "$(wc -c < "$(L)")" 0
eq "nothing stored" "$(ls "$R/data/k4gpu/store" 2> /dev/null | wc -l)" 0

CASE="L3 a new module on a failsafe boot does not erase the undone record or auto-select"
device; setp persist.sys.k4.gpu_driver 863; setp persist.sys.k4.gpu_trial testing
ksu_module modules_update adreno_new V@0744.0
boot
eq "failed=863 kept" "$(prop persist.sys.k4.gpu_failed)" 863
eq "trial failed" "$(prop persist.sys.k4.gpu_trial)" failed
eq "stock, not the new module" "$(prop persist.sys.k4.gpu_driver)" 530
has "but the new module is listed" "$(mslot adreno_new)" "$(L)"

CASE="L4 a hidden module disabled for a boot stays hidden and does not override the user's choice when re-enabled"
device; ksu_module modules adreno_h V@0744.0; boot
setp persist.sys.k4.gpu_driver 849; : > "$R/data/k4gpu/incoming/$(mslot adreno_h).hide"; boot
eq "hidden now" "$(wc -c < "$(L)")" 0
: > "$R/data/adb/modules/adreno_h/disable"; boot
rm "$R/data/adb/modules/adreno_h/disable"; boot
eq "still hidden after re-enable" "$(wc -c < "$(L)")" 0
eq "user's choice (849) survives" "$(prop persist.sys.k4.gpu_driver)" 849

CASE="L2 an empty/unreadable ro.k4.gpu_drivers must not destroy a built-in choice"
device; grep -v '^ro.k4.gpu_drivers=' "$T/props" > "$T/p2"; mv "$T/p2" "$T/props"
setp persist.sys.k4.gpu_driver 849; boot
eq "849 kept" "$(prop persist.sys.k4.gpu_driver)" 849

CASE="M4 safe mode runs the stock driver this boot without changing the selection"
device; ksu_module modules adreno_sm V@0744.0; boot
eq "module selected" "$(prop persist.sys.k4.gpu_driver)" "$(mslot adreno_sm)"
setp persist.sys.safemode 1; boot
eq "selection unchanged" "$(prop persist.sys.k4.gpu_driver)" "$(mslot adreno_sm)"
eq "but nothing mounted this boot" "$(wc -l < "$M")" 0
eq "active reports stock" "$(prop sys.k4.gpu_user_active)" ""
device; ksu_module modules adreno_sm V@0744.0; setp persist.sys.safemode 0; boot
eq "normal boot mounts again" "$(prop sys.k4.gpu_user_active)" "$(mslot adreno_sm)"

CASE="M4 the reset prop (settable from adb shell) reverts to the stock driver on the next boot"
device; ksu_module modules adreno_rs V@0744.0; boot
setp persist.sys.k4.gpu_driver "$(mslot adreno_rs)"; setp persist.sys.k4.gpu_trial ok
setp persist.sys.k4.gpu_reset 1; boot
eq "back to stock" "$(prop persist.sys.k4.gpu_driver)" 530
eq "reset flag cleared" "$(prop persist.sys.k4.gpu_reset)" ""
eq "nothing mounted" "$(wc -l < "$M")" 0

CASE="M4 settle promotes a trial to ok only after the window with no system_server restart"
device
printf 'persist.sys.k4.gpu_trial=testing\nsys.boot_completed=1\nsys.system_server.start_count=1\n' > "$T/props"
K4GPU_ROOT="$R" K4GPU_PROPFILE="$T/props" K4GPU_KMSG=/dev/null K4GPU_SLEEP=0 "$SH" "$SCRIPT" settle 20 > /dev/null 2>&1
eq "stable -> ok" "$(prop persist.sys.k4.gpu_trial)" ok

CASE="M4 settle leaves the trial testing if system_server restarts in the window"
device
printf 'persist.sys.k4.gpu_trial=testing\nsys.boot_completed=1\nsys.system_server.start_count=1\n' > "$T/props"
( K4GPU_ROOT="$R" K4GPU_PROPFILE="$T/props" K4GPU_KMSG=/dev/null K4GPU_SLEEP=0.3 "$SH" "$SCRIPT" settle 500 > /dev/null 2>&1 ) &
SPID=$!
sleep 0.5; setp sys.system_server.start_count 2
wait $SPID
eq "crash -> still testing" "$(prop persist.sys.k4.gpu_trial)" testing

CASE="L1 best-effort: more than MAX_NEW new modules are not all imported in one boot"
device; for i in 1 2 3 4 5 6; do ksu_module modules "big$i" V@0744.0; done; boot
imp="$(grep -c imported "$R/data/k4gpu/boot.log")"
[ "$imp" -le 4 ] && ok || bad "imported $imp new modules in one boot (cap is 4)"

CASE="polish 3: the stock driver is never on trial (pending left by an older Settings)"
device; setp persist.sys.k4.gpu_driver 530; setp persist.sys.k4.gpu_trial pending; boot
eq "trial ok" "$(prop persist.sys.k4.gpu_trial)" ok
rc_early_boot
eq "rc does not turn it into testing" "$(prop persist.sys.k4.gpu_trial)" ok

CASE="polish 3: testing left on the stock driver records no failure"
device; setp persist.sys.k4.gpu_driver 530; setp persist.sys.k4.gpu_trial testing; boot
eq "trial ok" "$(prop persist.sys.k4.gpu_trial)" ok
eq "no gpu_failed=530" "$(prop persist.sys.k4.gpu_failed)" ""

CASE="race review: settle re-run after a system_server restart (start_count 2) never promotes"
device
printf 'persist.sys.k4.gpu_trial=testing\nsys.boot_completed=1\nsys.system_server.start_count=2\n' > "$T/props"
K4GPU_ROOT="$R" K4GPU_PROPFILE="$T/props" K4GPU_KMSG=/dev/null K4GPU_SLEEP=0 "$SH" "$SCRIPT" settle 20 > /dev/null 2>&1
eq "trial stays testing" "$(prop persist.sys.k4.gpu_trial)" testing
eq "status prop" "$(prop sys.k4.gpu_settle)" "failed: system_server restarted this boot (start_count 2), trial stays testing"

CASE="polish 3: settle on the stock driver promotes at once (no 150 s window)"
device
printf 'persist.sys.k4.gpu_driver=530\npersist.sys.k4.gpu_trial=testing\nsys.boot_completed=1\n' > "$T/props"
K4GPU_ROOT="$R" K4GPU_PROPFILE="$T/props" K4GPU_KMSG=/dev/null K4GPU_SLEEP=5 timeout 4 "$SH" "$SCRIPT" settle 150 > /dev/null 2>&1
eq "ok without waiting" "$(prop persist.sys.k4.gpu_trial)" ok

CASE="polish 2: boot.log is group-writable so settle (user system) can append its result"
device; boot
eq "boot.log mode" "$(stat -c %a "$R/data/k4gpu/boot.log")" 660

CASE="polish 2: settle writes its result to boot.log and sys.k4.gpu_settle"
device; boot
printf 'persist.sys.k4.gpu_driver=u_x\npersist.sys.k4.gpu_trial=testing\nsys.boot_completed=1\nsys.system_server.start_count=1\n' > "$T/props"
K4GPU_ROOT="$R" K4GPU_PROPFILE="$T/props" K4GPU_KMSG=/dev/null K4GPU_SLEEP=0 "$SH" "$SCRIPT" settle 20 > /dev/null 2>&1
has "result in boot.log" "settle: 20s stable, trial ok" "$R/data/k4gpu/boot.log"
eq "status prop" "$(prop sys.k4.gpu_settle)" "ok: 20s stable"
printf 'persist.sys.k4.gpu_driver=u_x\npersist.sys.k4.gpu_trial=testing\nsys.boot_completed=1\nsys.system_server.start_count=1\n' > "$T/props"
( K4GPU_ROOT="$R" K4GPU_PROPFILE="$T/props" K4GPU_KMSG=/dev/null K4GPU_SLEEP=0.3 "$SH" "$SCRIPT" settle 500 > /dev/null 2>&1 ) &
SPID=$!
sleep 0.5; setp sys.system_server.start_count 2
wait $SPID
has "crash result in boot.log" "system_server restarted (1 -> 2)" "$R/data/k4gpu/boot.log"
eq "crash status prop" "$(prop sys.k4.gpu_settle)" "failed: system_server restarted (1 -> 2), trial stays testing"

CASE="polish 4: persist.sys.k4.gpu_prev is cleared when it equals the current choice"
device; setp persist.sys.k4.gpu_prev 530; boot
eq "prev cleared (530 == 530)" "$(prop persist.sys.k4.gpu_prev)" ""
device; ksu_module modules adreno_p V@0744.0; setp persist.sys.k4.gpu_driver 849; boot
eq "prev kept while it differs (module auto-selected, prev 849)" "$(prop persist.sys.k4.gpu_prev)" 849
rm -rf "$R/data/adb/modules/adreno_p"; boot
eq "module gone: back to prev" "$(prop persist.sys.k4.gpu_driver)" 849
eq "then prev cleared" "$(prop persist.sys.k4.gpu_prev)" ""

CASE="polish 1: the drivers list names the module id (not the slot) as its 5th field"
device; ksu_module modules k4test_adreno849 V@0744.0; boot
sl="$(mslot k4test_adreno849)"
eq "module line" "$(grep "^$sl	" "$(L)")" "$sl	module	-	V@0744.0 (module k4test_adreno849)	k4test_adreno849"
device; ksu_module modules adreno_ext V@0744.0
cp "$R/data/adb/modules/adreno_ext/vendor/lib64/egl/libGLESv2_adreno.so" "$R/vendor/lib64/egl/libGLESv2_adreno.so"; boot
eq "external line" "$(cut -f 5 "$(L)")" adreno_ext
device; staged u_0849_0_m V@0849.0 mine; boot
eq "added line: empty module field" "$(awk -F '\t' '{ print NF ":" $5 }' "$(L)")" "5:"

# --- the default driver (ro.k4.gpu_default = 849 since 9.3.106; the stock 530 stays the fallback) -----------------

CASE="default: no selection stored (new install) -> the default with a trial boot, mounted by the rc"
fresh_device; boot
eq "selected" "$(prop persist.sys.k4.gpu_driver)" 849
eq "on trial" "$(prop persist.sys.k4.gpu_trial)" pending
eq "no failure recorded" "$(prop persist.sys.k4.gpu_failed)" ""
eq "no user driver mounted by the script" "$(prop sys.k4.gpu_user_active)" ""
has "logged" "no driver selected yet: the default 849 is selected with a trial boot" "$R/data/k4gpu/boot.log"
rc_early_boot
eq "rc: trial testing" "$(prop persist.sys.k4.gpu_trial)" testing
eq "rc: the set is bound" "$(cat "$M")" "rcmount 849"
eq "rc: active" "$(prop sys.k4.gpu_active)" 849
boot_completed
eq "settled" "$(prop persist.sys.k4.gpu_trial)" ok

CASE="default: the next boot keeps it (no second trial), the rc mounts it again"
boot
eq "still selected" "$(prop persist.sys.k4.gpu_driver)" 849
eq "trial stays ok" "$(prop persist.sys.k4.gpu_trial)" ok
hasnt "not selected again" "no driver selected yet" "$R/data/k4gpu/boot.log"
rc_early_boot
eq "rc: bound" "$(cat "$M")" "rcmount 849"
eq "rc: active" "$(prop sys.k4.gpu_active)" 849

CASE="default: the trial boot never settles -> back to the stock driver, stored, no trial loop"
fresh_device; boot; rc_early_boot   # pending -> testing, bound; then the phone never settles
eq "was testing" "$(prop persist.sys.k4.gpu_trial)" testing
boot
eq "back to stock" "$(prop persist.sys.k4.gpu_driver)" 530
eq "the default recorded as failed" "$(prop persist.sys.k4.gpu_failed)" 849
eq "trial failed" "$(prop persist.sys.k4.gpu_trial)" failed
has "logged" "previous boot with 849 never settled: back to V@0530" "$R/data/k4gpu/boot.log"
rc_early_boot
eq "rc: nothing bound" "$(wc -l < "$M")" 0
eq "rc: stock active" "$(prop sys.k4.gpu_active)" 530
boot; rc_early_boot
eq "stays on stock (stored selection)" "$(prop persist.sys.k4.gpu_driver)" 530
eq "no new trial" "$(prop persist.sys.k4.gpu_trial)" failed
eq "still nothing bound" "$(wc -l < "$M")" 0
hasnt "the default is not selected again" "no driver selected yet" "$R/data/k4gpu/boot.log"
setp persist.sys.k4.gpu_failed ""; setp persist.sys.k4.gpu_trial ok   # the user acknowledges the banner in Settings
boot; rc_early_boot
eq "acknowledged: still stock" "$(prop persist.sys.k4.gpu_driver)" 530
eq "still nothing bound" "$(wc -l < "$M")" 0

CASE="default: the trial boot never settles and the rc's own failsafe ran first (script did not run that boot)"
fresh_device; boot; rc_early_boot
grep -v '^sys\.' "$T/props" > "$T/props.n"; mv "$T/props.n" "$T/props"
rc_early_boot   # next boot: the rc alone reverts (testing -> failed, 530)
eq "rc failsafe: stock stored" "$(prop persist.sys.k4.gpu_driver)" 530
eq "rc failsafe: failed recorded" "$(prop persist.sys.k4.gpu_failed)" 849
boot
eq "script agrees" "$(prop persist.sys.k4.gpu_driver)" 530
eq "record kept" "$(prop persist.sys.k4.gpu_failed)" 849
eq "trial failed" "$(prop persist.sys.k4.gpu_trial)" failed

CASE="default: a lost selection with a testing/failed trial never retries the default (no loop)"
fresh_device; setp persist.sys.k4.gpu_trial testing; boot
eq "testing + no selection: failsafe to stock" "$(prop persist.sys.k4.gpu_driver)" 530
eq "failed = the default it was testing" "$(prop persist.sys.k4.gpu_failed)" 849
eq "trial failed" "$(prop persist.sys.k4.gpu_trial)" failed
fresh_device; setp persist.sys.k4.gpu_trial failed; setp persist.sys.k4.gpu_failed 849; boot
eq "failed + no selection: stock" "$(prop persist.sys.k4.gpu_driver)" 530
eq "trial stays failed" "$(prop persist.sys.k4.gpu_trial)" failed
eq "record kept" "$(prop persist.sys.k4.gpu_failed)" 849
rc_early_boot
eq "nothing bound" "$(wc -l < "$M")" 0

CASE="default: an explicit 530 (every phone that ran 9.3.105 or older, or the user's choice) stays 530, no trial"
device; setp persist.sys.k4.gpu_driver 530; setp persist.sys.k4.gpu_trial ok; boot
eq "stays" "$(prop persist.sys.k4.gpu_driver)" 530
eq "no trial" "$(prop persist.sys.k4.gpu_trial)" ok
hasnt "not defaulted" "no driver selected yet" "$R/data/k4gpu/boot.log"
rc_early_boot
eq "nothing bound" "$(wc -l < "$M")" 0
eq "stock active" "$(prop sys.k4.gpu_active)" 530

CASE="default: an explicit 849 (trial ok) stays 849 with no new trial"
device; setp persist.sys.k4.gpu_driver 849; setp persist.sys.k4.gpu_trial ok; boot
eq "stays" "$(prop persist.sys.k4.gpu_driver)" 849
eq "trial ok" "$(prop persist.sys.k4.gpu_trial)" ok
rc_early_boot
eq "bound" "$(cat "$M")" "rcmount 849"
eq "active" "$(prop sys.k4.gpu_active)" 849

CASE="default: 849 picked in Settings (pending) goes through the same trial"
device; setp persist.sys.k4.gpu_driver 849; setp persist.sys.k4.gpu_trial pending; boot
eq "pending kept" "$(prop persist.sys.k4.gpu_trial)" pending
rc_early_boot
eq "testing" "$(prop persist.sys.k4.gpu_trial)" testing
eq "bound" "$(cat "$M")" "rcmount 849"
boot_completed
eq "ok" "$(prop persist.sys.k4.gpu_trial)" ok

CASE="default: no ro.k4.gpu_default, or one that is the stock / not a built-in -> the stock driver, no trial"
fresh_device; grep -v '^ro.k4.gpu_default=' "$T/props" > "$T/p2"; mv "$T/p2" "$T/props"; boot
eq "no default prop: stock" "$(prop persist.sys.k4.gpu_driver)" 530
eq "no trial" "$(prop persist.sys.k4.gpu_trial)" ""
fresh_device; setp ro.k4.gpu_default 530; boot
eq "default = stock: stock" "$(prop persist.sys.k4.gpu_driver)" 530
eq "no trial" "$(prop persist.sys.k4.gpu_trial)" ""
fresh_device; setp ro.k4.gpu_default 999; boot
eq "unknown default: stock" "$(prop persist.sys.k4.gpu_driver)" 530
fresh_device; grep -v '^ro.k4.gpu_drivers=' "$T/props" > "$T/p2"; mv "$T/p2" "$T/props"; boot
eq "unreadable list: stock" "$(prop persist.sys.k4.gpu_driver)" 530

CASE="default: the reset prop on a phone with no selection stores the stock driver, no prev"
fresh_device; setp persist.sys.k4.gpu_reset 1; boot
eq "stock" "$(prop persist.sys.k4.gpu_driver)" 530
eq "trial ok" "$(prop persist.sys.k4.gpu_trial)" ok
eq "no prev" "$(prop persist.sys.k4.gpu_prev)" ""

CASE="default: a new driver module on a phone with no selection wins (trial), the default is the previous choice"
fresh_device; ksu_module modules_update adreno_first V@0744.0; boot
eq "module selected" "$(prop persist.sys.k4.gpu_driver)" "$(mslot adreno_first)"
eq "trial" "$(prop persist.sys.k4.gpu_trial)" pending
eq "prev = the default" "$(prop persist.sys.k4.gpu_prev)" 849

CASE="default: the settle window runs for the default (not the stock short-cut)"
device
printf 'persist.sys.k4.gpu_driver=849\npersist.sys.k4.gpu_trial=testing\nsys.boot_completed=1\nsys.system_server.start_count=1\n' > "$T/props"
K4GPU_ROOT="$R" K4GPU_PROPFILE="$T/props" K4GPU_KMSG=/dev/null K4GPU_SLEEP=0 "$SH" "$SCRIPT" settle 20 > /dev/null 2>&1
eq "stable -> ok" "$(prop persist.sys.k4.gpu_trial)" ok
eq "status" "$(prop sys.k4.gpu_settle)" "ok: 20s stable"

# --- guard: driver modules get skip_mount before any metamodule mounts (KernelSU) ---------------------------------
# guard: as ksud's post-fs-data.d script / the init.rc action runs it (u:r:ksu), before ksud moves updates in
guard() {
    K4GPU_ROOT="$R" K4GPU_PROPFILE="$T/props" K4GPU_KMSG=/dev/null "$SH" "$SCRIPT" guard > "$T/gout" 2>&1
    eq "guard exit status" "$?" 0
    [ -s "$T/gout" ] && bad "guard printed: $(head -c 300 "$T/gout")"
    $VERBOSE && { echo "--- [$CASE] guard log"; cat "$R/data/adb/.k4_gpu_guard.log" 2> /dev/null; }
    return 0
}
GL() { echo "$R/data/adb/.k4_gpu_guard.log"; }
ours() { head -n 1 "$1" 2> /dev/null | grep -q '^k4-gpu-driver: Adreno GPU driver module' && ok || bad "$2: $1 not our skip_mount"; }
nofile() { [ -e "$1" ] || [ -L "$1" ] && bad "$2: $1 exists" || ok; }
plain_mod() { mkdir -p "$R/data/adb/modules/$1/system/etc"; printf 'id=%s\n' "$1" > "$R/data/adb/modules/$1/module.prop"; }

CASE="guard: an installed KernelSU driver module gets skip_mount; the selector still imports it"
device; ksu_module modules adreno_g V@0849.0; plain_mod plain_g
guard
ours "$R/data/adb/modules/adreno_g/skip_mount" marked
eq "marker mode" "$(stat -c %a "$R/data/adb/modules/adreno_g/skip_mount")" 644
nofile "$R/data/adb/modules/plain_g/skip_mount" "plain module"
eq "guard prop" "$(prop sys.k4.gpu_guard)" adreno_g
has "log" "adreno_g ($R/data/adb/modules): Adreno GPU driver module, skip_mount set (selector check: ok)" "$(GL)"
boot
eq "imported and selected" "$(prop persist.sys.k4.gpu_driver)" "$(mslot adreno_g)"
eq "trial" "$(prop persist.sys.k4.gpu_trial)" pending
eq "mounted by the selector" "$(prop sys.k4.gpu_user_active)" "$(mslot adreno_g)"
before="$(cat "$R/data/adb/modules/adreno_g/skip_mount")"
guard
eq "idempotent" "$(cat "$R/data/adb/modules/adreno_g/skip_mount")" "$before"
eq "idempotent prop" "$(prop sys.k4.gpu_guard)" adreno_g

CASE="guard: a fresh install (modules_update) - marked before ksud moves it in, the first boot after the install"
device
mkdir -p "$R/data/adb/modules/adreno_n" && printf 'id=adreno_n\n' > "$R/data/adb/modules/adreno_n/module.prop" && : > "$R/data/adb/modules/adreno_n/update"
ksu_module modules_update adreno_n V@0849.0
guard
ours "$R/data/adb/modules_update/adreno_n/skip_mount" "staged copy marked"
nofile "$R/data/adb/modules/adreno_n/skip_mount" "placeholder (no driver files) not marked"
# ksud's handle_updated_modules: the staged directory replaces modules/<id>
rm -rf "$R/data/adb/modules/adreno_n" && mv "$R/data/adb/modules_update/adreno_n" "$R/data/adb/modules/adreno_n"
ours "$R/data/adb/modules/adreno_n/skip_mount" "moved in with it"
boot
eq "imported and selected" "$(prop persist.sys.k4.gpu_driver)" "$(mslot adreno_n)"

CASE="guard: Mountify / Magic Mount layout, 32-bit only, rejected by the allowlist, disabled - all marked"
device
mkdir -p "$R/data/adb/modules/mfy_drv/system/vendor" && printf 'id=mfy_drv\n' > "$R/data/adb/modules/mfy_drv/module.prop"
fake_set "$R/data/adb/modules/mfy_drv/system/vendor" V@0849.0
ksu_module modules drv32 V@0849.0 32
ksu_module modules drv_extra V@0849.0 && fake_lib "$R/data/adb/modules/drv_extra/vendor/lib64/libsec-ril.so" -
ksu_module modules drv_off V@0849.0 && : > "$R/data/adb/modules/drv_off/disable"
guard
for x in mfy_drv drv32 drv_extra drv_off; do ours "$R/data/adb/modules/$x/skip_mount" "$x"; done
has "32-bit reason" "drv32 ($R/data/adb/modules): Adreno GPU driver module, skip_mount set (selector check: only 32-bit libraries)" "$(GL)"
has "allowlist reason" "drv_extra ($R/data/adb/modules): Adreno GPU driver module, skip_mount set (selector check: unexpected file: libsec-ril.so)" "$(GL)"
eq "guard prop" "$(prop sys.k4.gpu_guard)" "drv32 drv_extra drv_off mfy_drv"

CASE="guard: a module's own skip_mount is never touched; ours goes when the driver set is gone"
device
ksu_module modules drv_own V@0849.0 && echo "my own" > "$R/data/adb/modules/drv_own/skip_mount"
ksu_module modules drv_empty V@0849.0 && : > "$R/data/adb/modules/drv_empty/skip_mount"
ksu_module modules drv_link V@0849.0 && ln -s /nonexistent "$R/data/adb/modules/drv_link/skip_mount"
plain_mod plain_own && echo "user skip" > "$R/data/adb/modules/plain_own/skip_mount"
plain_mod was_drv && echo "k4-gpu-driver: Adreno GPU driver module: old" > "$R/data/adb/modules/was_drv/skip_mount"
guard
eq "own content" "$(cat "$R/data/adb/modules/drv_own/skip_mount")" "my own"
eq "own empty" "$(stat -c %s "$R/data/adb/modules/drv_empty/skip_mount")" 0
eq "own link" "$(readlink "$R/data/adb/modules/drv_link/skip_mount")" /nonexistent
eq "plain module's own" "$(cat "$R/data/adb/modules/plain_own/skip_mount")" "user skip"
nofile "$R/data/adb/modules/was_drv/skip_mount" "ours removed from a module without a driver set"
has "own logged" "drv_own ($R/data/adb/modules): Adreno GPU driver module with its own skip_mount, left as it is" "$(GL)"
eq "guard prop (only ours)" "$(prop sys.k4.gpu_guard)" ""

CASE="guard: a module with files under system/apex is never mounted (Play system updates / apexd), its own skip_mount is kept"
device
plain_mod apex_mod && mkdir -p "$R/data/adb/modules/apex_mod/system/apex" && : > "$R/data/adb/modules/apex_mod/system/apex/com.android.bt.apex"
plain_mod apex_own && mkdir -p "$R/data/adb/modules/apex_own/system/apex" && : > "$R/data/adb/modules/apex_own/system/apex/x.apex" && echo "user skip" > "$R/data/adb/modules/apex_own/skip_mount"
plain_mod apex_empty && mkdir -p "$R/data/adb/modules/apex_empty/system/apex"
plain_mod was_apex && echo "k4-apex-guard: module ships files under system/apex (old)" > "$R/data/adb/modules/was_apex/skip_mount"
mkdir -p "$R/data/adb/modules_update/apex_upd/system/apex" && printf 'id=apex_upd\n' > "$R/data/adb/modules_update/apex_upd/module.prop" && mkdir "$R/data/adb/modules_update/apex_upd/system/apex/com.android.foo.apex"
ksu_module modules adreno_a V@0849.0
guard
first="$(head -n 1 "$R/data/adb/modules/apex_mod/skip_mount" 2> /dev/null)"
case "$first" in "k4-apex-guard: module ships files under system/apex (com.android.bt.apex)"*) ok ;; *) bad "apex_mod skip_mount: '$first'" ;; esac
eq "marker mode" "$(stat -c %a "$R/data/adb/modules/apex_mod/skip_mount")" 644
first="$(head -n 1 "$R/data/adb/modules_update/apex_upd/skip_mount" 2> /dev/null)"
case "$first" in "k4-apex-guard: module ships files under system/apex (com.android.foo.apex)"*) ok ;; *) bad "apex_upd (a directory entry, staged copy): '$first'" ;; esac
eq "own skip_mount kept" "$(cat "$R/data/adb/modules/apex_own/skip_mount")" "user skip"
nofile "$R/data/adb/modules/apex_empty/skip_mount" "empty system/apex dir is not content"
nofile "$R/data/adb/modules/was_apex/skip_mount" "ours removed when the content is gone"
ours "$R/data/adb/modules/adreno_a/skip_mount" "driver module still marked by the driver check"
eq "apex guard prop" "$(prop sys.k4.gpu_guard_apex)" "apex_mod apex_upd"
eq "driver guard prop unchanged" "$(prop sys.k4.gpu_guard)" "adreno_a"
has "log" "apex_mod ($R/data/adb/modules): module with system/apex content (com.android.bt.apex), skip_mount set" "$(GL)"
has "own logged" "apex_own ($R/data/adb/modules): module with system/apex content and its own skip_mount, left as it is" "$(GL)"
has "removal logged" "was_apex ($R/data/adb/modules): no system/apex content any more, its skip_mount removed" "$(GL)"
before="$(cat "$R/data/adb/modules/apex_mod/skip_mount")"
guard
eq "idempotent" "$(cat "$R/data/adb/modules/apex_mod/skip_mount")" "$before"

CASE="guard: nothing with Magisk, nothing without modules, odd directory names skipped"
device; magisk_module adreno_mg V@0849.0
guard
nofile "$R/data/adb/modules/adreno_mg/skip_mount" "Magisk"
device; rm -rf "$R/data/adb/modules" "$R/data/adb/modules_update"
guard
nofile "$R/data/adb/.k4_gpu_guard.log" "no modules: no log"
device; ksu_module modules "bad id" V@0849.0
guard
nofile "$R/data/adb/modules/bad id/skip_mount" "odd id"
device; ksu_module modules drv_ro V@0849.0 && chmod 555 "$R/data/adb/modules/drv_ro"
if [ "$(id -u)" != 0 ]; then
    guard
    has "write failure logged" "drv_ro ($R/data/adb/modules): Adreno GPU driver module, could not set skip_mount" "$(GL)"
fi
chmod 755 "$R/data/adb/modules/drv_ro"

CASE="diag: the previous boot's log is kept and the boot reason is logged"
device; boot
setp persist.sys.k4.gpu_driver 849; setp persist.sys.k4.gpu_trial testing
echo "settle: 150s window for 849" >> "$R/data/k4gpu/boot.log"
setp persist.sys.boot.reason reboot,rescueparty_warm_reboot
boot
has "previous log kept" "settle: 150s window for 849" "$R/data/k4gpu/boot.log.prev"
has "boot reason at start" "start (stock V@0530.0, previous boot ended: reboot,rescueparty_warm_reboot)" "$R/data/k4gpu/boot.log"
has "failed trial logged" "previous boot with 849 never settled" "$R/data/k4gpu/boot.log"
hasnt "current log starts fresh" "settle: 150s window" "$R/data/k4gpu/boot.log"
eq "prev log mode" "$(stat -c %a "$R/data/k4gpu/boot.log.prev")" 660

CASE="diag: no clean shutdown recorded"
device; boot
has "empty reason" "start (stock V@0530.0, previous boot ended: no clean shutdown)" "$R/data/k4gpu/boot.log"

echo "$PASS passed, $FAIL failed"
[ "$FAIL" = 0 ]
