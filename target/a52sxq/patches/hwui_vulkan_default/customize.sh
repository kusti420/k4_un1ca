# Default the UI renderer to Vulkan (skiavk). unica/mods/settings forces persist.sys.unica.vulkan=false when the vendor
# does not declare ro.hwui.use_vulkan=true; the Adreno 642L V@0530 Vulkan 1.1 driver handles HWUI fine, and the OpenGL
# (skiagl) path shows tiled green artifacts in Instagram/Facebook videos on this port.
SET_PROP "vendor" "ro.hwui.use_vulkan" "true"
SET_PROP "system" "persist.sys.unica.vulkan" "true"
LOG "- UI renderer defaults to Vulkan (UN1CA toggle on by default)"
