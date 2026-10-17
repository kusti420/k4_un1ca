.class Lcom/k4/homeclock/AodHost$4;
.super Ljava/lang/Object;
.source "AodHost.java"

# interfaces
.implements Ljava/lang/Runnable;


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

.field final synthetic val$l:Ljava/lang/Object;

.field final synthetic val$listener:Ljava/lang/Class;

.field final synthetic val$wm:Ljava/lang/Object;


# direct methods
.method constructor <init>(Lcom/k4/homeclock/AodHost;Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Class;)V
    .registers 5
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010,
            0x1010,
            0x1010,
            0x1010
        }
        names = {
            null,
            null,
            null,
            null
        }
    .end annotation

    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 275
    iput-object p2, p0, Lcom/k4/homeclock/AodHost$4;->val$wm:Ljava/lang/Object;

    iput-object p3, p0, Lcom/k4/homeclock/AodHost$4;->val$l:Ljava/lang/Object;

    iput-object p4, p0, Lcom/k4/homeclock/AodHost$4;->val$listener:Ljava/lang/Class;

    iput-object p1, p0, Lcom/k4/homeclock/AodHost$4;->this$0:Lcom/k4/homeclock/AodHost;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .registers 5

    .line 278
    iget-object v0, p0, Lcom/k4/homeclock/AodHost$4;->this$0:Lcom/k4/homeclock/AodHost;

    invoke-static {v0}, Lcom/k4/homeclock/AodHost;->-$$Nest$fgetweatherManager(Lcom/k4/homeclock/AodHost;)Ljava/lang/Object;

    move-result-object v0

    iget-object v1, p0, Lcom/k4/homeclock/AodHost$4;->val$wm:Ljava/lang/Object;

    if-ne v0, v1, :cond_5c

    iget-object v0, p0, Lcom/k4/homeclock/AodHost$4;->this$0:Lcom/k4/homeclock/AodHost;

    invoke-static {v0}, Lcom/k4/homeclock/AodHost;->-$$Nest$fgetweatherListener(Lcom/k4/homeclock/AodHost;)Ljava/lang/Object;

    move-result-object v0

    iget-object v1, p0, Lcom/k4/homeclock/AodHost$4;->val$l:Ljava/lang/Object;

    if-eq v0, v1, :cond_15

    goto :goto_5c

    .line 282
    :cond_15
    const/4 v0, 0x1

    :try_start_16
    iget-object v1, p0, Lcom/k4/homeclock/AodHost$4;->this$0:Lcom/k4/homeclock/AodHost;

    const-string v2, "com.samsung.android.clockpack.plugins.clock.IWeatherManager"

    invoke-virtual {v1, v2}, Lcom/k4/homeclock/AodHost;->cls(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v1

    const-string v2, "registerListener"

    iget-object v3, p0, Lcom/k4/homeclock/AodHost$4;->val$listener:Ljava/lang/Class;

    filled-new-array {v3}, [Ljava/lang/Class;

    move-result-object v3

    invoke-virtual {v1, v2, v3}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v1

    iget-object v2, p0, Lcom/k4/homeclock/AodHost$4;->val$wm:Ljava/lang/Object;

    iget-object v3, p0, Lcom/k4/homeclock/AodHost$4;->val$l:Ljava/lang/Object;

    filled-new-array {v3}, [Ljava/lang/Object;

    move-result-object v3

    invoke-virtual {v1, v2, v3}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    .line 283
    iget-object v1, p0, Lcom/k4/homeclock/AodHost$4;->this$0:Lcom/k4/homeclock/AodHost;

    invoke-static {v1, v0}, Lcom/k4/homeclock/AodHost;->-$$Nest$fputweatherRegistered(Lcom/k4/homeclock/AodHost;Z)V
    :try_end_3a
    .catchall {:try_start_16 .. :try_end_3a} :catchall_3b

    .line 289
    goto :goto_5b

    .line 284
    :catchall_3b
    move-exception v1

    .line 285
    instance-of v2, v1, Ljava/lang/reflect/InvocationTargetException;

    if-eqz v2, :cond_4a

    invoke-virtual {v1}, Ljava/lang/Throwable;->getCause()Ljava/lang/Throwable;

    move-result-object v2

    if-eqz v2, :cond_4a

    invoke-virtual {v1}, Ljava/lang/Throwable;->getCause()Ljava/lang/Throwable;

    move-result-object v1

    .line 286
    :cond_4a
    const-string v2, "K4HomeClock"

    const-string v3, "AOD clock weather: registerListener failed"

    invoke-static {v2, v3, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 287
    iget-object v1, p0, Lcom/k4/homeclock/AodHost$4;->this$0:Lcom/k4/homeclock/AodHost;

    invoke-static {v1, v0}, Lcom/k4/homeclock/AodHost;->-$$Nest$fputweatherFailed(Lcom/k4/homeclock/AodHost;Z)V

    .line 288
    iget-object v0, p0, Lcom/k4/homeclock/AodHost$4;->this$0:Lcom/k4/homeclock/AodHost;

    invoke-static {v0}, Lcom/k4/homeclock/AodHost;->-$$Nest$mstopWeather(Lcom/k4/homeclock/AodHost;)V

    .line 290
    :goto_5b
    return-void

    .line 279
    :cond_5c
    :goto_5c
    return-void
.end method
