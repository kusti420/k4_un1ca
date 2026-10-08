# Effect libraries loaded by the vendor audio effects config (/system/lib/... -> lib64 for the 64-bit audioserver);
# they only talk to the framework through the audio effect library interface (AELI)
for f in libsamsungSoundbooster_plus_legacy.so lib_SoundBooster_ver1050.so libmysound_legacy.so; do
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/$f" 0 0 644 "u:object_r:system_lib_file:s0"
done
