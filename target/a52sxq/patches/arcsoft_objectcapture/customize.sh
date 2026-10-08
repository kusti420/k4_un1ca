SKIPUNZIP=1

# Libraries come from the S22 (SM-S901E) system image, compressed F2FS: extract with ~/s22_arcsoft_extract.sh
if [ ! -f "$MODPATH/system/system/lib64/libobjectcapture.arcsoft.so" ] || \
        [ ! -f "$MODPATH/system/system/lib64/libobjectcapture_jni.arcsoft.so" ]; then
    LOG "- ArcSoft object capture libraries not present, skipping"
else
    for f in libobjectcapture.arcsoft.so libobjectcapture_jni.arcsoft.so; do
        ADD_TO_WORK_DIR "$MODPATH" "system" "system/lib64/$f" 0 0 644 "u:object_r:system_lib_file:s0"
        grep -q "^$f$" "$WORK_DIR/system/system/etc/public.libraries-arcsoft.txt" || \
            echo "$f" >> "$WORK_DIR/system/system/etc/public.libraries-arcsoft.txt"
    done
fi
