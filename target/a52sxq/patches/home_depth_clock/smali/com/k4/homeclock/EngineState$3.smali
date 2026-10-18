.class Lcom/k4/homeclock/EngineState$3;
.super Landroid/content/BroadcastReceiver;
.source "EngineState.java"


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

    .line 65
    iput-object p1, p0, Lcom/k4/homeclock/EngineState$3;->this$0:Lcom/k4/homeclock/EngineState;

    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V

    return-void
.end method


# virtual methods
.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .registers 5

    .line 68
    iget-object p1, p0, Lcom/k4/homeclock/EngineState$3;->this$0:Lcom/k4/homeclock/EngineState;

    invoke-virtual {p2}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object v0

    const/4 v1, 0x0

    invoke-virtual {p1, v0, v1}, Lcom/k4/homeclock/EngineState;->redrawIfStale(Ljava/lang/String;Z)V

    .line 69
    iget-object p1, p0, Lcom/k4/homeclock/EngineState$3;->this$0:Lcom/k4/homeclock/EngineState;

    invoke-virtual {p2}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object p2

    invoke-static {p1, p2}, Lcom/k4/homeclock/EngineState;->-$$Nest$mretryWeather(Lcom/k4/homeclock/EngineState;Ljava/lang/String;)V

    .line 70
    return-void
.end method
