# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# SEC Floating Feature configuration file for Galaxy A52s 5G (a52sxq)

# Enable seamless refresh rate feature
SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_MODE=2

# Enable extra brightness feature
SEC_FLOATING_FEATURE_LCD_SUPPORT_EXTRA_BRIGHTNESS=TRUE

# Desktop windowing gives every fullscreen task a caption window on a phone (ShellWindowDecoration churn)
SEC_FLOATING_FEATURE_COMMON_SUPPORT_DESKTOP_WINDOWING=FALSE

# One UI taskbar (Fold/tablet feature). The Fold8 system has it compiled in; this single flag gates the launcher,
# SystemUI navbar and Settings > Display > Taskbar. The A52s panel already reports as the main (large) display.
SEC_FLOATING_FEATURE_LAUNCHER_SUPPORT_TASKBAR=TRUE
