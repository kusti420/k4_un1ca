Galaxy Z Fold8 wallpapers for target/a52sxq/patches/wallpaper_more
==================================================================
Source: SM-F976B INS F976BXXU1AZFW (PC-side firmware only; the SM-F9760 CHC build carries the same files),
/system/priv-app/wallpaper-res/wallpaper-res.apk.
Stills: the main-screen res/drawable-nodpi-v4/wallpaper_001..004.webp, 2504x2504 (square like every Samsung still, the picker
crops the 1080x2400 view out of the centre, the wave ribbon is centred), 1.8-3.7 MB, byte-identical copies:
  wpm_fold8_01 str_id_dark_gray cmf ZK | 02 cream ZW | 03 violet ZV | 04 green DG   (which 1)
The cover-screen stills (sub_wallpaper_*, 1080x2520) and cover videos (sub_video_*, type 8 plain video) are not taken.
Clips: res/raw/video_001..004.mp4, 2504x2504 HEVC Main 8-bit 120 fps, all-intra, 545 frames, 4.54 s, 107-110 Mbit/s, 61 MB each.
On the Fold8 they are "FoldInteractive" wallpapers (com.samsung.android.wallpaper.live.fold.FoldInteractive, service_settings
angle_frame_mapping "0 0, 60 60, 90 90, 175 545": the frame follows the hinge angle, the closed "8" ribbon unfolds into the
wave of the still) - nothing drives them on a flat phone, so they are recast as InfinityWallpaper clips with their own table.
  wpm_fold8_v01 <- video_001 dark_gray ZK | v02 <- video_002 cream ZW | v03 <- video_003 violet ZV | v04 <- video_004 green DG
Transcode: the prebuilts/wallpapers/s26u command with crop=1126:2504:689:0 (centre 9:20 of the square) and CRF 21 ->
1080x2400 HEVC Main 8-bit 30 fps, 136 frames, 4.53 s, every frame IDR_N_LP, 2.4-2.7 Mbit/s, 1.3-1.5 MB each.
Motion table (destination frames, the S24U default-table shape scaled to 136 frames; AOD shows the closed "8", lock/home the
open wave = the still, thumbnails frame 135):
  AOD AOD 0 30 1200 | AOD LOCK 0 68 1800 | AOD HOME 0 135 2500 | LOCK HOME 68 135 1200 | LOCK TOUCH 68 102 1000
Decoder budget at 1080x2400 (10125 blocks/frame): 259,625 / 385,250 / 546,720 / 569,500 / 351,750 blocks/s: all under the
1,044,480 cap.
