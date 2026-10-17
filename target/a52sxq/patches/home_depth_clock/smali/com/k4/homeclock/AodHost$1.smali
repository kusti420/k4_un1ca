.class Lcom/k4/homeclock/AodHost$1;
.super Ljava/lang/Object;
.source "AodHost.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/k4/homeclock/AodHost;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# direct methods
.method constructor <init>()V
    .registers 1

    .line 33
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .registers 3

    .line 36
    invoke-static {}, Lcom/k4/homeclock/AodHost;->-$$Nest$sfgetsHost()Lcom/k4/homeclock/AodHost;

    move-result-object v0

    .line 37
    if-eqz v0, :cond_13

    invoke-static {v0}, Lcom/k4/homeclock/AodHost;->-$$Nest$fgetrefs(Lcom/k4/homeclock/AodHost;)I

    move-result v1

    if-nez v1, :cond_13

    .line 38
    const/4 v1, 0x0

    invoke-static {v1}, Lcom/k4/homeclock/AodHost;->-$$Nest$sfputsHost(Lcom/k4/homeclock/AodHost;)V

    .line 39
    invoke-static {v0}, Lcom/k4/homeclock/AodHost;->-$$Nest$mdestroy(Lcom/k4/homeclock/AodHost;)V

    .line 41
    :cond_13
    return-void
.end method
