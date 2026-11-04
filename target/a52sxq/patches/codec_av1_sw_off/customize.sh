SKIPUNZIP=1
# See module.prop. The parser takes the FIRST search dir (/product/etc, /odm/etc, /vendor/etc, /system/etc) where a
# media_codecs_c2.xml / media_codecs_performance_c2.xml exists: refuse to shadow one that another partition ships.
for f in media_codecs_c2.xml media_codecs_performance_c2.xml; do
    for d in odm/etc vendor/etc system/system/etc; do
        [ -e "$WORK_DIR/$d/$f" ] && ABORT "codec_av1_sw_off: $d/$f exists, /product/etc/$f would shadow it"
    done
done
[ -e "$WORK_DIR/product/etc/media_codecs_performance_c2.xml" ] && \
    ABORT "codec_av1_sw_off: product/etc/media_codecs_performance_c2.xml exists (not ours)"
if [ -e "$WORK_DIR/product/etc/media_codecs_c2.xml" ] && \
        ! grep -q "codec_av1_sw_off" "$WORK_DIR/product/etc/media_codecs_c2.xml"; then
    ABORT "codec_av1_sw_off: product/etc/media_codecs_c2.xml exists and is not ours"
fi
[ -d "$WORK_DIR/product/etc" ] || ABORT "codec_av1_sw_off: no product/etc in the work dir"
ls "$WORK_DIR"/system/system/apex/com.google.android.media.swcodec*.apex > /dev/null 2>&1 || \
    ABORT "codec_av1_sw_off: no Google swcodec APEX in system/apex (the AV1 decoders this disables come from it)"
EVAL "cp -f \"$MODPATH/media_codecs_c2.xml\" \"$WORK_DIR/product/etc/media_codecs_c2.xml\""
SET_METADATA "product" "etc/media_codecs_c2.xml" 0 0 644 "u:object_r:system_file:s0"
LOG "- Software AV1 decoders (c2.android.av1*, swcodec APEX) hidden from the codec list: /product/etc/media_codecs_c2.xml"
