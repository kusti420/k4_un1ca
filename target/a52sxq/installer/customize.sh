# The bundled bone-machine kernel (patches/kernel_bone_machine) ships its own dtbo.img built from its sources.
if [ -f "$SRC_DIR/target/$TARGET_CODENAME/patches/kernel_bone_machine/disable" ]; then
    LOG "- Downloading A528NKSS7GYI1_kernel.tar"
    DOWNLOAD_FILE \
        "https://github.com/UN1CA/proprietary_vendor_samsung_sm7325/releases/download/A528NKSS7GYI1_KOO_OKR/A528NKSS7GYI1_kernel.tar" \
        "$TMP_DIR/A528NKSS7GYI1_kernel.tar" || return 1

    LOG "- Extracting dtbo.img.lz4"
    EVAL "cd \"$TMP_DIR\"; tar -xf \"A528NKSS7GYI1_kernel.tar\" \"dtbo.img.lz4\"" || return 1
    EVAL "rm -f \"$TMP_DIR/A528NKSS7GYI1_kernel.tar\"" || return 1

    LOG "- Decompressing dtbo.img.lz4"
    EVAL "lz4 -d -f --rm \"$TMP_DIR/dtbo.img.lz4\" \"$TMP_DIR/dtbo.img\"" || return 1

    "$SRC_DIR/scripts/unsign_bin.sh" "$TMP_DIR/dtbo.img" || return 1

    if ! $TARGET_DISABLE_AVB_SIGNING; then
        LOG "- Signing dtbo.img with AVB"
        EVAL "avbtool add_hash_footer --image \"$TMP_DIR/dtbo.img\" --partition_size \"25165824\" --partition_name \"dtbo\" --hash_algorithm \"sha256\" --algorithm \"SHA256_RSA4096\" --key \"$SRC_DIR/security/avb/testkey_rsa4096.pem\"" || return 1
    fi
else
    LOG "- Keeping the dtbo.img of the bundled bone-machine kernel"
fi

# De-Googled variant (target/a52sxq/patches/degoogle enabled): a flash over the Google build keeps /data, where Play
# Store had placed updated copies of the very packages this build drops. Without their system counterparts the
# package manager keeps them as plain user apps that crash-loop (no GSF). Remove those orphan copies during the
# install; the package manager drops the dead package records and their data on the next boot. User-installed Google
# apps that were never part of the image are left alone.
if [ ! -f "$SRC_DIR/target/$TARGET_CODENAME/patches/degoogle/disable" ]; then
    LOG "- Adding the de-Googled /data cleanup to the updater-script"
    DEGOOGLE_PKGS="com.google.android.gms com.google.android.gsf com.android.vending com.google.android.configupdater"
    DEGOOGLE_PKGS+=" com.google.android.googlequicksearchbox com.google.android.apps.messaging com.google.android.apps.photos"
    DEGOOGLE_PKGS+=" com.google.android.tts com.google.android.euicc com.google.android.projection.gearhead"
    DEGOOGLE_PKGS+=" com.google.android.partnersetup com.google.android.apps.restore com.google.android.apps.turbo"
    DEGOOGLE_PKGS+=" com.google.android.aicore com.google.android.as com.google.android.as.oss com.google.ambient.streaming"
    DEGOOGLE_PKGS+=" com.google.android.apps.carrier.carrierwifi com.google.android.callcore com.google.android.mosey"
    DEGOOGLE_PKGS+=" com.google.android.verifier com.google.ar.core com.google.android.syncadapters.calendar"
    DEGOOGLE_PKGS+=" com.google.android.gms.location.history com.google.android.feedback com.google.android.marvin.talkback"
    DEGOOGLE_PKGS+=" com.google.android.printservice.recommendation com.google.android.apps.aiwallpapers"
    DEGOOGLE_PKGS+=" com.google.android.glasses.core com.google.android.gms.supervision com.google.android.setupwizard"
    DEGOOGLE_PKGS+=" com.android.hotwordenrollment.okgoogle com.android.hotwordenrollment.xgoogle"
    DEGOOGLE_PKGS+=" com.google.mainline.telemetry com.google.mainline.adservices"
    DEGOOGLE_EDIFY="$(cat << EDIFY
if is_mounted("/data") then
  ui_print("De-Googled build: removing orphaned Play-updated Google packages from /data...");
  run_program("/system/bin/sh", "-c", "for p in $DEGOOGLE_PKGS; do rm -rf /data/app/*/\$p-* /data/app/\$p-*; done; rm -rf /data/apex/active/com.google.android.gmssystem*; exit 0");
endif;
EDIFY
)"
    python3 - "$TMP_DIR/META-INF/com/google/android/updater-script" "$DEGOOGLE_EDIFY" << 'PY' || return 1
import sys
p, block = sys.argv[1], sys.argv[2]
s = open(p).read()
marker = "set_progress(1.000000);"
assert s.count(marker) == 1, "set_progress marker not unique"
open(p, "w").write(s.replace(marker, block + "\n" + marker))
PY
    unset DEGOOGLE_PKGS DEGOOGLE_EDIFY
fi
