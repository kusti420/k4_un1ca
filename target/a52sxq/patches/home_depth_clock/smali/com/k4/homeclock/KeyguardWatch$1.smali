.class Lcom/k4/homeclock/KeyguardWatch$1;
.super Ljava/lang/Object;
.source "KeyguardWatch.java"

# interfaces
.implements Landroid/app/KeyguardManager$KeyguardLockedStateListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/k4/homeclock/KeyguardWatch;->ensure(Landroid/content/Context;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# direct methods
.method constructor <init>()V
    .registers 1

    .line 29
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onKeyguardLockedStateChanged(Z)V
    .registers 8

    .line 32
    sput-boolean p1, Lcom/k4/homeclock/KeyguardWatch;->locked:Z

    .line 33
    invoke-static {}, Lcom/k4/homeclock/HomeDepthClock;->states()[Lcom/k4/homeclock/EngineState;

    move-result-object v0

    array-length v1, v0

    const/4 v2, 0x0

    :goto_8
    if-ge v2, v1, :cond_1a

    aget-object v3, v0, v2

    .line 34
    if-eqz p1, :cond_11

    const-string v4, "keyguard shown"

    goto :goto_13

    :cond_11
    const-string v4, "keyguard gone"

    :goto_13
    const/4 v5, 0x1

    invoke-virtual {v3, v4, v5}, Lcom/k4/homeclock/EngineState;->redrawIfStale(Ljava/lang/String;Z)V

    .line 33
    add-int/lit8 v2, v2, 0x1

    goto :goto_8

    .line 36
    :cond_1a
    return-void
.end method
