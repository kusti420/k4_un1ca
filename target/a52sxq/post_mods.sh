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
# Time/weather AI wallpaper (SpriteWallpaper "magician", any value but V1/None): generated through SamsungAiCore's
# LVM (LVMInterface.RunWallpaperMix* on QNN HTP V81), on-device only. "None" is the __floating_feature fallback.
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GENAI_SUPPORT_TIME_WEATHER_WALLPAPER" "None"

# Game Booster: the ROM reports itself as SM-S948B, so server-side game policies (resolution/fps/perf targets per
# model) would be the S26 Ultra's for a far weaker SoC. Stock A52s has no policy queries and no default game frame
# rate (games start at 60); the __floating_feature fallback derives 120 from the panel's default refresh rate.
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GRAPHICS_SUPPORT_GAME_SERVER_POLICY_QUERIES" --delete
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GRAPHICS_CONFIG_GAME_DEFAULT_FRAMERATE" "60"
