.class public final Lcom/android/server/battery/K4FastChargingPd;
.super Ljava/lang/Object;
.source "K4FastChargingPd.java"


# direct methods
.method public static sync(Z)V
    .locals 2

    # Fast charging off -> also block USB PD high voltage / PPS (pd_disable=1); on -> allow it (pd_disable=0)
    const-string v0, "/sys/class/power_supply/battery/pd_disable"

    xor-int/lit8 v1, p0, 0x1

    invoke-static {v0, v1}, Lcom/android/server/battery/BattUtils;->writeNode(Ljava/lang/String;Z)Z

    return-void
.end method
