Galaxy S26 Ultra "Interactive wallpapers" for target/a52sxq/patches/wallpaper_more
================================================================================
Source: our own base, SM-S948B EUX S948BXXS4BZIG, /system/priv-app/wallpaper-res/wallpaper-res.apk res/raw/video_001..006.mp4:
1440x3120 HEVC Main10 (yuv420p10le, hvc1) 90 fps, all-intra, 1620 frames, 18.0 s, 59.7 Mbit/s, 134 MB each. patches/wallpaper
has to strip them (above the c2.qti.hevc.decoder budget of 1044480 16x16 blocks/s) and turns their entries into the stills;
this set brings them back re-encoded (the SM-S942B Galaxy S26 ships byte-identical clips).
  wpm_s26u_v01 <- video_001  str_id_black       cmf zk      wpm_s26u_v04 <- video_004  str_id_white   cmf zw
  wpm_s26u_v02 <- video_002  str_id_light_blue  cmf lb      wpm_s26u_v05 <- video_005  str_id_gold    cmf zd
  wpm_s26u_v03 <- video_003  str_id_violet      cmf zv      wpm_s26u_v06 <- video_006  str_id_silver  cmf zs
Transcode (ffmpeg 8 / libx265 4.3, the prebuilts/wallpapers/s24u recipe):
  ffmpeg -i <src> -vf "fps=30,crop=1404:3120:18:0,scale=1080:2400:flags=lanczos,format=yuv420p" -c:v libx265 -preset slow -crf 22 \
      -pix_fmt yuv420p -force_key_frames "expr:1" -forced-idr 1 \
      -x265-params "keyint=250:min-keyint=1:scenecut=0:bframes=0:open-gop=0:repeat-headers=1" -tag:v hvc1 -an -movflags +faststart <dst>
  -> 1080x2400 HEVC Main 8-bit, level 5.0, 30 fps (frame N = source frame 3N), 540 frames, 18.0 s, every frame IDR_N_LP,
     2.3-3.3 Mbit/s, 5.3-7.4 MB each (smooth gradients compress far better than the S24U sparkles at the same CRF).
Motion table: the source's own multi-direction table (LOCK HOME_LEFT/UP/RIGHT, LOCK TOUCH_LEFT/UP/RIGHT) with every frame
number x 30/90, durations unchanged, thumbnails 270 -> 90:
  AOD LOCK 0 90 1500 | AOD HOME 0 240 3000 | LOCK HOME_LEFT 90 240 3000 | LOCK HOME_UP 240 390 3000 | LOCK HOME_RIGHT 390 539 3000
  LOCK TOUCH_LEFT 90 173 3000 | LOCK TOUCH_UP 240 323 3000 | LOCK TOUCH_RIGHT 390 473 3000
Decoder budget at 1080x2400 (10125 blocks/frame): AOD LOCK 609,700 / AOD HOME 807,350 / LOCK HOME_* 502,500-505,850 /
LOCK TOUCH_* 281,400 blocks/s: every transition under the 1,044,480 cap (no scrub rows in this table).
Regenerate: /mnt/B1/OneUi9/scratch/wallpapers_more/ (transcode.sh, sets.json, build_fragments.py, INVENTORY.md).
