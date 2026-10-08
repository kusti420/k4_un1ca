if [ -f "$SRC_DIR/target/$TARGET_CODENAME/post_mods.sh" ]; then
    LOG_STEP_IN "- Applying target post-mods overrides"
    source "$SRC_DIR/target/$TARGET_CODENAME/post_mods.sh"
    LOG_STEP_OUT
fi
