.class Lcom/k4/homeclock/EngineState$2;
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

    .line 51
    iput-object p1, p0, Lcom/k4/homeclock/EngineState$2;->this$0:Lcom/k4/homeclock/EngineState;

    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V

    return-void
.end method


# virtual methods
.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .registers 5

    .line 54
    iget-object p1, p0, Lcom/k4/homeclock/EngineState$2;->this$0:Lcom/k4/homeclock/EngineState;

    invoke-static {p1}, Lcom/k4/homeclock/EngineState;->-$$Nest$fgetmain(Lcom/k4/homeclock/EngineState;)Landroid/os/Handler;

    move-result-object p1

    iget-object v0, p0, Lcom/k4/homeclock/EngineState$2;->this$0:Lcom/k4/homeclock/EngineState;

    invoke-static {v0}, Lcom/k4/homeclock/EngineState;->-$$Nest$fgetreload(Lcom/k4/homeclock/EngineState;)Ljava/lang/Runnable;

    move-result-object v0

    invoke-virtual {p1, v0}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    .line 59
    iget-object p1, p0, Lcom/k4/homeclock/EngineState$2;->this$0:Lcom/k4/homeclock/EngineState;

    const-string v0, "com.k4.homeclock.extra.WALLPAPER_PENDING"

    const/4 v1, 0x0

    invoke-virtual {p2, v0, v1}, Landroid/content/Intent;->getBooleanExtra(Ljava/lang/String;Z)Z

    move-result p2

    invoke-static {p1, p2}, Lcom/k4/homeclock/EngineState;->-$$Nest$fputreloadAwaitsWallpaper(Lcom/k4/homeclock/EngineState;Z)V

    .line 60
    iget-object p1, p0, Lcom/k4/homeclock/EngineState$2;->this$0:Lcom/k4/homeclock/EngineState;

    invoke-static {p1}, Lcom/k4/homeclock/EngineState;->-$$Nest$fgetmain(Lcom/k4/homeclock/EngineState;)Landroid/os/Handler;

    move-result-object p1

    iget-object p2, p0, Lcom/k4/homeclock/EngineState$2;->this$0:Lcom/k4/homeclock/EngineState;

    invoke-static {p2}, Lcom/k4/homeclock/EngineState;->-$$Nest$fgetreload(Lcom/k4/homeclock/EngineState;)Ljava/lang/Runnable;

    move-result-object p2

    iget-object v0, p0, Lcom/k4/homeclock/EngineState$2;->this$0:Lcom/k4/homeclock/EngineState;

    invoke-static {v0}, Lcom/k4/homeclock/EngineState;->-$$Nest$fgetreloadAwaitsWallpaper(Lcom/k4/homeclock/EngineState;)Z

    move-result v0

    if-eqz v0, :cond_32

    const-wide/16 v0, 0x1770

    goto :goto_34

    :cond_32
    const-wide/16 v0, 0x12c

    :goto_34
    invoke-virtual {p1, p2, v0, v1}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    .line 61
    return-void
.end method
