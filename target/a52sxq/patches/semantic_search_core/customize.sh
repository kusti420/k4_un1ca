# Samsung Semantic Search Core (see module.prop). A base that already carries it as a system app keeps its own copy.
if [ -d "$WORK_DIR/system/system/priv-app/SemanticSearchCore" ] || [ -d "$WORK_DIR/system/system/app/SemanticSearchCore" ]; then
    LOG "- SemanticSearchCore is already part of this base, skipping"
else
    ADD_TO_WORK_DIR "pa2qxxx" "system" \
        "system/priv-app/SemanticSearchCore/SemanticSearchCore.apk" 0 0 644 "u:object_r:system_file:s0"
fi
