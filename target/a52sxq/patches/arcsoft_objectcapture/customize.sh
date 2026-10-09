SKIPUNZIP=1

# Sources that ship the engine themselves (S25: lib64 + public.libraries-arcsoft.txt entries) keep their own copy,
# which matches their DressRoom/deepsky SDK; only sources without it (Fold8) get the S22 one.
SOURCE_LIB64="$FW_DIR/$SOURCE_FIRMWARE_PATH/system/system/lib64"
if [ -f "$SOURCE_LIB64/libobjectcapture.arcsoft.so" ] && [ -f "$SOURCE_LIB64/libobjectcapture_jni.arcsoft.so" ]; then
    LOG "- Source already ships the ArcSoft object capture libraries, skipping"
# Libraries come from the S22 (SM-S901E) system image, compressed F2FS: extract with ~/s22_arcsoft_extract.sh
elif [ ! -f "$MODPATH/system/system/lib64/libobjectcapture.arcsoft.so" ] || \
        [ ! -f "$MODPATH/system/system/lib64/libobjectcapture_jni.arcsoft.so" ]; then
    LOG "- ArcSoft object capture libraries not present, skipping"
else
    for f in libobjectcapture.arcsoft.so libobjectcapture_jni.arcsoft.so; do
        ADD_TO_WORK_DIR "$MODPATH" "system" "system/lib64/$f" 0 0 644 "u:object_r:system_lib_file:s0"
        grep -q "^$f$" "$WORK_DIR/system/system/etc/public.libraries-arcsoft.txt" || \
            echo "$f" >> "$WORK_DIR/system/system/etc/public.libraries-arcsoft.txt"
    done
fi
unset SOURCE_LIB64
