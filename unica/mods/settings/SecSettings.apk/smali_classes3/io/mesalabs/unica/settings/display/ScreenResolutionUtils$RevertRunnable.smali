.class final Lio/mesalabs/unica/settings/display/ScreenResolutionUtils$RevertRunnable;
.super Ljava/lang/Object;
.source "ScreenResolutionUtils.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x18
    name = "RevertRunnable"
.end annotation


# direct methods
.method constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 0

    invoke-static {}, Lio/mesalabs/unica/settings/display/ScreenResolutionUtils;->revert()V

    return-void
.end method
