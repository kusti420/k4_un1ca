.class Lcom/k4/media/K4SlowMoExport$6;
.super Ljava/lang/Object;

# interfaces
.implements Lcom/k4/media/K4SlowMoExport$FrameSink;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/k4/media/K4SlowMoExport;->renderOffline()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic blacklist this$0:Lcom/k4/media/K4SlowMoExport;

.field final synthetic blacklist val$diff:Ljava/util/ArrayList;

.field final synthetic blacklist val$fs:Landroid/os/IBinder;

.field final synthetic blacklist val$score:Ljava/util/HashMap;


# direct methods
.method constructor blacklist <init>(Lcom/k4/media/K4SlowMoExport;Ljava/util/ArrayList;Landroid/os/IBinder;Ljava/util/HashMap;)V
    .registers 5
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010,
            0x1010,
            0x1010,
            0x1010
        }
        names = {
            null,
            null,
            null,
            null
        }
    .end annotation

    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    iput-object p2, p0, Lcom/k4/media/K4SlowMoExport$6;->val$diff:Ljava/util/ArrayList;

    iput-object p3, p0, Lcom/k4/media/K4SlowMoExport$6;->val$fs:Landroid/os/IBinder;

    iput-object p4, p0, Lcom/k4/media/K4SlowMoExport$6;->val$score:Ljava/util/HashMap;

    iput-object p1, p0, Lcom/k4/media/K4SlowMoExport$6;->this$0:Lcom/k4/media/K4SlowMoExport;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public blacklist frame(I)V
    .registers 7
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    if-nez p1, :cond_f

    iget-object p0, p0, Lcom/k4/media/K4SlowMoExport$6;->val$diff:Ljava/util/ArrayList;

    const p1, 0x4e6e6b28    # 1.0E9f

    invoke-static {p1}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object p1

    invoke-virtual {p0, p1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    return-void

    :cond_f
    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport$6;->val$fs:Landroid/os/IBinder;

    add-int/lit8 v1, p1, -0x1

    invoke-static {v0, v1, p1}, Lcom/k4/media/K4SlowMoExport;->-$$Nest$smscorePair(Landroid/os/IBinder;II)[F

    move-result-object v0

    iget-object v2, p0, Lcom/k4/media/K4SlowMoExport$6;->val$score:Ljava/util/HashMap;

    invoke-static {v1, p1}, Lcom/k4/media/K4SlowMoExport;->-$$Nest$smkey(II)J

    move-result-wide v3

    invoke-static {v3, v4}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v3

    invoke-virtual {v2, v3, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    iget-object v2, p0, Lcom/k4/media/K4SlowMoExport$6;->val$diff:Ljava/util/ArrayList;

    const/4 v3, 0x3

    aget v0, v0, v3

    invoke-static {v0}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v0

    invoke-virtual {v2, v0}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    const/4 v0, 0x2

    if-lt p1, v0, :cond_5b

    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport$6;->val$diff:Ljava/util/ArrayList;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Float;

    invoke-virtual {v0}, Ljava/lang/Float;->floatValue()F

    move-result v0

    const v1, 0x3e19999a    # 0.15f

    cmpg-float v0, v0, v1

    if-gez v0, :cond_5b

    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport$6;->val$score:Ljava/util/HashMap;

    add-int/lit8 v1, p1, -0x2

    invoke-static {v1, p1}, Lcom/k4/media/K4SlowMoExport;->-$$Nest$smkey(II)J

    move-result-wide v2

    invoke-static {v2, v3}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v2

    iget-object v3, p0, Lcom/k4/media/K4SlowMoExport$6;->val$fs:Landroid/os/IBinder;

    invoke-static {v3, v1, p1}, Lcom/k4/media/K4SlowMoExport;->-$$Nest$smscorePair(Landroid/os/IBinder;II)[F

    move-result-object v1

    invoke-virtual {v0, v2, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    :cond_5b
    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport$6;->this$0:Lcom/k4/media/K4SlowMoExport;

    int-to-float p1, p1

    invoke-static {v0}, Lcom/k4/media/K4SlowMoExport;->-$$Nest$fgetmFps(Lcom/k4/media/K4SlowMoExport;)I

    move-result v1

    iget-object v2, p0, Lcom/k4/media/K4SlowMoExport$6;->this$0:Lcom/k4/media/K4SlowMoExport;

    invoke-static {v2}, Lcom/k4/media/K4SlowMoExport;->-$$Nest$fgetmEndMs(Lcom/k4/media/K4SlowMoExport;)I

    move-result v2

    iget-object p0, p0, Lcom/k4/media/K4SlowMoExport$6;->this$0:Lcom/k4/media/K4SlowMoExport;

    invoke-static {p0}, Lcom/k4/media/K4SlowMoExport;->-$$Nest$fgetmStartMs(Lcom/k4/media/K4SlowMoExport;)I

    move-result p0

    sub-int/2addr v2, p0

    mul-int/2addr v1, v2

    div-int/lit16 v1, v1, 0x3e8

    const/4 p0, 0x1

    invoke-static {p0, v1}, Ljava/lang/Math;->max(II)I

    move-result p0

    int-to-float p0, p0

    div-float/2addr p1, p0

    const/high16 p0, 0x3f800000    # 1.0f

    invoke-static {p0, p1}, Ljava/lang/Math;->min(FF)F

    move-result p0

    const p1, 0x3dcccccd    # 0.1f

    mul-float/2addr p0, p1

    invoke-static {v0, p0}, Lcom/k4/media/K4SlowMoExport;->-$$Nest$fputmWork(Lcom/k4/media/K4SlowMoExport;F)V

    return-void
.end method
