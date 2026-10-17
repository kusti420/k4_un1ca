.class Lcom/k4/homeclock/AodHost$5;
.super Landroid/database/ContentObserver;
.source "AodHost.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/k4/homeclock/AodHost;->startWeather()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/k4/homeclock/AodHost;


# direct methods
.method constructor <init>(Lcom/k4/homeclock/AodHost;Landroid/os/Handler;)V
    .registers 3
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010,
            0x0
        }
        names = {
            null,
            null
        }
    .end annotation

    .line 292
    iput-object p1, p0, Lcom/k4/homeclock/AodHost$5;->this$0:Lcom/k4/homeclock/AodHost;

    invoke-direct {p0, p2}, Landroid/database/ContentObserver;-><init>(Landroid/os/Handler;)V

    return-void
.end method


# virtual methods
.method public onChange(Z)V
    .registers 5

    .line 295
    invoke-static {}, Lcom/k4/homeclock/AodHost;->-$$Nest$smmain()Landroid/os/Handler;

    move-result-object p1

    iget-object v0, p0, Lcom/k4/homeclock/AodHost$5;->this$0:Lcom/k4/homeclock/AodHost;

    invoke-static {v0}, Lcom/k4/homeclock/AodHost;->-$$Nest$fgetrefetch(Lcom/k4/homeclock/AodHost;)Ljava/lang/Runnable;

    move-result-object v0

    invoke-virtual {p1, v0}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    .line 296
    invoke-static {}, Lcom/k4/homeclock/AodHost;->-$$Nest$smmain()Landroid/os/Handler;

    move-result-object p1

    iget-object v0, p0, Lcom/k4/homeclock/AodHost$5;->this$0:Lcom/k4/homeclock/AodHost;

    invoke-static {v0}, Lcom/k4/homeclock/AodHost;->-$$Nest$fgetrefetch(Lcom/k4/homeclock/AodHost;)Ljava/lang/Runnable;

    move-result-object v0

    const-wide/16 v1, 0x3e8

    invoke-virtual {p1, v0, v1, v2}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    .line 297
    return-void
.end method
