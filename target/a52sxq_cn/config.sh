# Galaxy A52s 5G, de-Googled variant built from the China Fold8 Ultra (SM-F9760 CHC) firmware, which never shipped
# GMS/GSF. Everything else (codename, patches, overlays, profiles) is the a52sxq target's; only the source image
# config differs. Build with `source buildenv.sh a52sxq_cn`.
source "$SRC_DIR/target/a52sxq/config.sh"
TARGET_OS_SINGLE_SYSTEM_IMAGE="qssi_chn"
