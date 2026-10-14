.class Lcom/k4/media/K4SlowMoExport$7;
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

.field final synthetic blacklist val$films:[I

.field final synthetic blacklist val$fs:Landroid/os/IBinder;

.field final synthetic blacklist val$fsz:I

.field final synthetic blacklist val$jobs:Ljava/util/ArrayList;

.field final synthetic blacklist val$mem:Ljava/nio/ByteBuffer;

.field final synthetic blacklist val$ms:[D

.field final synthetic blacklist val$n:I

.field final synthetic blacklist val$next:[I

.field final synthetic blacklist val$x0:[I

.field final synthetic blacklist val$y0:[I


# direct methods
.method constructor blacklist <init>(Lcom/k4/media/K4SlowMoExport;[ILjava/util/ArrayList;Ljava/nio/ByteBuffer;ILandroid/os/IBinder;[I[I[D[II)V
    .registers 12
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010,
            0x1010,
            0x1010,
            0x1010,
            0x1010,
            0x1010,
            0x1010,
            0x1010,
            0x1010,
            0x1010,
            0x1010
        }
        names = {
            null,
            null,
            null,
            null,
            null,
            null,
            null,
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

    iput-object p2, p0, Lcom/k4/media/K4SlowMoExport$7;->val$next:[I

    iput-object p3, p0, Lcom/k4/media/K4SlowMoExport$7;->val$jobs:Ljava/util/ArrayList;

    iput-object p4, p0, Lcom/k4/media/K4SlowMoExport$7;->val$mem:Ljava/nio/ByteBuffer;

    iput p5, p0, Lcom/k4/media/K4SlowMoExport$7;->val$fsz:I

    iput-object p6, p0, Lcom/k4/media/K4SlowMoExport$7;->val$fs:Landroid/os/IBinder;

    iput-object p7, p0, Lcom/k4/media/K4SlowMoExport$7;->val$x0:[I

    iput-object p8, p0, Lcom/k4/media/K4SlowMoExport$7;->val$y0:[I

    iput-object p9, p0, Lcom/k4/media/K4SlowMoExport$7;->val$ms:[D

    iput-object p10, p0, Lcom/k4/media/K4SlowMoExport$7;->val$films:[I

    iput p11, p0, Lcom/k4/media/K4SlowMoExport$7;->val$n:I

    iput-object p1, p0, Lcom/k4/media/K4SlowMoExport$7;->this$0:Lcom/k4/media/K4SlowMoExport;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public blacklist frame(I)V
    .registers 15
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    :goto_0
    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport$7;->val$next:[I

    const/4 v1, 0x0

    aget v0, v0, v1

    iget-object v2, p0, Lcom/k4/media/K4SlowMoExport$7;->val$jobs:Ljava/util/ArrayList;

    invoke-virtual {v2}, Ljava/util/ArrayList;->size()I

    move-result v2

    const/4 v3, 0x1

    if-ge v0, v2, :cond_d0

    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport$7;->val$jobs:Ljava/util/ArrayList;

    iget-object v2, p0, Lcom/k4/media/K4SlowMoExport$7;->val$next:[I

    aget v2, v2, v1

    invoke-virtual {v0, v2}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [I

    aget v0, v0, v3

    if-ne v0, p1, :cond_d0

    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport$7;->val$next:[I

    aget v2, v0, v1

    add-int/lit8 v4, v2, 0x1

    aput v4, v0, v1

    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport$7;->val$jobs:Ljava/util/ArrayList;

    invoke-virtual {v0, v2}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [I

    const/4 v4, 0x2

    aget v5, v0, v4

    if-eqz v5, :cond_3b

    iget-object v5, p0, Lcom/k4/media/K4SlowMoExport$7;->this$0:Lcom/k4/media/K4SlowMoExport;

    invoke-static {v5}, Lcom/k4/media/K4SlowMoExport;->-$$Nest$fgetmScale(Lcom/k4/media/K4SlowMoExport;)I

    move-result v5

    mul-int/2addr v5, v4

    goto :goto_41

    :cond_3b
    iget-object v4, p0, Lcom/k4/media/K4SlowMoExport$7;->this$0:Lcom/k4/media/K4SlowMoExport;

    invoke-static {v4}, Lcom/k4/media/K4SlowMoExport;->-$$Nest$fgetmScale(Lcom/k4/media/K4SlowMoExport;)I

    move-result v5

    :goto_41
    add-int/lit8 v4, v5, -0x1

    new-array v11, v4, [F

    move v6, v3

    :goto_46
    if-ge v6, v5, :cond_52

    add-int/lit8 v7, v6, -0x1

    int-to-float v8, v6

    int-to-float v9, v5

    div-float/2addr v8, v9

    aput v8, v11, v7

    add-int/lit8 v6, v6, 0x1

    goto :goto_46

    :cond_52
    iget-object v5, p0, Lcom/k4/media/K4SlowMoExport$7;->this$0:Lcom/k4/media/K4SlowMoExport;

    iget-object v6, p0, Lcom/k4/media/K4SlowMoExport$7;->val$mem:Ljava/nio/ByteBuffer;

    aget v7, v0, v1

    rem-int/lit8 v7, v7, 0x4

    iget v8, p0, Lcom/k4/media/K4SlowMoExport$7;->val$fsz:I

    mul-int/2addr v7, v8

    invoke-static {v5, v6, v7}, Lcom/k4/media/K4SlowMoExport;->-$$Nest$mencodeFrame(Lcom/k4/media/K4SlowMoExport;Ljava/nio/ByteBuffer;I)V

    iget-object v6, p0, Lcom/k4/media/K4SlowMoExport$7;->val$fs:Landroid/os/IBinder;

    aget v5, v0, v1

    rem-int/lit8 v7, v5, 0x4

    aget v5, v0, v3

    rem-int/lit8 v8, v5, 0x4

    iget-object v5, p0, Lcom/k4/media/K4SlowMoExport$7;->val$x0:[I

    aget v9, v5, v2

    iget-object v5, p0, Lcom/k4/media/K4SlowMoExport$7;->val$y0:[I

    aget v10, v5, v2

    iget-object v12, p0, Lcom/k4/media/K4SlowMoExport$7;->val$ms:[D

    invoke-static/range {v6 .. v12}, Lcom/k4/media/K4SlowMoExport;->-$$Nest$smrenderPair(Landroid/os/IBinder;IIII[F[D)I

    move-result v2

    const/4 v5, -0x2

    if-eq v2, v5, :cond_b0

    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport$7;->val$films:[I

    aget v2, v0, v1

    add-int/2addr v2, v3

    aput v2, v0, v1

    move v0, v1

    :goto_83
    if-ge v0, v4, :cond_94

    iget-object v2, p0, Lcom/k4/media/K4SlowMoExport$7;->this$0:Lcom/k4/media/K4SlowMoExport;

    iget-object v3, p0, Lcom/k4/media/K4SlowMoExport$7;->val$mem:Ljava/nio/ByteBuffer;

    add-int/lit8 v5, v0, 0x4

    iget v6, p0, Lcom/k4/media/K4SlowMoExport$7;->val$fsz:I

    mul-int/2addr v5, v6

    invoke-static {v2, v3, v5}, Lcom/k4/media/K4SlowMoExport;->-$$Nest$mencodeFrame(Lcom/k4/media/K4SlowMoExport;Ljava/nio/ByteBuffer;I)V

    add-int/lit8 v0, v0, 0x1

    goto :goto_83

    :cond_94
    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport$7;->this$0:Lcom/k4/media/K4SlowMoExport;

    iget-object v2, p0, Lcom/k4/media/K4SlowMoExport$7;->val$next:[I

    aget v1, v2, v1

    int-to-float v1, v1

    const v2, 0x3f666666    # 0.9f

    mul-float/2addr v1, v2

    iget-object v2, p0, Lcom/k4/media/K4SlowMoExport$7;->val$jobs:Ljava/util/ArrayList;

    invoke-virtual {v2}, Ljava/util/ArrayList;->size()I

    move-result v2

    int-to-float v2, v2

    div-float/2addr v1, v2

    const v2, 0x3dcccccd    # 0.1f

    add-float/2addr v1, v2

    invoke-static {v0, v1}, Lcom/k4/media/K4SlowMoExport;->-$$Nest$fputmWork(Lcom/k4/media/K4SlowMoExport;F)V

    goto/16 :goto_0

    :cond_b0
    new-instance p0, Ljava/lang/IllegalStateException;

    new-instance p1, Ljava/lang/StringBuilder;

    const-string v2, "FILM failed at frames "

    invoke-direct {p1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    aget v1, v0, v1

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, "-"

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    aget v0, v0, v3

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p0

    :cond_d0
    iget v0, p0, Lcom/k4/media/K4SlowMoExport$7;->val$n:I

    sub-int/2addr v0, v3

    if-ne p1, v0, :cond_e1

    iget-object v0, p0, Lcom/k4/media/K4SlowMoExport$7;->this$0:Lcom/k4/media/K4SlowMoExport;

    iget-object v1, p0, Lcom/k4/media/K4SlowMoExport$7;->val$mem:Ljava/nio/ByteBuffer;

    rem-int/lit8 p1, p1, 0x4

    iget p0, p0, Lcom/k4/media/K4SlowMoExport$7;->val$fsz:I

    mul-int/2addr p1, p0

    invoke-static {v0, v1, p1}, Lcom/k4/media/K4SlowMoExport;->-$$Nest$mencodeFrame(Lcom/k4/media/K4SlowMoExport;Ljava/nio/ByteBuffer;I)V

    :cond_e1
    return-void
.end method
