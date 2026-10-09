# Remove the legacy WSM userspace stack. It cannot provide a valid trust
# result on an unlocked device and only adds another failing HAL path.
DELETE_FROM_WORK_DIR "system" "system/etc/public.libraries-wsm.samsung.txt"
DELETE_FROM_WORK_DIR "system" "system/lib/libhal.wsm.samsung.so"
DELETE_FROM_WORK_DIR "system" "system/lib/vendor.samsung.hardware.security.wsm.service-V1-ndk.so"
DELETE_FROM_WORK_DIR "system" "system/lib64/libhal.wsm.samsung.so"
DELETE_FROM_WORK_DIR "system" "system/lib64/vendor.samsung.hardware.security.wsm.service-V1-ndk.so"

# Install the static KnoxPatch dispatcher into framework.jar. The dispatcher
# scopes app-facing spoofing to the same packages as upstream KnoxPatch.
DECODE_APK "system" "system/framework/framework.jar"
mkdir -p "$APKTOOL_DIR/system/framework/framework.jar/smali_classes6/io/mesalabs/unica"
cp -f "$MODPATH/framework.jar/KnoxPatchHooks.smali" \
    "$APKTOOL_DIR/system/framework/framework.jar/smali_classes6/io/mesalabs/unica/KnoxPatchHooks.smali"

# Initialise package-scoped behavior when an application is created.
SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali/android/app/Instrumentation.smali" "replace" \
    'newApplication(Ljava/lang/Class;Landroid/content/Context;)Landroid/app/Application;' \
    'return-object p0' \
    '    invoke-static {p1}, Lio/mesalabs/unica/KnoxPatchHooks;->init(Landroid/content/Context;)V\n\n    return-object p0'
SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali/android/app/Instrumentation.smali" "replace" \
    'newApplication(Ljava/lang/ClassLoader;Ljava/lang/String;Landroid/content/Context;)Landroid/app/Application;' \
    'return-object p0' \
    '    invoke-static {p3}, Lio/mesalabs/unica/KnoxPatchHooks;->init(Landroid/content/Context;)V\n\n    return-object p0'

# Intercept both SystemProperties overloads. SemSystemProperties delegates to
# these methods on One UI 9, so this covers Auto Blocker, Secure Folder,
# Secure Wi-Fi, SmartThings, FMM and the system-server ASKS check.
SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali_classes3/android/os/SystemProperties.smali" "replace" \
    'get(Ljava/lang/String;)Ljava/lang/String;' \
    '.locals 0' '.locals 1'
SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali_classes3/android/os/SystemProperties.smali" "replace" \
    'get(Ljava/lang/String;)Ljava/lang/String;' \
    'invoke-static {p0}, Landroid/os/SystemProperties;->native_get(Ljava/lang/String;)Ljava/lang/String;' \
    '    invoke-static {p0}, Lio/mesalabs/unica/KnoxPatchHooks;->onSystemPropertiesGet(Ljava/lang/String;)Ljava/lang/String;\n\n    move-result-object v0\n\n    if-eqz v0, :unica_knoxpatch_get\n\n    return-object v0\n\n    :unica_knoxpatch_get\n    invoke-static {p0}, Landroid/os/SystemProperties;->native_get(Ljava/lang/String;)Ljava/lang/String;'
SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali_classes3/android/os/SystemProperties.smali" "replace" \
    'get(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;' \
    '.locals 0' '.locals 1'
SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali_classes3/android/os/SystemProperties.smali" "replace" \
    'get(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;' \
    'invoke-static {p0, p1}, Landroid/os/SystemProperties;->native_get(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;' \
    '    invoke-static {p0, p1}, Lio/mesalabs/unica/KnoxPatchHooks;->onSystemPropertiesGet(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;\n\n    move-result-object v0\n\n    if-eqz v0, :unica_knoxpatch_get_default\n\n    return-object v0\n\n    :unica_knoxpatch_get_default\n    invoke-static {p0, p1}, Landroid/os/SystemProperties;->native_get(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;'

# Hide known root managers from the package query used by KnoxPatch's
# supported third-party apps. KernelSU/SUSFS handles filesystem/process
# visibility; this closes the framework PackageManager path.
SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali/android/app/ApplicationPackageManager.smali" "replace" \
    'getPackageInfo(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;' \
    'int-to-long v0, p2' \
    '    invoke-static {p1}, Lio/mesalabs/unica/KnoxPatchHooks;->onPackageNameQuery(Ljava/lang/String;)Ljava/lang/String;\n\n    move-result-object p1\n\n    int-to-long v0, p2'

# Samsung Health expects Knox SDK to report unsupported only in its process.
SMALI_PATCH "system" "system/framework/knoxsdk.jar" \
    "smali/com/samsung/android/knox/EnterpriseDeviceManager.smali" "replace" \
    'getAPILevel()I' \
    'invoke-static {}, Lcom/samsung/android/knox/EdmUtils;->getAPILevelForInternal()I' \
    '    invoke-static {}, Lio/mesalabs/unica/KnoxPatchHooks;->shouldDisableKnoxSdk()Z\n\n    move-result v0\n\n    if-eqz v0, :unica_knoxpatch_edm\n\n    const/4 v0, -0x1\n\n    return v0\n\n    :unica_knoxpatch_edm\n    invoke-static {}, Lcom/samsung/android/knox/EdmUtils;->getAPILevelForInternal()I'

# SAK/ICD: make verifiable integrity available through both copies used by
# One UI 9. The services.jar copy accesses the field directly; the public
# samsungkeystoreutils.jar copy uses the accessor.
SMALI_PATCH "system" "system/framework/samsungkeystoreutils.jar" \
    "smali/com/samsung/android/security/keystore/AttestParameterSpec.smali" "return" \
    'isVerifiableIntegrity()Z' 'true'
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali_classes2/com/samsung/android/security/keystore/AttestationUtils.smali" "replace" \
    'generateKeyPair(Lcom/samsung/android/security/keystore/AttestParameterSpec;)Ljava/security/KeyPair;' \
    'iget-object v0, p1, Lcom/samsung/android/security/keystore/AttestParameterSpec;->mSpec:Landroid/security/keystore/KeyGenParameterSpec;' \
    '    const/4 v0, 0x1\n\n    iput-boolean v0, p1, Lcom/samsung/android/security/keystore/AttestParameterSpec;->mVerifiableIntegrity:Z\n\n    iget-object v0, p1, Lcom/samsung/android/security/keystore/AttestParameterSpec;->mSpec:Landroid/security/keystore/KeyGenParameterSpec;'

# Secure Folder/work-profile trust decisions moved behind DAR binder methods.
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali/com/android/server/knox/dar/DarManagerService.smali" "return" \
    'checkDeviceIntegrity([Ljava/security/cert/Certificate;)Z' 'true'
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali/com/android/server/knox/dar/DarManagerService.smali" "return" \
    'isDeviceRootKeyInstalled()Z' 'true'
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali/com/android/server/knox/dar/DarManagerService.smali" "return" \
    'isKnoxKeyInstallable()Z' 'true'
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali/com/android/server/StorageManagerService.smali" "return" \
    'isRootedDevice()Z' 'false'

# Match the upstream KnoxPatch behavior at the KnoxGuard service constructor
# boundary: throw right after the Binder stub is initialised so SystemServer's
# existing catch path ("Failed to add KnoxGuardService.") skips registration.
# Depending on the source, SystemServer instantiates either KnoxGuard30Service
# (e.g. Fold8 One UI 9) or the legacy KnoxGuardSeService (e.g. S25 One UI 9).
# Only p1 (already consumed) and v0 are used, so .locals stays untouched.
DECODE_APK "system" "system/framework/services.jar"
for KG_CLASS in \
    "com/samsung/android/knoxguard30/service/KnoxGuard30Service" \
    "com/samsung/android/knoxguard/service/KnoxGuardSeService"
do
    KG_SMALI="$(cd "$APKTOOL_DIR/system/framework/services.jar" && \
        find . -path "./smali*/$KG_CLASS.smali" | sed "s|^\./||")"
    [ "$KG_SMALI" ] || continue
    grep -q -F "L$KG_CLASS;-><init>(Landroid/content/Context;)V" \
        "$APKTOOL_DIR/system/framework/services.jar/smali/com/android/server/SystemServer.smali" || continue
    SMALI_PATCH "system" "system/framework/services.jar" \
        "$KG_SMALI" "replace" \
        '<init>(Landroid/content/Context;)V' \
        "sput-object p1, L$KG_CLASS;->mContext:Landroid/content/Context;" \
        '    new-instance v0, Ljava/lang/UnsupportedOperationException;\n\n    const-string p1, "KnoxGuard is unsupported on this port"\n\n    invoke-direct {v0, p1}, Ljava/lang/UnsupportedOperationException;-><init>(Ljava/lang/String;)V\n\n    throw v0'
    KG_PATCHED=true
done
if [ "$KG_PATCHED" != "true" ]; then
    ABORT "No KnoxGuard service constructor instantiated by SystemServer was found"
fi
unset KG_CLASS KG_SMALI KG_PATCHED

# Knox Matrix 3.x verifies parsed attestation objects through FabricCertUtil.
# Patch the decision points as well as the value-object accessors used by its
# other trust-chain implementations. Do not download a moving Galaxy Store
# build during ROM compilation.
if [ -f "$WORK_DIR/system/system/priv-app/KmxService/KmxService.apk" ]; then
    SMALI_PATCH "system" "system/priv-app/KmxService/KmxService.apk" \
        "smali_classes2/com/samsung/android/kmxservice/fabrickeystore/keystore/cert/FabricCertUtil.smali" "return" \
        'checkIntegrityStatus(Lcom/samsung/android/kmxservice/fabrickeystore/keystore/cert/IntegrityStatus;)Z' 'true'
    SMALI_PATCH "system" "system/priv-app/KmxService/KmxService.apk" \
        "smali_classes2/com/samsung/android/kmxservice/fabrickeystore/keystore/cert/FabricCertUtil.smali" "return" \
        'checkRootOfTrust(Lcom/samsung/android/kmxservice/fabrickeystore/keystore/cert/RootOfTrust;)Z' 'true'

    for ROOT_OF_TRUST in \
        "common/util/RootOfTrust" \
        "fabrickeystore/keystore/cert/RootOfTrust" \
        "sdk/trustchain/util/RootOfTrust"
    do
        SMALI_PATCH "system" "system/priv-app/KmxService/KmxService.apk" \
            "smali_classes2/com/samsung/android/kmxservice/$ROOT_OF_TRUST.smali" "return" \
            'getVerifiedBootState()I' '0'
        SMALI_PATCH "system" "system/priv-app/KmxService/KmxService.apk" \
            "smali_classes2/com/samsung/android/kmxservice/$ROOT_OF_TRUST.smali" "return" \
            'isDeviceLocked()Z' 'true'
    done

    SMALI_PATCH "system" "system/priv-app/KmxService/KmxService.apk" \
        "smali_classes2/com/samsung/android/kmxservice/common/util/IntegrityStatus.smali" "return" \
        'getStatus()I' '0'
    SMALI_PATCH "system" "system/priv-app/KmxService/KmxService.apk" \
        "smali_classes2/com/samsung/android/kmxservice/common/util/IntegrityStatus.smali" "return" \
        'isNormal()Z' 'true'
    SMALI_PATCH "system" "system/priv-app/KmxService/KmxService.apk" \
        "smali_classes2/com/samsung/android/kmxservice/fabrickeystore/keystore/cert/IntegrityStatus.smali" "return" \
        'isNormal()Z' 'true'
    SMALI_PATCH "system" "system/priv-app/KmxService/KmxService.apk" \
        "smali_classes2/com/samsung/android/kmxservice/sdk/trustchain/util/IntegrityStatus.smali" "return" \
        'getStatus()I' '0'
    SMALI_PATCH "system" "system/priv-app/KmxService/KmxService.apk" \
        "smali_classes2/com/samsung/android/kmxservice/sdk/trustchain/util/IntegrityStatus.smali" "return" \
        'isNormal()Z' 'true'
fi
