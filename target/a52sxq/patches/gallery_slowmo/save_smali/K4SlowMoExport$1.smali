.class Lcom/k4/media/K4SlowMoExport$1;
.super Ljava/lang/Object;

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/k4/media/K4SlowMoExport;->begin()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic blacklist this$0:Lcom/k4/media/K4SlowMoExport;


# direct methods
.method constructor blacklist <init>(Lcom/k4/media/K4SlowMoExport;)V
    .registers 2
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010
        }
        names = {
            null
        }
    .end annotation

    iput-object p1, p0, Lcom/k4/media/K4SlowMoExport$1;->this$0:Lcom/k4/media/K4SlowMoExport;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public blacklist run()V
    .registers 1

    iget-object p0, p0, Lcom/k4/media/K4SlowMoExport$1;->this$0:Lcom/k4/media/K4SlowMoExport;

    invoke-virtual {p0}, Lcom/k4/media/K4SlowMoExport;->drain()V

    return-void
.end method
