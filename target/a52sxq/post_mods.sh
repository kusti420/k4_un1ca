# Runs after unica/mods (see unica/mods/zz_target). Undo miracle floating features the A52s can't back.

# Super HDR (Advanced features): the panel has no HDR headroom (HDR video settings are hidden for the same reason)
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_MMFW_SUPPORT_PHOTOHDR" --delete
# TalkBack AI image descriptions run on AICore/Gemini Nano, which has no SM7325 model
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_ACCESSIBILITY_SUPPORT_AI_CORE_IMAGE_DESCRIPTION" --delete
# Game Booster "Touch response speed": secinputdev sends the TSP command set_fast_response, which the A52s stm_ts.ko
# doesn't implement (it has set_game_mode/glove_mode/set_sip_mode only, same module as stock); stock had no such option
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GRAPHICS_SUPPORT_TOUCH_FAST_RESPONSE" --delete
# On-device Gauss LLM ("Samsung Language Core", com.samsung.android.offline.languagemodel): no model ships (unica
# debloats the S26 store stub) and SamsungAiCore's supported_config.json only lists LLM/LVM runtimes for
# sm8850/sm8750/s5e9965/s5e9955 (QNN HTP V79+/ENN). With the keys set Keyboard "Style and grammar" (on-device), Smart
# Suggestions suggested replies and Call Assistant's on-device call summary are offered with no backend, and they send
# the user to the Store for an SM8850 Language Core. Cloud Writing/Chat assist and call summaries don't use these keys.
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GENAI_SUPPORT_OFFLINE_LANGUAGEMODEL" --delete
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GENAI_CONFIG_FOUNDATION_MODEL" --delete
# GENAI_CONFIG_LLM_VERSION (miracle sets 2.81, S26U stock 0.81) is the on-device Gauss generation, read only by
# on-device paths (feature audit 2026-10-16 F1): Launcher Finder "Recall" (decimal >= 70), My Files "Show file
# summaries"/summary notice (dots stripped, > 70, so "2.69" would still be 269: delete, don't lower), Keyboard
# on-device contextual/suggested replies (>= 50 / >= 70), InCallUI live suggestions + TelephonyUI call brief/call
# suggestion (>= 81, also need PERSONALIZED_DATA_CORE), Smart Suggestions suggested replies, Moments AI summary and
# services.jar NmRune AI notification priority/summary/nudge. Every reader treats a missing key as unsupported.
# Keyboard Writing assist (cloud), Interpreter and Finder semantic search (SSCO + SEMANTIC_SEARCH_VERSION) don't read
# it; TelephonyUI's call screening badge helper does (isSupportCallScreeningLlm) but nothing calls it.
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GENAI_CONFIG_LLM_VERSION" --delete
# Time/weather AI wallpaper (SpriteWallpaper "magician", any value but V1/None): generated through SamsungAiCore's
# LVM (LVMInterface.RunWallpaperMix* on QNN HTP V81), on-device only. "None" is the __floating_feature fallback.
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GENAI_SUPPORT_TIME_WEATHER_WALLPAPER" "None"

# Game Booster: the ROM reports itself as SM-S948B, so server-side game policies (resolution/fps/perf targets per
# model) would be the S26 Ultra's for a far weaker SoC. Stock A52s has no policy queries and no default game frame
# rate (games start at 60); the __floating_feature fallback derives 120 from the panel's default refresh rate.
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GRAPHICS_SUPPORT_GAME_SERVER_POLICY_QUERIES" --delete
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GRAPHICS_CONFIG_GAME_DEFAULT_FRAMERATE" "60"

# Game Booster "Pause USB Power Delivery" (pass-through charging): BatteryService writes /sys/class/power_supply/
# battery/pass_through, which only the bone-machine kernel provides (k4 patch 0008 holds the charger in
# CHARGING_OFF while set). The stock A52s kernel has no such node, so only offer it with our kernel.
if [ ! -f "$SRC_DIR/target/a52sxq/patches/kernel_bone_machine/disable" ]; then
    SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_BATTERY_SUPPORT_PASS_THROUGH" "TRUE"
fi
# Glasses (XR projected) support from the S26U Miracle features: no glasses app on this port (feature audit 2026-10-16 F7)
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_COMMON_SUPPORT_WEARABLE_GLASSES" --delete

# Guard: one line per key. SET_FLOATING_FEATURE_CONFIG replaces by line number, so a key that ever ends up twice
# (e.g. EU_BATTERY_REGULATORY, reported twice on the phone) breaks later replaces. Keep the first occurrence.
FF_XML="$WORK_DIR/system/system/etc/floating_feature.xml"
if [ -f "$FF_XML" ]; then
    FF_DUPES="$(grep -o -P '(?<=<)SEC_FLOATING_FEATURE_[A-Z0-9_]+(?=>)' "$FF_XML" | sort | uniq -d | tr '\n' ' ')"
    if [ "$FF_DUPES" ]; then
        LOG "- Removing duplicate floating features: $FF_DUPES"
        awk 'match($0, /<SEC_FLOATING_FEATURE_[A-Z0-9_]+>/) { k = substr($0, RSTART, RLENGTH); if (seen[k]++) next } { print }' \
            "$FF_XML" > "$FF_XML.tmp" && mv -f "$FF_XML.tmp" "$FF_XML"
    fi
    unset FF_DUPES
fi
unset FF_XML

# Gallery Remaster AI HDR models (target/a52sxq/patches/remaster_models): installed here, not from the patch, because
# unica/patches/legacy replaces /vendor/etc/midas after the device patches have run
if [ ! -f "$SRC_DIR/target/a52sxq/patches/remaster_models/disable" ]; then
    # shellcheck source=/dev/null
    source "$SRC_DIR/target/a52sxq/patches/remaster_models/install.sh"
    REMASTER_MODELS_INSTALL
    unset REMASTER_MODELS_LIST
    unset -f REMASTER_MODELS_SRC REMASTER_MODELS_CHECK_SOURCES REMASTER_MODELS_INSTALL
fi

# Home screen depth clock switch (target/a52sxq/patches/home_depth_clock): added here, not from the patch, because
# res/xml/unica_ui_settings.xml only exists once unica/mods/settings has run
if [ ! -f "$SRC_DIR/target/a52sxq/patches/home_depth_clock/disable" ]; then
    # shellcheck source=/dev/null
    source "$SRC_DIR/target/a52sxq/patches/home_depth_clock/settings.sh"
fi
