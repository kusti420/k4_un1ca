.class Lcom/k4/media/K4SlowMoExport$4;
.super Ljava/lang/Object;

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/k4/media/K4SlowMoExport;->beginOffline()V
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

    iput-object p1, p0, Lcom/k4/media/K4SlowMoExport$4;->this$0:Lcom/k4/media/K4SlowMoExport;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public blacklist run()V
    .registers 1

    iget-object p0, p0, Lcom/k4/media/K4SlowMoExport$4;->this$0:Lcom/k4/media/K4SlowMoExport;

    invoke-static {p0}, Lcom/k4/media/K4SlowMoExport;->-$$Nest$mdrain(Lcom/k4/media/K4SlowMoExport;)V

    return-void
.end method
