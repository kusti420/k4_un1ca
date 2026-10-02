SMALI_PATCH "system" "system/framework/services.jar" \
    "smali/com/android/server/NandswapManager.smali" "null" "schedNextLimitReset()V"
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali/com/android/server/NandswapManager.smali" "null" "schedNextUpdateAverage()V"

# Samsung LockSettingsService passes the Gatekeeper auth token (HAT) to vold's unlockCeStorage when
# ro.product.first_api_level <= 30 (legacy auth-bound CE keys). The A52s launched on R, but Fold8's vold rejects
# tokens ("Vold doesn't use auth tokens, but non-empty token passed") -> EINVAL -> user 0 never unlocks after a
# reboot with a PIN ("Phone is starting..."). Take the token-less path regardless of first API level.
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali_classes2/com/android/server/locksettings/LockSettingsService.smali" "replace" \
    'unlockCeStorage(ILcom/android/server/locksettings/SyntheticPasswordManager$SyntheticPassword;)V' \
    'const/16 v4, 0x1e' \
    'const/4 v4, 0x0'
