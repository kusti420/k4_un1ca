.class Lcom/k4/media/K4SlowMoCapture$3;
.super Ljava/lang/Object;

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/k4/media/K4SlowMoCapture;->main([Ljava/lang/String;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic blacklist val$c:Lcom/k4/media/K4SlowMoCapture$FakeCapture;


# direct methods
.method constructor blacklist <init>(Lcom/k4/media/K4SlowMoCapture$FakeCapture;)V
    .registers 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    iput-object p1, p0, Lcom/k4/media/K4SlowMoCapture$3;->val$c:Lcom/k4/media/K4SlowMoCapture$FakeCapture;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public blacklist run()V
    .registers 4

    :goto_0
    const-wide/16 v0, 0x7d0

    :try_start_2
    invoke-static {v0, v1}, Ljava/lang/Thread;->sleep(J)V

    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "K4G progress "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v2, p0, Lcom/k4/media/K4SlowMoCapture$3;->val$c:Lcom/k4/media/K4SlowMoCapture$FakeCapture;

    invoke-static {v2}, Lcom/k4/media/K4SlowMoCapture;->progress(Ljava/lang/Object;)F

    move-result v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    const-string v2, " ours "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v2, p0, Lcom/k4/media/K4SlowMoCapture$3;->val$c:Lcom/k4/media/K4SlowMoCapture$FakeCapture;

    invoke-static {v2}, Lcom/k4/media/K4SlowMoCapture;->ours(Ljava/lang/Object;)Z

    move-result v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    :try_end_2f
    .catch Ljava/lang/InterruptedException; {:try_start_2 .. :try_end_2f} :catch_30

    goto :goto_0

    :catch_30
    return-void
.end method
