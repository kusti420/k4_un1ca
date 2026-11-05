Galaxy S24 Ultra still wallpapers for target/a52sxq/patches/wallpaper_more
==========================================================================
Source: SM-S928B EUX S928BXXS6EZJ1 (PC-side firmware only), /system/priv-app/wallpaper-res/wallpaper-res.apk,
res/drawable-nodpi-v4/Wallpaper_009..016.webp, 3120x3120 (Samsung ships stills square, the picker crops them to the screen),
3.2-8.3 MB each. The "Featured_Signature_Image" set: lock/home pairs per colour (which 1 = home or lock, 2 = lock screen only):
  wpm_s24u_01 <- Wallpaper_009  str_id_black        which 1   cmf zk,lg      wpm_s24u_02 <- Wallpaper_010  str_id_gray       which 2
  wpm_s24u_03 <- Wallpaper_011  str_id_dark_gray    which 1   cmf zt         wpm_s24u_04 <- Wallpaper_012  str_id_warm_gray  which 2
  wpm_s24u_05 <- Wallpaper_013  str_id_dark_violet  which 1   cmf zv,lb      wpm_s24u_06 <- Wallpaper_014  str_id_violet     which 2
  wpm_s24u_07 <- Wallpaper_015  str_id_dark_yellow  which 1   cmf zy,zo      wpm_s24u_08 <- Wallpaper_016  str_id_yellow     which 2
Conversion: ffmpeg scale=2400:2400 (lanczos) -> cwebp -q 95 -m 6 -sharp_yuv: 2400x2400 (the A52s screen height; the S26U stills
stay 3120 as shipped), 164-328 KB each, the particle sparkles of the dark variants survive (compared at 100 %).
All str_ids exist in our wallpaper-res strings. Regenerate: /mnt/B1/OneUi9/scratch/wallpapers_more/ (sets.json, build_fragments.py).
