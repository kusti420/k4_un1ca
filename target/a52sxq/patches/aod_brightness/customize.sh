# Automatic AOD brightness with wallpaper AOD (sff.sh LCD_CONFIG_AOD_FULLSCREEN=1).
#
# AODService (S26 Ultra) has two brightness modes, chosen by BrightnessManager.isPlatformBrightness() (obfuscated i()):
#   g6.p && bj1.S(), where g6.p = ha6.K0 = (LCD_CONFIG_AOD_FULLSCREEN > 0) and bj1.S() = (AOD_FULLSCREEN == 1).
# - fullscreen "platform brightness" mode (true since wallpaper AOD was enabled): the sensor hub is registered with
#   CarryingDetectionAttribute(9, low, high) ("registerInner isHysteresis: true") and reports lux; updateLux() turns lux
#   into nits with a Spline over config_autoBrightnessLevels_doze / config_autoBrightnessDisplayValuesNits_doze, then
#   DisplayManager.convertToBrightness(nits) -> platform brightness, min()'d with the lock screen brightness, and sends
#   onUpdateDozeBrightness(mode, -1, brightness) to SystemUI. Those two arrays are empty in framework-res and only the
#   S26 Ultra's product overlay fills them, so here the spline is null, every lux gives 0 nits -> brightness 0 ->
#   AODScreenBrightness float 0.0 -> the panel's HLPM 2 nit level in any light ("mCurrentPlatformBrightness : 0").
# - index mode (stock A52s, AOD_FULLSCREEN=0): the hub is registered with CarryingDetectionAttribute(11, ...) and sends
#   status 101-104 (reason 12) = AOD brightness index 0-3 with its own lux thresholds and hysteresis; while charging the
#   light sensor picks the index (<=2 / <=50 / <=100 / >100 lux). The index is capped by the lock screen brightness and
#   SystemUI maps it through config_aodBrightnessValues (0, 12, 32, 55 from the A52s overlay) onto the S6E3FC3
#   samsung,aod_candela_map_table (bl 0-11 = 2 nit, 12-31 = 10, 32-54 = 30, 55-255 = 60 nit HLPM).
# g6.p is read only by the brightness code (BrightnessManager.i(), the charging light sensor model, the SemContext lux
# handler and threshold sender, and a lux debug view); the wallpaper AOD UI keys off ha6.K0 / bj1.S() directly. So
# clearing g6.p keeps wallpaper AOD and restores the stock A52s index brightness (g6.r stays true through the
# config_aodBrightnessValues fallback, so dozeMode stays 0x10002).
# k4 (9.3.13): no longer patched in the APK. Rebuilding AODService replaced Samsung's signature, so Galaxy Store
# could not update Always On Display (compareSignature false) - and any update would have dropped the fix. The
# platform brightness mode now gets its lux -> nits arrays (config_autoBrightnessLevels_doze /
# config_autoBrightnessDisplayValuesNits_doze) from target/a52sxq/overlay instead, see arrays.xml there.
LOG "- AOD brightness: lux -> nits doze arrays come from the target overlay (AODService left unmodified)"
