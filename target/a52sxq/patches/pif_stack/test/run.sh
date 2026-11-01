#!/usr/bin/env bash
# Host test of k4-gmscompat (the Play Integrity module stack boot hook): every scenario runs the real script against
# a fake root (K4GC_ROOT: /data/adb), properties in a file (K4GC_PROPFILE), the real shipped zips with a manifest
# like the build writes, and a fake ksud: `module install` stages the zip in modules_update/<id> (FAKE_KSUD_FAIL=1:
# fails), `module enable|disable` removes/creates modules/<id>/disable. Nothing here is shipped.
# Usage: run.sh [-v]   (-v: print the script's log of every run). K4GC_TEST_SH=<shell> runs it with another shell
# (the phone runs /system/bin/sh = mksh).
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="$HERE/../k4-gmscompat"
SH="${K4GC_TEST_SH:-bash}"
VERBOSE=false
[ "${1:-}" = -v ] && VERBOSE=true
T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT
PASS=0
FAIL=0

ok() { PASS=$((PASS + 1)); }
bad() { FAIL=$((FAIL + 1)); echo "FAIL [$CASE]: $*"; }
eq() { [ "$2" = "$3" ] && ok || bad "$1: expected '$3', got '$2'"; }
yes_() { [ -e "$2" ] && ok || bad "$1: $2 missing"; }
no_() { [ -e "$2" ] && bad "$1: $2 exists" || ok; }
prop() { awk -v k="$1" 'index($0, k "=") == 1 { v = substr($0, length(k) + 2) } END { print v }' "$T/props"; }
calls() { grep -c "${1:-.}" "$T/ksud.calls" || true; }

# shipped files, as customize.sh lays them out
mkdir -p "$T/src/seed"
: > "$T/src/manifest"
for id in zygisksu teesim playintegrityfix; do
    cp "$HERE/../$id.zip" "$T/src/$id.zip"
    echo "$id.zip $(sha256sum "$T/src/$id.zip" | cut -d ' ' -f 1) $(unzip -p "$T/src/$id.zip" module.prop | sed -n 's/^versionCode=//p' | tr -d '\r')" >> "$T/src/manifest"
done
cp "$HERE/../seed/"* "$T/src/seed/"
echo "<AndroidAttestation>test</AndroidAttestation>" > "$T/src/seed/keybox.xml"
echo "# shipped keyboxes" > "$T/src/seed/keybox.history"
echo "<AndroidAttestation>old-shipped</AndroidAttestation>" > "$T/kb_old.xml"
sha256sum "$T/kb_old.xml" | cut -d ' ' -f 1 >> "$T/src/seed/keybox.history"
sha256sum "$T/src/seed/keybox.xml" | cut -d ' ' -f 1 >> "$T/src/seed/keybox.history"
kbsha() { sha256sum "$1" | cut -d ' ' -f 1; }

cat > "$T/ksud" << 'EOF'
#!/usr/bin/env bash
echo "$*" >> "$KT/ksud.calls"
ADB="$K4GC_ROOT/data/adb"
case "$1 $2" in
    "module install")
        [ -n "${FAKE_KSUD_FAIL:-}" ] && exit 1
        id="$(unzip -p "$3" module.prop | sed -n 's/^id=//p' | tr -d '\r')"
        if [ "$id" = playintegrityfix ]; then
            # PIF's customize.sh: find /data/adb/modules /data/adb/modules_update -name libzygisk.so
            [ -n "$(find "$ADB/modules" "$ADB/modules_update" -name libzygisk.so)" ] || { echo "! Zygisk is not enabled"; exit 1; }
        fi
        mkdir -p "$ADB/modules_update/$id" && unzip -p "$3" module.prop > "$ADB/modules_update/$id/module.prop"
        # Zygisk Next ships lib/<abi>/libzygisk.so, installed as lib64/
        [ "$id" = zygisksu ] && mkdir -p "$ADB/modules_update/$id/lib64" && : > "$ADB/modules_update/$id/lib64/libzygisk.so"
        exit 0 ;;
    "module disable") [ -d "$ADB/modules/$3" ] && : > "$ADB/modules/$3/disable" ;;
    "module enable") [ -d "$ADB/modules/$3" ] && rm -f "$ADB/modules/$3/disable" ;;
    *) exit 2 ;;
esac
EOF
chmod +x "$T/ksud"

ADB="$T/root/data/adb"
fresh() {
    CASE="$1"
    rm -rf "$T/root" "$T/props" "$T/kmsg" "$T/secure_keybox"
    : > "$T/ksud.calls"
    mkdir -p "$ADB/modules" "$ADB/modules_update"
    : > "$T/props"
}
# fake `settings`: `settings --user 0 get secure unica_keybox_data` prints $T/secure_keybox (or "null")
cat > "$T/settings" << 'EOF'
#!/usr/bin/env bash
[ "$*" = "--user 0 get secure unica_keybox_data" ] || exit 2
[ -s "$KT/secure_keybox" ] && cat "$KT/secure_keybox" || echo null
EOF
chmod +x "$T/settings"
run() {
    KT="$T" K4GC_ROOT="$T/root" K4GC_PROPFILE="$T/props" K4GC_KSUD="${KSUD_BIN:-$T/ksud}" K4GC_SRC="$T/src" \
        K4GC_KMSG="$T/kmsg" K4GC_NOMAGISK=1 K4GC_SETTINGS="$T/settings" "$SH" "$SCRIPT" apply
    $VERBOSE && { echo "--- $CASE"; cat "$ADB/.k4_gmscompat.log"; }
}
# what ksud's next post-fs-data does: staged modules replace the installed ones
reboot_() {
    for u in "$ADB"/modules_update/*; do
        [ -d "$u" ] || continue
        rm -rf "$ADB/modules/${u##*/}" && mv "$u" "$ADB/modules/"
    done
    for m in "$ADB"/modules/*; do [ -e "$m/remove" ] && rm -rf "$m"; done
    : > "$T/ksud.calls"
}
mod() { mkdir -p "$ADB/modules/$1" && printf 'id=%s\nversionCode=%s\n' "$1" "$2" > "$ADB/modules/$1/module.prop"; }

fresh "fresh install, switch unset"
run
for id in zygisksu teesim playintegrityfix; do yes_ "$id staged" "$ADB/modules_update/$id/module.prop"; done
eq "status" "$(prop sys.k4.gmscompat)" "on zygisksu:installed teesim:installed playintegrityfix:installed"
eq "install order" "$(grep -o 'install [^ ]*' "$T/ksud.calls" | tr '\n' ' ')" \
    "install $T/src/zygisksu.zip install $T/src/teesim.zip install $T/src/playintegrityfix.zip "
cmp -s "$ADB/teesim/config.json" "$T/src/seed/teesim_config.json" && ok || bad "teesim config not seeded"
cmp -s "$ADB/teesim/overrides.json" "$T/src/seed/teesim_overrides.json" && ok || bad "overrides not seeded"
cmp -s "$ADB/teesim/keybox.xml" "$T/src/seed/keybox.xml" && ok || bad "keybox not seeded"
eq "keybox mode" "$(stat -c %a "$ADB/teesim/keybox.xml")" 600
cmp -s "$ADB/pif.prop" "$T/src/seed/pif.prop" && ok || bad "pif.prop not seeded"
eq "state dir mode" "$(stat -c %a "$ADB/.k4_gmscompat")" 700
reboot_
run
eq "second boot: nothing installed" "$(calls install)" 0
eq "second boot status" "$(prop sys.k4.gmscompat)" "on zygisksu:ours teesim:ours playintegrityfix:ours"

fresh "existing configs and keybox are never touched"
mkdir -p "$ADB/teesim"
echo mine > "$ADB/teesim/keybox.xml"; echo mine > "$ADB/teesim/config.json"; echo mine > "$ADB/pif.prop"
run
eq "keybox" "$(cat "$ADB/teesim/keybox.xml")" mine
eq "keybox status" "$(prop sys.k4.keybox)" user
eq "config" "$(cat "$ADB/teesim/config.json")" mine
eq "pif.prop" "$(cat "$ADB/pif.prop")" mine
yes_ "overrides seeded (none existed)" "$ADB/teesim/overrides.json"

fresh "no keybox shipped: none seeded"
mv "$T/src/seed/keybox.xml" "$T/kb.xml"
run
no_ "keybox" "$ADB/teesim/keybox.xml"
eq "keybox status" "$(prop sys.k4.keybox)" none
mv "$T/kb.xml" "$T/src/seed/keybox.xml"

fresh "fresh install seeds the keybox and remembers it as ours"
run
eq "keybox status" "$(prop sys.k4.keybox)" shipped
eq "remembered" "$(cat "$ADB/.k4_gmscompat/keybox.ours")" "$(kbsha "$T/src/seed/keybox.xml")"
eq "teesim dir mode" "$(stat -c %a "$ADB/teesim")" 700

fresh "an older shipped keybox (history) is replaced by the new shipped one"
mkdir -p "$ADB/teesim"; cp "$T/kb_old.xml" "$ADB/teesim/keybox.xml"
run
cmp -s "$ADB/teesim/keybox.xml" "$T/src/seed/keybox.xml" && ok || bad "old shipped keybox not renewed"
eq "keybox status" "$(prop sys.k4.keybox)" shipped

fresh "a foreign keybox stays"
mkdir -p "$ADB/teesim"; echo "<AndroidAttestation>foreign</AndroidAttestation>" > "$ADB/teesim/keybox.xml"
run
eq "foreign keybox untouched" "$(cat "$ADB/teesim/keybox.xml")" "<AndroidAttestation>foreign</AndroidAttestation>"
eq "keybox status" "$(prop sys.k4.keybox)" user

fresh "Settings import: switch on -> imported keybox is teesim's, switch off -> shipped again"
run; reboot_
echo "<AndroidAttestation>imported</AndroidAttestation>" > "$T/secure_keybox"
run
cmp -s "$ADB/teesim/keybox.xml" "$T/src/seed/keybox.xml" && ok || bad "import applied while the switch is off"
echo "persist.sys.unica.keybox=true" >> "$T/props"
run
eq "imported" "$(cat "$ADB/teesim/keybox.xml")" "<AndroidAttestation>imported</AndroidAttestation>"
eq "keybox mode" "$(stat -c %a "$ADB/teesim/keybox.xml")" 600
eq "keybox status" "$(prop sys.k4.keybox)" imported
no_ "no temp left" "$ADB/.k4_gmscompat/keybox.import"
run
eq "idempotent" "$(prop sys.k4.keybox)" imported
echo "<AndroidAttestation>imported2</AndroidAttestation>" > "$T/secure_keybox"
run
eq "re-import replaces" "$(cat "$ADB/teesim/keybox.xml")" "<AndroidAttestation>imported2</AndroidAttestation>"
echo "persist.sys.unica.keybox=false" >> "$T/props"
run
cmp -s "$ADB/teesim/keybox.xml" "$T/src/seed/keybox.xml" && ok || bad "switch off did not restore the shipped keybox"
eq "keybox status" "$(prop sys.k4.keybox)" shipped
echo "persist.sys.unica.keybox=true" >> "$T/props"
: > "$T/secure_keybox"
run
eq "switch on without an import keeps the shipped one" "$(prop sys.k4.keybox)" shipped
echo "garbage" > "$T/secure_keybox"
run
eq "non-keybox setting ignored" "$(prop sys.k4.keybox)" shipped

fresh "Settings import never overwrites a foreign keybox"
mkdir -p "$ADB/teesim"; echo "<AndroidAttestation>foreign</AndroidAttestation>" > "$ADB/teesim/keybox.xml"
echo "persist.sys.unica.keybox=true" >> "$T/props"
echo "<AndroidAttestation>imported</AndroidAttestation>" > "$T/secure_keybox"
run
eq "foreign keybox untouched" "$(cat "$ADB/teesim/keybox.xml")" "<AndroidAttestation>foreign</AndroidAttestation>"
eq "keybox status" "$(prop sys.k4.keybox)" user

fresh "import with no shipped keybox"
mv "$T/src/seed/keybox.xml" "$T/kb.xml"
echo "persist.sys.unica.keybox=true" >> "$T/props"
echo "<AndroidAttestation>imported</AndroidAttestation>" > "$T/secure_keybox"
run
eq "imported" "$(prop sys.k4.keybox)" imported
echo "persist.sys.unica.keybox=false" >> "$T/props"
run
eq "switch off, nothing shipped: ours stays, reported shipped" "$(prop sys.k4.keybox)" shipped
mv "$T/kb.xml" "$T/src/seed/keybox.xml"

fresh "user's own modules (any version) are left alone"
mod zygisksu 800; mod teesim 76; mod playintegrityfix 480
run
eq "no ksud calls" "$(calls)" 0
eq "status" "$(prop sys.k4.gmscompat)" "on zygisksu:user teesim:user playintegrityfix:user"

fresh "another Zygisk (ReZygisk), TrickyStore: those parts skipped"
mod rezygisk 100; mkdir -p "$ADB/modules/rezygisk/lib64"; : > "$ADB/modules/rezygisk/lib64/libzygisk.so"
mod tricky_store 200
run
eq "status" "$(prop sys.k4.gmscompat)" "on zygisksu:other teesim:other playintegrityfix:installed"
no_ "no ZN" "$ADB/modules_update/zygisksu"

fresh "a disabled other Zygisk does not count"
mod rezygisk 100; mkdir -p "$ADB/modules/rezygisk/lib64"; : > "$ADB/modules/rezygisk/lib64/libzygisk.so"
: > "$ADB/modules/rezygisk/disable"
run
yes_ "ZN installed" "$ADB/modules_update/zygisksu"

fresh "switch off disables the stack (also the user's), on enables what it disabled"
mod zygisksu 864; mod teesim 73; mod playintegrityfix 490; mod other 1
echo "persist.sys.unica.pif=true" >> "$T/props"
run
echo "persist.sys.unica.pif=false" >> "$T/props"
run
for id in zygisksu teesim playintegrityfix; do yes_ "$id disabled" "$ADB/modules/$id/disable"; done
no_ "other module untouched" "$ADB/modules/other/disable"
eq "status off" "$(prop sys.k4.gmscompat)" "off zygisksu:disabled teesim:disabled playintegrityfix:disabled"
run
eq "off again: no more calls" "$(calls disable)" 3
echo "persist.sys.unica.pif=true" >> "$T/props"
run
for id in zygisksu teesim playintegrityfix; do no_ "$id enabled" "$ADB/modules/$id/disable"; done

fresh "switch on does not enable what the user disabled"
mod teesim 73; : > "$ADB/modules/teesim/disable"
mod zygisksu 864; mod playintegrityfix 490
run
yes_ "still disabled" "$ADB/modules/teesim/disable"

fresh "legacy persist.sys.unica.pif=false is reset once"
echo "persist.sys.unica.pif=false" >> "$T/props"
run
eq "reset" "$(prop persist.sys.unica.pif)" true
yes_ "installed" "$ADB/modules_update/teesim"
reboot_
echo "persist.sys.unica.pif=false" >> "$T/props"
run
eq "after the first run false means off" "$(prop persist.sys.unica.pif)" false
yes_ "disabled" "$ADB/modules/teesim/disable"

fresh "a module the user removed is not installed again, until the switch goes off and on"
run; reboot_
: > "$ADB/modules/teesim/remove"
reboot_
run
eq "status" "$(prop sys.k4.gmscompat)" "on zygisksu:ours teesim:removed playintegrityfix:ours"
eq "no install" "$(calls install)" 0
run
eq "still removed" "$(calls install)" 0
echo "persist.sys.unica.pif=false" >> "$T/props"; run
echo "persist.sys.unica.pif=true" >> "$T/props"; run
yes_ "re-armed and installed" "$ADB/modules_update/teesim"

fresh "our older module is updated, the user's older one is not"
run; reboot_
sed -i 's/^versionCode=.*/versionCode=70/' "$ADB/modules/teesim/module.prop"
sed -i 's/^versionCode=.*/versionCode=480/' "$ADB/modules/playintegrityfix/module.prop"
rm -f "$ADB/.k4_gmscompat/playintegrityfix.ours"
run
yes_ "teesim update staged" "$ADB/modules_update/teesim"
no_ "user's PIF not updated" "$ADB/modules_update/playintegrityfix"

fresh "pending metamodule: nothing done, nothing counted"
mkdir -p "$ADB/modules_update/meta-overlayfs"; printf 'id=meta-overlayfs\nmetamodule=1\n' > "$ADB/modules_update/meta-overlayfs/module.prop"
run
eq "status" "$(prop sys.k4.gmscompat)" wait-meta
eq "no calls" "$(calls)" 0

fresh "failed installs: 3 tries, then left alone until re-armed"
for i in 1 2 3 4; do FAKE_KSUD_FAIL=1 run; done
eq "3 tries per module" "$(calls 'install.*teesim')" 3
eq "status" "$(prop sys.k4.gmscompat)" "on zygisksu:failed teesim:failed playintegrityfix:failed"

fresh "tampered zip is not installed"
cp "$T/src/teesim.zip" "$T/teesim.bak"; echo x >> "$T/src/teesim.zip"
run
no_ "teesim" "$ADB/modules_update/teesim"
cp "$T/teesim.bak" "$T/src/teesim.zip"

fresh "no KernelSU"
KSUD_BIN="$ADB/ksud" run
eq "status" "$(prop sys.k4.gmscompat)" none
no_ "state" "$ADB/.k4_gmscompat"

echo "k4-gmscompat host test ($SH): $PASS passed, $FAIL failed"
[ "$FAIL" = 0 ]
