.class Lcom/k4/media/K4SlowMoCapture$4;
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


# direct methods
.method constructor blacklist <init>()V
    .registers 1

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public blacklist run()V
    .registers 2

    sget-object p0, Ljava/lang/System;->out:Ljava/io/PrintStream;

    const-string v0, "K4G TIMEOUT"

    invoke-virtual {p0, v0}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V

    const/4 p0, 0x3

    invoke-static {p0}, Ljava/lang/System;->exit(I)V

    return-void
.end method
