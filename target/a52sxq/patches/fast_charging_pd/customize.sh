# See module.prop.
SERVICES="system/framework/services.jar"
DECODE_APK "system" "$SERVICES" || ABORT "Failed to decode $SERVICES"
LOG "- Making the Fast charging switch also control USB PD / PPS (pd_disable)"
DST="$APKTOOL_DIR/system/${SERVICES//system\//}/smali_classes2/com/android/server/battery"
mkdir -p "$DST"
cp -f "$SRC_DIR/target/a52sxq/patches/fast_charging_pd/K4FastChargingPd.smali" "$DST/"
SMALI_PATCH "system" "$SERVICES" \
    "smali/com/android/server/BatteryService.smali" "replace" \
    'setAdaptiveFastCharging(Z)V' \
    'iget-object v0, p0, Lcom/android/server/BatteryService;->mHealthServiceWrapper:Lcom/android/server/health/HealthServiceWrapper;' \
    '    invoke-static {p1}, Lcom/android/server/battery/K4FastChargingPd;->sync(Z)V\n\n    iget-object v0, p0, Lcom/android/server/BatteryService;->mHealthServiceWrapper:Lcom/android/server/health/HealthServiceWrapper;'
unset SERVICES DST
