.class final Lcom/k4/lockscreen/K4LockSnapshot$Writer;
.super Ljava/lang/Object;
.source "K4LockSnapshot.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/k4/lockscreen/K4LockSnapshot;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x18
    name = "Writer"
.end annotation


# instance fields
.field private final blacklist mApp:Landroid/content/Context;


# direct methods
.method constructor blacklist <init>(Landroid/content/Context;)V
    .registers 2

    .line 315
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 316
    iput-object p1, p0, Lcom/k4/lockscreen/K4LockSnapshot$Writer;->mApp:Landroid/content/Context;

    .line 317
    return-void
.end method


# virtual methods
.method public blacklist run()V
    .registers 2

    .line 321
    iget-object v0, p0, Lcom/k4/lockscreen/K4LockSnapshot$Writer;->mApp:Landroid/content/Context;

    invoke-static {v0}, Lcom/k4/lockscreen/K4LockSnapshot;->write(Landroid/content/Context;)V

    .line 322
    return-void
.end method
