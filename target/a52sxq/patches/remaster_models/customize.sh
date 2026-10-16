# See module.prop. Device patches run BEFORE unica/patches, and unica/patches/legacy deletes /vendor/etc/midas and
# installs the portable a73xqxx set (no .dlc), so installing here would be wiped. This step only checks the sources
# (fail early, before the long ROM patch stage); install.sh does the work from target/a52sxq/post_mods.sh, which
# unica/mods/zz_target runs after every unica patch and mod.
#
# Third-party files are NOT in git: they are taken from the extracted firmwares in out/fw.
REMASTER_MODELS_DIR="$SRC_DIR/target/a52sxq/patches/remaster_models"
# shellcheck source=/dev/null
source "$REMASTER_MODELS_DIR/install.sh"

REMASTER_MODELS_CHECK_SOURCES

unset REMASTER_MODELS_DIR
