if [ -d "$WORK_DIR/product/overlay/SoftapOverlay" ] && [ -f "$WORK_DIR/vendor/overlay/SoftapOverlay/SoftapOverlay.apk" ]; then
    DELETE_FROM_WORK_DIR "product" "overlay/SoftapOverlay"
fi
