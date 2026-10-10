if [ ! "$(GET_PROP "system" "ro.unica.version")" ]; then
    SET_PROP "system" "ro.unica.version" "$ROM_VERSION"
fi

# Show battery regulatory info in Settings
# Requires SEM_BATTERY_PROPERTY_IC_AUTHENTICATION_RESULT support
if [ "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_BATTERY_SUPPORT_BSOH_SETTINGS")" ]; then
    SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_BATTERY_SUPPORT_BSOH_SETTINGS" --delete
fi
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_SETTINGS_ENABLE_EU_BATTERY_REGULATORY" "TRUE"

SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali/android/app/Instrumentation.smali" "replace" \
    'newApplication(Ljava/lang/Class;Landroid/content/Context;)Landroid/app/Application;' \
    'invoke-virtual {p0, p1}, Landroid/app/Application;->attach(Landroid/content/Context;)V' \
    '    invoke-virtual {p0, p1}, Landroid/app/Application;->attach(Landroid/content/Context;)V\n\n    invoke-static {p1}, Lio/mesalabs/unica/SamsungPropsHooks;->init(Landroid/content/Context;)V' \
    > /dev/null
SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali/android/app/Instrumentation.smali" "replace" \
    'newApplication(Ljava/lang/ClassLoader;Ljava/lang/String;Landroid/content/Context;)Landroid/app/Application;' \
    'invoke-virtual {p0, p3}, Landroid/app/Application;->attach(Landroid/content/Context;)V' \
    '    invoke-virtual {p0, p3}, Landroid/app/Application;->attach(Landroid/content/Context;)V\n\n    invoke-static {p3}, Lio/mesalabs/unica/SamsungPropsHooks;->init(Landroid/content/Context;)V' \
    > /dev/null

DECODE_APK "system" "system/priv-app/SecSettings/SecSettings.apk"

# Add backend hooks for Settings toggles that live outside SecSettings.
DECODE_APK "system" "system/framework/framework.jar"
EVAL "mkdir -p \"$APKTOOL_DIR/system/framework/framework.jar/smali_classes6/io/mesalabs/unica\""
EVAL "cp -f \"$MODPATH/framework.jar/FloatingFeatureHooks.smali\" \"$APKTOOL_DIR/system/framework/framework.jar/smali_classes6/io/mesalabs/unica/FloatingFeatureHooks.smali\""

SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali_classes6/com/samsung/android/feature/SemFloatingFeature.smali" "replace" \
    'getBoolean(Ljava/lang/String;)Z' \
    '.locals 1' \
    '.locals 2'
SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali_classes6/com/samsung/android/feature/SemFloatingFeature.smali" "replace" \
    'getBoolean(Ljava/lang/String;)Z' \
    'iget-object p0, p0, Lcom/samsung/android/feature/SemFloatingFeature;->mFeatureList:Ljava/util/Hashtable;' \
    'invoke-static {p1}, Lio/mesalabs/unica/FloatingFeatureHooks;->onGetBoolean(Ljava/lang/String;)Ljava/lang/Boolean;\n\n    move-result-object v1\n\n    if-eqz v1, :unica_ff_bool\n\n    invoke-virtual {v1}, Ljava/lang/Boolean;->booleanValue()Z\n\n    move-result p0\n\n    return p0\n\n    :unica_ff_bool\n    iget-object p0, p0, Lcom/samsung/android/feature/SemFloatingFeature;->mFeatureList:Ljava/util/Hashtable;'
SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali_classes6/com/samsung/android/feature/SemFloatingFeature.smali" "replace" \
    'getInt(Ljava/lang/String;)I' \
    '.locals 1' \
    '.locals 2'
SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali_classes6/com/samsung/android/feature/SemFloatingFeature.smali" "replace" \
    'getInt(Ljava/lang/String;)I' \
    'iget-object p0, p0, Lcom/samsung/android/feature/SemFloatingFeature;->mFeatureList:Ljava/util/Hashtable;' \
    'invoke-static {p1}, Lio/mesalabs/unica/FloatingFeatureHooks;->onGetInt(Ljava/lang/String;)Ljava/lang/Integer;\n\n    move-result-object v1\n\n    if-eqz v1, :unica_ff_int\n\n    invoke-virtual {v1}, Ljava/lang/Integer;->intValue()I\n\n    move-result p0\n\n    return p0\n\n    :unica_ff_int\n    iget-object p0, p0, Lcom/samsung/android/feature/SemFloatingFeature;->mFeatureList:Ljava/util/Hashtable;'
SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali_classes6/com/samsung/android/feature/SemFloatingFeature.smali" "replace" \
    'getString(Ljava/lang/String;)Ljava/lang/String;' \
    '.locals 1' \
    '.locals 2'
SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali_classes6/com/samsung/android/feature/SemFloatingFeature.smali" "replace" \
    'getString(Ljava/lang/String;)Ljava/lang/String;' \
    'iget-object p0, p0, Lcom/samsung/android/feature/SemFloatingFeature;->mFeatureList:Ljava/util/Hashtable;' \
    'invoke-static {p1}, Lio/mesalabs/unica/FloatingFeatureHooks;->onGetString(Ljava/lang/String;)Ljava/lang/String;\n\n    move-result-object v1\n\n    if-eqz v1, :unica_ff_string\n\n    move-object p0, v1\n\n    return-object p0\n\n    :unica_ff_string\n    iget-object p0, p0, Lcom/samsung/android/feature/SemFloatingFeature;->mFeatureList:Ljava/util/Hashtable;'

SMALI_PATCH "system" "system/framework/services.jar" \
    'smali_classes2/com/android/server/wm/WindowManagerService$SettingsObserver.smali' "replace" \
    '<init>(Lcom/android/server/wm/WindowManagerService;)V' \
    'disable_secure_windows' \
    'unica_secure_ss'
SMALI_PATCH "system" "system/framework/services.jar" \
    'smali_classes2/com/android/server/wm/WindowManagerService$SettingsObserver.smali' "replace" \
    '<init>(Lcom/android/server/wm/WindowManagerService;)V' \
    'invoke-static {v9}, Landroid/provider/Settings$Secure;->getUriFor(Ljava/lang/String;)Landroid/net/Uri;' \
    'invoke-static {v9}, Landroid/provider/Settings$System;->getUriFor(Ljava/lang/String;)Landroid/net/Uri;'
SMALI_PATCH "system" "system/framework/services.jar" \
    'smali_classes2/com/android/server/wm/WindowManagerService$SettingsObserver.smali' "replace" \
    'updateDisableSecureWindows()V' \
    'if-nez v0, :cond_0' \
    'goto :cond_0'
SMALI_PATCH "system" "system/framework/services.jar" \
    'smali_classes2/com/android/server/wm/WindowManagerService$SettingsObserver.smali' "replace" \
    'updateDisableSecureWindows()V' \
    'disable_secure_windows' \
    'unica_secure_ss'
SMALI_PATCH "system" "system/framework/services.jar" \
    'smali_classes2/com/android/server/wm/WindowManagerService$SettingsObserver.smali' "replace" \
    'updateDisableSecureWindows()V' \
    'invoke-static {v0, v2, v1}, Landroid/provider/Settings$Secure;->getIntForUser(Landroid/content/ContentResolver;Ljava/lang/String;I)I' \
    'invoke-static {v0, v2, v1}, Landroid/provider/Settings$System;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I'

SMALI_PATCH "system" "system/framework/services.jar" \
    "smali_classes2/com/android/server/wm/ScreenRecordingCallbackController.smali" "replace" \
    'dispatchCallbacks(Landroid/util/ArraySet;Z)V' \
    '.locals 5' \
    '.locals 8'
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali_classes2/com/android/server/wm/ScreenRecordingCallbackController.smali" "replace" \
    'dispatchCallbacks(Landroid/util/ArraySet;Z)V' \
    'invoke-virtual {p1}, Landroid/util/ArraySet;->isEmpty()Z' \
    'iget-object v5, p0, Lcom/android/server/wm/ScreenRecordingCallbackController;->mWms:Lcom/android/server/wm/WindowManagerService;\n\n    iget-object v5, v5, Lcom/android/server/wm/WindowManagerService;->mContext:Landroid/content/Context;\n\n    invoke-virtual {v5}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;\n\n    move-result-object v5\n\n    const-string v6, "unica_ss_detection"\n\n    const/4 v7, 0x0\n\n    invoke-static {v5, v6, v7}, Landroid/provider/Settings$System;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I\n\n    move-result v5\n\n    if-eqz v5, :unica_ss_detection_callbacks\n\n    const/4 p2, 0x0\n\n    :unica_ss_detection_callbacks\n    invoke-virtual {p1}, Landroid/util/ArraySet;->isEmpty()Z'
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali_classes2/com/android/server/wm/WindowManagerService.smali" "replace" \
    'notifyScreenshotListeners(I)Ljava/util/List;' \
    '.locals 4' \
    '.locals 7'
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali_classes2/com/android/server/wm/WindowManagerService.smali" "replace" \
    'notifyScreenshotListeners(I)Ljava/util/List;' \
    'iget-object v0, p0, Lcom/android/server/wm/WindowManagerService;->mGlobalLock:Lcom/android/server/wm/WindowManagerGlobalLock;' \
    'iget-object v4, p0, Lcom/android/server/wm/WindowManagerService;->mContext:Landroid/content/Context;\n\n    invoke-virtual {v4}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;\n\n    move-result-object v4\n\n    const-string v5, "unica_ss_detection"\n\n    const/4 v6, 0x0\n\n    invoke-static {v4, v5, v6}, Landroid/provider/Settings$System;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I\n\n    move-result v4\n\n    if-eqz v4, :unica_ss_detection_notify\n\n    invoke-static {}, Ljava/util/Collections;->emptyList()Ljava/util/List;\n\n    move-result-object p0\n\n    return-object p0\n\n    :unica_ss_detection_notify\n    const/4 v2, 0x1\n\n    iget-object v0, p0, Lcom/android/server/wm/WindowManagerService;->mGlobalLock:Lcom/android/server/wm/WindowManagerGlobalLock;'
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali_classes2/com/android/server/wm/WindowManagerService.smali" "replace" \
    'registerScreenRecordingCallback(Landroid/window/IScreenRecordingCallback;)Z' \
    '.locals 8' \
    '.locals 11'
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali_classes2/com/android/server/wm/WindowManagerService.smali" "replace" \
    'registerScreenRecordingCallback(Landroid/window/IScreenRecordingCallback;)Z' \
    'iget-object p0, p0, Lcom/android/server/wm/WindowManagerService;->mScreenRecordingCallbackController:Lcom/android/server/wm/ScreenRecordingCallbackController;' \
    'iget-object v8, p0, Lcom/android/server/wm/WindowManagerService;->mContext:Landroid/content/Context;\n\n    invoke-virtual {v8}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;\n\n    move-result-object v8\n\n    const-string v9, "unica_ss_detection"\n\n    const/4 v10, 0x0\n\n    invoke-static {v8, v9, v10}, Landroid/provider/Settings$System;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I\n\n    move-result v8\n\n    if-eqz v8, :unica_ss_detection_register\n\n    return v10\n\n    :unica_ss_detection_register\n    iget-object p0, p0, Lcom/android/server/wm/WindowManagerService;->mScreenRecordingCallbackController:Lcom/android/server/wm/ScreenRecordingCallbackController;'

SMALI_PATCH "system" "system/framework/services.jar" \
    "smali_classes2/com/android/server/pm/PackageManagerService.smali" "replace" \
    'verifyReplacingVersionCode(Landroid/content/pm/PackageInfoLite;JI)Landroid/util/Pair;' \
    'invoke-virtual {v2}, Ljava/lang/Object;->getClass()Ljava/lang/Class;' \
    'invoke-virtual {v2}, Ljava/lang/Object;->getClass()Ljava/lang/Class;\n\n    iget-object v12, v2, Lcom/android/server/pm/InstallPackageHelper;->mContext:Landroid/content/Context;\n\n    invoke-virtual {v12}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;\n\n    move-result-object v12\n\n    const-string v13, "unica_allow_downgrade"\n\n    const/4 v14, 0x0\n\n    invoke-static {v12, v13, v14}, Landroid/provider/Settings$System;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I\n\n    move-result v12\n\n    if-eqz v12, :unica_allow_downgrade\n\n    const v12, 0x100080\n\n    or-int/2addr v3, v12\n\n    :unica_allow_downgrade'
# Allow installing apps below MIN_INSTALLABLE_TARGET_SDK unless "unica_allow_sdkbypass" is set to 0 (on by default,
# so users can install old apps out of the box; the UN1CA Settings switch reads the same default).
# Registers/labels differ per source build: anchor on the MIN_INSTALLABLE_TARGET_SDK check,
# append three registers past .locals and resolve the low register holding "this".
INSTALL_HELPER_SMALI="$(cd "$APKTOOL_DIR/system/framework/services.jar" && \
    find . -path "./smali*/com/android/server/pm/InstallPackageHelper.smali" | sed "s|^\./||")"
if [ ! "$INSTALL_HELPER_SMALI" ] || ! python3 - "$APKTOOL_DIR/system/framework/services.jar/$INSTALL_HELPER_SMALI" <<'PYEOF'
import re, sys
path = sys.argv[1]
src = open(path).read()
sig = ".method public final preparePackage(Lcom/android/server/pm/InstallRequest;)V\n"
start = src.find(sig)
end = src.find("\n.end method", start)
if start < 0 or end < 0 or src.count(sig) != 1:
    sys.exit("preparePackage(InstallRequest) not found")
body = src[start:end]
if "unica_allow_sdkbypass" in body:
    sys.exit(0)
locals_m = re.search(r"\n    \.locals (\d+)\n", body)
this_m = re.search(r"\n    move-object(?:/from16)? (v\d+), p0\n", body)
gate = re.compile(
    r"\n    if-nez (v\d+), (:cond_\w+)\n"
    r"(?=\n    invoke-interface \{v\d+\}, Lcom/android/internal/pm/parsing/pkg/ParsedPackage;->getTargetSdkVersion\(\)I\n"
    r"\n    move-result \1\n"
    r"\n    sget v\d+, Lcom/android/server/pm/PackageManagerService;->MIN_INSTALLABLE_TARGET_SDK:I\n)")
hits = gate.findall(body)
if not locals_m or not this_m or len(hits) != 1:
    sys.exit("unexpected preparePackage shape (locals=%s this=%s gates=%d)" % (bool(locals_m), bool(this_m), len(hits)))
n = int(locals_m.group(1))
flag, label = hits[0]
this = this_m.group(1)
if int(flag[1:]) > 15 or int(this[1:]) > 15:
    sys.exit("preparePackage registers out of iget-object range")
r0, r1, r2 = "v%d" % n, "v%d" % (n + 1), "v%d" % (n + 2)
hook = (
    "\n    if-nez %(flag)s, %(label)s\n"
    "\n    iget-object %(flag)s, %(this)s, Lcom/android/server/pm/InstallPackageHelper;->mContext:Landroid/content/Context;\n"
    "\n    invoke-virtual {%(flag)s}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;\n"
    "\n    move-result-object %(r0)s\n"
    "\n    const-string %(r1)s, \"unica_allow_sdkbypass\"\n"
    "\n    const/16 %(r2)s, 0x1\n"
    "\n    invoke-static/range {%(r0)s .. %(r2)s}, Landroid/provider/Settings$System;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I\n"
    "\n    move-result %(r0)s\n"
    "\n    if-nez %(r0)s, %(label)s\n"
) % dict(flag=flag, label=label, this=this, r0=r0, r1=r1, r2=r2)
body = gate.sub(lambda m: hook, body, count=1)
body = body.replace("\n    .locals %d\n" % n, "\n    .locals %d\n" % (n + 3), 1)
open(path, "w").write(src[:start] + body + src[end:])
print("    - Patched SDK bypass in preparePackage (.locals %d -> %d, gate %s/%s)" % (n, n + 3, flag, label))
PYEOF
then
    ABORT "Failed to patch InstallPackageHelper.preparePackage SDK bypass"
fi
unset INSTALL_HELPER_SMALI

ASKS_SMALI="$APKTOOL_DIR/system/framework/services.jar/smali/com/android/server/asks/ASKSManagerService.smali"
ASKS_POLICY_METHOD='getUnknownAppsDataFromXML(ILjava/util/ArrayList;Ljava/util/HashMap;Z)V'
if ! sed -n '/^\.method.*getUnknownAppsDataFromXML(/,/^\.end method/p' "$ASKS_SMALI" | \
        grep -q 'ro.build.official.release'; then
    ASKS_POLICY_METHOD='getPolicyFilePath(IZ)Ljava/lang/String;'
fi
# Some One UI 9 builds (e.g. S25) moved the body of refreshInstalledUnknownList_NEW()
# into a locked refreshInstalledUnknownList_NEWInner() helper
ASKS_REFRESH_METHOD='refreshInstalledUnknownList_NEW()V'
if ! sed -n '/^\.method.* refreshInstalledUnknownList_NEW()V/,/^\.end method/p' "$ASKS_SMALI" | \
        grep -q 'ro.build.official.release'; then
    ASKS_REFRESH_METHOD='refreshInstalledUnknownList_NEWInner()V'
fi

SMALI_PATCH "system" "system/framework/services.jar" \
    "smali/com/android/server/asks/ASKSManagerService.smali" "replace" \
    "$ASKS_POLICY_METHOD" \
    'ro.build.official.release' \
    'persist.sys.unica.asks'
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali/com/android/server/asks/ASKSManagerService.smali" "replace" \
    "$ASKS_POLICY_METHOD" \
    'false' \
    'true'
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali/com/android/server/asks/ASKSManagerService.smali" "replace" \
    "$ASKS_REFRESH_METHOD" \
    'ro.build.official.release' \
    'persist.sys.unica.asks'
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali/com/android/server/asks/ASKSManagerService.smali" "replace" \
    "$ASKS_REFRESH_METHOD" \
    'false' \
    'true'
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali/com/android/server/asks/ASKSManagerService.smali" "replace" \
    'verifyASKStokenForPackage(Ljava/lang/String;Ljava/lang/String;J[Landroid/content/pm/Signature;Ljava/lang/String;Ljava/lang/String;Z)I' \
    'ro.build.official.release' \
    'persist.sys.unica.asks'
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali/com/android/server/asks/ASKSManagerService.smali" "replace" \
    'verifyASKStokenForPackage(Ljava/lang/String;Ljava/lang/String;J[Landroid/content/pm/Signature;Ljava/lang/String;Ljava/lang/String;Z)I' \
    'invoke-static {v6}, Landroid/os/SystemProperties;->get(Ljava/lang/String;)Ljava/lang/String;' \
    'const-string/jumbo v10, "true"\n\n    invoke-static {v6, v10}, Landroid/os/SystemProperties;->get(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;'
unset ASKS_SMALI ASKS_POLICY_METHOD ASKS_REFRESH_METHOD

LOG_STEP_IN "- Adding UN1CA Settings"

# Dynamically patch SecSettings
# - Add missing/non-xml files in place
# - Patch existing files
#   - Use the first line of the file to tell sed how to apply the rest of the content
#   - Exception made for files under *res/values* where the "resources" tag gets nuked
while IFS= read -r f; do
    f="${f//$MODPATH\/SecSettings.apk\//}"

    if [ ! -f "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/$f" ] || \
            [[ "$f" != *".xml" ]]; then
        LOG "- Adding \"$f\" to /system/system/priv-app/SecSettings.apk"
        EVAL "mkdir -p \"$(dirname "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/$f")\""
        EVAL "cp -a \"$MODPATH/SecSettings.apk/${f//\$/\\$}\" \"$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/${f//\$/\\$}\""
    else
        LOG "- Patching \"$f\" in /system/system/priv-app/SecSettings.apk"
        if [[ "$f" == *"res/values"* ]]; then
            PATCH_INST="/<\/resources>/i"
            CONTENT="$(sed -e "/?xml/d" -e "/resources>/d" "$MODPATH/SecSettings.apk/$f")"
        else
            PATCH_INST="$(head -n 1 "$MODPATH/SecSettings.apk/$f")"
            CONTENT="$(tail -n +2 "$MODPATH/SecSettings.apk/$f")"
        fi
        CONTENT="$(sed -e "s/\"/\\\\\"/g" -e "s/\\$/\\\\$/g" -e "s/ /\\\ /g" -e "s/\\\\n/\\\\\\\\\n/g" <<< "$CONTENT")"
        CONTENT="$(sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' <<< "$CONTENT")"
        EVAL "sed -i \"$PATCH_INST $CONTENT\" \"$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/$f\""
    fi
done < <(find "$MODPATH/SecSettings.apk" -type f)

# The SecDisplayUtils refresh-rate helpers take a Context on some One UI 9 builds (Fold8)
# but not on others (S25): match the ForceMaxRefreshRate controller calls to the source.
SEC_DISPLAY_UTILS="$(cd "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk" && \
    find . -path "./smali*/com/samsung/android/settings/display/SecDisplayUtils.smali" | sed "s|^\./||")"
FORCE_MAX_RR="$(cd "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk" && \
    find . -path "./smali*/io/mesalabs/unica/settings/ui/ForceMaxRefreshRatePreferenceController.smali" | sed "s|^\./||")"
if [ "$SEC_DISPLAY_UTILS" ] && [ "$FORCE_MAX_RR" ]; then
    SEC_DISPLAY_UTILS="$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/$SEC_DISPLAY_UTILS"
    FORCE_MAX_RR="$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/$FORCE_MAX_RR"
    if ! grep -q "^\.method.* getHighRefreshRateSeamlessType(Landroid/content/Context;I)I" "$SEC_DISPLAY_UTILS" && \
            grep -q "^\.method.* getHighRefreshRateSeamlessType(I)I" "$SEC_DISPLAY_UTILS"; then
        LOG "- Using getHighRefreshRateSeamlessType(I)I in ForceMaxRefreshRatePreferenceController"
        EVAL "sed -i 's|invoke-static {p2, p1}, Lcom/samsung/android/settings/display/SecDisplayUtils;->getHighRefreshRateSeamlessType(Landroid/content/Context;I)I|invoke-static {p1}, Lcom/samsung/android/settings/display/SecDisplayUtils;->getHighRefreshRateSeamlessType(I)I|' \"$FORCE_MAX_RR\""
    fi
    if ! grep -q "^\.method.* getHighRefreshRateMaxValue(Landroid/content/Context;)I" "$SEC_DISPLAY_UTILS" && \
            grep -q "^\.method.* getHighRefreshRateMaxValue()I" "$SEC_DISPLAY_UTILS"; then
        LOG "- Using getHighRefreshRateMaxValue()I in ForceMaxRefreshRatePreferenceController"
        EVAL "sed -i 's|invoke-static {p2}, Lcom/samsung/android/settings/display/SecDisplayUtils;->getHighRefreshRateMaxValue(Landroid/content/Context;)I|invoke-static {}, Lcom/samsung/android/settings/display/SecDisplayUtils;->getHighRefreshRateMaxValue()I|' \"$FORCE_MAX_RR\""
    fi
    for SDU_CALL in $(grep -o "SecDisplayUtils;->[A-Za-z0-9_]*([^)]*)[^ ]*" "$FORCE_MAX_RR" | sed "s/SecDisplayUtils;->//" | sort -u); do
        grep -q -F -- " $SDU_CALL" <(grep "^\.method" "$SEC_DISPLAY_UTILS") || \
            ABORT "SecDisplayUtils;->$SDU_CALL used by ForceMaxRefreshRatePreferenceController is missing in the source SecSettings"
    done
fi
unset SEC_DISPLAY_UTILS FORCE_MAX_RR SDU_CALL

# Add UN1CA Settings SearchIndexableData registrations
LOG "- Patching \"smali_classes2/com/android/settings/search/SearchFeatureProviderImpl\$\$ExternalSyntheticLambda0.smali\" in /system/system/priv-app/SecSettings.apk"
SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "smali_classes2/com/android/settings/search/SearchFeatureProviderImpl\$\$ExternalSyntheticLambda0.smali" "replace" \
    'invoke()Ljava/lang/Object;' \
    'return-object p0' \
    '    invoke-static {p0}, Lio/mesalabs/unica/search/UnicaSearchIndexableResources;->register(Lcom/android/settingslib/search/SearchIndexableResourcesBase;)V\n\n    return-object p0' \
    > /dev/null

DECODE_APK "system" "system/priv-app/SecSettingsIntelligence/SecSettingsIntelligence.apk"
LOG "- Patching \"smali_classes2/com/samsung/android/settings/intelligence/search/categorizing/TopLevelKeysCollector.smali\" in /system/system/priv-app/SecSettingsIntelligence/SecSettingsIntelligence.apk"
SMALI_PATCH "system" "system/priv-app/SecSettingsIntelligence/SecSettingsIntelligence.apk" \
    "smali_classes2/com/samsung/android/settings/intelligence/search/categorizing/TopLevelKeysCollector.smali" "replace" \
    '<init>(Landroid/content/Context;)V' \
    '.locals 37' \
    '.locals 38' \
    > /dev/null
SMALI_PATCH "system" "system/priv-app/SecSettingsIntelligence/SecSettingsIntelligence.apk" \
    "smali_classes2/com/samsung/android/settings/intelligence/search/categorizing/TopLevelKeysCollector.smali" "replace" \
    '<init>(Landroid/content/Context;)V' \
    'filled-new-array/range {v1 .. v36}, [Ljava/lang/String;' \
    '    const-string v37, "top_level_unica"\n\n    filled-new-array/range {v1 .. v37}, [Ljava/lang/String;' \
    > /dev/null

# Show Vulkan renderer toggle if required
if [[ "$(GET_PROP "vendor" "ro.hwui.use_vulkan")" != "true" ]]; then
    SET_PROP "system" "persist.sys.unica.vulkan" "false"
fi

unset PATCH_INST CONTENT

LOG_STEP_OUT
