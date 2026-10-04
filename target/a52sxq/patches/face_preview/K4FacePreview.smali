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

    .line 99
    :try_start_0
    sget-object v0, Lcom/k4/face/K4FacePreview;->sSurface:Landroid/view/Surface;

    if-eqz v0, :cond_7

    invoke-virtual {v0}, Landroid/view/Surface;->release()V
    :try_end_7
    .catchall {:try_start_0 .. :try_end_7} :catchall_7

    :catchall_7
    :cond_7
    const/4 v0, 0x0

    .line 101
    sput-object v0, Lcom/k4/face/K4FacePreview;->sSurface:Landroid/view/Surface;

    .line 102
    sput-object v0, Lcom/k4/face/K4FacePreview;->sTexture:Landroid/graphics/SurfaceTexture;

    return-void
.end method

.method public static render(Landroid/view/View;Ljava/lang/Object;[BIIIILandroid/os/Bundle;)V
    .registers 16

    .line 38
    const-string p1, "x"

    const-string v1, "K4FacePreview"

    :try_start_4
    instance-of v0, p0, Landroid/view/TextureView;

    if-eqz v0, :cond_19e

    if-lez p3, :cond_19e

    if-gtz p4, :cond_e

    goto/16 :goto_19e

    :cond_e
    const/4 v0, 0x0

    if-nez p2, :cond_56

    if-eqz p7, :cond_56

    .line 40
    const-string v2, "memoryfile_descriptor"

    invoke-virtual {p7, v2}, Landroid/os/Bundle;->getParcelable(Ljava/lang/String;)Landroid/os/Parcelable;

    move-result-object p7

    check-cast p7, Landroid/os/ParcelFileDescriptor;

    if-eqz p7, :cond_56

    mul-int p2, p3, p4

    mul-int/lit8 p2, p2, 0x3

    .line 42
    div-int/lit8 p2, p2, 0x2

    .line 43
    new-array v2, p2, [B
    :try_end_25
    .catchall {:try_start_4 .. :try_end_25} :catchall_197

    .line 44
    :try_start_25
    new-instance v3, Ljava/io/FileInputStream;

    invoke-virtual {p7}, Landroid/os/ParcelFileDescriptor;->getFileDescriptor()Ljava/io/FileDescriptor;

    move-result-object v4

    invoke-direct {v3, v4}, Ljava/io/FileInputStream;-><init>(Ljava/io/FileDescriptor;)V
    :try_end_2e
    .catchall {:try_start_25 .. :try_end_2e} :catchall_50

    move v4, v0

    :goto_2f
    if-ge v4, p2, :cond_48

    sub-int v5, p2, v4

    .line 47
    :try_start_33
    invoke-virtual {v3, v2, v4, v5}, Ljava/io/FileInputStream;->read([BII)I

    move-result v5
    :try_end_37
    .catchall {:try_start_33 .. :try_end_37} :catchall_3c

    if-gtz v5, :cond_3a

    goto :goto_48

    :cond_3a
    add-int/2addr v4, v5

    goto :goto_2f

    :catchall_3c
    move-exception v0

    move-object p0, v0

    .line 44
    :try_start_3e
    invoke-virtual {v3}, Ljava/io/FileInputStream;->close()V
    :try_end_41
    .catchall {:try_start_3e .. :try_end_41} :catchall_42

    goto :goto_47

    :catchall_42
    move-exception v0

    move-object p1, v0

    :try_start_44
    invoke-virtual {p0, p1}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :goto_47
    throw p0

    .line 51
    :cond_48
    :goto_48
    invoke-virtual {v3}, Ljava/io/FileInputStream;->close()V
    :try_end_4b
    .catchall {:try_start_44 .. :try_end_4b} :catchall_50

    .line 52
    :try_start_4b
    invoke-virtual {p7}, Landroid/os/ParcelFileDescriptor;->close()V
    :try_end_4e
    .catch Ljava/lang/Exception; {:try_start_4b .. :try_end_4e} :catch_4e
    .catchall {:try_start_4b .. :try_end_4e} :catchall_197

    :catch_4e
    move-object v3, v2

    goto :goto_57

    :catchall_50
    move-exception v0

    move-object p0, v0

    :try_start_52
    invoke-virtual {p7}, Landroid/os/ParcelFileDescriptor;->close()V
    :try_end_55
    .catch Ljava/lang/Exception; {:try_start_52 .. :try_end_55} :catch_55
    .catchall {:try_start_52 .. :try_end_55} :catchall_197

    .line 53
    :catch_55
    :try_start_55
    throw p0

    :cond_56
    move-object v3, p2

    :goto_57
    if-eqz v3, :cond_19e

    .line 56
    array-length p2, v3

    mul-int p7, p3, p4

    mul-int/lit8 p7, p7, 0x3

    div-int/lit8 p7, p7, 0x2

    if-ge p2, p7, :cond_64

    goto/16 :goto_19e

    .line 57
    :cond_64
    check-cast p0, Landroid/view/TextureView;

    invoke-virtual {p0}, Landroid/view/TextureView;->getSurfaceTexture()Landroid/graphics/SurfaceTexture;

    move-result-object p0

    if-nez p0, :cond_6e

    goto/16 :goto_19e

    .line 59
    :cond_6e
    sget-object p2, Lcom/k4/face/K4FacePreview;->sTexture:Landroid/graphics/SurfaceTexture;

    if-eq p0, p2, :cond_82

    .line 60
    sget-object p2, Lcom/k4/face/K4FacePreview;->sSurface:Landroid/view/Surface;

    if-eqz p2, :cond_79

    invoke-virtual {p2}, Landroid/view/Surface;->release()V

    .line 61
    :cond_79
    sput-object p0, Lcom/k4/face/K4FacePreview;->sTexture:Landroid/graphics/SurfaceTexture;

    .line 62
    new-instance p2, Landroid/view/Surface;

    invoke-direct {p2, p0}, Landroid/view/Surface;-><init>(Landroid/graphics/SurfaceTexture;)V

    sput-object p2, Lcom/k4/face/K4FacePreview;->sSurface:Landroid/view/Surface;

    .line 64
    :cond_82
    new-instance p0, Ljava/io/ByteArrayOutputStream;

    invoke-direct {p0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 65
    new-instance v2, Landroid/graphics/YuvImage;

    const/16 v4, 0x11

    const/4 v7, 0x0

    move v5, p3

    move v6, p4

    invoke-direct/range {v2 .. v7}, Landroid/graphics/YuvImage;-><init>([BIII[I)V

    new-instance p2, Landroid/graphics/Rect;

    invoke-direct {p2, v0, v0, v5, v6}, Landroid/graphics/Rect;-><init>(IIII)V

    const/16 p3, 0x55

    .line 66
    invoke-virtual {v2, p2, p3, p0}, Landroid/graphics/YuvImage;->compressToJpeg(Landroid/graphics/Rect;ILjava/io/OutputStream;)Z

    .line 67
    invoke-virtual {p0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object p2

    invoke-virtual {p0}, Ljava/io/ByteArrayOutputStream;->size()I

    move-result p0

    invoke-static {p2, v0, p0}, Landroid/graphics/BitmapFactory;->decodeByteArray([BII)Landroid/graphics/Bitmap;

    move-result-object p0

    if-nez p0, :cond_ab

    goto/16 :goto_19e

    .line 69
    :cond_ab
    sget-object p2, Lcom/k4/face/K4FacePreview;->sSurface:Landroid/view/Surface;

    const/4 p3, 0x0

    invoke-virtual {p2, p3}, Landroid/view/Surface;->lockCanvas(Landroid/graphics/Rect;)Landroid/graphics/Canvas;

    move-result-object p2
    :try_end_b2
    .catchall {:try_start_55 .. :try_end_b2} :catchall_197

    if-nez p2, :cond_b6

    goto/16 :goto_19e

    :cond_b6
    const/high16 p4, -0x1000000

    .line 72
    :try_start_b8
    invoke-virtual {p2, p4}, Landroid/graphics/Canvas;->drawColor(I)V

    .line 74
    new-instance p4, Landroid/graphics/Matrix;

    invoke-direct {p4}, Landroid/graphics/Matrix;-><init>()V

    int-to-float p7, p5

    .line 75
    invoke-virtual {p0}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v0

    int-to-float v0, v0

    const/high16 v2, 0x40000000    # 2.0f

    div-float/2addr v0, v2

    invoke-virtual {p0}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v3

    int-to-float v3, v3

    div-float/2addr v3, v2

    invoke-virtual {p4, p7, v0, v3}, Landroid/graphics/Matrix;->postRotate(FFF)Z

    .line 76
    new-instance p7, Landroid/graphics/RectF;

    invoke-virtual {p0}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v0

    int-to-float v0, v0

    invoke-virtual {p0}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v3

    int-to-float v3, v3

    const/4 v4, 0x0

    invoke-direct {p7, v4, v4, v0, v3}, Landroid/graphics/RectF;-><init>(FFFF)V

    .line 77
    invoke-virtual {p4, p7}, Landroid/graphics/Matrix;->mapRect(Landroid/graphics/RectF;)Z

    .line 78
    iget v0, p7, Landroid/graphics/RectF;->left:F

    neg-float v0, v0

    iget v3, p7, Landroid/graphics/RectF;->top:F

    neg-float v3, v3

    invoke-virtual {p4, v0, v3}, Landroid/graphics/Matrix;->postTranslate(FF)Z

    .line 79
    invoke-virtual {p7}, Landroid/graphics/RectF;->width()F

    move-result v0

    invoke-virtual {p7}, Landroid/graphics/RectF;->height()F

    move-result p7

    .line 80
    invoke-virtual {p2}, Landroid/graphics/Canvas;->getWidth()I

    move-result v3

    int-to-float v3, v3

    div-float/2addr v3, v0

    invoke-virtual {p2}, Landroid/graphics/Canvas;->getHeight()I

    move-result v4

    int-to-float v4, v4

    div-float/2addr v4, p7

    invoke-static {v3, v4}, Ljava/lang/Math;->max(FF)F

    move-result v3

    neg-float v4, v3

    .line 81
    invoke-virtual {p4, v4, v3}, Landroid/graphics/Matrix;->postScale(FF)Z

    .line 82
    invoke-virtual {p2}, Landroid/graphics/Canvas;->getWidth()I

    move-result v4

    int-to-float v4, v4

    invoke-virtual {p2}, Landroid/graphics/Canvas;->getWidth()I

    move-result v7

    int-to-float v7, v7

    mul-float/2addr v0, v3

    sub-float/2addr v7, v0

    div-float/2addr v7, v2

    sub-float/2addr v4, v7

    invoke-virtual {p2}, Landroid/graphics/Canvas;->getHeight()I

    move-result v0

    int-to-float v0, v0

    mul-float/2addr p7, v3

    sub-float/2addr v0, p7

    div-float/2addr v0, v2

    invoke-virtual {p4, v4, v0}, Landroid/graphics/Matrix;->postTranslate(FF)Z

    .line 83
    invoke-virtual {p2, p0, p4, p3}, Landroid/graphics/Canvas;->drawBitmap(Landroid/graphics/Bitmap;Landroid/graphics/Matrix;Landroid/graphics/Paint;)V
    :try_end_126
    .catchall {:try_start_b8 .. :try_end_126} :catchall_18f

    .line 85
    :try_start_126
    sget-object p3, Lcom/k4/face/K4FacePreview;->sSurface:Landroid/view/Surface;

    invoke-virtual {p3, p2}, Landroid/view/Surface;->unlockCanvasAndPost(Landroid/graphics/Canvas;)V

    .line 87
    invoke-virtual {p0}, Landroid/graphics/Bitmap;->recycle()V

    .line 88
    sget p0, Lcom/k4/face/K4FacePreview;->sFrames:I

    add-int/lit8 p3, p0, 0x1

    sput p3, Lcom/k4/face/K4FacePreview;->sFrames:I

    rem-int/lit8 p0, p0, 0x1e

    if-nez p0, :cond_19e

    .line 90
    invoke-virtual {p2}, Landroid/graphics/Canvas;->getWidth()I

    move-result p0

    invoke-virtual {p2}, Landroid/graphics/Canvas;->getHeight()I

    move-result p2

    new-instance p4, Ljava/lang/StringBuilder;

    invoke-direct {p4}, Ljava/lang/StringBuilder;-><init>()V

    const-string p7, "frame "

    invoke-virtual {p4, p7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p4

    invoke-virtual {p4, p3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p3

    const-string p4, " "

    invoke-virtual {p3, p4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p3

    invoke-virtual {p3, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p3

    invoke-virtual {p3, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p3

    invoke-virtual {p3, v6}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p3

    const-string p4, " fmt="

    invoke-virtual {p3, p4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p3

    invoke-virtual {p3, p6}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p3

    const-string p4, " ori="

    invoke-virtual {p3, p4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p3

    invoke-virtual {p3, p5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p3

    const-string p4, " canvas="

    invoke-virtual {p3, p4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p3

    invoke-virtual {p3, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    .line 89
    invoke-static {v1, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_19e

    :catchall_18f
    move-exception v0

    move-object p0, v0

    .line 85
    sget-object p1, Lcom/k4/face/K4FacePreview;->sSurface:Landroid/view/Surface;

    invoke-virtual {p1, p2}, Landroid/view/Surface;->unlockCanvasAndPost(Landroid/graphics/Canvas;)V

    .line 86
    throw p0
    :try_end_197
    .catchall {:try_start_126 .. :try_end_197} :catchall_197

    :catchall_197
    move-exception v0

    move-object p0, v0

    .line 93
    const-string p1, "render failed"

    invoke-static {v1, p1, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_19e
    :goto_19e
    return-void
.end method
