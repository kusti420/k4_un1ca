# See module.prop. Device Care (com.samsung.android.lool) builds every sleeping-app Add list in jc/e.c(II).
DEVICECARE="system/priv-app/SmartManager_v5/SmartManager_v5.apk"
DECODE_APK "system" "$DEVICECARE" || ABORT "Failed to decode $DEVICECARE"
LOG "- Listing every restrictable app in the sleeping-app Add lists"
DST="$APKTOOL_DIR/system/${DEVICECARE//system\//}/smali/com/k4/devicecare"
mkdir -p "$DST"
cp -f "$SRC_DIR/target/a52sxq/patches/devicecare_sleep_lists/smali/com/k4/devicecare/K4RestrictList.smali" "$DST/"
SMALI_PATCH "system" "$DEVICECARE" \
    "smali/jc/e.smali" "replace" \
    'c(II)Ljava/util/ArrayList;' \
    'invoke-virtual {v2, p1, v5, v7}, Lcom/samsung/android/sdhms/SemAppRestrictionManager;->canRestrict(ILjava/lang/String;I)Z' \
    'invoke-static {v2, p1, v5, v7}, Lcom/k4/devicecare/K4RestrictList;->canList(Lcom/samsung/android/sdhms/SemAppRestrictionManager;ILjava/lang/String;I)Z'
unset DEVICECARE DST
