#!/bin/bash
# Host tests for k4-pif-cleanup: bash test/run.sh
H="$(cd "$(dirname "$0")/.." && pwd)"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
pass=0; failn=0
ok() { pass=$((pass + 1)); }
bad() { failn=$((failn + 1)); echo "FAIL [$CASE] $*"; }
eq() { [ "$2" = "$3" ] && ok || bad "$1: got '$2' want '$3'"; }
has() { [ -e "$2" ] && ok || bad "$1: $2 missing"; }
no_() { [ ! -e "$2" ] && ok || bad "$1: $2 still there"; }
prop() { awk -v k="$1" 'index($0, k "=") == 1 { v = substr($0, length(k) + 2) } END { print v }' "$T/props"; }
ADB="$T/root/data/adb"
cat > "$T/ksud" << 'K'
#!/bin/bash
[ "$1 $2" = "module uninstall" ] || exit 2
[ -n "$KSUD_FAIL" ] && exit 1
[ -d "$K4PC_ROOT/data/adb/modules/$3" ] || exit 1
touch "$K4PC_ROOT/data/adb/modules/$3/remove"
K
cat > "$T/settings" << 'S'
#!/bin/bash
echo "$*" >> "$K4PC_ROOT/settings.log"
S
chmod +x "$T/ksud" "$T/settings"
mod() { mkdir -p "$ADB/modules/$1"; printf 'id=%s\nversionCode=%s\n' "$1" "$2" > "$ADB/modules/$1/module.prop"; [ -z "$3" ] || mkdir -p "$ADB/modules/$1/zygisk"; }
fresh() {
    CASE="$1"; rm -rf "$T/root" "$T/props"; mkdir -p "$ADB/.k4_gmscompat"; : > "$T/props"; touch "$ADB/ksud"; chmod +x "$ADB/ksud"
    echo log > "$ADB/.k4_gmscompat.log"
    mod zygisksu 864; mod teesim 73; mod playintegrityfix 490 z
    echo 864 > "$ADB/.k4_gmscompat/zygisksu.ours"; echo 73 > "$ADB/.k4_gmscompat/teesim.ours"; echo 490 > "$ADB/.k4_gmscompat/playintegrityfix.ours"
    mkdir -p "$ADB/teesim"
    cp "$T/seed_config" "$ADB/teesim/config.json"
    cp "$T/seed_overrides" "$ADB/teesim/overrides.json"; cp "$T/seed_pif" "$ADB/pif.prop"; cp "$T/kb_shipped" "$ADB/teesim/keybox.xml"
}
run() { K4PC_ROOT="$T/root" K4PC_PROPFILE="$T/props" K4PC_KSUD="$T/ksud" K4PC_SETTINGS="$T/settings" K4PC_KMSG="$T/kmsg" sh "$H/k4-pif-cleanup"; }
# the seeds as shipped, from git history: 48488c07 is 9.3.97, the last release with pif_stack
for p in "pif.prop seed_pif" "teesim_config.json seed_config" "teesim_overrides.json seed_overrides"; do
    set -- $p; git -C "$H" show "48488c07:target/a52sxq/patches/pif_stack/seed/$1" > "$T/$2" || { echo "cannot get seed $1"; exit 1; }
done
# a stand-in "shipped keybox" with the shipped hash cannot be made; patch the script copy's hash list instead
printf '<AndroidAttestation>shipped</AndroidAttestation>\n' > "$T/kb_shipped"
KBSHA="$(sha256sum "$T/kb_shipped" | cut -d ' ' -f 1)"
sed "s/^SHA_SHIPPED_KEYBOXES=\"/SHA_SHIPPED_KEYBOXES=\"$KBSHA /" "$H/k4-pif-cleanup" > "$T/k4-pif-cleanup"; H2="$H"; H="$T"
# the seed hashes in the script must match the real seeds
for v in "SHA_PIF_PROP seed_pif" "SHA_TEESIM_CONFIG seed_config" "SHA_TEESIM_OVERRIDES seed_overrides"; do
    set -- $v; CASE=hashes; eq "$1" "$(sed -n "s/^$1=//p" "$H2/k4-pif-cleanup")" "$(sha256sum "$T/$2" | cut -d ' ' -f 1)"
done

# ksud removes modules marked "remove" at the next boot
reboot_() { for m in "$ADB"/modules/*; do [ -e "$m/remove" ] && rm -rf "$m"; done; }

fresh "no old stack: nothing happens"
rm -rf "$ADB/.k4_gmscompat"; run
eq status "$(prop sys.k4.pifcleanup)" none; has "teesim kept" "$ADB/modules/teesim/module.prop"; no_ "no remove" "$ADB/modules/teesim/remove"
no_ "settings untouched" "$T/root/settings.log"

fresh "boot 1 uninstalls and clears settings, files wait for boot 2 (modules still running)"
mkdir -p "$T/root/data/system/users/0" "$T/root/data/system/users/10"; run
for m in zygisksu teesim playintegrityfix; do has "$m marked" "$ADB/modules/$m/remove"; done
eq status "$(prop sys.k4.pifcleanup)" "pending:teesim,playintegrityfix,zygisksu"
for f in pif.prop teesim/config.json teesim/keybox.xml .k4_gmscompat; do has "$f still there" "$ADB/$f"; done
eq settings "$(cat "$T/root/settings.log")" "$(printf -- '--user 0 delete secure unica_keybox_data\n--user 10 delete secure unica_keybox_data')"
eq "pif prop cleared" "$(prop persist.sys.unica.pif)" ""; grep -q '^persist.sys.unica.keybox_import=$' "$T/props" && ok || bad "keybox_import not cleared"
CASE="boot 1 again (system_server restart re-run): still pending, nothing deleted"; run
eq status "$(prop sys.k4.pifcleanup)" "pending: teesim still installed, next boot"; has "config still there" "$ADB/teesim/config.json"
CASE="boot 2: modules gone -> files removed, state gone"; reboot_; run
for f in pif.prop teesim/config.json teesim/overrides.json teesim/keybox.xml .k4_gmscompat .k4_gmscompat.log teesim; do no_ "$f" "$ADB/$f"; done
eq status "$(prop sys.k4.pifcleanup)" "done:teesim,playintegrityfix,zygisksu"
CASE="boot 3: nothing left to do"; rm -f "$T/root/settings.log"; run; eq status "$(prop sys.k4.pifcleanup)" none; no_ "no settings call" "$T/root/settings.log"

fresh "teesim runtime files go with our teesim (boot 2), the user's keybox stays"
echo '{"rewritten":1}' > "$ADB/teesim/config.json"; echo x > "$ADB/teesim/harvest.json"; echo x > "$ADB/teesim/.state"
echo "<AndroidAttestation>mine</AndroidAttestation>" > "$ADB/teesim/keybox.xml"; run
has "harvest still there on boot 1" "$ADB/teesim/harvest.json"
reboot_; run
eq "only the user's keybox left" "$(ls -A "$ADB/teesim")" keybox.xml

fresh "user's own teesim: its runtime files stay"
mod teesim 80; echo x > "$ADB/teesim/harvest.json"; run; reboot_; run
has "harvest kept" "$ADB/teesim/harvest.json"; has "config kept" "$ADB/teesim/config.json"

fresh "LSPosed keeps zygisksu"
mod zygisk_lsposed 7000 z; run
no_ "zygisksu kept" "$ADB/modules/zygisksu/remove"; has "teesim removed" "$ADB/modules/teesim/remove"; has "pif removed" "$ADB/modules/playintegrityfix/remove"
reboot_; run; eq status "$(prop sys.k4.pifcleanup)" "done:teesim,playintegrityfix"; has "zygisksu still installed" "$ADB/modules/zygisksu/module.prop"

fresh "a disabled zygisk module does not keep zygisksu"
mod zygisk_lsposed 7000 z; touch "$ADB/modules/zygisk_lsposed/disable"; run
has "zygisksu removed" "$ADB/modules/zygisksu/remove"

fresh "user-updated modules stay, with their configs (done in one boot: nothing to wait for)"
mod teesim 80; mod playintegrityfix 500 z; run
no_ "teesim kept" "$ADB/modules/teesim/remove"; no_ "pif kept" "$ADB/modules/playintegrityfix/remove"
no_ "zygisksu kept (user PIF uses zygisk)" "$ADB/modules/zygisksu/remove"
has "teesim config kept" "$ADB/teesim/config.json"; has "keybox kept" "$ADB/teesim/keybox.xml"; has "pif.prop kept" "$ADB/pif.prop"
eq status "$(prop sys.k4.pifcleanup)" "done"

fresh "user update staged in modules_update: kept"
mkdir -p "$ADB/modules_update/teesim"; printf 'versionCode=80\n' > "$ADB/modules_update/teesim/module.prop"; run
no_ "teesim kept" "$ADB/modules/teesim/remove"; has "staged update kept" "$ADB/modules_update/teesim/module.prop"

fresh "edited configs and a foreign/imported keybox stay"
echo "edited" >> "$ADB/pif.prop"; echo "<AndroidAttestation>mine</AndroidAttestation>" > "$ADB/teesim/keybox.xml"; run; reboot_; run
has "pif.prop kept" "$ADB/pif.prop"; has "own keybox kept" "$ADB/teesim/keybox.xml"; no_ "seeded config gone" "$ADB/teesim/config.json"
has "teesim dir kept" "$ADB/teesim"

fresh "modules the user removed: seeds still cleaned"
rm -rf "$ADB/modules/teesim" "$ADB/modules/playintegrityfix"; run; reboot_; run
no_ "keybox" "$ADB/teesim/keybox.xml"; no_ "pif.prop" "$ADB/pif.prop"; no_ "zygisksu gone" "$ADB/modules/zygisksu"
eq status "$(prop sys.k4.pifcleanup)" "done:zygisksu"

fresh "ksud failure: nothing deleted, state kept for a retry next boot"
export KSUD_FAIL=1; run; unset KSUD_FAIL
eq status "$(prop sys.k4.pifcleanup)" retry; has "state kept" "$ADB/.k4_gmscompat/teesim.ours"; has "config kept" "$ADB/teesim/config.json"
CASE="retry succeeds over two boots"; run; reboot_; run; eq status "$(prop sys.k4.pifcleanup)" "done:teesim,playintegrityfix,zygisksu"; no_ "state gone" "$ADB/.k4_gmscompat"

fresh "no ksud"
rm -f "$ADB/ksud"; K4PC_ROOT="$T/root" K4PC_PROPFILE="$T/props" K4PC_KSUD="$ADB/ksud" K4PC_SETTINGS="$T/settings" K4PC_KMSG="$T/kmsg" sh "$H/k4-pif-cleanup"
eq status "$(prop sys.k4.pifcleanup)" noksud; has "state kept" "$ADB/.k4_gmscompat"

echo "pass=$pass fail=$failn"
[ "$failn" = 0 ]
