.class Lcom/k4/homeclock/AodHost$3$1;
.super Ljava/lang/Object;
.source "AodHost.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/k4/homeclock/AodHost$3;->invoke(Ljava/lang/Object;Ljava/lang/reflect/Method;[Ljava/lang/Object;)Ljava/lang/Object;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcom/k4/homeclock/AodHost$3;

.field final synthetic val$info:Ljava/lang/Object;


# direct methods
.method constructor <init>(Lcom/k4/homeclock/AodHost$3;Ljava/lang/Object;)V
    .registers 3
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010,
            0x1010
        }
        names = {
            null,
            null
        }
    .end annotation

    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 249
    iput-object p2, p0, Lcom/k4/homeclock/AodHost$3$1;->val$info:Ljava/lang/Object;

    iput-object p1, p0, Lcom/k4/homeclock/AodHost$3$1;->this$1:Lcom/k4/homeclock/AodHost$3;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .registers 3

    .line 252
    iget-object v0, p0, Lcom/k4/homeclock/AodHost$3$1;->this$1:Lcom/k4/homeclock/AodHost$3;

    iget-object v0, v0, Lcom/k4/homeclock/AodHost$3;->this$0:Lcom/k4/homeclock/AodHost;

    iget-object v1, p0, Lcom/k4/homeclock/AodHost$3$1;->val$info:Ljava/lang/Object;

    invoke-static {v0, v1}, Lcom/k4/homeclock/AodHost;->-$$Nest$monWeather(Lcom/k4/homeclock/AodHost;Ljava/lang/Object;)V

    .line 253
    return-void
.end method
