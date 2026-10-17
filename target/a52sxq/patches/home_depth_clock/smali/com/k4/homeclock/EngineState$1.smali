.class Lcom/k4/homeclock/EngineState$1;
.super Ljava/lang/Object;
.source "EngineState.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/k4/homeclock/EngineState;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/k4/homeclock/EngineState;


# direct methods
.method constructor <init>(Lcom/k4/homeclock/EngineState;)V
    .registers 2
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010
        }
        names = {
            null
        }
    .end annotation

    .line 30
    iput-object p1, p0, Lcom/k4/homeclock/EngineState$1;->this$0:Lcom/k4/homeclock/EngineState;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .registers 7

    .line 33
    iget-object v0, p0, Lcom/k4/homeclock/EngineState$1;->this$0:Lcom/k4/homeclock/EngineState;

    invoke-static {v0}, Lcom/k4/homeclock/EngineState;->-$$Nest$fgetengine(Lcom/k4/homeclock/EngineState;)Ljava/lang/ref/WeakReference;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lf3/a;

    .line 34
    if-nez v0, :cond_f

    .line 35
    return-void

    .line 37
    :cond_f
    invoke-static {}, Lcom/k4/homeclock/HomeDepthClock;->enabled()Z

    move-result v1

    const/4 v2, 0x0

    const/4 v3, 0x1

    if-eqz v1, :cond_27

    invoke-virtual {v0}, Lf3/a;->getWhich()I

    move-result v1

    and-int/lit8 v1, v1, 0x3

    if-eq v1, v3, :cond_25

    invoke-static {}, Lcom/k4/homeclock/HomeDepthClock;->sharedEnabled()Z

    move-result v1

    if-eqz v1, :cond_27

    :cond_25
    move v1, v3

    goto :goto_28

    :cond_27
    move v1, v2

    .line 38
    :goto_28
    invoke-static {v0}, Lcom/k4/homeclock/HomeDepthClock;->clockOf(Lf3/a;)Lcom/k4/homeclock/ClockNode;

    move-result-object v4

    if-nez v4, :cond_34

    iget-object v4, v0, Lf3/a;->g:Lh3/a;

    instance-of v4, v4, Lcom/k4/homeclock/HomeClockPresenter;

    if-eqz v4, :cond_35

    :cond_34
    move v2, v3

    .line 39
    :cond_35
    if-nez v1, :cond_3a

    if-nez v2, :cond_3a

    .line 40
    return-void

    .line 42
    :cond_3a
    invoke-virtual {v0}, Lf3/a;->getWhich()I

    move-result v3

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "reload (which="

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, ", clock "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, " -> "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "): rebuilding the engine"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    const-string v2, "K4HomeClock"

    invoke-static {v2, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 43
    invoke-virtual {v0}, Lf3/a;->stopSelf()V

    .line 44
    return-void
.end method
