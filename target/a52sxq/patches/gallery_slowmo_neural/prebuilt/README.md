# prebuilt/k4neuralmpp

Our own binary (plain C, NDK binder; no third-party code): the neural MPP front store.

- Source: `../src/{k4neuralmpp.c,k4n_engine.c,k4n.h}`; rebuild with `../src/build.sh` (AOSP prebuilt clang r596125,
  NDK sysroot API 30 and bionic crt objects of an AOSP tree; C only, no libc++). Working copy and test tools:
  `/mnt/B1/OneUi9/scratch/htpre/neural` on the build PC (NOTES.md one level up).
- This copy: sha256 `2efeffd4d61e7d5c80260e5015e4641e111ab831e30a16a1513a9879da775713`, 56936 bytes, built 2026-10-11 20:11.
  Tested on R5CTA0ESFTF (9.3.21-bece5ae2-dirty) from /data/local/tmp under a private service name: probe x4 and the
  scripted SemMediaPlayer harness (30 fps at 0.25x, landscape and portrait). The 9.3.21-dirty test ROM itself carries the
  previous build (sha 1215e9c9..., proven in the hal_mpp_default domain); differences since then: work split into more
  parts than threads (warp 22 -> 16 ms per 1080p frame), sigmoid lookup table, engine warm-up on getCapabilityByType(FRC).
- Links only LLNDK libraries: libbinder_ndk, liblog, libm, libdl, libc. dlopens
  `/vendor/lib64/k4neural/{libSnpeHtpV68Stub.so,libSNPE.so}` by path.

Not here on purpose (see ../customize.sh): the Qualcomm AI Runtime libraries (`prebuilts/qairt/2.46.0/`)
and the model (`prebuilts/k4neural/k4n_v3_htp.dlc`); both directories are in `.git/info/exclude`.
