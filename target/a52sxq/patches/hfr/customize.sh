# https://android.googlesource.com/platform/frameworks/native/+/refs/tags/android-16.0.0_r2/services/surfaceflinger/Scheduler/RefreshRateSelector.h#314
IDLE_TIMER_MS=250
# https://android.googlesource.com/platform/frameworks/native/+/refs/tags/android-16.0.0_r2/services/surfaceflinger/sysprop/SurfaceFlingerProperties.sysprop#346
TOUCH_TIMER_MS=300

SET_PROP "vendor" "ro.surface_flinger.use_content_detection_for_refresh_rate" "true"
LOG "- Adding \"ro.surface_flinger.set_idle_timer_ms\" prop with \"$IDLE_TIMER_MS\" in /vendor/default.prop"
EVAL "sed -i \"/use_content_detection/a ro.surface_flinger.set_idle_timer_ms=$IDLE_TIMER_MS\" \"$WORK_DIR/vendor/default.prop\""
LOG "- Adding \"ro.surface_flinger.set_touch_timer_ms\" prop with \"$TOUCH_TIMER_MS\" in /vendor/default.prop"
EVAL "sed -i \"/set_idle_timer_ms/a ro.surface_flinger.set_touch_timer_ms=$TOUCH_TIMER_MS\" \"$WORK_DIR/vendor/default.prop\""
LOG "- Replacing \"ro.surface_flinger.enable_frame_rate_override\" prop with \"true\" in /vendor/default.prop"
EVAL "sed -i \"/enable_frame_rate_override/d\" \"$WORK_DIR/vendor/default.prop\""
EVAL "sed -i \"/persist.sys.usb.config/i ro.surface_flinger.enable_frame_rate_override=true\" \"$WORK_DIR/vendor/default.prop\""

# The source SurfaceFlinger's getKernelIdleTimerController() always answers "Sysprop" for the primary display
# (an LTPO panel whose kernel/panel driver drops the refresh rate on idle by itself), so SurfaceFlinger never runs
# its own idle timer and Adaptive mode sits at the maximum rate whenever no layer votes otherwise. The A52s panel
# has no kernel idle timer: turn that `b.ne` into an unconditional branch so the AOSP path (HIDL composer reports
# no kernel idle timer -> SurfaceFlinger's own set_idle_timer_ms timer) is taken. Offset is specific to this
# binary, the byte check aborts on any other build.
SF="$WORK_DIR/system/system/bin/surfaceflinger"
SF_OFF=$((0x546d08))
if [ -f "$SF" ]; then
    if [[ "$(xxd -p -s "$SF_OFF" -l 4 "$SF")" == "10000014" ]]; then
        :
    elif [[ "$(xxd -p -s "$SF_OFF" -l 4 "$SF")" == "01020054" ]]; then
        LOG "- Disabling the kernel idle timer controller in /system/bin/surfaceflinger"
        printf '\x10\x00\x00\x14' | dd of="$SF" bs=1 seek="$SF_OFF" conv=notrunc status=none
    else
        ABORT "surfaceflinger: unexpected bytes at $(printf '0x%x' "$SF_OFF")"
    fi
fi

unset IDLE_TIMER_MS TOUCH_TIMER_MS SF SF_OFF
