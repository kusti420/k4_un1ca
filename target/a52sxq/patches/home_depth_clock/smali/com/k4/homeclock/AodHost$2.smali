.class Lcom/k4/homeclock/AodHost$2;
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


# instance fields
.field final synthetic this$0:Lcom/k4/homeclock/AodHost;


# direct methods
.method constructor <init>(Lcom/k4/homeclock/AodHost;)V
    .registers 2
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010
        }
        names = {
            null
        }
    .end annotation

    .line 84
    iput-object p1, p0, Lcom/k4/homeclock/AodHost$2;->this$0:Lcom/k4/homeclock/AodHost;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .registers 3

    .line 87
    iget-object v0, p0, Lcom/k4/homeclock/AodHost$2;->this$0:Lcom/k4/homeclock/AodHost;

    const-string v1, "settings changed"

    invoke-static {v0, v1}, Lcom/k4/homeclock/AodHost;->-$$Nest$mrefetchWeather(Lcom/k4/homeclock/AodHost;Ljava/lang/String;)V

    .line 88
    return-void
.end method
