DECODE_APK "system" "system/priv-app/SecSetupWizard_Global/SecSetupWizard_Global.apk"

_SETUPWIZARD_APK_DIR="$APKTOOL_DIR/system/priv-app/SecSetupWizard_Global/SecSetupWizard_Global.apk"
_SETUPWIZARD_ACTIVITY_SMALI="$_SETUPWIZARD_APK_DIR/smali/com/sec/android/app/SecSetupWizard/SecSetupWizardActivity.smali"

# The step list builder lives in an R8-obfuscated class (e7/f on One UI 9): locate it by
# its stable shape instead, i.e. a static (Context;Z)ArrayList method listing the
# "disclaimer" and "omc_agent_setup" steps.
_SETUPWIZARD_LIST_SMALI=""
while IFS= read -r f; do
    if grep -q '^\.method public static [A-Za-z0-9_$]*(Landroid/content/Context;Z)Ljava/util/ArrayList;$' "$f" && \
            grep -q 'const-string v[0-9]*, "omc_agent_setup"' "$f"; then
        [ "$_SETUPWIZARD_LIST_SMALI" ] && { ABORT "Multiple SecSetupWizard step list candidates found"; return 1; }
        _SETUPWIZARD_LIST_SMALI="$f"
    fi
done < <(grep -rl --include="*.smali" 'const-string v[0-9]*, "disclaimer"' "$_SETUPWIZARD_APK_DIR"/smali*)
[ "$_SETUPWIZARD_LIST_SMALI" ] || { ABORT "SecSetupWizard step list smali not found"; return 1; }
_SETUPWIZARD_LIST_METHOD="$(grep -o '^\.method public static [A-Za-z0-9_$]*(Landroid/content/Context;Z)Ljava/util/ArrayList;$' "$_SETUPWIZARD_LIST_SMALI" | awk '{print $NF}' | head -n 1)"
_SETUPWIZARD_LIST_REL="${_SETUPWIZARD_LIST_SMALI//$_SETUPWIZARD_APK_DIR\//}"

LOG "- Enabling navigation bar type settings step"
if grep -q "navigationbar_setting" "$_SETUPWIZARD_LIST_SMALI"; then
    SMALI_PATCH "system" "system/priv-app/SecSetupWizard_Global/SecSetupWizard_Global.apk" \
        "$_SETUPWIZARD_LIST_REL" "replace" \
        "$_SETUPWIZARD_LIST_METHOD" \
        "navigationbar_setting" \
        "this_string_does_not_exist" \
        > /dev/null
fi
# The activity's step-skip check is an obfuscated (String)Z method: pick the one holding the string
_SETUPWIZARD_ACTIVITY_METHOD="$(awk '
    /^\.method/ { m = $NF }
    /^\.end method/ { m = "" }
    m ~ /^[A-Za-z0-9_$]+\(Ljava\/lang\/String;\)Z$/ && /"navigationbar_setting"/ { print m; exit }
' "$_SETUPWIZARD_ACTIVITY_SMALI")"
if [ "$_SETUPWIZARD_ACTIVITY_METHOD" ]; then
    SMALI_PATCH "system" "system/priv-app/SecSetupWizard_Global/SecSetupWizard_Global.apk" \
        "smali/com/sec/android/app/SecSetupWizard/SecSetupWizardActivity.smali" "replace" \
        "$_SETUPWIZARD_ACTIVITY_METHOD" \
        "navigationbar_setting" \
        "this_string_does_not_exist" \
        > /dev/null
fi

LOG "- Disabling Recommended apps step"
EVAL "sed -i \"/omcagent/d\" \"$APKTOOL_DIR/system/priv-app/SecSetupWizard_Global/SecSetupWizard_Global.apk/res/values/arrays.xml\""

# Dynamically patch SecSetupWizard_Global
# - Add missing/non-xml files in place
# - Patch existing files
#   - Use the first line of the file to tell sed how to apply the rest of the content
#   - Exception made for files under *res/values* where the "resources" tag gets nuked
while IFS= read -r f; do
    f="${f//$MODPATH\/SecSetupWizard_Global.apk\//}"

    if [ ! -f "$APKTOOL_DIR/system/priv-app/SecSetupWizard_Global/SecSetupWizard_Global.apk/$f" ] || \
            [[ "$f" != *".xml" ]]; then
        LOG "- Adding \"$f\" to /system/system/priv-app/SecSetupWizard_Global.apk"
        EVAL "mkdir -p \"$(dirname "$APKTOOL_DIR/system/priv-app/SecSetupWizard_Global/SecSetupWizard_Global.apk/$f")\""
        EVAL "cp -a \"$MODPATH/SecSetupWizard_Global.apk/${f//\$/\\$}\" \"$APKTOOL_DIR/system/priv-app/SecSetupWizard_Global/SecSetupWizard_Global.apk/${f//\$/\\$}\""
    else
        LOG "- Patching \"$f\" in /system/system/priv-app/SecSetupWizard_Global.apk"
        if [[ "$f" == *"res/values"* ]]; then
            PATCH_INST="/<\/resources>/i"
            while IFS= read -r RESOURCE_NAME; do
                EVAL "sed -i \"/name=\\\"$RESOURCE_NAME\\\"/d\" \"$APKTOOL_DIR/system/priv-app/SecSetupWizard_Global/SecSetupWizard_Global.apk/$f\""
            done < <(sed -n 's/.*name="\([^"]*\)".*/\1/p' "$MODPATH/SecSetupWizard_Global.apk/$f")
            CONTENT="$(sed -e "/?xml/d" -e "/resources>/d" "$MODPATH/SecSetupWizard_Global.apk/$f")"
        else
            PATCH_INST="$(head -n 1 "$MODPATH/SecSetupWizard_Global.apk/$f")"
            CONTENT="$(tail -n +2 "$MODPATH/SecSetupWizard_Global.apk/$f")"
        fi
        CONTENT="$(sed -e "s/\"/\\\\\"/g" -e "s/\\\\\\\\\"/\\\\\\\\\\\\\\\\\\\\\"/g" -e "s/\\$/\\\\$/g" -e "s/ /\\\ /g" -e "s/\\\\n/\\\\\\\\\n/g" <<< "$CONTENT")"
        CONTENT="$(sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' <<< "$CONTENT")"
        EVAL "sed -i \"$PATCH_INST $CONTENT\" \"$APKTOOL_DIR/system/priv-app/SecSetupWizard_Global/SecSetupWizard_Global.apk/$f\""
    fi
done < <(find "$MODPATH/SecSetupWizard_Global.apk" -type f)

_SETUPWIZARD_PUBLIC_ID()
{
    local TYPE="$1"
    local NAME="$2"
    local PUBLIC_XML="$APKTOOL_DIR/system/priv-app/SecSetupWizard_Global/SecSetupWizard_Global.apk/res/values/public.xml"
    local ID
    local LAST
    local NEXT

    ID="$(sed -n "s/.*<public type=\"$TYPE\" name=\"$NAME\" id=\"\\(0x[0-9a-fA-F]*\\)\".*/\\1/p" "$PUBLIC_XML" | head -n 1)"
    if [ "$ID" ]; then
        echo "$ID"
        return 0
    fi

    LAST="$(sed -n "s/.*<public type=\"$TYPE\" .* id=\"0x\\([0-9a-fA-F]*\\)\".*/\\1/p" "$PUBLIC_XML" | tail -n 1)"
    [ "$LAST" ] || return 1

    NEXT="$(printf "0x%08x" "$((16#$LAST + 1))")"
    sed -i "/<\/resources>/i\\    <public type=\"$TYPE\" name=\"$NAME\" id=\"$NEXT\" />" "$PUBLIC_XML"
    echo "$NEXT"
}

_SETUPWIZARD_ICON_ID="$(_SETUPWIZARD_PUBLIC_ID "drawable" "suw_ic_unica")" || return 1
_SETUPWIZARD_TEXT_ID="$(_SETUPWIZARD_PUBLIC_ID "string" "disclaimer_unica_description")" || return 1

LOG "- Patching custom disclaimer page in /system/system/priv-app/SecSetupWizard_Global.apk"
# Force the disclaimer step: the last gate before the "disclaimer" step is appended to the
# list is an "if-lez vN, :skip" falling through to "<label>: ArrayList->add". Replace it
# with a jump to that label (registers/labels are build specific, e.g. v9/:cond_46/:cond_19).
if ! grep -q "UN1CA force disclaimer step" "$_SETUPWIZARD_LIST_SMALI"; then
    python3 - "$_SETUPWIZARD_LIST_SMALI" <<'PYEOF' || { LOG "\033[0;31m! ERROR: custom disclaimer sequence patch failed\033[0m"; return 1; }
import re, sys
path = sys.argv[1]
src = open(path).read()
anchor = re.search(r'\n    const-string v\d+, "disclaimer"\n', src)
if not anchor:
    sys.exit(1)
gate = re.compile(r'\n    if-lez v\d+, :cond_\w+\n\n    (:cond_\w+)\n    invoke-virtual \{v\d+, v\d+\}, Ljava/util/ArrayList;->add\(Ljava/lang/Object;\)Z\n')
m = gate.search(src, anchor.end())
nxt = re.search(r'\n    const-string v\d+, "[a-z_]+"\n\n    invoke-virtual \{v\d+, v\d+\}, Ljava/lang/String;->equals', src[anchor.end():])
if not m or (nxt and anchor.end() + nxt.start() < m.start()):
    sys.exit(1)
repl = "\n    # UN1CA force disclaimer step\n    goto %s\n\n    %s\n    invoke-virtual" % (m.group(1), m.group(1))
body = m.group(0)
new = repl + body[body.index("\n    invoke-virtual") + len("\n    invoke-virtual"):]
open(path, "w").write(src[:m.start()] + new + src[m.end():])
PYEOF
fi

_SETUPWIZARD_DISCLAIMER_SMALI="$_SETUPWIZARD_APK_DIR/smali/com/sec/android/app/SecSetupWizard/UI/DisclaimerActivity.smali"
# DisclaimerActivity extends an obfuscated base activity (l7/a on One UI 9). Resolve it from
# ".super" and find its header icon setter: the (Drawable)V method calling GlifLayout.setIcon().
_SETUPWIZARD_BASE="$(grep -m 1 '^\.super ' "$_SETUPWIZARD_DISCLAIMER_SMALI" | awk '{print $2}')"
_SETUPWIZARD_BASE_SMALI="$(find "$_SETUPWIZARD_APK_DIR"/smali* -path "*/${_SETUPWIZARD_BASE:1:-1}.smali" | head -n 1)"
_SETUPWIZARD_ICON_SETTER="$(awk '
    /^\.method/ { m = $NF }
    /^\.end method/ { m = "" }
    m ~ /^[A-Za-z0-9_$]+\(Landroid\/graphics\/drawable\/Drawable;\)V$/ && /GlifLayout;->setIcon\(Landroid\/graphics\/drawable\/Drawable;\)V/ { print m; exit }
' "$_SETUPWIZARD_BASE_SMALI" 2> /dev/null)"
if [ ! "$_SETUPWIZARD_BASE" ] || [ ! "$_SETUPWIZARD_ICON_SETTER" ]; then
    LOG "\033[0;31m! ERROR: DisclaimerActivity base class/icon setter not found\033[0m"
    return 1
fi
if ! grep -q "UN1CA custom disclaimer" "$_SETUPWIZARD_DISCLAIMER_SMALI"; then
    awk -v ICON_ID="$_SETUPWIZARD_ICON_ID" -v TEXT_ID="$_SETUPWIZARD_TEXT_ID" \
        -v BASE="$_SETUPWIZARD_BASE" -v ICON_SETTER="$_SETUPWIZARD_ICON_SETTER" '
        BEGIN { icon_done = 0; text_done = 0 }
        {
            print

            if (!icon_done && index($0, "invoke-virtual {p0, p1}, " BASE "->setContentView(I)V")) {
                print ""
                print "    # UN1CA custom disclaimer icon"
                print "    invoke-virtual {p0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;"
                print ""
                print "    move-result-object p1"
                print ""
                print "    const v1, " ICON_ID
                print ""
                print "    invoke-virtual {p0}, Landroid/content/Context;->getTheme()Landroid/content/res/Resources$Theme;"
                print ""
                print "    move-result-object v2"
                print ""
                print "    invoke-virtual {p1, v1, v2}, Landroid/content/res/Resources;->getDrawable(ILandroid/content/res/Resources$Theme;)Landroid/graphics/drawable/Drawable;"
                print ""
                print "    move-result-object p1"
                print ""
                print "    invoke-virtual {p0, p1}, " BASE "->" ICON_SETTER
                icon_done = 1
            }

            if (!text_done && index($0, "check-cast p1, Landroid/widget/TextView;")) {
                print ""
                print "    # UN1CA custom disclaimer"
                print "    const v0, " TEXT_ID
                print ""
                print "    invoke-virtual {p0, v0}, Landroid/content/Context;->getString(I)Ljava/lang/String;"
                print ""
                print "    move-result-object p0"
                print ""
                print "    invoke-virtual {p1, p0}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V"
                print ""
                print "    return-void"
                text_done = 1
            }
        }
        END { if (!icon_done || !text_done) exit 1 }
    ' "$_SETUPWIZARD_DISCLAIMER_SMALI" > "$_SETUPWIZARD_DISCLAIMER_SMALI.tmp" && \
        mv "$_SETUPWIZARD_DISCLAIMER_SMALI.tmp" "$_SETUPWIZARD_DISCLAIMER_SMALI"
    [ $? -ne 0 ] && { LOG "\033[0;31m! ERROR: custom disclaimer patch failed\033[0m"; return 1; }
fi

unset PATCH_INST CONTENT _SETUPWIZARD_APK_DIR _SETUPWIZARD_ACTIVITY_SMALI _SETUPWIZARD_LIST_SMALI _SETUPWIZARD_LIST_METHOD _SETUPWIZARD_LIST_REL _SETUPWIZARD_ACTIVITY_METHOD _SETUPWIZARD_DISCLAIMER_SMALI _SETUPWIZARD_BASE _SETUPWIZARD_BASE_SMALI _SETUPWIZARD_ICON_SETTER _SETUPWIZARD_ICON_ID _SETUPWIZARD_TEXT_ID
unset -f _SETUPWIZARD_PUBLIC_ID
