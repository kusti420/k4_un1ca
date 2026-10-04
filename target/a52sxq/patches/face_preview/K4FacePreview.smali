.class public final Lcom/k4/face/K4FacePreview;
.super Ljava/lang/Object;
.source "K4FacePreview.java"


# static fields
.field private static final TAG:Ljava/lang/String; = "K4FacePreview"

.field private static sFrames:I

.field private static sSurface:Landroid/view/Surface;

.field private static sTexture:Landroid/graphics/SurfaceTexture;


# direct methods
.method private constructor <init>()V
    .registers 1

    .line 33
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static release()V
    .registers 1

    .line 109
    :try_start_0
    sget-object v0, Lcom/k4/face/K4FacePreview;->sSurface:Landroid/view/Surface;

    if-eqz v0, :cond_7

    invoke-virtual {v0}, Landroid/view/Surface;->release()V
    :try_end_7
    .catchall {:try_start_0 .. :try_end_7} :catchall_7

    :catchall_7
    :cond_7
    const/4 v0, 0x0

    .line 111
    sput-object v0, Lcom/k4/face/K4FacePreview;->sSurface:Landroid/view/Surface;

    .line 112
    sput-object v0, Lcom/k4/face/K4FacePreview;->sTexture:Landroid/graphics/SurfaceTexture;

    return-void
.end method

.method public static render(Landroid/view/View;Ljava/lang/Object;[BIIIILandroid/os/Bundle;)V
    .registers 25

    move-object/from16 v0, p0

    move-object/from16 v1, p2

    move/from16 v3, p3

    move/from16 v4, p4

    move/from16 v6, p5

    move-object/from16 v2, p7

    .line 38
    const-string v7, "K4FacePreview"

    .line 0
    const-string v5, "bundle has no memoryfile_descriptor: "

    const-string v8, "onImageProcessed #"

    .line 38
    :try_start_12
    sget v9, Lcom/k4/face/K4FacePreview;->sFrames:I
    :try_end_14
    .catchall {:try_start_12 .. :try_end_14} :catchall_2cc

    const-string v10, "x"

    const-string v11, "null"

    const/4 v12, 0x3

    if-lt v9, v12, :cond_23

    :try_start_1b
    rem-int/lit8 v13, v9, 0x1e

    if-nez v13, :cond_20

    goto :goto_23

    :cond_20
    move/from16 p1, v12

    goto :goto_90

    .line 39
    :cond_23
    :goto_23
    invoke-static {v0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v13

    if-nez v1, :cond_2b

    move-object v14, v11

    goto :goto_30

    :cond_2b
    array-length v14, v1

    invoke-static {v14}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v14

    :goto_30
    invoke-static {v14}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v14

    invoke-static {v2}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v15

    move/from16 p1, v12

    new-instance v12, Ljava/lang/StringBuilder;

    invoke-direct {v12, v8}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v12, v9}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v8

    const-string v9, " view="

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8, v13}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    const-string v9, " data="

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8, v14}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    const-string v9, " "

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v8

    const-string v9, " ori="

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8, v6}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v8

    const-string v9, " fmt="

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    move/from16 v9, p6

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v8

    const-string v9, " extras="

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8, v15}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v8

    invoke-static {v7, v8}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 42
    :goto_90
    sget v8, Lcom/k4/face/K4FacePreview;->sFrames:I

    add-int/lit8 v8, v8, 0x1

    sput v8, Lcom/k4/face/K4FacePreview;->sFrames:I

    .line 43
    instance-of v8, v0, Landroid/view/TextureView;

    if-eqz v8, :cond_2c6

    if-lez v3, :cond_2c6

    if-gtz v4, :cond_a0

    goto/16 :goto_2c6

    :cond_a0
    mul-int v8, v3, v4

    mul-int/lit8 v8, v8, 0x3

    .line 44
    div-int/lit8 v9, v8, 0x2
    :try_end_a6
    .catchall {:try_start_1b .. :try_end_a6} :catchall_2cc

    .line 47
    const-string v12, ")"

    if-eqz v1, :cond_ad

    :try_start_aa
    array-length v13, v1

    if-ge v13, v9, :cond_15d

    :cond_ad
    if-eqz v2, :cond_15d

    .line 48
    const-string v13, "memoryfile_descriptor"

    invoke-virtual {v2, v13}, Landroid/os/Bundle;->getParcelable(Ljava/lang/String;)Landroid/os/Parcelable;

    move-result-object v13

    check-cast v13, Landroid/os/ParcelFileDescriptor;

    if-eqz v13, :cond_140

    .line 50
    new-array v2, v9, [B
    :try_end_bb
    .catchall {:try_start_aa .. :try_end_bb} :catchall_2cc

    .line 51
    :try_start_bb
    new-instance v5, Ljava/io/FileInputStream;

    invoke-virtual {v13}, Landroid/os/ParcelFileDescriptor;->getFileDescriptor()Ljava/io/FileDescriptor;

    move-result-object v14

    invoke-direct {v5, v14}, Ljava/io/FileInputStream;-><init>(Ljava/io/FileDescriptor;)V
    :try_end_c4
    .catchall {:try_start_bb .. :try_end_c4} :catchall_13b

    .line 53
    :try_start_c4
    invoke-static {v2}, Ljava/nio/ByteBuffer;->wrap([B)Ljava/nio/ByteBuffer;

    move-result-object v14

    const-wide/16 v15, 0x0

    move-wide v0, v15

    .line 55
    :goto_cb
    invoke-virtual {v14}, Ljava/nio/ByteBuffer;->hasRemaining()Z

    move-result v15

    if-eqz v15, :cond_e5

    .line 56
    invoke-virtual {v5}, Ljava/io/FileInputStream;->getChannel()Ljava/nio/channels/FileChannel;

    move-result-object v15

    invoke-virtual {v15, v14, v0, v1}, Ljava/nio/channels/FileChannel;->read(Ljava/nio/ByteBuffer;J)I

    move-result v15

    if-gtz v15, :cond_dc

    goto :goto_e5

    :cond_dc
    move-object/from16 v16, v2

    int-to-long v2, v15

    add-long/2addr v0, v2

    move/from16 v3, p3

    move-object/from16 v2, v16

    goto :goto_cb

    :cond_e5
    :goto_e5
    move-object/from16 v16, v2

    .line 60
    sget v2, Lcom/k4/face/K4FacePreview;->sFrames:I

    move/from16 v3, p1

    if-gt v2, v3, :cond_11f

    invoke-virtual {v13}, Landroid/os/ParcelFileDescriptor;->getStatSize()J

    move-result-wide v2

    new-instance v14, Ljava/lang/StringBuilder;

    invoke-direct {v14}, Ljava/lang/StringBuilder;-><init>()V

    const-string v15, "read "

    invoke-virtual {v14, v15}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v14

    invoke-virtual {v14, v0, v1}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v14

    const-string v15, " of "

    invoke-virtual {v14, v15}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v14

    invoke-virtual {v14, v9}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v14

    const-string v15, " bytes from memory file (stat size "

    invoke-virtual {v14, v15}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v14

    invoke-virtual {v14, v2, v3}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v12}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v7, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_11f
    .catchall {:try_start_c4 .. :try_end_11f} :catchall_130

    :cond_11f
    int-to-long v2, v9

    cmp-long v0, v0, v2

    if-ltz v0, :cond_125

    goto :goto_127

    :cond_125
    move-object/from16 v16, p2

    .line 62
    :goto_127
    :try_start_127
    invoke-virtual {v5}, Ljava/io/FileInputStream;->close()V
    :try_end_12a
    .catchall {:try_start_127 .. :try_end_12a} :catchall_13b

    .line 63
    :try_start_12a
    invoke-virtual {v13}, Landroid/os/ParcelFileDescriptor;->close()V
    :try_end_12d
    .catch Ljava/lang/Exception; {:try_start_12a .. :try_end_12d} :catch_12d
    .catchall {:try_start_12a .. :try_end_12d} :catchall_2cc

    :catch_12d
    move-object/from16 v1, v16

    goto :goto_15f

    :catchall_130
    move-exception v0

    move-object v1, v0

    .line 51
    :try_start_132
    invoke-virtual {v5}, Ljava/io/FileInputStream;->close()V
    :try_end_135
    .catchall {:try_start_132 .. :try_end_135} :catchall_136

    goto :goto_13a

    :catchall_136
    move-exception v0

    :try_start_137
    invoke-virtual {v1, v0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :goto_13a
    throw v1
    :try_end_13b
    .catchall {:try_start_137 .. :try_end_13b} :catchall_13b

    :catchall_13b
    move-exception v0

    .line 63
    :try_start_13c
    invoke-virtual {v13}, Landroid/os/ParcelFileDescriptor;->close()V
    :try_end_13f
    .catch Ljava/lang/Exception; {:try_start_13c .. :try_end_13f} :catch_13f
    .catchall {:try_start_13c .. :try_end_13f} :catchall_2cc

    .line 64
    :catch_13f
    :try_start_13f
    throw v0

    .line 65
    :cond_140
    sget v0, Lcom/k4/face/K4FacePreview;->sFrames:I

    const/4 v3, 0x3

    if-gt v0, v3, :cond_15d

    .line 66
    invoke-virtual {v2}, Landroid/os/Bundle;->keySet()Ljava/util/Set;

    move-result-object v0

    invoke-static {v0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1, v5}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v7, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_15d
    move-object/from16 v1, p2

    :goto_15f
    if-eqz v1, :cond_29d

    .line 69
    array-length v0, v1

    div-int/lit8 v8, v8, 0x2

    if-ge v0, v8, :cond_168

    goto/16 :goto_29d

    .line 70
    :cond_168
    move-object/from16 v0, p0

    check-cast v0, Landroid/view/TextureView;

    invoke-virtual {v0}, Landroid/view/TextureView;->getSurfaceTexture()Landroid/graphics/SurfaceTexture;

    move-result-object v0

    if-nez v0, :cond_196

    .line 71
    move-object/from16 v0, p0

    check-cast v0, Landroid/view/TextureView;

    invoke-virtual {v0}, Landroid/view/TextureView;->isAvailable()Z

    move-result v0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "TextureView has no SurfaceTexture yet (available="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v12}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v7, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    goto/16 :goto_2d2

    .line 72
    :cond_196
    sget-object v2, Lcom/k4/face/K4FacePreview;->sTexture:Landroid/graphics/SurfaceTexture;

    if-eq v0, v2, :cond_1aa

    .line 73
    sget-object v2, Lcom/k4/face/K4FacePreview;->sSurface:Landroid/view/Surface;

    if-eqz v2, :cond_1a1

    invoke-virtual {v2}, Landroid/view/Surface;->release()V

    .line 74
    :cond_1a1
    sput-object v0, Lcom/k4/face/K4FacePreview;->sTexture:Landroid/graphics/SurfaceTexture;

    .line 75
    new-instance v2, Landroid/view/Surface;

    invoke-direct {v2, v0}, Landroid/view/Surface;-><init>(Landroid/graphics/SurfaceTexture;)V

    sput-object v2, Lcom/k4/face/K4FacePreview;->sSurface:Landroid/view/Surface;

    .line 77
    :cond_1aa
    new-instance v8, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v8}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 78
    new-instance v0, Landroid/graphics/YuvImage;

    const/16 v2, 0x11

    const/4 v5, 0x0

    move/from16 v3, p3

    invoke-direct/range {v0 .. v5}, Landroid/graphics/YuvImage;-><init>([BIII[I)V

    new-instance v1, Landroid/graphics/Rect;

    const/4 v2, 0x0

    invoke-direct {v1, v2, v2, v3, v4}, Landroid/graphics/Rect;-><init>(IIII)V

    const/16 v3, 0x55

    .line 79
    invoke-virtual {v0, v1, v3, v8}, Landroid/graphics/YuvImage;->compressToJpeg(Landroid/graphics/Rect;ILjava/io/OutputStream;)Z

    .line 80
    invoke-virtual {v8}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v0

    invoke-virtual {v8}, Ljava/io/ByteArrayOutputStream;->size()I

    move-result v1

    invoke-static {v0, v2, v1}, Landroid/graphics/BitmapFactory;->decodeByteArray([BII)Landroid/graphics/Bitmap;

    move-result-object v0

    if-nez v0, :cond_1d4

    goto/16 :goto_2d2

    .line 82
    :cond_1d4
    sget-object v1, Lcom/k4/face/K4FacePreview;->sSurface:Landroid/view/Surface;

    const/4 v2, 0x0

    invoke-virtual {v1, v2}, Landroid/view/Surface;->lockCanvas(Landroid/graphics/Rect;)Landroid/graphics/Canvas;

    move-result-object v1

    if-nez v1, :cond_1e4

    .line 83
    const-string v0, "lockCanvas returned null"

    invoke-static {v7, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_1e2
    .catchall {:try_start_13f .. :try_end_1e2} :catchall_2cc

    goto/16 :goto_2d2

    :cond_1e4
    const/high16 v3, -0x1000000

    .line 85
    :try_start_1e6
    invoke-virtual {v1, v3}, Landroid/graphics/Canvas;->drawColor(I)V

    .line 87
    new-instance v3, Landroid/graphics/Matrix;

    invoke-direct {v3}, Landroid/graphics/Matrix;-><init>()V

    int-to-float v4, v6

    .line 88
    invoke-virtual {v0}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v5

    int-to-float v5, v5

    const/high16 v6, 0x40000000    # 2.0f

    div-float/2addr v5, v6

    invoke-virtual {v0}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v8

    int-to-float v8, v8

    div-float/2addr v8, v6

    invoke-virtual {v3, v4, v5, v8}, Landroid/graphics/Matrix;->postRotate(FFF)Z

    .line 89
    new-instance v4, Landroid/graphics/RectF;

    invoke-virtual {v0}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v5

    int-to-float v5, v5

    invoke-virtual {v0}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v8

    int-to-float v8, v8

    const/4 v9, 0x0

    invoke-direct {v4, v9, v9, v5, v8}, Landroid/graphics/RectF;-><init>(FFFF)V

    .line 90
    invoke-virtual {v3, v4}, Landroid/graphics/Matrix;->mapRect(Landroid/graphics/RectF;)Z

    .line 91
    iget v5, v4, Landroid/graphics/RectF;->left:F

    neg-float v5, v5

    iget v8, v4, Landroid/graphics/RectF;->top:F

    neg-float v8, v8

    invoke-virtual {v3, v5, v8}, Landroid/graphics/Matrix;->postTranslate(FF)Z

    .line 92
    invoke-virtual {v4}, Landroid/graphics/RectF;->width()F

    move-result v5

    invoke-virtual {v4}, Landroid/graphics/RectF;->height()F

    move-result v4

    .line 93
    invoke-virtual {v1}, Landroid/graphics/Canvas;->getWidth()I

    move-result v8

    int-to-float v8, v8

    div-float/2addr v8, v5

    invoke-virtual {v1}, Landroid/graphics/Canvas;->getHeight()I

    move-result v9

    int-to-float v9, v9

    div-float/2addr v9, v4

    invoke-static {v8, v9}, Ljava/lang/Math;->max(FF)F

    move-result v8

    neg-float v9, v8

    .line 94
    invoke-virtual {v3, v9, v8}, Landroid/graphics/Matrix;->postScale(FF)Z

    .line 95
    invoke-virtual {v1}, Landroid/graphics/Canvas;->getWidth()I

    move-result v9

    int-to-float v9, v9

    invoke-virtual {v1}, Landroid/graphics/Canvas;->getWidth()I

    move-result v11

    int-to-float v11, v11

    mul-float/2addr v5, v8

    sub-float/2addr v11, v5

    div-float/2addr v11, v6

    sub-float/2addr v9, v11

    invoke-virtual {v1}, Landroid/graphics/Canvas;->getHeight()I

    move-result v5

    int-to-float v5, v5

    mul-float/2addr v4, v8

    sub-float/2addr v5, v4

    div-float/2addr v5, v6

    invoke-virtual {v3, v9, v5}, Landroid/graphics/Matrix;->postTranslate(FF)Z

    .line 96
    invoke-virtual {v1, v0, v3, v2}, Landroid/graphics/Canvas;->drawBitmap(Landroid/graphics/Bitmap;Landroid/graphics/Matrix;Landroid/graphics/Paint;)V
    :try_end_254
    .catchall {:try_start_1e6 .. :try_end_254} :catchall_296

    .line 98
    :try_start_254
    sget-object v2, Lcom/k4/face/K4FacePreview;->sSurface:Landroid/view/Surface;

    invoke-virtual {v2, v1}, Landroid/view/Surface;->unlockCanvasAndPost(Landroid/graphics/Canvas;)V

    .line 100
    invoke-virtual {v0}, Landroid/graphics/Bitmap;->recycle()V

    .line 101
    sget v0, Lcom/k4/face/K4FacePreview;->sFrames:I

    const/4 v3, 0x3

    if-le v0, v3, :cond_265

    rem-int/lit8 v2, v0, 0x1e

    if-nez v2, :cond_2d2

    :cond_265
    invoke-virtual {v1}, Landroid/graphics/Canvas;->getWidth()I

    move-result v2

    invoke-virtual {v1}, Landroid/graphics/Canvas;->getHeight()I

    move-result v1

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "drew frame "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v3, " canvas="

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v7, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_2d2

    :catchall_296
    move-exception v0

    .line 98
    sget-object v2, Lcom/k4/face/K4FacePreview;->sSurface:Landroid/view/Surface;

    invoke-virtual {v2, v1}, Landroid/view/Surface;->unlockCanvasAndPost(Landroid/graphics/Canvas;)V

    .line 99
    throw v0

    :cond_29d
    :goto_29d
    if-nez v1, :cond_2a0

    goto :goto_2a5

    .line 69
    :cond_2a0
    array-length v0, v1

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v11

    :goto_2a5
    invoke-static {v11}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "no frame data ("

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " bytes)"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v7, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_2d2

    .line 43
    :cond_2c6
    :goto_2c6
    const-string v0, "bad view/size"

    invoke-static {v7, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_2cb
    .catchall {:try_start_254 .. :try_end_2cb} :catchall_2cc

    return-void

    :catchall_2cc
    move-exception v0

    .line 103
    const-string v1, "render failed"

    invoke-static {v7, v1, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_2d2
    :goto_2d2
    return-void
.end method
