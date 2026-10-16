#!/bin/bash
# Builds prebuilt/k4neuralmpp (arm64, vendor, plain C) from this directory.
# Needs an AOSP tree for the toolchain only: the prebuilt clang, the NDK sysroot produced by a platform build
# (API 30 stubs of libc, libm, libdl, liblog, libbinder_ndk) and bionic's crtbegin_dynamic.o / crtend_android.o.
#   AOSP=~/git/android ./build.sh
set -e
cd "$(dirname "$0")"
AOSP=${AOSP:-$HOME/git/android}
CLANG=${CLANG:-$AOSP/prebuilts/clang/host/linux-x86/clang-r596125/bin/clang}
SYSROOT=${SYSROOT:-$AOSP/out/soong/ndk/sysroot}
CRT=${CRT:-$AOSP/out/soong/.intermediates/bionic/libc}
for f in "$CLANG" "$SYSROOT/usr/include/android/binder_ibinder.h" "$CRT/crtbegin_dynamic/android_arm64_armv8-a/crtbegin_dynamic.o" "$CRT/crtend_android/android_arm64_armv8-a/crtend_android.o"; do
    [ -e "$f" ] || { echo "missing: $f" >&2; exit 1; }
done
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
cp "$CRT/crtbegin_dynamic/android_arm64_armv8-a/crtbegin_dynamic.o" "$CRT/crtend_android/android_arm64_armv8-a/crtend_android.o" "$T/"
"$CLANG" --target=aarch64-linux-android30 --sysroot="$SYSROOT" -B"$T" -O2 -fPIE -pie -Wall -Wno-unused-function -ffp-contract=fast \
    -Wl,--export-dynamic-symbol=remote_handle64_control \
    k4neuralmpp.c k4n_engine.c -o ../prebuilt/k4neuralmpp -lbinder_ndk -llog -lm -ldl
ls -la ../prebuilt/k4neuralmpp; sha256sum ../prebuilt/k4neuralmpp
