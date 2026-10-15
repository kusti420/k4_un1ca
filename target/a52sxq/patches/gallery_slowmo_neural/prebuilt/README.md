# prebuilt/k4neuralmpp

Our own binary (plain C, NDK binder; no third-party code): the neural MPP front store.

- Source: `../src/{k4neuralmpp.c,k4n_engine.c,k4n.h}`; rebuild with `../src/build.sh` (AOSP prebuilt clang r596125,
  NDK sysroot API 30 and bionic crt objects of an AOSP tree; C only, no libc++). Working copy and test tools:
  `/mnt/B1/OneUi9/scratch/htpre/neural` on the build PC (NOTES.md one level up).
- This copy: sha256 `84d04202c5d73c2e2e05698933e02a536cd06603c61dd6791c576fc356fe22ff`, 106832 bytes, built 2026-10-15 with
  `build.sh`: better hands in saved clips (render session): a second FILM crop when a second region moves at least half
  as much as the first, FILM also at the quarter positions for the fastest 25% of pairs (x4 saves), the strongest
  motion kept >= 48 px inside the crop; persist.sys.k4.slowmo_save_hands (default 1) switches it off. About 1.27x the
  config-A save time on the reference clip (/mnt/B1/OneUi9/scratch/htpre/hands_patch/NOTES.md). NOT yet run on a phone.
  Previous copy: sha256 `e9a97d837fb61869c60e6c9b2d6cfd79b9514ecb92b16e0620fcf412ad054249`, 104536 bytes, built 2026-10-15 with
  `build.sh` (the same toolchain rebuilds the previous copy, b7e16c4f..., byte for byte from its sources). Robustness
  on top of the FILM save (b7e16c4f..., 9.3.32-9.3.36): the network is built on a build thread only (binder calls wait
  at most 8 s, then take the classic pipe; the engine state is read without the engine lock); transaction 0x4B3404
  reports the engine state (1 ready / 0 not built / -1 not usable) without waiting; a known-bad engine sends FRC
  creates straight to the classic pipe; init() hands a video the engine cannot take (size, format, no engine) to a
  classic pipe instead of failing; flush/reset wait at most 3 s, then the pipe is failed (onError, every further call
  an error, its memory kept); the idle release never blocks; 8 binder threads instead of 4. NOT yet run on a phone.
  Previous copy: sha256 `0285ba7dc049450902d3a198fe92523d81f1f0a67981405b79029cf78ffa1653`, 86216 bytes, built 2026-10-13: repeat
  bridging (d5091601...) + quality modes (2f5184b6..., see `/mnt/B1/OneUi9/scratch/htpre/quality`) + the live/save
  split: a pipe announced by the recorder with transaction 0x4B3402 (K4SlowMoExport.announceSave) uses
  `persist.sys.k4.slowmo_quality_save` (default 1), every other pipe `persist.sys.k4.slowmo_quality` (default 0).
  Reason: on 9.3.27 (mode 1 everywhere) the worst frame pair at live speed went from ~110 to ~160 ms (budget 133).
  The split itself has NOT run on a phone yet.
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

- FILM (saved slow-mo clips): `prebuilts/k4neural/k4n_film256_htp.dlc` (not in git) is Google Research's FILM
  frame interpolation network (film_net, https://github.com/google-research/frame-interpolation, code and weights
  Apache-2.0), ported to PyTorch, rewritten without wide concats (exact), quantized to 16-bit activations / 8-bit
  per-channel weights and prepared for the SM7325 HTP. Recipe: /mnt/B1/OneUi9/scratch/htpre/quality/film_qnn (NOTES.md).
