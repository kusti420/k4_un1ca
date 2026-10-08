#!/usr/bin/env bash
# Reproduce the bone-machine "One-UI ReSukiSU" A52s 5G kernel release build-20261004-122005 locally
# (GitHub Actions run 37200490865 of mna08072-cmyk/android_kernel_samsung_sm7325_a52s_5g, matrix branch resukisu-oneui).
#
#   ./k4_build.sh                 # exact release reproduction
#   K4_BACKPORTS=1 ./k4_build.sh  # same, plus k4-patches/*.patch (Android 17 kernel-feature backports)
#
# Pins (from the release notes of build-20261004-122005 and the workflow file at main 6806314d69):
#   kernel source   resukisu-oneui @ 93b49d0ccd89ee2de118f34b5d51862d9c6cb2dd (branch tip at run time)
#   ReSukiSU        8770c7e324a22895703c4916b8a16520e0b81c79 (v4.2.0-rc3-32-g8770c7e3), submodule KernelSU/
#   NoMount         maxsteeel/nomount dev @ 5fac312b143e632e483c3c8b9ab325b6d4527314 (use_nomount=true)
#   Baseband-Guard  vc-teahouse/Baseband-guard main @ a54e0dc6cf0aff4dd87fec49644a02d2eb612905 (use_bbg=true)
#   toolchain       clang-r530567 (AOSP clang 19.0.0, build 12328485) from the repo's toolchain-r530567 release
# Output: bone-machine_<date>_One-UI_ReSukiSU-*_a52sxq.zip in the repo root (boot/vendor_boot/dtbo), out/ build tree.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

SRC_COMMIT=93b49d0ccd89ee2de118f34b5d51862d9c6cb2dd
RESUK_PIN=8770c7e324a22895703c4916b8a16520e0b81c79
NOMOUNT_PIN=5fac312b143e632e483c3c8b9ab325b6d4527314
BBG_PIN=a54e0dc6cf0aff4dd87fec49644a02d2eb612905
MAIN_COMMIT=6806314d69f2bf73199a2f31ea177b5b9b48f4af
CLANG_TGZ_URL=https://github.com/Tomkun-desu/android_kernel_samsung_sm7325_a52s_5g/releases/download/toolchain-r530567/clang-r530567-linux-x86.tar.gz
CLANG_TGZ_SHA256=8527a2d302c0d507d65f99e73d3d6a4942686cf3822a8a2ed1e2f4c4611270f3
CACHE="${K4_CACHE:-$HOME/toolchains/k4-kernel-cache}"
DEFCONFIG=arch/arm64/configs/vendor/a52sxq_kor_single_defconfig

log() { printf '\033[1;36m[k4]\033[0m %s\n' "$*"; }

# 1. Pristine source at the release commit on a branch named like the CI matrix branch (the build script derives
#    the One UI variant and ReSukiSU root solution from the branch name).
log "Resetting source to resukisu-oneui @ ${SRC_COMMIT:0:12}"
git checkout -q -B resukisu-oneui "$SRC_COMMIT"
git reset -q --hard "$SRC_COMMIT"
git clean -q -fdx -e k4_build.sh -e 'k4_build*.log' -e k4-patches/ -e k4-out/ -e toolchain/clang -e /out/ -e '*.zip'
rm -f security/baseband-guard

# 2. ReSukiSU at the pinned commit; keep build_kernel_zip.sh's "git submodule update" from resetting it.
git submodule update -q --init KernelSU
git -C KernelSU fetch -q origin "$RESUK_PIN" 2>/dev/null || git -C KernelSU fetch -q origin main --tags
git -C KernelSU checkout -q "$RESUK_PIN"
git -C KernelSU fetch -q origin --tags 2>/dev/null || true
git config submodule.KernelSU.update none
[ "$(git -C KernelSU rev-parse HEAD)" = "$RESUK_PIN" ]

mkdir -p "$CACHE"
fetch_pin() { # url dir sha
    if [ ! -d "$2/.git" ]; then git clone -q "$1" "$2"; fi
    git -C "$2" fetch -q origin "$3" 2>/dev/null || git -C "$2" fetch -q origin
    git -C "$2" checkout -q "$3"
    [ "$(git -C "$2" rev-parse HEAD)" = "$3" ]
}

# 3. NoMount (workflow step "Float NoMount", use_nomount=true)
log "NoMount @ ${NOMOUNT_PIN:0:12}"
fetch_pin https://github.com/maxsteeel/nomount.git "$CACHE/nomount" "$NOMOUNT_PIN"
NM_SRC="$CACHE/nomount/kernel/src"
mkdir -p fs/nomount
cp "$NM_SRC/nomount.c" "$NM_SRC/nomount.h" "$NM_SRC/Kconfig" "$NM_SRC/Makefile" fs/nomount/
grep -q 'obj-$(CONFIG_NOMOUNT) += nomount/' fs/Makefile || echo 'obj-$(CONFIG_NOMOUNT) += nomount/' >> fs/Makefile
if ! grep -q 'source "fs/nomount/Kconfig"' fs/Kconfig; then
    awk '/^endmenu$/ { last = NR } { lines[NR] = $0 } END { for (i = 1; i <= NR; i++) { if (i == last) print "source \"fs/nomount/Kconfig\""; print lines[i] } }' fs/Kconfig > fs/Kconfig.nomount
    mv fs/Kconfig.nomount fs/Kconfig
fi
grep -q '^CONFIG_NOMOUNT=y' "$DEFCONFIG" || echo 'CONFIG_NOMOUNT=y' >> "$DEFCONFIG"

# 4. Baseband-Guard (workflow step "Float Baseband-Guard", use_bbg=true)
log "Baseband-Guard @ ${BBG_PIN:0:12}"
fetch_pin https://github.com/vc-teahouse/Baseband-guard.git "$CACHE/bbg" "$BBG_PIN"
BBG_DIR="$CACHE/bbg-$BBG_PIN"
rm -rf "$BBG_DIR"; cp -a "$CACHE/bbg" "$BBG_DIR"; rm -rf "$BBG_DIR/.git"
{ grep -rl '#include <linux/kstrtox.h>' "$BBG_DIR/" 2>/dev/null || true; } | while read -r f; do sed -i '/#include <linux\/kstrtox.h>/d' "$f"; done
ln -sfn "$BBG_DIR" security/baseband-guard
grep -q 'baseband-guard/' security/Makefile || printf '\nobj-$(CONFIG_BBG) += baseband-guard/\n' >> security/Makefile
if ! grep -q 'security/baseband-guard/Kconfig' security/Kconfig; then
    awk '/^endmenu$/ { last = NR } { lines[NR] = $0 } END { for (i = 1; i <= NR; i++) { if (i == last) print "source \"security/baseband-guard/Kconfig\""; print lines[i] } }' security/Kconfig > security/Kconfig.bbg
    mv security/Kconfig.bbg security/Kconfig
fi
BBG_FRAG=arch/arm64/configs/bbg.config
if [ ! -s "$BBG_FRAG" ]; then
    git show "$MAIN_COMMIT:arch/arm64/configs/bbg.config" > "$CACHE/bbg.config"
    BBG_FRAG="$CACHE/bbg.config"
fi
while IFS= read -r LINE || [ -n "$LINE" ]; do
    case "$LINE" in
        '# CONFIG_'*' is not set')
            SYM="${LINE#'# '}"; SYM="${SYM%' is not set'}"
            sed -i "/^${SYM}=y$/d" "$DEFCONFIG"; grep -qx "$LINE" "$DEFCONFIG" || echo "$LINE" >> "$DEFCONFIG" ;;
        CONFIG_*'=y')
            SYM="${LINE%'=y'}"
            sed -i "/^# ${SYM} is not set$/d" "$DEFCONFIG"; sed -i "/^${SYM}=\".*\"$/d" "$DEFCONFIG"
            grep -qx "$LINE" "$DEFCONFIG" || echo "$LINE" >> "$DEFCONFIG" ;;
        CONFIG_*'="'*'"')
            SYM="${LINE%%=*}"
            sed -i "/^${SYM}=.*$/d" "$DEFCONFIG"; sed -i "/^# ${SYM} is not set$/d" "$DEFCONFIG"
            grep -qx "$LINE" "$DEFCONFIG" || echo "$LINE" >> "$DEFCONFIG" ;;
        ''|'#'*) continue ;;
        *) echo "unexpected line in bbg.config: $LINE"; exit 1 ;;
    esac
done < "$BBG_FRAG"

# 4b. eBPF defconfig options (workflow step "Enable eBPF defconfig options", use_ebpf=true in the release:
#     the release kernel's embedded config has CONFIG_NET_ACT_BPF=y)
sed -i '/^CONFIG_NET_ACT_BPF[= ].*/d; /^# CONFIG_NET_ACT_BPF is not set/d' "$DEFCONFIG"
echo 'CONFIG_NET_ACT_BPF=y' >> "$DEFCONFIG"

# 4c. Unicode bypass fix (workflow step "Apply Unicode bypass fix", use_unicode_fix). on by default (K4_UNICODE=0 disables it),
#     pinned to the kernel_patches tip at release time (41ae18b3; the patch file itself last changed in 5757dbf5).
if [ "${K4_UNICODE:-1}" = "1" ]; then
    fetch_pin https://github.com/WildKernels/kernel_patches.git "$CACHE/wk" 41ae18b35d20e0c6ac04116785a4a1089528ae94
    git apply --check "$CACHE/wk/common/unicode_bypass_fix_6.1-.patch"
    git apply "$CACHE/wk/common/unicode_bypass_fix_6.1-.patch"
    log "Unicode bypass fix applied"
fi

# Release build stamp (uname -v) so the image matches the release as closely as possible
export KBUILD_BUILD_TIMESTAMP="${KBUILD_BUILD_TIMESTAMP:-Sun Oct 4 12:00:42 UTC 2026}"

# 5. Optional Android 17 kernel-feature backports
if [ "${K4_BACKPORTS:-0}" = "1" ]; then
    for p in "$ROOT"/k4-patches/*.patch; do
        [ -e "$p" ] || continue
        log "Backport: $(basename "$p")"
        git apply --check "$p"
        git apply "$p"
    done
fi

# 6. Toolchain: the CI's clang-r530567 release, placed where build_kernel_zip.sh looks for it
if [ ! -x toolchain/clang/bin/clang ]; then
    TC="$HOME/toolchains/clang-r530567"
    if [ ! -x "$TC/toolchain/bin/clang" ]; then
        mkdir -p "$TC"
        curl -sL -o "$TC.tar.gz" "$CLANG_TGZ_URL"
        echo "$CLANG_TGZ_SHA256  $TC.tar.gz" | sha256sum -c -
        tar -xzf "$TC.tar.gz" -C "$TC"
    fi
    ln -sfn "$TC/toolchain" toolchain/clang
fi
export PATH="$ROOT/toolchain/clang/bin:$PATH"
clang --version | head -1

# 7. Build exactly like the CI step "Build kernel"
log "Building (logs: out/../k4_build.log)"
# build_kernel_zip.sh refuses to run unless its directory is named like the upstream repo; run it through a
# symlink with that name (it derives KERNEL_ROOT from `cd "$(dirname "$0")" && pwd`, which keeps the link name).
LINKDIR="$CACHE/src"
mkdir -p "$LINKDIR"
ln -sfn "$ROOT" "$LINKDIR/android_kernel_samsung_sm7325_a52s_5g"
( cd "$LINKDIR/android_kernel_samsung_sm7325_a52s_5g" && ./build_kernel_zip.sh < /dev/null )
make -C . O=out ARCH=arm64 olddefconfig
grep -q '^CONFIG_NOMOUNT=y' out/.config
grep -q '^CONFIG_BBG=y' out/.config
if grep -q '^CONFIG_KSU_SUSFS=y' out/.config; then echo "resukisu-oneui must not enable SUSFS"; exit 1; fi
log "Done: $(ls -t "$ROOT"/bone-machine_*_One-UI_*.zip | head -1)"
