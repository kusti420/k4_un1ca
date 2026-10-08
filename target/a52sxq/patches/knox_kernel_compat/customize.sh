# Userspace companion for the bone-machine kernel (ReSukiSU/KernelSU built in, Samsung Knox kernel features off).
# Applies only when the kernel patch is enabled, so a build with the stock kernel is unchanged.
if [ -f "$SRC_DIR/target/a52sxq/patches/kernel_bone_machine/disable" ]; then
    LOG "- Stock kernel in use, nothing to do"
    return 0
fi

# KernelSU (throne_tracker) only accepts a manager installed under /data/app whose signing certificate is in the
# kernel's allowlist; a copy in /system/app is never recognised. Samsung's PrePackageInstaller installs every APK in
# /system/preload/<dir>/ as a regular user app on first boot, after an upgrade and whenever the build fingerprint
# changes (every flash of this ROM), skipping it when a higher version is already installed.
KSU_APK="$SRC_DIR/prebuilts/kernel/bone-machine/ReSukiSU_v4.2.0-rc3_35203-arm64-v8a-release.apk"
KSU_SHA="8c760adde1a256202e9b6e7c0523219f0b7af71c4f5306bd3b564875d8d70dad"
[ -f "$KSU_APK" ] || ABORT "knox_kernel_compat: $KSU_APK not found"
[ "$(sha256sum "$KSU_APK" | cut -d " " -f 1)" = "$KSU_SHA" ] || ABORT "knox_kernel_compat: sha256 mismatch for $KSU_APK"
# unica/patches/_debloat deletes /system/preload after the target patches run, so stage the APK outside the
# partition trees; unica/mods/preload copies .extra_preload/* into /system/preload, sets its metadata and adds it
# to vpl_apks_count_list.txt (PrePackageInstaller only installs listed APKs).
mkdir -p "$WORK_DIR/.extra_preload/ReSukiSU"
cp -f "$KSU_APK" "$WORK_DIR/.extra_preload/ReSukiSU/ReSukiSU.apk"
LOG "- ReSukiSU v4.2.0-rc3 (35203) manager staged for /system/preload (installed as a user app on first boot)"
unset KSU_APK KSU_SHA
