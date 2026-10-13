# prebuilt/k4neuralmpp

Our own binary (plain C, NDK binder; no third-party code): the neural MPP front store.

- Source: `../src/{k4neuralmpp.c,k4n_engine.c,k4n.h}`; rebuild with `../src/build.sh` (AOSP prebuilt clang r596125,
  NDK sysroot API 30 and bionic crt objects of an AOSP tree; C only, no libc++). Working copy and test tools:
  `/mnt/B1/OneUi9/scratch/htpre/neural` on the build PC (NOTES.md one level up).
- This copy: sha256 `7361ddee1bd1797a0328998d05716769411f9b60426d99f90f339f0da71c49c6`, 71672 bytes, built 2026-10-13.
  NOT yet run in a ROM. Against the copy shipped in 9.3.21-9.3.25 (sha 2efeffd4..., kept at
  `/mnt/B1/OneUi9/scratch/htpre/neural/packaging/k4neuralmpp.2efeffd4.shipped_9.3.21-25`) it adds: per-hold statistics
  and a single-copy pass-through; NEON warp (bit-exact with the C warp under qemu, 13.2 -> 5.3 ms per 1080p frame on
  the phone for the first version of it), warp straight into the output buffer, a two-stage pipeline (inference of
  pair N+1 overlaps the warp of pair N), pool workers pinned to the big cores, optional event trace (`K4N_TRACE`).
  Only the first version of the NEON/pipeline work ran on R5CTA0ESFTF (private service name, 9.3.22); three more NEON
  paths are PC-verified only. Measurements and the test scripts: `/mnt/B1/OneUi9/scratch/htpre/perf` (REPORT.md,
  `dev/final.sh`).
  Switches, read at the start of every hold (no daemon restart): `persist.sys.k4.slowmo_pipeline` (0 = the old
  single-thread order), `persist.sys.k4.slowmo_neon` (0 = reference C warp), besides `persist.sys.k4.slowmo_neural`.
- Links only LLNDK libraries: libbinder_ndk, liblog, libm, libdl, libc. dlopens
  `/vendor/lib64/k4neural/{libSnpeHtpV68Stub.so,libSNPE.so}` by path.

Not here on purpose (see ../customize.sh): the Qualcomm AI Runtime libraries (`prebuilts/qairt/2.46.0/`)
and the model (`prebuilts/k4neural/k4n_v3_htp.dlc`); both directories are in `.git/info/exclude`.
