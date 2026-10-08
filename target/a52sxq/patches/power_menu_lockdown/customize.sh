# One UI 8.5+ SamsungGlobalActionsPresenter.onShowDialog() posts lambda$onShowDialog$3 (500 ms) which calls
# LockPatternUtilsWrapper.lockDownDelayed(0) -> requireStrongAuth(AFTER_USER_LOCKDOWN) + lockNow(): the phone locks
# as soon as the power menu opens, so cancelling it lands on the bouncer and biometrics are refused until the
# PIN/pattern is entered (on secure devices; USB data also drops). The Settings switch "Secure lock with Power button"
# (Settings.Secure lockdown_option_enabled) is only consulted when the menu was opened from the quick panel
# (mSideKeyType == 2); from the side key / key combo the lockdown is unconditional. Drop the side-key-type check so the
# switch governs every entry point - turn it off and the power menu never locks the phone.
DECODE_APK "system" "system/framework/framework.jar"
python3 - "$APKTOOL_DIR/system/framework/framework.jar" << 'PYEOF' || ABORT "Failed to patch the power menu lockdown"
import glob, sys
f = glob.glob(sys.argv[1] + "/smali*/com/samsung/android/globalactions/presentation/SamsungGlobalActionsPresenter.smali")
assert len(f) == 1, "SamsungGlobalActionsPresenter.smali"
s = open(f[0]).read()
start = s.index(".method private synthetic blacklist lambda$onShowDialog$3()V")
end = s.index(".end method", start)
body = s[start:end]
P = "Lcom/samsung/android/globalactions/presentation/SamsungGlobalActionsPresenter;"
old = ("    iget v0, p0, " + P + "->mSideKeyType:I\n\n"
       "    const/4 v1, 0x2\n\n"
       "    if-ne v0, v1, :cond_0\n\n")
assert body.count(old) == 1, "side key type check"
assert "IS_LOCKDOWN_OPTION_ENABLED" in body and "lockDownDelayed" in body, "unexpected lambda body"
s = s[:start] + body.replace(old, "") + s[end:]
open(f[0], "w").write(s)
PYEOF
LOG "- Power menu only locks the phone when \"Secure lock with Power button\" is on"
