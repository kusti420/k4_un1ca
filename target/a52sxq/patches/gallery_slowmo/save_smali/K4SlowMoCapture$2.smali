.class Lcom/k4/media/K4SlowMoCapture$2;
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

.field final synthetic blacklist val$out:Ljava/io/FileOutputStream;


# direct methods
.method constructor blacklist <init>(Lcom/k4/media/K4SlowMoCapture$FakeCapture;Ljava/io/FileOutputStream;)V
    .registers 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    iput-object p1, p0, Lcom/k4/media/K4SlowMoCapture$2;->val$c:Lcom/k4/media/K4SlowMoCapture$FakeCapture;

    iput-object p2, p0, Lcom/k4/media/K4SlowMoCapture$2;->val$out:Ljava/io/FileOutputStream;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public blacklist run()V
    .registers 6

    const-string v0, "K4G after cancel: output "

    const-string v1, "K4G stopCapture -> "

    :try_start_4
    sget-object v2, Ljava/lang/System;->out:Ljava/io/PrintStream;

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    iget-object v1, p0, Lcom/k4/media/K4SlowMoCapture$2;->val$c:Lcom/k4/media/K4SlowMoCapture$FakeCapture;

    invoke-static {v1}, Lcom/k4/media/K4SlowMoCapture;->stopCapture(Ljava/lang/Object;)Z

    move-result v1

    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    const-string v1, ", progress "

    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Lcom/k4/media/K4SlowMoCapture$2;->val$c:Lcom/k4/media/K4SlowMoCapture$FakeCapture;

    invoke-static {v1}, Lcom/k4/media/K4SlowMoCapture;->progress(Ljava/lang/Object;)F

    move-result v1

    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v2, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V

    const-wide/16 v1, 0x5dc

    invoke-static {v1, v2}, Ljava/lang/Thread;->sleep(J)V

    sget-object v1, Ljava/lang/System;->out:Ljava/io/PrintStream;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    iget-object v0, p0, Lcom/k4/media/K4SlowMoCapture$2;->val$out:Ljava/io/FileOutputStream;

    invoke-virtual {v0}, Ljava/io/FileOutputStream;->getChannel()Ljava/nio/channels/FileChannel;

    move-result-object v0

    invoke-virtual {v0}, Ljava/nio/channels/FileChannel;->size()J

    move-result-wide v3

    invoke-virtual {v2, v3, v4}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    const-string v0, " bytes, ours "

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object p0, p0, Lcom/k4/media/K4SlowMoCapture$2;->val$c:Lcom/k4/media/K4SlowMoCapture$FakeCapture;

    invoke-static {p0}, Lcom/k4/media/K4SlowMoCapture;->ours(Ljava/lang/Object;)Z

    move-result p0

    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-virtual {v1, p0}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    :try_end_57
    .catch Ljava/lang/Exception; {:try_start_4 .. :try_end_57} :catch_57

    :catch_57
    const/4 p0, 0x0

    invoke-static {p0}, Ljava/lang/System;->exit(I)V

    return-void
.end method
