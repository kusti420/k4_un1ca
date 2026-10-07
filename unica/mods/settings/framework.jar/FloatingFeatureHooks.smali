.class public final Lio/mesalabs/unica/FloatingFeatureHooks;
.super Ljava/lang/Object;
.source "FloatingFeatureHooks.java"


# Backend for the UN1CA Settings toggles that override floating features at runtime
# (called from SemFloatingFeature.getBoolean/getInt/getString). Returning null keeps the value from
# floating_feature.xml, so an unset property never changes stock behaviour.
#   persist.sys.unica.nativeblur (true/false) -> SEC_FLOATING_FEATURE_GRAPHICS_SUPPORT_3D_SURFACE_TRANSITION_FLAG
#   persist.sys.unica.launcher_anim_type (0..3) -> SEC_FLOATING_FEATURE_LAUNCHER_CONFIG_ANIMATION_TYPE
#                                                  (HighEnd, Mass, LowEnd, LowestEnd)


# direct methods
.method public static constructor blacklist <clinit>()V
    .locals 0

    return-void
.end method

.method public static blacklist onGetBoolean(Ljava/lang/String;)Ljava/lang/Boolean;
    .locals 2

    const-string v0, "SEC_FLOATING_FEATURE_GRAPHICS_SUPPORT_3D_SURFACE_TRANSITION_FLAG"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_none

    const-string v0, "persist.sys.unica.nativeblur"

    const-string v1, ""

    invoke-static {v0, v1}, Landroid/os/SystemProperties;->get(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v1

    if-nez v1, :cond_none

    invoke-static {v0}, Ljava/lang/Boolean;->parseBoolean(Ljava/lang/String;)Z

    move-result v0

    invoke-static {v0}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v0

    return-object v0

    :cond_none
    const/4 v0, 0x0

    return-object v0
.end method

.method public static blacklist onGetInt(Ljava/lang/String;)Ljava/lang/Integer;
    .locals 0

    const/4 p0, 0x0

    return-object p0
.end method

.method public static blacklist onGetString(Ljava/lang/String;)Ljava/lang/String;
    .locals 2

    const-string v0, "SEC_FLOATING_FEATURE_LAUNCHER_CONFIG_ANIMATION_TYPE"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_none

    const-string v0, "persist.sys.unica.launcher_anim_type"

    const/4 v1, -0x1

    invoke-static {v0, v1}, Landroid/os/SystemProperties;->getInt(Ljava/lang/String;I)I

    move-result v0

    if-nez v0, :cond_1

    const-string v0, "HighEnd"

    return-object v0

    :cond_1
    const/4 v1, 0x1

    if-ne v0, v1, :cond_2

    const-string v0, "Mass"

    return-object v0

    :cond_2
    const/4 v1, 0x2

    if-ne v0, v1, :cond_3

    const-string v0, "LowEnd"

    return-object v0

    :cond_3
    const/4 v1, 0x3

    if-ne v0, v1, :cond_none

    const-string v0, "LowestEnd"

    return-object v0

    :cond_none
    const/4 v0, 0x0

    return-object v0
.end method
