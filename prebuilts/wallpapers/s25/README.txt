Galaxy S25 wallpapers for target/a52sxq/patches/wallpaper_more
==============================================================
Source: SM-S931B EUX S931BXXUCDZIF (PC-side firmware only), /system/priv-app/wallpaper-res/wallpaper-res.apk.
Stills: res/drawable-nodpi-v4/wallpaper_001..010.webp, 2340x2340, 2.2-4.4 MB, byte-identical copies, lock/home pairs:
  wpm_s25_01 silver (which 2) / 02 dark_silver (1)  cmf zs,zk     wpm_s25_07 blue (2) / 08 dark_blue (1)  cmf db
  wpm_s25_03 green (2) / 04 dark_green (1)          cmf lg        wpm_s25_09 pink (2) / 10 dark_pink (1)  cmf zr,zd
  wpm_s25_05 light_blue (2) / 06 blue_violet (1)    cmf lb
Clips: res/raw/video_001..005.mp4, 1440x3120 HEVC Main10 120 fps level 6.2, all-intra, 2040 frames, 17.0 s, 74-82 Mbit/s,
157-176 MB each (patches/wallpaper would strip them on an S25 source for the same decoder reason).
  wpm_s25_v01 <- video_001 str_id_silver cmf zs,zk | v02 <- video_002 green lg | v03 <- video_003 light_blue lb |
  v04 <- video_004 blue db | v05 <- video_005 pink zr,zd
Transcode: the prebuilts/wallpapers/s26u command (CRF 22) -> 1080x2400 HEVC Main 8-bit 30 fps (frame N = source frame 4N),
510 frames, 17.0 s, every frame IDR_N_LP, 2.0-2.2 Mbit/s, 4.2-4.7 MB each.
Motion table: the source's own (S25 generation, same as the SpriteWallpaper 2.8.78 built-in SEM_FIRST_SDK_INT >= 35 table plus
AOD AOD) x 30/120, durations unchanged, thumbnails 700 -> 175 (lock, preview), 2042 -> 509 (system, clamped to the last frame):
  AOD AOD 0 75 1200 | AOD LOCK 0 175 1000 | AOD HOME 0 509 2500 | LOCK HOME 175 509 1500 | LOCK TOUCH 175 438 1500
Decoder budget at 1080x2400 (10125 blocks/frame): AOD AOD 636,500 OK; AOD LOCK 1,768,800, AOD HOME 2,050,200, LOCK HOME
2,244,500, LOCK TOUCH 1,768,800 blocks/s are scrubs (more frames than any display shows in the time: the engine seeks once per
vsync, 60 Hz = 607,500, 120 Hz = 1,215,000 blocks/s, the same situation as the S24U set verified live in 9.3.105).
