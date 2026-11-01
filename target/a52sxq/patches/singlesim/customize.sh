# Set default SIM count to 1
# A52s 5G note (2026-11-01): the A528B exists as single-SIM and /DS (hybrid tray). This only changes the vendor RIL's
# DEFAULT when the EFS carries no slot configuration: on a /DS unit (owner's R5CTA0ESFTF, 2 slots) the patched build still
# reports ro.vendor.multisim.simslotcount=2 / dsds with two phones, i.e. the EFS wins and slot 2 is intact; a single-SIM
# unit no longer shows a ghost second slot. TARGET_RIL_SIM_CONFIG_MULTISIM_TRAYCOUNT=1 (config.sh) is the number of
# TRAYS, which is 1 on both variants.
# Before: [mov w0, #0x2]
# After: [mov w0, #0x1]
# A528BXXU5FWK4: one aligned match (0x64e8); 19 other `mov w0, #0x1` already exist, so the match must be unique
HEX_PATCH_ONCE "$WORK_DIR/vendor/bin/secril_config_svc" "40008052" "20008052" || \
    ABORT "singlesim: secril_config_svc SIM count patch (mov w0, #0x2 -> #0x1) did not apply"
