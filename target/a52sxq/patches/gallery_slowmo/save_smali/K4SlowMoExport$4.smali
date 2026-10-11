.class Lcom/k4/media/K4SlowMoExport$4;
.super Ljava/lang/Object;

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/k4/media/K4SlowMoExport;->main([Ljava/lang/String;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic blacklist val$e:Lcom/k4/media/K4SlowMoExport;


# direct methods
.method constructor blacklist <init>(Lcom/k4/media/K4SlowMoExport;)V
    .registers 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    iput-object p1, p0, Lcom/k4/media/K4SlowMoExport$4;->val$e:Lcom/k4/media/K4SlowMoExport;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public blacklist run()V
    .registers 3

    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;

    const-string v1, "K4E cancel"

    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V

    iget-object p0, p0, Lcom/k4/media/K4SlowMoExport$4;->val$e:Lcom/k4/media/K4SlowMoExport;

    invoke-virtual {p0}, Lcom/k4/media/K4SlowMoExport;->cancel()V

    return-void
.end method
