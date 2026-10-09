# A17 init loads /vendor/build.prop and /vendor/default.prop with an SELinux check in the vendor_init context
# ("SELinux permission check failed (source_context=u:r:vendor_init:s0 ...)" in the kernel log), and the A17 platform
# property_contexts/policy no longer let vendor_init set the labels these A14 vendor props get:
#   persist.vendor.bt.a2dp_offload_cap -> bluetooth_prop   (A2DP offload codec list; without it the Bluetooth stack only
#                                                           offers SBC/aptX/SSC: no AAC, aptX HD, aptX TWS+, LDAC)
#   ro.build.scafe.version, ro.apk_verity.mode, ro.smps.enable, persist.backup.ntpServer -> default_prop
#   persist.vendor.cne.feature -> vendor_cnd_prop
# /system/build.prop is loaded without that check, so non-vendor-prefixed keys are re-declared there. init refuses
# vendor-prefixed keys (persist.vendor.*) from system prop files, so those are set from an init script instead
# (init's own context may set any property).
LOG_STEP_IN "- Re-declaring vendor props that A17 init rejects from /vendor"
RC="$WORK_DIR/system/system/etc/init/a52sxq_vendor_props.rc"
RC_LINES=""
# A2DP offload: ro.bluetooth.a2dp_offload.supported / persist.bluetooth.a2dp_offload.* carry the A17 label
# bluetooth_a2dp_offload_prop, which vendor_init may not set either. Without them the native Bluetooth stack
# runs the software A2DP path ("IsCodecOffloadingEnabled: offload mode - false"), for which the A52s audio
# policy has no output: the policy picks the A2DP device but opens no output (getOutput() ... output 0) and
# Bluetooth headsets stay silent.
for p in persist.vendor.bt.a2dp_offload_cap persist.vendor.cne.feature ro.build.scafe.version ro.apk_verity.mode ro.smps.enable persist.backup.ntpServer \
        ro.bluetooth.a2dp_offload.supported persist.bluetooth.a2dp_offload.disabled persist.bluetooth.a2dp_offload.cap vendor.audio.feature.a2dp_offload.enable; do
    v=""
    for f in "$WORK_DIR/vendor/build.prop" "$WORK_DIR/vendor/default.prop"; do
        [ -f "$f" ] || continue
        v="$(grep -m1 "^$p=" "$f" | cut -d "=" -f 2-)"
        [ "$v" ] && break
    done
    if [ ! "$v" ]; then
        LOG "  - $p not found in the target vendor props, skipping"
    elif [[ "$p" == *.vendor.* ]] || [[ "$p" == vendor.* ]] || [[ "$p" == persist.* ]]; then
        RC_LINES="$RC_LINES    setprop $p $v"$'\n'
        LOG "  - Setting \"$p\" to \"$v\" from a52sxq_vendor_props.rc"
    else
        SET_PROP "system" "$p" "$v"
    fi
done
if [ "$RC_LINES" ]; then
    {
        echo "# Vendor-prefixed and persist props from the A14 /vendor/build.prop that A17 init rejects there (vendor_init may not"
        echo "# set their A17 property labels) or that /system/build.prop cannot carry. See the a52sxq_vendor_props patch."
        echo "on init"
        printf "%s" "$RC_LINES"
        echo "    setprop k4.vendor_props.applied init"
        echo ""
        echo "# persist.* values set before the persistent properties are loaded are not written back; apply again afterwards"
        echo "on property:ro.persistent_properties.ready=true"
        printf "%s" "$RC_LINES"
        echo "    setprop k4.vendor_props.applied persist"
    } > "$RC"
    SET_METADATA "system" "system/etc/init/a52sxq_vendor_props.rc" 0 0 644 "u:object_r:system_file:s0"
fi
unset RC RC_LINES p v f
LOG_STEP_OUT

# S26 Ultra SurfaceFlinger computes the density from ro.sf.init.lcd_density (native-resolution density, used for its
# QHD+/FHD+ switching); unset it fell back to 213 dpi -> tablet UI (smallest width 811dp). The A52s panel is natively
# 1080 wide, so the native density equals ro.sf.lcd_density.
SET_PROP "vendor" "ro.sf.init.lcd_density" "450"
