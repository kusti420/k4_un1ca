# Runs after unica/mods (see unica/mods/zz_target). Undo miracle floating features the A52s can't back.

# Super HDR (Advanced features): the panel has no HDR headroom (HDR video settings are hidden for the same reason)
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_MMFW_SUPPORT_PHOTOHDR" --delete
# TalkBack AI image descriptions run on AICore/Gemini Nano, which has no SM7325 model
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_ACCESSIBILITY_SUPPORT_AI_CORE_IMAGE_DESCRIPTION" --delete
