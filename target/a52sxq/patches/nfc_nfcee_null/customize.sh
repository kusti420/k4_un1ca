DECODE_APK "system" "system/priv-app/SecNfc/SecNfc.apk"
python3 - "$APKTOOL_DIR" << 'PYEOF' || ABORT "Failed to patch SecNfc getActiveNfceeTech"
import glob, re, sys
f = glob.glob(sys.argv[1] + "/**/SecNfc.apk/smali*/com/samsung/android/nfc/cardemulation/NfcSecureElement.smali", recursive=True)
assert len(f) == 1, "NfcSecureElement.smali"; f = f[0]
s = open(f).read()
start = s.index(".method public getActiveNfceeTech()B")
end = s.index(".end method", start)
body = s[start:end]
m = re.search(r"(    invoke-virtual \{(\w+)\}, Landroid/nfc/NfcOemExtension;->getActiveNfceeList\(\)Ljava/util/Map;\n\n    move-result-object (\w+)\n)", body)
assert m and body.count("getActiveNfceeList") == 1, "getActiveNfceeList call"
assert "k4_nfcee_ok" not in body, "already patched"
reg = m.group(3)
guard = m.group(1) + f"\n    if-nez {reg}, :k4_nfcee_ok\n\n    const/4 {reg}, 0x0\n\n    return {reg}\n\n    :k4_nfcee_ok\n"
s = s[:start] + body.replace(m.group(1), guard) + s[end:]
open(f, "w").write(s)
PYEOF
LOG "- SecNfc: null NFCEE list no longer crashes com.android.nfc"
