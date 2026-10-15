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

.field final synthetic blacklist val$quart:[Z

.field final synthetic blacklist val$two:[Z

.field final synthetic blacklist val$x0:[I

.field final synthetic blacklist val$x1:[I

.field final synthetic blacklist val$y0:[I

.field final synthetic blacklist val$y1:[I


# direct methods
.method constructor blacklist <init>(Lcom/k4/media/K4SlowMoExport;[ILjava/util/ArrayList;Ljava/nio/ByteBuffer;ILandroid/os/IBinder;[I[I[I[I[Z[Z[D[II)V
    .registers 16
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

    iput-object p9, p0, Lcom/k4/media/K4SlowMoExport$7;->val$x1:[I

    iput-object p10, p0, Lcom/k4/media/K4SlowMoExport$7;->val$y1:[I

    iput-object p11, p0, Lcom/k4/media/K4SlowMoExport$7;->val$two:[Z

    iput-object p12, p0, Lcom/k4/media/K4SlowMoExport$7;->val$quart:[Z

    iput-object p13, p0, Lcom/k4/media/K4SlowMoExport$7;->val$ms:[D

    iput-object p14, p0, Lcom/k4/media/K4SlowMoExport$7;->val$films:[I

    iput p15, p0, Lcom/k4/media/K4SlowMoExport$7;->val$n:I

    iput-object p1, p0, Lcom/k4/media/K4SlowMoExport$7;->this$0:Lcom/k4/media/K4SlowMoExport;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public blacklist frame(I)V
    .registers 21
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    move-object/from16 v0, p0

    move/from16 v1, p1

    :goto_4
    iget-object v2, v0, Lcom/k4/media/K4SlowMoExport$7;->val$next:[I

    const/4 v3, 0x0

    aget v2, v2, v3

    iget-object v4, v0, Lcom/k4/media/K4SlowMoExport$7;->val$jobs:Ljava/util/ArrayList;

    invoke-virtual {v4}, Ljava/util/ArrayList;->size()I

    move-result v4

    const/4 v5, 0x1

    if-ge v2, v4, :cond_e8

    iget-object v2, v0, Lcom/k4/media/K4SlowMoExport$7;->val$jobs:Ljava/util/ArrayList;

    iget-object v4, v0, Lcom/k4/media/K4SlowMoExport$7;->val$next:[I

    aget v4, v4, v3

    invoke-virtual {v2, v4}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, [I

    aget v2, v2, v5

    if-ne v2, v1, :cond_e8

    iget-object v2, v0, Lcom/k4/media/K4SlowMoExport$7;->val$next:[I

    aget v4, v2, v3

    add-int/lit8 v6, v4, 0x1

    aput v6, v2, v3

    iget-object v2, v0, Lcom/k4/media/K4SlowMoExport$7;->val$jobs:Ljava/util/ArrayList;

    invoke-virtual {v2, v4}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, [I

    const/4 v6, 0x2

    aget v7, v2, v6

    if-eqz v7, :cond_3f

    iget-object v7, v0, Lcom/k4/media/K4SlowMoExport$7;->this$0:Lcom/k4/media/K4SlowMoExport;

    invoke-static {v7}, Lcom/k4/media/K4SlowMoExport;->-$$Nest$fgetmScale(Lcom/k4/media/K4SlowMoExport;)I

    move-result v7

    mul-int/2addr v7, v6

    goto :goto_45

    :cond_3f
    iget-object v6, v0, Lcom/k4/media/K4SlowMoExport$7;->this$0:Lcom/k4/media/K4SlowMoExport;

    invoke-static {v6}, Lcom/k4/media/K4SlowMoExport;->-$$Nest$fgetmScale(Lcom/k4/media/K4SlowMoExport;)I

    move-result v7

    :goto_45
    add-int/lit8 v6, v7, -0x1

    new-array v8, v6, [F

    move v9, v5

    :goto_4a
    if-ge v9, v7, :cond_56

    add-int/lit8 v10, v9, -0x1

    int-to-float v11, v9

    int-to-float v12, v7

    div-float/2addr v11, v12

    aput v11, v8, v10

    add-int/lit8 v9, v9, 0x1

    goto :goto_4a

    :cond_56
    iget-object v7, v0, Lcom/k4/media/K4SlowMoExport$7;->this$0:Lcom/k4/media/K4SlowMoExport;

    iget-object v9, v0, Lcom/k4/media/K4SlowMoExport$7;->val$mem:Ljava/nio/ByteBuffer;

    aget v10, v2, v3

    rem-int/lit8 v10, v10, 0x4

    iget v11, v0, Lcom/k4/media/K4SlowMoExport$7;->val$fsz:I

    mul-int/2addr v10, v11

    invoke-static {v7, v9, v10}, Lcom/k4/media/K4SlowMoExport;->-$$Nest$mencodeFrame(Lcom/k4/media/K4SlowMoExport;Ljava/nio/ByteBuffer;I)V

    move-object/from16 v17, v8

    iget-object v8, v0, Lcom/k4/media/K4SlowMoExport$7;->val$fs:Landroid/os/IBinder;

    aget v7, v2, v3

    rem-int/lit8 v9, v7, 0x4

    aget v7, v2, v5

    rem-int/lit8 v10, v7, 0x4

    iget-object v7, v0, Lcom/k4/media/K4SlowMoExport$7;->val$x0:[I

    aget v11, v7, v4

    iget-object v7, v0, Lcom/k4/media/K4SlowMoExport$7;->val$y0:[I

    aget v12, v7, v4

    iget-object v7, v0, Lcom/k4/media/K4SlowMoExport$7;->val$x1:[I

    aget v13, v7, v4

    iget-object v7, v0, Lcom/k4/media/K4SlowMoExport$7;->val$y1:[I

    aget v14, v7, v4

    iget-object v7, v0, Lcom/k4/media/K4SlowMoExport$7;->val$two:[Z

    aget-boolean v15, v7, v4

    iget-object v7, v0, Lcom/k4/media/K4SlowMoExport$7;->val$quart:[Z

    aget-boolean v16, v7, v4

    iget-object v4, v0, Lcom/k4/media/K4SlowMoExport$7;->val$ms:[D

    move-object/from16 v18, v4

    invoke-static/range {v8 .. v18}, Lcom/k4/media/K4SlowMoExport;->-$$Nest$smrenderPair(Landroid/os/IBinder;IIIIIIZZ[F[D)I

    move-result v4

    const/4 v7, -0x2

    if-eq v4, v7, :cond_c8

    iget-object v2, v0, Lcom/k4/media/K4SlowMoExport$7;->val$films:[I

    aget v4, v2, v3

    add-int/2addr v4, v5

    aput v4, v2, v3

    move v2, v3

    :goto_9b
    if-ge v2, v6, :cond_ac

    iget-object v4, v0, Lcom/k4/media/K4SlowMoExport$7;->this$0:Lcom/k4/media/K4SlowMoExport;

    iget-object v5, v0, Lcom/k4/media/K4SlowMoExport$7;->val$mem:Ljava/nio/ByteBuffer;

    add-int/lit8 v7, v2, 0x4

    iget v8, v0, Lcom/k4/media/K4SlowMoExport$7;->val$fsz:I

    mul-int/2addr v7, v8

    invoke-static {v4, v5, v7}, Lcom/k4/media/K4SlowMoExport;->-$$Nest$mencodeFrame(Lcom/k4/media/K4SlowMoExport;Ljava/nio/ByteBuffer;I)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_9b

    :cond_ac
    iget-object v2, v0, Lcom/k4/media/K4SlowMoExport$7;->this$0:Lcom/k4/media/K4SlowMoExport;

    iget-object v4, v0, Lcom/k4/media/K4SlowMoExport$7;->val$next:[I

    aget v3, v4, v3

    int-to-float v3, v3

    const v4, 0x3f666666    # 0.9f

    mul-float/2addr v3, v4

    iget-object v4, v0, Lcom/k4/media/K4SlowMoExport$7;->val$jobs:Ljava/util/ArrayList;

    invoke-virtual {v4}, Ljava/util/ArrayList;->size()I

    move-result v4

    int-to-float v4, v4

    div-float/2addr v3, v4

    const v4, 0x3dcccccd    # 0.1f

    add-float/2addr v3, v4

    invoke-static {v2, v3}, Lcom/k4/media/K4SlowMoExport;->-$$Nest$fputmWork(Lcom/k4/media/K4SlowMoExport;F)V

    goto/16 :goto_4

    :cond_c8
    new-instance v0, Ljava/lang/IllegalStateException;

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v4, "FILM failed at frames "

    invoke-direct {v1, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    aget v3, v2, v3

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v3, "-"

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    aget v2, v2, v5

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0

    :cond_e8
    iget v2, v0, Lcom/k4/media/K4SlowMoExport$7;->val$n:I

    sub-int/2addr v2, v5

    if-ne v1, v2, :cond_f9

    iget-object v2, v0, Lcom/k4/media/K4SlowMoExport$7;->this$0:Lcom/k4/media/K4SlowMoExport;

    iget-object v3, v0, Lcom/k4/media/K4SlowMoExport$7;->val$mem:Ljava/nio/ByteBuffer;

    rem-int/lit8 v1, v1, 0x4

    iget v0, v0, Lcom/k4/media/K4SlowMoExport$7;->val$fsz:I

    mul-int/2addr v1, v0

    invoke-static {v2, v3, v1}, Lcom/k4/media/K4SlowMoExport;->-$$Nest$mencodeFrame(Lcom/k4/media/K4SlowMoExport;Ljava/nio/ByteBuffer;I)V

    :cond_f9
    return-void
.end method
