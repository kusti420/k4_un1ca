# prebuilt/k4neuralmpp

Our own binary (plain C, NDK binder; no third-party code): the neural MPP front store.

- Source: `../src/{k4neuralmpp.c,k4n_engine.c,k4n.h}`; rebuild with `../src/build.sh` (AOSP prebuilt clang r596125,
  NDK sysroot API 30 and bionic crt objects of an AOSP tree; C only, no libc++). Working copy and test tools:
  `/mnt/B1/OneUi9/scratch/htpre/neural` on the build PC (NOTES.md one level up).
- This copy: sha256 `d50916016db283f3d775cb3fdc2e2a017f7c1e4272772d432897b30cdae565f7`, 75128 bytes, built 2026-10-13.
  History: 2efeffd4... shipped in 9.3.21-9.3.25; 7361ddee... in 9.3.26 (NEON warp, two-stage pipeline, hold statistics,
  single-copy pass-through - real Gallery on 9.3.26, 720p x4: 31.7 fps, intervals median 33 ms, max 52 ms). This copy
  adds bridging of repeated source frames: an isolated repeat (mean abs difference of the prepared luma tensors < 0.15)
  is held back and the next frame is interpolated against the frame before the repeat in 2 x factor steps, so 24/25/27
  -> 30 fps conversions no longer freeze for `factor` frames. Verified on the PC (bridge frames byte-identical to the
  engine at t = k/8) and on R5CTA0ESFTF through a private instance with the real player (user's clip, full length:
  277 duplicate outputs -> 0, same output count and time stamps, intervals no worse); NOT yet run inside the ROM.
  Details: DEDUP and PERF sections of `/mnt/B1/OneUi9/scratch/htpre/NOTES.md`, test scripts in `.../htpre/perf`.
  Switches, read at the start of every hold (no daemon restart): `persist.sys.k4.slowmo_dedup` (0 = no bridging),
  `persist.sys.k4.slowmo_pipeline` (0 = the old single-thread order), `persist.sys.k4.slowmo_neon` (0 = reference C
  warp), besides `persist.sys.k4.slowmo_neural`.
- Links only LLNDK libraries: libbinder_ndk, liblog, libm, libdl, libc. dlopens
  `/vendor/lib64/k4neural/{libSnpeHtpV68Stub.so,libSNPE.so}` by path.

Not here on purpose (see ../customize.sh): the Qualcomm AI Runtime libraries (`prebuilts/qairt/2.46.0/`)
and the model (`prebuilts/k4neural/k4n_v3_htp.dlc`); both directories are in `.git/info/exclude`.
