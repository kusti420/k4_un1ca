.class final Lcom/k4/media/K4SlowMoCapture$FakeCapture;
.super Ljava/lang/Object;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/k4/media/K4SlowMoCapture;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x18
    name = "FakeCapture"
.end annotation


# instance fields
.field blacklist mEventHandler:Landroid/os/Handler;

.field blacklist mWrapper:Ljava/lang/Object;


# direct methods
.method constructor blacklist <init>()V
    .registers 2

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    new-instance v0, Lcom/k4/media/K4SlowMoCapture$FakeWrapper;

    invoke-direct {v0}, Lcom/k4/media/K4SlowMoCapture$FakeWrapper;-><init>()V

    iput-object v0, p0, Lcom/k4/media/K4SlowMoCapture$FakeCapture;->mWrapper:Ljava/lang/Object;

    return-void
.end method
