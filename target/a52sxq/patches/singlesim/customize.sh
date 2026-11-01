# Set default SIM count to 1
# Before: [mov w0, #0x2]
# After: [mov w0, #0x1]
# A528BXXU5FWK4: one aligned match (0x64e8); 19 other `mov w0, #0x1` already exist, so the match must be unique
HEX_PATCH_ONCE "$WORK_DIR/vendor/bin/secril_config_svc" "40008052" "20008052" || \
    ABORT "singlesim: secril_config_svc SIM count patch (mov w0, #0x2 -> #0x1) did not apply"
