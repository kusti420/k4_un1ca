Galaxy S7 edge still wallpapers for target/a52sxq/patches/wallpaper_more
========================================================================
Source: SM-G935F BTU G935FXXU8EVG2 (Android 8.0, Samsung Experience 9; the last firmware FUS still serves, fetched PC-side
with samloader, TAC 35899707 from a public TAC database; only framework-res.apk + build.prop were kept at
/mnt/B1/OneUi9/fw/SM-G935F_BTU/). 2016 firmwares keep the stills in /system/framework/framework-res.apk
res/drawable-xxxhdpi-v4/, already square (2240x2240, the format the picker centre-crops to the screen; our 1080x2400 view is
scaled by 2400/2240, no cropping/letterboxing needed):
  wpm_s7edge_01 <- default_wallpaper.png         (Black Onyx)       str_id_black
  wpm_s7edge_02 <- default_wallpaper_gold.png    (Gold Platinum)    str_id_gold
  wpm_s7edge_03 <- default_wallpaper_pink.png    (Pink Gold)        str_id_pink
  wpm_s7edge_04 <- default_wallpaper_silver.png  (Silver Titanium)  str_id_silver
  wpm_s7edge_05 <- default_wallpaper_white.png   (White Pearl)      str_id_white
  wpm_s7edge_06..08 <- essential_built_in_wallpaper_1..3.png  (no desc id: generic preset title)
Conversion: cwebp -q 95 -m 6 -sharp_yuv from the PNGs, 51-409 KB each (1.1 MB total), which 1, cmf none.
