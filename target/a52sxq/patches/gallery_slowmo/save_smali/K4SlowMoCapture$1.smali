.class Lcom/k4/media/K4SlowMoCapture$1;
.super Landroid/os/Handler;


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

.field final synthetic blacklist val$out:Ljava/io/FileOutputStream;

.field final synthetic blacklist val$t0:J


# direct methods
.method constructor blacklist <init>(Landroid/os/Looper;JLcom/k4/media/K4SlowMoCapture$FakeCapture;Ljava/io/FileOutputStream;)V
    .registers 6

    iput-wide p2, p0, Lcom/k4/media/K4SlowMoCapture$1;->val$t0:J

    iput-object p4, p0, Lcom/k4/media/K4SlowMoCapture$1;->val$c:Lcom/k4/media/K4SlowMoCapture$FakeCapture;

    iput-object p5, p0, Lcom/k4/media/K4SlowMoCapture$1;->val$out:Ljava/io/FileOutputStream;

    invoke-direct {p0, p1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    return-void
.end method


# virtual methods
.method public blacklist handleMessage(Landroid/os/Message;)V
    .registers 9

    const-string v0, "K4G message "

    :try_start_2
    sget-object v1, Ljava/lang/System;->out:Ljava/io/PrintStream;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    iget p1, p1, Landroid/os/Message;->what:I

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string p1, " after "

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v3

    iget-wide v5, p0, Lcom/k4/media/K4SlowMoCapture$1;->val$t0:J

    sub-long/2addr v3, v5

    invoke-virtual {v2, v3, v4}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    const-string p1, " ms on "

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-static {}, Ljava/lang/Thread;->currentThread()Ljava/lang/Thread;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/Thread;->getName()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string p1, ", progress "

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object p1, p0, Lcom/k4/media/K4SlowMoCapture$1;->val$c:Lcom/k4/media/K4SlowMoCapture$FakeCapture;

    invoke-static {p1}, Lcom/k4/media/K4SlowMoCapture;->progress(Ljava/lang/Object;)F

    move-result p1

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    const-string p1, ", output "

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object p1, p0, Lcom/k4/media/K4SlowMoCapture$1;->val$out:Ljava/io/FileOutputStream;

    invoke-virtual {p1}, Ljava/io/FileOutputStream;->getChannel()Ljava/nio/channels/FileChannel;

    move-result-object p1

    invoke-virtual {p1}, Ljava/nio/channels/FileChannel;->size()J

    move-result-wide v3

    invoke-virtual {v2, v3, v4}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    const-string p1, " bytes"

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v1, p1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    :try_end_59
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_59} :catch_59

    :catch_59
    iget-object p1, p0, Lcom/k4/media/K4SlowMoCapture$1;->val$c:Lcom/k4/media/K4SlowMoCapture$FakeCapture;

    invoke-static {p1}, Lcom/k4/media/K4SlowMoCapture;->stopCapture(Ljava/lang/Object;)Z

    iget-object p0, p0, Lcom/k4/media/K4SlowMoCapture$1;->val$c:Lcom/k4/media/K4SlowMoCapture$FakeCapture;

    invoke-static {p0}, Lcom/k4/media/K4SlowMoCapture;->release(Ljava/lang/Object;)V

    const/4 p0, 0x0

    invoke-static {p0}, Ljava/lang/System;->exit(I)V

    return-void
.end method
