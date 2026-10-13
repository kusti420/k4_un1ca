# SystemUI helper for the a52sxq "AOD brightness" choice. Called from
# com.android.systemui.doze.AODScreenBrightness.updateDozeBrightness(III)V with the platform brightness (0-255
# backlight level, or -1 = "no value yet") that AODService asked for; returns the level SystemUI should really send
# to PowerManager (DreamService.semSetDozeScreenBrightness).
#
# persist.sys.k4.aod_brightness:
#   0 / unset  Automatic - Samsung's value is passed through unchanged
#   1          always  2 nit  (backlight  0)
#   2          always 10 nit  (backlight 12)
#   3          always 30 nit  (backlight 32)
#   4          always 60 nit  (backlight 55)
#   5          Automatic, one step brighter (2 -> 10, 10 -> 30, 30 -> 60 nit; "no value yet" -> 10 nit)
#
# The backlight numbers are the "from" column of the S6E3FC3 samsung,aod_candela_map_table_revA
# (0-11 = 2 nit, 12-31 = 10, 32-54 = 30, 55-255 = 60) = stock config_aodBrightnessValues {0, 12, 32, 55}.

.class public final Lcom/k4/aod/K4AodBrightness;
.super Ljava/lang/Object;
.source "K4AodBrightness.java"


# direct methods
.method private constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static apply(I)I
    .locals 2

    const-string v0, "persist.sys.k4.aod_brightness"

    const/4 v1, 0x0

    invoke-static {v0, v1}, Landroid/os/SystemProperties;->getInt(Ljava/lang/String;I)I

    move-result v0

    const/4 v1, 0x1

    if-ne v0, v1, :cond_0

    const/4 p0, 0x0

    return p0

    :cond_0
    const/4 v1, 0x2

    if-ne v0, v1, :cond_1

    const/16 p0, 0xc

    return p0

    :cond_1
    const/4 v1, 0x3

    if-ne v0, v1, :cond_2

    const/16 p0, 0x20

    return p0

    :cond_2
    const/4 v1, 0x4

    if-ne v0, v1, :cond_3

    const/16 p0, 0x37

    return p0

    :cond_3
    const/4 v1, 0x5

    if-ne v0, v1, :cond_6

    # Automatic, one HLPM step brighter
    const/16 v1, 0xc

    if-ge p0, v1, :cond_4

    return v1

    :cond_4
    const/16 v1, 0x20

    if-ge p0, v1, :cond_5

    return v1

    :cond_5
    const/16 v1, 0x37

    if-ge p0, v1, :cond_6

    return v1

    :cond_6
    return p0
.end method
