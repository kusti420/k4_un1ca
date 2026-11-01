SKIPUNZIP=1

# Play Integrity module stack by default (see module.prop and k4-gmscompat). Ships the exact module zips that pass
# BASIC+DEVICE+STRONG on this phone, the configs that passed and the boot hook /system/bin/k4-gmscompat with
# /system/etc/init/k4_gmscompat.rc:
#   init.svc.k4_metamod=stopped        -> k4_gmscompat (KernelSU's own domain u:r:ksu:s0): installs the stack with
#                                         `ksud module install` (k4_metamod only runs after its gate found KernelSU,
#                                         so the domain exists, and any metamodule install of this boot is done)
#   persist.sys.unica.pif changes      -> the same, at once (the Settings "Play Integrity Fix" switch)
# Without KernelSU nothing runs. Needs ksu_metamodule (its services, its status property type).
# zygisksu and playintegrityfix are the upstream releases, unmodified. teesim is the upstream canary 73 with ONE
# byte changed in arm64-v8a/libteesim_keymint.so (offset 0xe0206, 0x02->0x03: cmp x24,#0x80 -> #0xc0, raising the
# kmr MAX_ATTESTATION_CHALLENGE_SIZE 128->192) so GMS 26.42.31+'s 144-byte attestation challenge is accepted instead
# of rejected (INVALID_INPUT_LENGTH -> Play Integrity INTERNAL_ERROR/-100). 192 still rejects Duck Detector's >=256
# probes. See PROVENANCE.txt; unmodified upstream archived at pi_stack_ship/. The keybox is NOT in this repository
# (public): a keybox.xml at $K4_PIF_KEYBOX (default /mnt/B1/OneUi9/keybox/keybox.xml) is shipped when it exists.
PIF_ZIPS="ce50b13fecb9e4456db69ef17b715f7cfbc094004dd9f30f7d6348dfab619a96 zygisksu 864
39598955355cc94cb87110b6f1e648c541e079eb2266df3da23c442324c7205c teesim 73
bc7a9d92638a6bd90a41b70d3aaf86bc549dd8d3a1e5e901b315a6c425852697 playintegrityfix 490"
PIF_KEYBOX="${K4_PIF_KEYBOX:-/mnt/B1/OneUi9/keybox/keybox.xml}"
PIF_DIR="$WORK_DIR/system/system/etc/k4/gmscompat"

[ -f "$WORK_DIR/system/system/etc/init/k4_metamodule.rc" ] || \
    ABORT "pif_stack: needs ksu_metamodule (k4_metamodule.rc not in the work dir)"

EVAL "rm -rf \"$PIF_DIR\" && mkdir -p \"$PIF_DIR/seed\""
SET_METADATA "system" "system/etc/k4" 0 0 755 "u:object_r:system_file:s0"
# root only: apps cannot list what is in here
SET_METADATA "system" "system/etc/k4/gmscompat" 0 0 700 "u:object_r:system_file:s0"
SET_METADATA "system" "system/etc/k4/gmscompat/seed" 0 0 700 "u:object_r:system_file:s0"
: > "$PIF_DIR/manifest"
while read -r h id vc; do
    [ "$(sha256sum "$MODPATH/$id.zip" | cut -d " " -f 1)" = "$h" ] || \
        ABORT "pif_stack: $id.zip does not match the pinned sha256 (PROVENANCE.txt)"
    [ "$(unzip -p "$MODPATH/$id.zip" module.prop | sed -n 's/^id=//p' | tr -d '\r')" = "$id" ] || \
        ABORT "pif_stack: $id.zip is not module $id"
    [ "$(unzip -p "$MODPATH/$id.zip" module.prop | sed -n 's/^versionCode=//p' | tr -d '\r')" = "$vc" ] || \
        ABORT "pif_stack: $id.zip is not versionCode $vc"
    EVAL "cp -f \"$MODPATH/$id.zip\" \"$PIF_DIR/$id.zip\""
    SET_METADATA "system" "system/etc/k4/gmscompat/$id.zip" 0 0 600 "u:object_r:system_file:s0"
    echo "$id.zip $h $vc" >> "$PIF_DIR/manifest"
done <<< "$PIF_ZIPS"
SET_METADATA "system" "system/etc/k4/gmscompat/manifest" 0 0 600 "u:object_r:system_file:s0"

for f in teesim_config.json teesim_overrides.json pif.prop; do
    EVAL "cp -f \"$MODPATH/seed/$f\" \"$PIF_DIR/seed/$f\""
    SET_METADATA "system" "system/etc/k4/gmscompat/seed/$f" 0 0 600 "u:object_r:system_file:s0"
done
# seed/keybox.history: sha256 of every keybox a release shipped, so k4-gmscompat may replace an old shipped keybox on
# the phone with this build's (and never the user's). This build's keybox is appended when it is new.
EVAL "cp -f \"$MODPATH/seed/keybox.history\" \"$PIF_DIR/seed/keybox.history\""
if [ -f "$PIF_KEYBOX" ]; then
    grep -q "<AndroidAttestation>" "$PIF_KEYBOX" || ABORT "pif_stack: $PIF_KEYBOX is not a keybox"
    KB_SHA="$(sha256sum "$PIF_KEYBOX" | cut -d " " -f 1)"
    # Expiry gate: the leaf certificate (first <Certificate> of each <CertificateChain>) is what Play Integrity
    # validates; an expired one drops DEVICE/STRONG. The PEM lines are indented in the xml, so strip them first.
    KB_TMP="$(mktemp -d)"
    awk -v dir="$KB_TMP" '
        { sub(/^[[:space:]]+/, "") }
        /<CertificateChain>/ { want = 1; next }
        /-----BEGIN CERTIFICATE-----/ { if (want) { out = sprintf("%s/leaf%d.pem", dir, ++n); inblk = 1 } }
        inblk { print > out }
        /-----END CERTIFICATE-----/ { if (inblk) { close(out); inblk = 0; want = 0 } }
    ' "$PIF_KEYBOX"
    [ "$(ls "$KB_TMP"/leaf*.pem 2> /dev/null | wc -l)" = "$(grep -c "<CertificateChain>" "$PIF_KEYBOX")" ] || \
        ABORT "pif_stack: could not extract one leaf certificate per <CertificateChain> from $PIF_KEYBOX"
    KB_EXPIRY=""
    for f in "$KB_TMP"/leaf*.pem; do
        KB_END="$(openssl x509 -noout -enddate -in "$f")" || ABORT "pif_stack: openssl cannot parse ${f##*/} of $PIF_KEYBOX"
        KB_END="$(date -d "${KB_END#notAfter=}" +%s)" || ABORT "pif_stack: unparsable notAfter in ${f##*/} of $PIF_KEYBOX"
        [ "$KB_EXPIRY" ] && [ "$KB_END" -ge "$KB_EXPIRY" ] || KB_EXPIRY="$KB_END"
    done
    rm -rf "$KB_TMP"
    KB_DAYS=$(( (KB_EXPIRY - $(date +%s)) / 86400 ))
    KB_DATE="$(date -u -d "@$KB_EXPIRY" +%Y-%m-%d)"
    if [ "$KB_EXPIRY" -le "$(date +%s)" ]; then
        ABORT "pif_stack: keybox $(echo "$KB_SHA" | cut -c 1-8) EXPIRED on $KB_DATE: renew $PIF_KEYBOX (or point K4_PIF_KEYBOX at a valid one)"
    elif [ "$KB_DAYS" -lt 30 ]; then
        LOGW "  WARNING: keybox $(echo "$KB_SHA" | cut -c 1-8) expires in $KB_DAYS days ($KB_DATE)"
    else
        LOG "  (keybox $(echo "$KB_SHA" | cut -c 1-8) valid until $KB_DATE, $KB_DAYS days)"
    fi
    EVAL "cp -f \"$PIF_KEYBOX\" \"$PIF_DIR/seed/keybox.xml\""
    SET_METADATA "system" "system/etc/k4/gmscompat/seed/keybox.xml" 0 0 600 "u:object_r:system_file:s0"
    # seed/keybox.expiry: the earliest leaf notAfter as epoch seconds, for k4-gmscompat (no openssl on the phone) to
    # stop installing/keeping a shipped keybox once it has expired
    echo "$KB_EXPIRY" > "$PIF_DIR/seed/keybox.expiry"
    SET_METADATA "system" "system/etc/k4/gmscompat/seed/keybox.expiry" 0 0 600 "u:object_r:system_file:s0"
    grep -q -x "$KB_SHA" "$PIF_DIR/seed/keybox.history" || echo "$KB_SHA" >> "$PIF_DIR/seed/keybox.history"
    grep -q -x "$KB_SHA" "$MODPATH/seed/keybox.history" || \
        LOG "  (new keybox $(echo "$KB_SHA" | cut -c 1-8): add its sha256 to patches/pif_stack/seed/keybox.history and commit)"
    LOG "- Play Integrity stack: keybox $(echo "$KB_SHA" | cut -c 1-8) shipped"
    unset KB_SHA KB_TMP KB_END KB_EXPIRY KB_DAYS KB_DATE
else
    LOG "- Play Integrity stack: no keybox at $PIF_KEYBOX, shipping none (STRONG needs the user's own)"
fi
SET_METADATA "system" "system/etc/k4/gmscompat/seed/keybox.history" 0 0 600 "u:object_r:system_file:s0"

EVAL "cp -f \"$MODPATH/k4-gmscompat\" \"$WORK_DIR/system/system/bin/k4-gmscompat\""
SET_METADATA "system" "system/bin/k4-gmscompat" 0 2000 755 "u:object_r:system_file:s0"

cat > "$WORK_DIR/system/system/etc/init/k4_gmscompat.rc" << 'EOF'
# Play Integrity module stack by default (target/a52sxq/patches/pif_stack). k4_metamod (k4_metamodule.rc) only
# runs once its gate found KernelSU, so u:r:ksu:s0 exists when this starts; starting after it also means this
# boot's metamodule install is complete.
on property:init.svc.k4_metamod=stopped
    start k4_gmscompat

# the Settings "Play Integrity Fix" switch
on property:persist.sys.unica.pif=* && property:init.svc.k4_metamod=stopped
    start k4_gmscompat

# the Settings "Key attestation spoof" switch and its keybox import/clear (persist.sys.unica.keybox_import is bumped by
# Settings after every import or clear): the keybox goes to TEESimulator, see k4-gmscompat sync_keybox
on property:persist.sys.unica.keybox=* && property:init.svc.k4_metamod=stopped
    start k4_gmscompat
on property:persist.sys.unica.keybox_import=* && property:init.svc.k4_metamod=stopped
    start k4_gmscompat

service k4_gmscompat /system/bin/timeout 180 /system/bin/sh /system/bin/k4-gmscompat apply
    user root
    group root
    seclabel u:r:ksu:s0
    oneshot
    disabled
EOF
SET_METADATA "system" "system/etc/init/k4_gmscompat.rc" 0 0 644 "u:object_r:system_file:s0"

# result property: the status type of ksu_metamodule (set by the ksu domain, readable from adb shell)
PLAT_PC="$WORK_DIR/system/system/etc/selinux/plat_property_contexts"
grep -q "k4_metamod_status_prop" "$PLAT_PC" || ABORT "pif_stack: k4_metamod_status_prop not in plat_property_contexts"
for k in sys.k4.gmscompat sys.k4.keybox; do
    if ! grep -q "^${k//./\\.} " "$PLAT_PC"; then
        [ -z "$(tail -c 1 "$PLAT_PC")" ] || echo >> "$PLAT_PC"
        printf '%-28s u:object_r:k4_metamod_status_prop:s0\n' "$k" >> "$PLAT_PC"
    fi
done

LOG "- Play Integrity stack (Zygisk Next 864, TEESimulator 73, PIF 490) in /system/etc/k4/gmscompat, installed by k4-gmscompat"
unset PIF_ZIPS PIF_KEYBOX PIF_DIR PLAT_PC h id vc f
