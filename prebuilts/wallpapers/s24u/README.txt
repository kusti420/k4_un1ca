Galaxy S24 Ultra "Interactive wallpapers" for target/a52sxq/patches/wallpaper_interactive
=======================================================================================

Source: SM-S928B EUX S928BXXS6EZJ1 (One UI 8 / OS17 build, PC-side firmware only), system partition,
/system/priv-app/wallpaper-res/wallpaper-res.apk (com.samsung.android.wallpaper.res), res/raw/E3_Infinite_Video_Wallpaper_*.mp4
1440x3120 HEVC Main10 (yuv420p10le, hvc1, bt709 tv range), 120 fps, all-intra, 2953 frames, 24.608 s, 52-53 Mbit/s, 162-163 MB each.

  video_001.mp4  <- E3_Infinite_Video_Wallpaper_ZKLG.mp4  str_id_black      cmf zk,lg
  video_002.mp4  <- E3_Infinite_Video_Wallpaper_ZT.mp4    str_id_warm_gray  cmf zt
  video_003.mp4  <- E3_Infinite_Video_Wallpaper_ZVLB.mp4  str_id_violet     cmf zv,lb
  video_004.mp4  <- E3_Infinite_Video_Wallpaper_ZYZO.mp4  str_id_yellow     cmf zy,zo

Transcode (ffmpeg 8 / libx265 4.3), identical for every clip:
  ffmpeg -i <src> -vf "fps=30,crop=1404:3120:18:0,scale=1080:2400:flags=lanczos,format=yuv420p" \
      -c:v libx265 -preset slow -crf 21 -pix_fmt yuv420p -force_key_frames "expr:1" -forced-idr 1 \
      -x265-params "keyint=250:min-keyint=1:scenecut=0:bframes=0:open-gop=0:repeat-headers=1" -tag:v hvc1 -an -movflags +faststart <dst>
  -> 1080x2400 HEVC Main 8-bit (general_profile_idc 1), level 5.0, 30 fps (frame N = source frame 4N), 738 frames,
     24.6 s, every frame an IDR_N_LP NAL (type 20) like Samsung's own clips (open-gop=0; without it the forced key frames come out as CRA). (keyint=1 is not used on purpose: x265 then signals the RExt "Main Intra"
     profile, idc 4, which the SM7325 decoder does not advertise; forcing IDR on every frame with keyint 250 yields the
     same all-intra stream signalled as Main, as Samsung's own all-intra clips are signalled Main 10.)

resources_info_infinity.json: the four type-10 "infinity" entries in the S26U (2.8.78) schema that customize.sh appends to
res/raw/resources_info.json. transition_frame_info is the SpriteWallpaper 2.8.78 built-in table for SEM_FIRST_SDK_INT < 35
(the S24U json has none, the One UI 8 engine used that default) with every frame number multiplied by 30/120:
  AOD AOD    0  75 1200 ms    AOD LOCK   0 180 1800 ms    AOD HOME   0 737 2500 ms
  LOCK HOME 180 737 1200 ms   LOCK TOUCH 180 450 1000 ms   (738 clamped to the last frame, 737)
The "_s24u_source" key in each entry is documentation only; customize.sh drops it.

Regenerate: /mnt/B1/OneUi9/scratch/s24u_wallpapers/work/ (transcode.sh, build_fragment.py, INVENTORY.md) on the build PC.
