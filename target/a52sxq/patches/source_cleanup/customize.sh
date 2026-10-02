for f in bin/qccsyshal@1.2-service etc/init/vendor.qti.hardware.qccsyshal@1.2-service.rc lib64/vendor.qti.hardware.qccsyshal@1.2-halimpl.so; do
    [ -e "$WORK_DIR/system/system/system_ext/$f" ] && DELETE_FROM_WORK_DIR "system" "system/system_ext/$f"
done
SET_PROP "product" "traced.relay_producer_port" --delete
