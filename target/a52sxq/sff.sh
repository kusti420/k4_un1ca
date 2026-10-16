# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# SEC Floating Feature configuration file for Galaxy A52s 5G (a52sxq)

# Enable seamless refresh rate feature
SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_MODE=2

# Enable extra brightness feature
SEC_FLOATING_FEATURE_LCD_SUPPORT_EXTRA_BRIGHTNESS=TRUE

# Desktop windowing / Samsung DeX: back on (9.3.42 test). It was turned off on the Fold8 base (every fullscreen task got an
# app-handle caption window); the S26U base ships it TRUE. Verify on the phone: no handle on fullscreen apps, DeX entry, pop-ups.
SEC_FLOATING_FEATURE_COMMON_SUPPORT_DESKTOP_WINDOWING=TRUE

# Wallpaper AOD ("Show Lock screen wallpaper" on Always On Display), as on the Fold8/S23/S25; no LTPO needed
SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_FULLSCREEN=1
