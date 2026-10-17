.class public final Lcom/k4/dressroom/EditXf;
.super Ljava/lang/Object;
.source "EditXf.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/k4/dressroom/EditXf$Guide;
    }
.end annotation


# static fields
.field static final CROP:Ljava/lang/String; = "com.samsung.android.app.dressroom.presentation.preview.widget.CropImageView"

.field static final EXPANDABLE:Ljava/lang/String; = "fj.j"

.field static final MAX_DEG:F = 45.0f

.field static final MIN_S:F = 0.5f

.field static final ROT_SLOP_DEG:F = 6.0f

.field static final SNAP_DEG:F = 2.0f

.field static final TAG:Ljava/lang/String; = "K4HomeClock"

.field static volatile deg:F

.field static volatile s:F

.field private static sBaked:Ljava/lang/ref/WeakReference;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/lang/ref/WeakReference<",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation
.end field

.field private static sBakedBg:Landroid/graphics/Bitmap;

.field private static sCopy:Landroid/view/MotionEvent;

.field private static sCount:I

.field private static sFill:Landroid/graphics/drawable/Drawable;

.field private static sFillFor:Landroid/graphics/Bitmap;

.field private static sFx:F

.field private static sFy:F

.field private static sGuide:Lcom/k4/dressroom/EditXf$Guide;

.field private static final sObjBaked:Ljava/lang/ThreadLocal;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/lang/ThreadLocal<",
            "Ljava/lang/Boolean;",
            ">;"
        }
    .end annotation
.end field

.field private static sRotBase:F

.field private static sRotStart:F

.field private static sRotating:Z

.field static sSemIndex:Ljava/lang/reflect/Method;

.field private static sView:Ljava/lang/ref/WeakReference;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/lang/ref/WeakReference<",
            "Landroid/view/View;",
            ">;"
        }
    .end annotation
.end field

.field static volatile tx:F

.field static volatile ty:F


# direct methods
.method static constructor <clinit>()V
    .locals 2

    new-instance v0, Ljava/lang/ref/WeakReference;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/dressroom/EditXf;->sView:Ljava/lang/ref/WeakReference;

    const/high16 v0, 0x3f800000    # 1.0f

    sput v0, Lcom/k4/dressroom/EditXf;->s:F

    const/4 v0, 0x0

    sput v0, Lcom/k4/dressroom/EditXf;->deg:F

    sput v0, Lcom/k4/dressroom/EditXf;->tx:F

    sput v0, Lcom/k4/dressroom/EditXf;->ty:F

    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, v1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/dressroom/EditXf;->sBaked:Ljava/lang/ref/WeakReference;

    new-instance v0, Ljava/lang/ThreadLocal;

    invoke-direct {v0}, Ljava/lang/ThreadLocal;-><init>()V

    sput-object v0, Lcom/k4/dressroom/EditXf;->sObjBaked:Ljava/lang/ThreadLocal;

    return-void
.end method

.method private constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method static angle(Landroid/view/MotionEvent;I)F
    .locals 4

    const/4 v0, -0x1

    const/4 v1, 0x0

    move v2, v1

    move v1, v0

    :goto_0
    invoke-virtual {p0}, Landroid/view/MotionEvent;->getPointerCount()I

    move-result v3

    if-ge v2, v3, :cond_2

    if-gez v0, :cond_2

    if-ne v2, p1, :cond_0

    goto :goto_1

    :cond_0
    if-gez v1, :cond_1

    move v1, v2

    goto :goto_1

    :cond_1
    move v0, v2

    :goto_1
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    :cond_2
    if-gez v0, :cond_3

    const/4 p0, 0x0

    return p0

    :cond_3
    invoke-virtual {p0, v0}, Landroid/view/MotionEvent;->getY(I)F

    move-result p1

    invoke-virtual {p0, v1}, Landroid/view/MotionEvent;->getY(I)F

    move-result v2

    sub-float/2addr p1, v2

    float-to-double v2, p1

    invoke-virtual {p0, v0}, Landroid/view/MotionEvent;->getX(I)F

    move-result p1

    invoke-virtual {p0, v1}, Landroid/view/MotionEvent;->getX(I)F

    move-result p0

    sub-float/2addr p1, p0

    float-to-double p0, p1

    invoke-static {v2, v3, p0, p1}, Ljava/lang/Math;->atan2(DD)D

    move-result-wide p0

    invoke-static {p0, p1}, Ljava/lang/Math;->toDegrees(D)D

    move-result-wide p0

    double-to-float p0, p0

    return p0
.end method

.method static apply(Landroid/view/View;Landroid/graphics/Canvas;)V
    .locals 1

    invoke-static {p0}, Lcom/k4/dressroom/EditXf;->mine(Landroid/view/View;)Z

    move-result v0

    if-eqz v0, :cond_0

    invoke-static {}, Lcom/k4/dressroom/EditXf;->identity()Z

    move-result v0

    if-nez v0, :cond_0

    invoke-static {p0}, Lcom/k4/dressroom/EditXf;->matrix(Landroid/view/View;)Landroid/graphics/Matrix;

    move-result-object p0

    invoke-virtual {p1, p0}, Landroid/graphics/Canvas;->concat(Landroid/graphics/Matrix;)V

    :cond_0
    return-void
.end method

.method static atMin(Landroid/view/View;)Z
    .locals 4

    const/4 v0, 0x0

    :try_start_0
    const-string v1, "getDrawableBounds"

    invoke-static {p0, v1}, Lcom/k4/dressroom/EditXf;->call(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/graphics/RectF;

    const-string v2, "getDrawableOriginScaledBounds"

    invoke-static {p0, v2}, Lcom/k4/dressroom/EditXf;->call(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Landroid/graphics/RectF;

    const-string v3, "x"

    invoke-static {p0, v3}, Lcom/k4/dressroom/HomeClock;->field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Float;

    invoke-virtual {p0}, Ljava/lang/Float;->floatValue()F

    move-result p0

    if-eqz v1, :cond_0

    if-eqz v2, :cond_0

    invoke-virtual {v1}, Landroid/graphics/RectF;->width()F

    move-result v1

    invoke-virtual {v2}, Landroid/graphics/RectF;->width()F

    move-result v2
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    mul-float/2addr v2, p0

    const/high16 p0, 0x40000000    # 2.0f

    add-float/2addr v2, p0

    cmpg-float p0, v1, v2

    if-gtz p0, :cond_0

    const/4 p0, 0x1

    return p0

    :catchall_0
    :cond_0
    return v0
.end method

.method public static bakeBackground(Ljava/lang/Object;Landroid/graphics/RectF;Landroid/graphics/RectF;Landroid/graphics/RectF;)V
    .locals 10

    const-string v1, "K4HomeClock"

    new-instance v0, Ljava/lang/ref/WeakReference;

    const/4 v2, 0x0

    invoke-direct {v0, v2}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/dressroom/EditXf;->sBaked:Ljava/lang/ref/WeakReference;

    sget-boolean v0, Lcom/k4/dressroom/HomeClock;->active:Z

    if-eqz v0, :cond_3

    invoke-static {}, Lcom/k4/dressroom/EditXf;->identity()Z

    move-result v0

    if-nez v0, :cond_3

    if-eqz p0, :cond_3

    if-eqz p1, :cond_3

    if-eqz p2, :cond_3

    if-nez p3, :cond_0

    goto/16 :goto_1

    :cond_0
    :try_start_0
    sget-object v0, Lcom/k4/dressroom/EditXf;->sView:Ljava/lang/ref/WeakReference;

    invoke-virtual {v0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/view/View;

    if-eqz v0, :cond_2

    invoke-virtual {v0}, Landroid/view/View;->getWidth()I

    move-result v2

    if-eqz v2, :cond_2

    invoke-virtual {v0}, Landroid/view/View;->getHeight()I

    move-result v2

    if-nez v2, :cond_1

    goto/16 :goto_0

    :cond_1
    invoke-static {p0}, Lcom/k4/dressroom/EditXf;->screen(Ljava/lang/Object;)Landroid/util/Size;

    move-result-object v2

    invoke-virtual {v2}, Landroid/util/Size;->getWidth()I

    move-result v3

    invoke-virtual {v2}, Landroid/util/Size;->getHeight()I

    move-result v2

    sget-object v4, Landroid/graphics/Bitmap$Config;->ARGB_8888:Landroid/graphics/Bitmap$Config;

    invoke-static {v3, v2, v4}, Landroid/graphics/Bitmap;->createBitmap(IILandroid/graphics/Bitmap$Config;)Landroid/graphics/Bitmap;

    move-result-object v4

    new-instance v5, Landroid/graphics/Canvas;

    invoke-direct {v5, v4}, Landroid/graphics/Canvas;-><init>(Landroid/graphics/Bitmap;)V

    int-to-float v6, v3

    invoke-virtual {v0}, Landroid/view/View;->getWidth()I

    move-result v7

    int-to-float v7, v7

    div-float v7, v6, v7

    int-to-float v8, v2

    invoke-virtual {v0}, Landroid/view/View;->getHeight()I

    move-result v9

    int-to-float v9, v9

    div-float v9, v8, v9

    invoke-virtual {v5, v7, v9}, Landroid/graphics/Canvas;->scale(FF)V

    const/4 v7, 0x1

    const/4 v9, 0x0

    invoke-static {v0, v5, v7, v9}, Lcom/k4/dressroom/EditXf;->paint(Landroid/view/View;Landroid/graphics/Canvas;ZZ)V

    const-string v0, "h"

    invoke-static {p0, v0, v4}, Lcom/k4/dressroom/EditXf;->set(Ljava/lang/Object;Ljava/lang/String;Ljava/lang/Object;)V

    const-string v0, "o"

    const/4 v5, 0x0

    invoke-static {v5}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v7

    invoke-static {p0, v0, v7}, Lcom/k4/dressroom/EditXf;->set(Ljava/lang/Object;Ljava/lang/String;Ljava/lang/Object;)V

    const-string v0, "p"

    invoke-static {v5}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v7

    invoke-static {p0, v0, v7}, Lcom/k4/dressroom/EditXf;->set(Ljava/lang/Object;Ljava/lang/String;Ljava/lang/Object;)V

    invoke-virtual {p1, v5, v5, v6, v8}, Landroid/graphics/RectF;->set(FFFF)V

    mul-float p1, v6, v6

    div-float/2addr p1, v8

    sub-float v0, v8, p1

    const/high16 v7, 0x40000000    # 2.0f

    div-float/2addr v0, v7

    add-float/2addr v8, p1

    div-float/2addr v8, v7

    invoke-virtual {p2, v5, v0, v6, v8}, Landroid/graphics/RectF;->set(FFFF)V

    sub-int p1, v2, v3

    int-to-float p1, p1

    div-float/2addr p1, v7

    add-int p2, v2, v3

    int-to-float p2, p2

    div-float/2addr p2, v7

    invoke-virtual {p3, v5, p1, v6, p2}, Landroid/graphics/RectF;->set(FFFF)V

    sput-object v4, Lcom/k4/dressroom/EditXf;->sBakedBg:Landroid/graphics/Bitmap;

    new-instance p1, Ljava/lang/ref/WeakReference;

    invoke-direct {p1, p0}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object p1, Lcom/k4/dressroom/EditXf;->sBaked:Ljava/lang/ref/WeakReference;

    sget-object p0, Ljava/util/Locale;->US:Ljava/util/Locale;

    const-string p1, "home save: background rendered %dx%d (scale %.3f, %.1f deg, offset %.0f,%.0f)"

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v4

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    sget p2, Lcom/k4/dressroom/EditXf;->s:F

    invoke-static {p2}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v6

    invoke-static {}, Lcom/k4/dressroom/EditXf;->shownDeg()F

    move-result p2

    invoke-static {p2}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v7

    sget p2, Lcom/k4/dressroom/EditXf;->tx:F

    invoke-static {p2}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v8

    sget p2, Lcom/k4/dressroom/EditXf;->ty:F

    invoke-static {p2}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v9

    filled-new-array/range {v4 .. v9}, [Ljava/lang/Object;

    move-result-object p2

    invoke-static {p0, p1, p2}, Ljava/lang/String;->format(Ljava/util/Locale;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    invoke-static {v1, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    return-void

    :cond_2
    :goto_0
    const-string p0, "home save: no editor view, picture saved without zoom-out/rotation"

    invoke-static {v1, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return-void

    :catchall_0
    move-exception v0

    move-object p0, v0

    const-string p1, "bakeBackground"

    invoke-static {v1, p1, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_3
    :goto_1
    return-void
.end method

.method public static bakeObject(Ljava/lang/Object;Landroid/graphics/Bitmap;Landroid/graphics/Rect;F)Landroid/graphics/Bitmap;
    .locals 16

    move-object/from16 v0, p0

    move-object/from16 v1, p2

    const-string v2, "K4HomeClock"

    const-string v3, "home save: subject rendered "

    sget-object v4, Lcom/k4/dressroom/EditXf;->sObjBaked:Ljava/lang/ThreadLocal;

    sget-object v5, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    invoke-virtual {v4, v5}, Ljava/lang/ThreadLocal;->set(Ljava/lang/Object;)V

    if-eqz v0, :cond_5

    sget-object v5, Lcom/k4/dressroom/EditXf;->sBaked:Ljava/lang/ref/WeakReference;

    invoke-virtual {v5}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v5

    if-ne v5, v0, :cond_5

    if-nez v1, :cond_0

    goto/16 :goto_1

    :cond_0
    :try_start_0
    sget-object v5, Lcom/k4/dressroom/EditXf;->sView:Ljava/lang/ref/WeakReference;

    invoke-virtual {v5}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Landroid/view/View;

    sget-object v6, Lcom/k4/dressroom/HomeClock;->sSubjectView:Ljava/lang/ref/WeakReference;

    invoke-virtual {v6}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v6

    check-cast v6, Lcom/k4/dressroom/HomeClock$SubjectView;

    if-eqz v5, :cond_4

    if-eqz v6, :cond_4

    iget-object v7, v6, Lcom/k4/dressroom/HomeClock$SubjectView;->subject:Landroid/graphics/drawable/BitmapDrawable;

    if-eqz v7, :cond_4

    iget-object v7, v6, Lcom/k4/dressroom/HomeClock$SubjectView;->crop:Landroid/widget/ImageView;

    if-eq v7, v5, :cond_1

    goto/16 :goto_0

    :cond_1
    invoke-static {v0}, Lcom/k4/dressroom/EditXf;->screen(Ljava/lang/Object;)Landroid/util/Size;

    move-result-object v0

    invoke-virtual {v0}, Landroid/util/Size;->getWidth()I

    move-result v7

    invoke-virtual {v0}, Landroid/util/Size;->getHeight()I

    move-result v0

    move-object v8, v5

    check-cast v8, Landroid/widget/ImageView;

    invoke-static {v5}, Lcom/k4/dressroom/EditXf;->outer(Landroid/view/View;)Landroid/graphics/drawable/Drawable;

    move-result-object v9

    iget-object v6, v6, Lcom/k4/dressroom/HomeClock$SubjectView;->subject:Landroid/graphics/drawable/BitmapDrawable;

    invoke-virtual {v6}, Landroid/graphics/drawable/BitmapDrawable;->getBitmap()Landroid/graphics/Bitmap;

    move-result-object v6

    if-eqz v9, :cond_5

    if-nez v6, :cond_2

    goto/16 :goto_1

    :cond_2
    invoke-virtual {v6}, Landroid/graphics/Bitmap;->getConfig()Landroid/graphics/Bitmap$Config;

    move-result-object v10

    sget-object v11, Landroid/graphics/Bitmap$Config;->HARDWARE:Landroid/graphics/Bitmap$Config;

    const/4 v12, 0x0

    if-ne v10, v11, :cond_3

    sget-object v10, Landroid/graphics/Bitmap$Config;->ARGB_8888:Landroid/graphics/Bitmap$Config;

    invoke-virtual {v6, v10, v12}, Landroid/graphics/Bitmap;->copy(Landroid/graphics/Bitmap$Config;Z)Landroid/graphics/Bitmap;

    move-result-object v6

    :cond_3
    sget-object v10, Landroid/graphics/Bitmap$Config;->ARGB_8888:Landroid/graphics/Bitmap$Config;

    invoke-static {v7, v0, v10}, Landroid/graphics/Bitmap;->createBitmap(IILandroid/graphics/Bitmap$Config;)Landroid/graphics/Bitmap;

    move-result-object v10

    new-instance v11, Landroid/graphics/Canvas;

    invoke-direct {v11, v10}, Landroid/graphics/Canvas;-><init>(Landroid/graphics/Bitmap;)V

    int-to-float v13, v7

    invoke-virtual {v5}, Landroid/view/View;->getWidth()I

    move-result v14

    int-to-float v14, v14

    div-float/2addr v13, v14

    int-to-float v14, v0

    invoke-virtual {v5}, Landroid/view/View;->getHeight()I

    move-result v15

    int-to-float v15, v15

    div-float/2addr v14, v15

    invoke-virtual {v11, v13, v14}, Landroid/graphics/Canvas;->scale(FF)V

    invoke-static {v5}, Lcom/k4/dressroom/EditXf;->matrix(Landroid/view/View;)Landroid/graphics/Matrix;

    move-result-object v13

    invoke-virtual {v11, v13}, Landroid/graphics/Canvas;->concat(Landroid/graphics/Matrix;)V

    invoke-static {v8}, Lcom/k4/dressroom/EditXf;->imageMatrix(Landroid/widget/ImageView;)Landroid/graphics/Matrix;

    move-result-object v8

    invoke-virtual {v11, v8}, Landroid/graphics/Canvas;->concat(Landroid/graphics/Matrix;)V

    new-instance v8, Landroid/graphics/drawable/BitmapDrawable;

    invoke-virtual {v5}, Landroid/view/View;->getResources()Landroid/content/res/Resources;

    move-result-object v5

    invoke-direct {v8, v5, v6}, Landroid/graphics/drawable/BitmapDrawable;-><init>(Landroid/content/res/Resources;Landroid/graphics/Bitmap;)V

    const/4 v5, 0x1

    invoke-virtual {v8, v5}, Landroid/graphics/drawable/BitmapDrawable;->setFilterBitmap(Z)V

    invoke-virtual {v9}, Landroid/graphics/drawable/Drawable;->getBounds()Landroid/graphics/Rect;

    move-result-object v5

    invoke-virtual {v8, v5}, Landroid/graphics/drawable/BitmapDrawable;->setBounds(Landroid/graphics/Rect;)V

    invoke-virtual {v8, v11}, Landroid/graphics/drawable/BitmapDrawable;->draw(Landroid/graphics/Canvas;)V

    invoke-virtual {v1, v12, v12, v7, v0}, Landroid/graphics/Rect;->set(IIII)V

    sget-object v1, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    invoke-virtual {v4, v1}, Ljava/lang/ThreadLocal;->set(Ljava/lang/Object;)V

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, v7}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v3, "x"

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v2, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    return-object v10

    :cond_4
    :goto_0
    const-string v0, "home save: no subject for the rendered picture"

    invoke-static {v2, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return-object p1

    :catchall_0
    move-exception v0

    const-string v1, "bakeObject"

    invoke-static {v2, v1, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_5
    :goto_1
    return-object p1
.end method

.method public static beforeXml(Ljava/lang/Object;Ljava/util/ArrayList;Ljava/lang/Object;)V
    .locals 1

    const-string p1, "K4HomeClock"

    if-eqz p0, :cond_3

    sget-object v0, Lcom/k4/dressroom/EditXf;->sBaked:Ljava/lang/ref/WeakReference;

    invoke-virtual {v0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v0

    if-ne v0, p0, :cond_3

    if-nez p2, :cond_0

    goto :goto_1

    :cond_0
    :try_start_0
    const-string p0, "a"

    invoke-static {p2, p0}, Lcom/k4/dressroom/HomeClock;->field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p0

    instance-of p2, p0, Ljava/util/ArrayList;

    if-eqz p2, :cond_3

    check-cast p0, Ljava/util/ArrayList;

    invoke-virtual {p0}, Ljava/util/ArrayList;->iterator()Ljava/util/Iterator;

    move-result-object p0

    :cond_1
    :goto_0
    invoke-interface {p0}, Ljava/util/Iterator;->hasNext()Z

    move-result p2

    if-eqz p2, :cond_2

    invoke-interface {p0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object p2

    instance-of v0, p2, Landroid/graphics/RectF;

    if-eqz v0, :cond_1

    check-cast p2, Landroid/graphics/RectF;

    invoke-virtual {p2}, Landroid/graphics/RectF;->setEmpty()V

    goto :goto_0

    :cond_2
    const-string p0, "home save: expand offsets cleared"

    invoke-static {p1, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return-void

    :catchall_0
    move-exception p0

    const-string p2, "beforeXml"

    invoke-static {p1, p2, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_3
    :goto_1
    return-void
.end method

.method static bitmapOf(Landroid/graphics/drawable/Drawable;)Landroid/graphics/Bitmap;
    .locals 1

    instance-of v0, p0, Landroid/graphics/drawable/BitmapDrawable;

    if-eqz v0, :cond_0

    check-cast p0, Landroid/graphics/drawable/BitmapDrawable;

    invoke-virtual {p0}, Landroid/graphics/drawable/BitmapDrawable;->getBitmap()Landroid/graphics/Bitmap;

    move-result-object p0

    return-object p0

    :cond_0
    const/4 p0, 0x0

    return-object p0
.end method

.method static bool(Ljava/lang/Object;Ljava/lang/String;)Z
    .locals 0

    :try_start_0
    invoke-static {p0, p1}, Lcom/k4/dressroom/HomeClock;->field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Boolean;

    invoke-virtual {p0}, Ljava/lang/Boolean;->booleanValue()Z

    move-result p0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return p0

    :catchall_0
    const/4 p0, 0x0

    return p0
.end method

.method static call(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;
    .locals 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v0

    const/4 v1, 0x0

    invoke-virtual {v0, p1, v1}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object p1

    invoke-virtual {p1, p0, v1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    return-object p0
.end method

.method static clampT(Landroid/view/View;)V
    .locals 3

    invoke-virtual {p0}, Landroid/view/View;->getWidth()I

    move-result v0

    int-to-float v0, v0

    const/high16 v1, 0x40000000    # 2.0f

    div-float/2addr v0, v1

    invoke-virtual {p0}, Landroid/view/View;->getHeight()I

    move-result p0

    int-to-float p0, p0

    div-float/2addr p0, v1

    neg-float v1, v0

    sget v2, Lcom/k4/dressroom/EditXf;->tx:F

    invoke-static {v0, v2}, Ljava/lang/Math;->min(FF)F

    move-result v0

    invoke-static {v1, v0}, Ljava/lang/Math;->max(FF)F

    move-result v0

    sput v0, Lcom/k4/dressroom/EditXf;->tx:F

    neg-float v0, p0

    sget v1, Lcom/k4/dressroom/EditXf;->ty:F

    invoke-static {p0, v1}, Ljava/lang/Math;->min(FF)F

    move-result p0

    invoke-static {v0, p0}, Ljava/lang/Math;->max(FF)F

    move-result p0

    sput p0, Lcom/k4/dressroom/EditXf;->ty:F

    return-void
.end method

.method public static draw(Landroid/view/View;Landroid/graphics/Canvas;)Z
    .locals 2

    invoke-static {p0}, Lcom/k4/dressroom/EditXf;->mine(Landroid/view/View;)Z

    move-result v0

    const/4 v1, 0x0

    if-eqz v0, :cond_1

    invoke-static {}, Lcom/k4/dressroom/EditXf;->identity()Z

    move-result v0

    if-eqz v0, :cond_0

    goto :goto_0

    :cond_0
    const/4 v0, 0x1

    :try_start_0
    invoke-static {p0, p1, v1, v0}, Lcom/k4/dressroom/EditXf;->paint(Landroid/view/View;Landroid/graphics/Canvas;ZZ)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return v0

    :catchall_0
    move-exception p0

    const-string p1, "K4HomeClock"

    const-string v0, "draw"

    invoke-static {p1, v0, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_1
    :goto_0
    return v1
.end method

.method static guide(Landroid/view/View;Z)V
    .locals 3

    :try_start_0
    invoke-virtual {p0}, Landroid/view/View;->getRootView()Landroid/view/View;

    move-result-object v0

    if-nez v0, :cond_0

    goto :goto_0

    :cond_0
    sget-object v1, Lcom/k4/dressroom/EditXf;->sGuide:Lcom/k4/dressroom/EditXf$Guide;

    if-eqz v1, :cond_1

    iget-object v1, v1, Lcom/k4/dressroom/EditXf$Guide;->root:Ljava/lang/ref/WeakReference;

    invoke-virtual {v1}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v1

    if-eq v1, v0, :cond_2

    :cond_1
    new-instance v1, Lcom/k4/dressroom/EditXf$Guide;

    invoke-direct {v1, p0, v0}, Lcom/k4/dressroom/EditXf$Guide;-><init>(Landroid/view/View;Landroid/view/View;)V

    sput-object v1, Lcom/k4/dressroom/EditXf;->sGuide:Lcom/k4/dressroom/EditXf$Guide;

    invoke-virtual {v0}, Landroid/view/View;->getOverlay()Landroid/view/ViewOverlay;

    move-result-object v1

    sget-object v2, Lcom/k4/dressroom/EditXf;->sGuide:Lcom/k4/dressroom/EditXf$Guide;

    invoke-virtual {v1, v2}, Landroid/view/ViewOverlay;->add(Landroid/graphics/drawable/Drawable;)V

    :cond_2
    sget-object v1, Lcom/k4/dressroom/EditXf;->sGuide:Lcom/k4/dressroom/EditXf$Guide;

    new-instance v2, Ljava/lang/ref/WeakReference;

    invoke-direct {v2, p0}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    iput-object v2, v1, Lcom/k4/dressroom/EditXf$Guide;->crop:Ljava/lang/ref/WeakReference;

    sget-object p0, Lcom/k4/dressroom/EditXf;->sGuide:Lcom/k4/dressroom/EditXf$Guide;

    invoke-virtual {v0}, Landroid/view/View;->getWidth()I

    move-result v1

    invoke-virtual {v0}, Landroid/view/View;->getHeight()I

    move-result v0

    const/4 v2, 0x0

    invoke-virtual {p0, v2, v2, v1, v0}, Lcom/k4/dressroom/EditXf$Guide;->setBounds(IIII)V

    sget-object p0, Lcom/k4/dressroom/EditXf;->sGuide:Lcom/k4/dressroom/EditXf$Guide;

    invoke-virtual {p0, p1}, Lcom/k4/dressroom/EditXf$Guide;->fade(Z)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return-void

    :catchall_0
    move-exception p0

    const-string p1, "K4HomeClock"

    const-string v0, "guide"

    invoke-static {p1, v0, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :goto_0
    return-void
.end method

.method static handles(Landroid/view/View;)Z
    .locals 1

    invoke-virtual {p0}, Landroid/view/View;->isEnabled()Z

    move-result v0

    if-eqz v0, :cond_0

    const-string v0, "C"

    invoke-static {p0, v0}, Lcom/k4/dressroom/EditXf;->bool(Ljava/lang/Object;Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_0

    const-string v0, "E"

    invoke-static {p0, v0}, Lcom/k4/dressroom/EditXf;->bool(Ljava/lang/Object;Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_0

    const-string v0, "D"

    invoke-static {p0, v0}, Lcom/k4/dressroom/EditXf;->bool(Ljava/lang/Object;Ljava/lang/String;)Z

    move-result p0

    if-nez p0, :cond_0

    const/4 p0, 0x1

    return p0

    :cond_0
    const/4 p0, 0x0

    return p0
.end method

.method static haptic(Landroid/view/View;)V
    .locals 5

    const-string v0, "K4HomeClock"

    const-string v1, "level: haptic semGetVibrationIndex(1)="

    :try_start_0
    sget-object v2, Lcom/k4/dressroom/EditXf;->sSemIndex:Ljava/lang/reflect/Method;

    if-nez v2, :cond_0

    const-class v2, Landroid/view/HapticFeedbackConstants;

    const-string v3, "semGetVibrationIndex"

    sget-object v4, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    filled-new-array {v4}, [Ljava/lang/Class;

    move-result-object v4

    invoke-virtual {v2, v3, v4}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v2

    sput-object v2, Lcom/k4/dressroom/EditXf;->sSemIndex:Ljava/lang/reflect/Method;

    :cond_0
    sget-object v2, Lcom/k4/dressroom/EditXf;->sSemIndex:Ljava/lang/reflect/Method;

    const/4 v3, 0x1

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    filled-new-array {v3}, [Ljava/lang/Object;

    move-result-object v3

    const/4 v4, 0x0

    invoke-virtual {v2, v4, v3}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/Integer;

    invoke-virtual {v2}, Ljava/lang/Integer;->intValue()I

    move-result v2

    invoke-virtual {p0, v2}, Landroid/view/View;->performHapticFeedback(I)Z

    move-result v3

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, " -> "

    invoke-virtual {v4, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return-void

    :catchall_0
    move-exception v1

    const-string v2, "level: haptic"

    invoke-static {v0, v2, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    const/4 v0, 0x4

    invoke-virtual {p0, v0}, Landroid/view/View;->performHapticFeedback(I)Z

    return-void
.end method

.method static identity()Z
    .locals 2

    sget v0, Lcom/k4/dressroom/EditXf;->s:F

    const/high16 v1, 0x3f800000    # 1.0f

    cmpl-float v0, v0, v1

    if-ltz v0, :cond_0

    invoke-static {}, Lcom/k4/dressroom/EditXf;->shownDeg()F

    move-result v0

    const/4 v1, 0x0

    cmpl-float v0, v0, v1

    if-nez v0, :cond_0

    sget v0, Lcom/k4/dressroom/EditXf;->tx:F

    cmpl-float v0, v0, v1

    if-nez v0, :cond_0

    sget v0, Lcom/k4/dressroom/EditXf;->ty:F

    cmpl-float v0, v0, v1

    if-nez v0, :cond_0

    const/4 v0, 0x1

    return v0

    :cond_0
    const/4 v0, 0x0

    return v0
.end method

.method static imageMatrix(Landroid/widget/ImageView;)Landroid/graphics/Matrix;
    .locals 2

    new-instance v0, Landroid/graphics/Matrix;

    invoke-virtual {p0}, Landroid/widget/ImageView;->getImageMatrix()Landroid/graphics/Matrix;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/graphics/Matrix;-><init>(Landroid/graphics/Matrix;)V

    invoke-virtual {p0}, Landroid/widget/ImageView;->getPaddingLeft()I

    move-result v1

    int-to-float v1, v1

    invoke-virtual {p0}, Landroid/widget/ImageView;->getPaddingTop()I

    move-result p0

    int-to-float p0, p0

    invoke-virtual {v0, v1, p0}, Landroid/graphics/Matrix;->postTranslate(FF)Z

    return-object v0
.end method

.method static isExpandable(Landroid/graphics/drawable/Drawable;)Z
    .locals 1

    if-eqz p0, :cond_0

    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/Class;->getName()Ljava/lang/String;

    move-result-object p0

    const-string v0, "fj.j"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_0

    const/4 p0, 0x1

    return p0

    :cond_0
    const/4 p0, 0x0

    return p0
.end method

.method static matrix(Landroid/view/View;)Landroid/graphics/Matrix;
    .locals 4

    new-instance v0, Landroid/graphics/Matrix;

    invoke-direct {v0}, Landroid/graphics/Matrix;-><init>()V

    invoke-virtual {p0}, Landroid/view/View;->getWidth()I

    move-result v1

    int-to-float v1, v1

    const/high16 v2, 0x40000000    # 2.0f

    div-float/2addr v1, v2

    invoke-virtual {p0}, Landroid/view/View;->getHeight()I

    move-result p0

    int-to-float p0, p0

    div-float/2addr p0, v2

    neg-float v2, v1

    neg-float v3, p0

    invoke-virtual {v0, v2, v3}, Landroid/graphics/Matrix;->setTranslate(FF)V

    sget v2, Lcom/k4/dressroom/EditXf;->s:F

    sget v3, Lcom/k4/dressroom/EditXf;->s:F

    invoke-virtual {v0, v2, v3}, Landroid/graphics/Matrix;->postScale(FF)Z

    invoke-static {}, Lcom/k4/dressroom/EditXf;->shownDeg()F

    move-result v2

    invoke-virtual {v0, v2}, Landroid/graphics/Matrix;->postRotate(F)Z

    sget v2, Lcom/k4/dressroom/EditXf;->tx:F

    add-float/2addr v1, v2

    sget v2, Lcom/k4/dressroom/EditXf;->ty:F

    add-float/2addr p0, v2

    invoke-virtual {v0, v1, p0}, Landroid/graphics/Matrix;->postTranslate(FF)Z

    return-object v0
.end method

.method static mine(Landroid/view/View;)Z
    .locals 1

    sget-boolean v0, Lcom/k4/dressroom/HomeClock;->active:Z

    if-eqz v0, :cond_0

    if-eqz p0, :cond_0

    sget-object v0, Lcom/k4/dressroom/EditXf;->sView:Ljava/lang/ref/WeakReference;

    invoke-virtual {v0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v0

    if-ne v0, p0, :cond_0

    const/4 p0, 0x1

    return p0

    :cond_0
    const/4 p0, 0x0

    return p0
.end method

.method static norm(F)F
    .locals 2

    :goto_0
    const/high16 v0, 0x43340000    # 180.0f

    cmpl-float v0, p0, v0

    const/high16 v1, 0x43b40000    # 360.0f

    if-lez v0, :cond_0

    sub-float/2addr p0, v1

    goto :goto_0

    :cond_0
    :goto_1
    const/high16 v0, -0x3ccc0000    # -180.0f

    cmpg-float v0, p0, v0

    if-gez v0, :cond_1

    add-float/2addr p0, v1

    goto :goto_1

    :cond_1
    return p0
.end method

.method public static objectScale(F)F
    .locals 2

    sget-object v0, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    sget-object v1, Lcom/k4/dressroom/EditXf;->sObjBaked:Ljava/lang/ThreadLocal;

    invoke-virtual {v1}, Ljava/lang/ThreadLocal;->get()Ljava/lang/Object;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    const/high16 p0, 0x3f800000    # 1.0f

    :cond_0
    return p0
.end method

.method static outer(Landroid/view/View;)Landroid/graphics/drawable/Drawable;
    .locals 1

    :try_start_0
    const-string v0, "getDrawableInner"

    invoke-static {p0, v0}, Lcom/k4/dressroom/EditXf;->call(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/graphics/drawable/Drawable;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return-object v0

    :catchall_0
    check-cast p0, Landroid/widget/ImageView;

    invoke-virtual {p0}, Landroid/widget/ImageView;->getDrawable()Landroid/graphics/drawable/Drawable;

    move-result-object p0

    return-object p0
.end method

.method static declared-synchronized ownFill(Landroid/content/Context;Landroid/graphics/Bitmap;)Landroid/graphics/drawable/Drawable;
    .locals 5

    const-class v0, Lcom/k4/dressroom/EditXf;

    monitor-enter v0

    const/4 v1, 0x0

    if-nez p1, :cond_0

    monitor-exit v0

    return-object v1

    :cond_0
    :try_start_0
    sget-object v2, Lcom/k4/dressroom/EditXf;->sFillFor:Landroid/graphics/Bitmap;

    if-ne v2, p1, :cond_1

    sget-object v2, Lcom/k4/dressroom/EditXf;->sFill:Landroid/graphics/drawable/Drawable;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_1

    if-eqz v2, :cond_1

    monitor-exit v0

    return-object v2

    :cond_1
    :try_start_1
    invoke-virtual {p1}, Landroid/graphics/Bitmap;->getConfig()Landroid/graphics/Bitmap$Config;

    move-result-object v2

    sget-object v3, Landroid/graphics/Bitmap$Config;->HARDWARE:Landroid/graphics/Bitmap$Config;

    const/4 v4, 0x0

    if-ne v2, v3, :cond_2

    sget-object v2, Landroid/graphics/Bitmap$Config;->ARGB_8888:Landroid/graphics/Bitmap$Config;

    invoke-virtual {p1, v2, v4}, Landroid/graphics/Bitmap;->copy(Landroid/graphics/Bitmap$Config;Z)Landroid/graphics/Bitmap;

    move-result-object v2

    goto :goto_0

    :cond_2
    move-object v2, p1

    :goto_0
    new-instance v3, Landroid/graphics/drawable/BitmapDrawable;

    invoke-virtual {p0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object p0

    invoke-direct {v3, p0, v2}, Landroid/graphics/drawable/BitmapDrawable;-><init>(Landroid/content/res/Resources;Landroid/graphics/Bitmap;)V

    invoke-virtual {v2}, Landroid/graphics/Bitmap;->getWidth()I

    move-result p0

    invoke-virtual {v2}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v2

    invoke-virtual {v3, v4, v4, p0, v2}, Landroid/graphics/drawable/BitmapDrawable;->setBounds(IIII)V

    const-string p0, "fj.j"

    const-class v2, Lcom/k4/dressroom/EditXf;

    invoke-virtual {v2}, Ljava/lang/Class;->getClassLoader()Ljava/lang/ClassLoader;

    move-result-object v2

    const/4 v4, 0x1

    invoke-static {p0, v4, v2}, Ljava/lang/Class;->forName(Ljava/lang/String;ZLjava/lang/ClassLoader;)Ljava/lang/Class;

    move-result-object p0

    const-class v2, Landroid/graphics/drawable/Drawable;

    filled-new-array {v2}, [Ljava/lang/Class;

    move-result-object v2

    invoke-virtual {p0, v2}, Ljava/lang/Class;->getConstructor([Ljava/lang/Class;)Ljava/lang/reflect/Constructor;

    move-result-object p0

    filled-new-array {v3}, [Ljava/lang/Object;

    move-result-object v2

    invoke-virtual {p0, v2}, Ljava/lang/reflect/Constructor;->newInstance([Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Landroid/graphics/drawable/Drawable;

    sput-object p0, Lcom/k4/dressroom/EditXf;->sFill:Landroid/graphics/drawable/Drawable;

    sput-object p1, Lcom/k4/dressroom/EditXf;->sFillFor:Landroid/graphics/Bitmap;
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    goto :goto_1

    :catchall_0
    move-exception p0

    :try_start_2
    const-string p1, "K4HomeClock"

    const-string v2, "expand fill"

    invoke-static {p1, v2, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    sput-object v1, Lcom/k4/dressroom/EditXf;->sFill:Landroid/graphics/drawable/Drawable;

    :goto_1
    sget-object p0, Lcom/k4/dressroom/EditXf;->sFill:Landroid/graphics/drawable/Drawable;
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_1

    monitor-exit v0

    return-object p0

    :catchall_1
    move-exception p0

    :try_start_3
    monitor-exit v0
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_1

    throw p0
.end method

.method static paint(Landroid/view/View;Landroid/graphics/Canvas;ZZ)V
    .locals 16

    move-object/from16 v0, p1

    move-object/from16 v1, p0

    check-cast v1, Landroid/widget/ImageView;

    invoke-static/range {p0 .. p0}, Lcom/k4/dressroom/EditXf;->outer(Landroid/view/View;)Landroid/graphics/drawable/Drawable;

    move-result-object v2

    invoke-virtual {v1}, Landroid/widget/ImageView;->getDrawable()Landroid/graphics/drawable/Drawable;

    move-result-object v3

    const/4 v4, 0x0

    if-ne v3, v2, :cond_0

    instance-of v5, v2, Landroid/graphics/drawable/LayerDrawable;

    if-eqz v5, :cond_0

    move-object v5, v2

    check-cast v5, Landroid/graphics/drawable/LayerDrawable;

    invoke-virtual {v5}, Landroid/graphics/drawable/LayerDrawable;->getNumberOfLayers()I

    move-result v6

    if-lez v6, :cond_0

    invoke-virtual {v5, v4}, Landroid/graphics/drawable/LayerDrawable;->getDrawable(I)Landroid/graphics/drawable/Drawable;

    move-result-object v3

    :cond_0
    if-eqz v2, :cond_f

    if-nez v3, :cond_1

    goto/16 :goto_3

    :cond_1
    new-instance v5, Landroid/graphics/Rect;

    invoke-virtual {v2}, Landroid/graphics/drawable/Drawable;->getBounds()Landroid/graphics/Rect;

    move-result-object v6

    invoke-direct {v5, v6}, Landroid/graphics/Rect;-><init>(Landroid/graphics/Rect;)V

    invoke-static {v1}, Lcom/k4/dressroom/EditXf;->imageMatrix(Landroid/widget/ImageView;)Landroid/graphics/Matrix;

    move-result-object v6

    invoke-static/range {p0 .. p0}, Lcom/k4/dressroom/EditXf;->matrix(Landroid/view/View;)Landroid/graphics/Matrix;

    move-result-object v7

    invoke-static {}, Lcom/k4/dressroom/EditXf;->shownDeg()F

    move-result v8

    new-instance v9, Landroid/graphics/RectF;

    invoke-direct {v9, v5}, Landroid/graphics/RectF;-><init>(Landroid/graphics/Rect;)V

    invoke-virtual {v6, v9}, Landroid/graphics/Matrix;->mapRect(Landroid/graphics/RectF;)Z

    new-instance v10, Landroid/graphics/Matrix;

    invoke-direct {v10}, Landroid/graphics/Matrix;-><init>()V

    invoke-virtual/range {p0 .. p0}, Landroid/view/View;->getWidth()I

    move-result v11

    int-to-float v11, v11

    const/high16 v12, 0x40000000    # 2.0f

    div-float/2addr v11, v12

    invoke-virtual/range {p0 .. p0}, Landroid/view/View;->getHeight()I

    move-result v13

    int-to-float v13, v13

    div-float/2addr v13, v12

    neg-float v14, v11

    neg-float v15, v13

    invoke-virtual {v10, v14, v15}, Landroid/graphics/Matrix;->setTranslate(FF)V

    sget v14, Lcom/k4/dressroom/EditXf;->s:F

    sget v15, Lcom/k4/dressroom/EditXf;->s:F

    invoke-virtual {v10, v14, v15}, Landroid/graphics/Matrix;->postScale(FF)Z

    sget v14, Lcom/k4/dressroom/EditXf;->tx:F

    add-float/2addr v11, v14

    sget v14, Lcom/k4/dressroom/EditXf;->ty:F

    add-float/2addr v13, v14

    invoke-virtual {v10, v11, v13}, Landroid/graphics/Matrix;->postTranslate(FF)Z

    invoke-virtual {v10, v9}, Landroid/graphics/Matrix;->mapRect(Landroid/graphics/RectF;)Z

    const/4 v10, 0x0

    cmpl-float v10, v8, v10

    if-eqz v10, :cond_2

    invoke-static {v8}, Ljava/lang/Math;->abs(F)F

    move-result v8

    float-to-double v10, v8

    invoke-static {v10, v11}, Ljava/lang/Math;->toRadians(D)D

    move-result-wide v10

    invoke-static {v10, v11}, Ljava/lang/Math;->cos(D)D

    move-result-wide v13

    double-to-float v8, v13

    invoke-static {v10, v11}, Ljava/lang/Math;->sin(D)D

    move-result-wide v10

    double-to-float v10, v10

    invoke-virtual {v9}, Landroid/graphics/RectF;->width()F

    move-result v11

    invoke-virtual {v9}, Landroid/graphics/RectF;->height()F

    move-result v13

    mul-float v14, v11, v8

    mul-float v15, v13, v10

    add-float/2addr v14, v15

    div-float v14, v11, v14

    mul-float/2addr v10, v11

    mul-float/2addr v8, v13

    add-float/2addr v10, v8

    div-float v8, v13, v10

    invoke-static {v14, v8}, Ljava/lang/Math;->min(FF)F

    move-result v8

    const/high16 v10, 0x3f800000    # 1.0f

    sub-float/2addr v10, v8

    mul-float/2addr v11, v10

    div-float/2addr v11, v12

    mul-float/2addr v13, v10

    div-float/2addr v13, v12

    invoke-virtual {v9, v11, v13}, Landroid/graphics/RectF;->inset(FF)V

    :cond_2
    new-instance v8, Landroid/graphics/Rect;

    invoke-direct {v8}, Landroid/graphics/Rect;-><init>()V

    invoke-virtual {v9, v8}, Landroid/graphics/RectF;->round(Landroid/graphics/Rect;)V

    invoke-static {v3}, Lcom/k4/dressroom/EditXf;->bitmapOf(Landroid/graphics/drawable/Drawable;)Landroid/graphics/Bitmap;

    move-result-object v9

    const/4 v10, 0x0

    if-nez p2, :cond_4

    invoke-static {v2}, Lcom/k4/dressroom/EditXf;->isExpandable(Landroid/graphics/drawable/Drawable;)Z

    move-result v11

    if-eqz v11, :cond_3

    move-object v11, v2

    goto :goto_0

    :cond_3
    instance-of v11, v2, Landroid/graphics/drawable/LayerDrawable;

    if-eqz v11, :cond_4

    move-object v11, v2

    check-cast v11, Landroid/graphics/drawable/LayerDrawable;

    invoke-virtual {v11}, Landroid/graphics/drawable/LayerDrawable;->getNumberOfLayers()I

    move-result v12

    if-lez v12, :cond_4

    invoke-virtual {v11, v4}, Landroid/graphics/drawable/LayerDrawable;->getDrawable(I)Landroid/graphics/drawable/Drawable;

    move-result-object v12

    invoke-static {v12}, Lcom/k4/dressroom/EditXf;->isExpandable(Landroid/graphics/drawable/Drawable;)Z

    move-result v12

    if-eqz v12, :cond_4

    invoke-virtual {v11, v4}, Landroid/graphics/drawable/LayerDrawable;->getDrawable(I)Landroid/graphics/drawable/Drawable;

    move-result-object v11

    goto :goto_0

    :cond_4
    move-object v11, v10

    :goto_0
    if-nez v11, :cond_5

    invoke-virtual/range {p0 .. p0}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object v11

    invoke-static {v11, v9}, Lcom/k4/dressroom/EditXf;->ownFill(Landroid/content/Context;Landroid/graphics/Bitmap;)Landroid/graphics/drawable/Drawable;

    move-result-object v11

    :cond_5
    const/high16 v12, -0x1000000

    invoke-virtual {v0, v12}, Landroid/graphics/Canvas;->drawColor(I)V

    if-eqz v11, :cond_6

    new-instance v12, Landroid/graphics/Rect;

    invoke-virtual {v11}, Landroid/graphics/drawable/Drawable;->getBounds()Landroid/graphics/Rect;

    move-result-object v13

    invoke-direct {v12, v13}, Landroid/graphics/Rect;-><init>(Landroid/graphics/Rect;)V

    invoke-virtual {v0}, Landroid/graphics/Canvas;->save()I

    move-result v13

    invoke-virtual {v11, v8}, Landroid/graphics/drawable/Drawable;->setBounds(Landroid/graphics/Rect;)V

    invoke-virtual {v11, v0}, Landroid/graphics/drawable/Drawable;->draw(Landroid/graphics/Canvas;)V

    invoke-virtual {v0, v13}, Landroid/graphics/Canvas;->restoreToCount(I)V

    invoke-virtual {v11, v12}, Landroid/graphics/drawable/Drawable;->setBounds(Landroid/graphics/Rect;)V

    :cond_6
    if-eqz p2, :cond_9

    if-eqz v9, :cond_7

    invoke-virtual {v9}, Landroid/graphics/Bitmap;->getConfig()Landroid/graphics/Bitmap$Config;

    move-result-object v3

    sget-object v8, Landroid/graphics/Bitmap$Config;->HARDWARE:Landroid/graphics/Bitmap$Config;

    if-ne v3, v8, :cond_7

    sget-object v3, Landroid/graphics/Bitmap$Config;->ARGB_8888:Landroid/graphics/Bitmap$Config;

    invoke-virtual {v9, v3, v4}, Landroid/graphics/Bitmap;->copy(Landroid/graphics/Bitmap$Config;Z)Landroid/graphics/Bitmap;

    move-result-object v9

    :cond_7
    if-eqz v9, :cond_8

    new-instance v3, Landroid/graphics/drawable/BitmapDrawable;

    invoke-virtual/range {p0 .. p0}, Landroid/view/View;->getResources()Landroid/content/res/Resources;

    move-result-object v4

    invoke-direct {v3, v4, v9}, Landroid/graphics/drawable/BitmapDrawable;-><init>(Landroid/content/res/Resources;Landroid/graphics/Bitmap;)V

    goto :goto_1

    :cond_8
    move-object v3, v10

    :cond_9
    :goto_1
    invoke-virtual {v0}, Landroid/graphics/Canvas;->save()I

    move-result v4

    invoke-virtual {v0, v7}, Landroid/graphics/Canvas;->concat(Landroid/graphics/Matrix;)V

    invoke-virtual {v0, v6}, Landroid/graphics/Canvas;->concat(Landroid/graphics/Matrix;)V

    invoke-virtual {v1}, Landroid/widget/ImageView;->getColorFilter()Landroid/graphics/ColorFilter;

    move-result-object v1

    if-eqz v1, :cond_a

    new-instance v6, Landroid/graphics/Paint;

    invoke-direct {v6}, Landroid/graphics/Paint;-><init>()V

    invoke-virtual {v6, v1}, Landroid/graphics/Paint;->setColorFilter(Landroid/graphics/ColorFilter;)Landroid/graphics/ColorFilter;

    new-instance v1, Landroid/graphics/RectF;

    invoke-direct {v1, v5}, Landroid/graphics/RectF;-><init>(Landroid/graphics/Rect;)V

    invoke-virtual {v0, v1, v6}, Landroid/graphics/Canvas;->saveLayer(Landroid/graphics/RectF;Landroid/graphics/Paint;)I

    :cond_a
    const/4 v1, 0x1

    if-eqz v3, :cond_c

    instance-of v6, v3, Landroid/graphics/drawable/BitmapDrawable;

    if-eqz v6, :cond_b

    move-object v6, v3

    check-cast v6, Landroid/graphics/drawable/BitmapDrawable;

    invoke-virtual {v6, v1}, Landroid/graphics/drawable/BitmapDrawable;->setFilterBitmap(Z)V

    :cond_b
    invoke-virtual {v3, v5}, Landroid/graphics/drawable/Drawable;->setBounds(Landroid/graphics/Rect;)V

    invoke-virtual {v3, v0}, Landroid/graphics/drawable/Drawable;->draw(Landroid/graphics/Canvas;)V

    :cond_c
    if-eqz p3, :cond_e

    if-nez p2, :cond_e

    instance-of v3, v2, Landroid/graphics/drawable/LayerDrawable;

    if-eqz v3, :cond_e

    check-cast v2, Landroid/graphics/drawable/LayerDrawable;

    :goto_2
    invoke-virtual {v2}, Landroid/graphics/drawable/LayerDrawable;->getNumberOfLayers()I

    move-result v3

    if-ge v1, v3, :cond_e

    invoke-virtual {v2, v1}, Landroid/graphics/drawable/LayerDrawable;->getDrawable(I)Landroid/graphics/drawable/Drawable;

    move-result-object v3

    if-eqz v3, :cond_d

    invoke-virtual {v3}, Landroid/graphics/drawable/Drawable;->getAlpha()I

    move-result v5

    if-lez v5, :cond_d

    invoke-virtual {v3, v0}, Landroid/graphics/drawable/Drawable;->draw(Landroid/graphics/Canvas;)V

    :cond_d
    add-int/lit8 v1, v1, 0x1

    goto :goto_2

    :cond_e
    invoke-virtual {v0, v4}, Landroid/graphics/Canvas;->restoreToCount(I)V

    :cond_f
    :goto_3
    return-void
.end method

.method static redraw(Landroid/view/View;)V
    .locals 0

    invoke-virtual {p0}, Landroid/view/View;->invalidate()V

    sget-object p0, Lcom/k4/dressroom/HomeClock;->sSubjectView:Ljava/lang/ref/WeakReference;

    invoke-virtual {p0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Landroid/view/View;

    if-eqz p0, :cond_0

    invoke-virtual {p0}, Landroid/view/View;->invalidate()V

    :cond_0
    return-void
.end method

.method static reset()V
    .locals 2

    const/high16 v0, 0x3f800000    # 1.0f

    sput v0, Lcom/k4/dressroom/EditXf;->s:F

    const/4 v0, 0x0

    sput v0, Lcom/k4/dressroom/EditXf;->deg:F

    sput v0, Lcom/k4/dressroom/EditXf;->tx:F

    sput v0, Lcom/k4/dressroom/EditXf;->ty:F

    const/4 v0, 0x0

    sput-boolean v0, Lcom/k4/dressroom/EditXf;->sRotating:Z

    sput v0, Lcom/k4/dressroom/EditXf;->sCount:I

    new-instance v0, Ljava/lang/ref/WeakReference;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/dressroom/EditXf;->sView:Ljava/lang/ref/WeakReference;

    sput-object v1, Lcom/k4/dressroom/EditXf;->sGuide:Lcom/k4/dressroom/EditXf$Guide;

    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, v1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/dressroom/EditXf;->sBaked:Ljava/lang/ref/WeakReference;

    sput-object v1, Lcom/k4/dressroom/EditXf;->sBakedBg:Landroid/graphics/Bitmap;

    return-void
.end method

.method public static scale(Landroid/view/View;F)F
    .locals 4

    invoke-static {p0}, Lcom/k4/dressroom/EditXf;->mine(Landroid/view/View;)Z

    move-result v0

    if-eqz v0, :cond_4

    const/high16 v0, 0x3f800000    # 1.0f

    cmpl-float v1, p1, v0

    if-eqz v1, :cond_4

    invoke-static {p1}, Ljava/lang/Float;->isNaN(F)Z

    move-result v1

    if-eqz v1, :cond_0

    goto :goto_1

    :cond_0
    cmpg-float v1, p1, v0

    if-gez v1, :cond_2

    :try_start_0
    sget v1, Lcom/k4/dressroom/EditXf;->s:F

    cmpg-float v1, v1, v0

    if-ltz v1, :cond_1

    invoke-static {p0}, Lcom/k4/dressroom/EditXf;->atMin(Landroid/view/View;)Z

    move-result v1

    if-eqz v1, :cond_4

    :cond_1
    sget v1, Lcom/k4/dressroom/EditXf;->s:F

    mul-float/2addr v1, p1

    const/high16 v2, 0x3f000000    # 0.5f

    invoke-static {v2, v1}, Ljava/lang/Math;->max(FF)F

    move-result v1

    sput v1, Lcom/k4/dressroom/EditXf;->s:F

    invoke-static {p0}, Lcom/k4/dressroom/EditXf;->redraw(Landroid/view/View;)V

    return v0

    :cond_2
    sget v1, Lcom/k4/dressroom/EditXf;->s:F

    cmpg-float v1, v1, v0

    if-gez v1, :cond_4

    sget v1, Lcom/k4/dressroom/EditXf;->s:F

    mul-float/2addr v1, p1

    invoke-static {v0, v1}, Ljava/lang/Math;->min(FF)F

    move-result v1

    cmpl-float v2, v1, v0

    if-ltz v2, :cond_3

    const/4 v2, 0x0

    goto :goto_0

    :cond_3
    sub-float v2, v0, v1

    sget v3, Lcom/k4/dressroom/EditXf;->s:F

    sub-float v3, v0, v3

    div-float/2addr v2, v3

    :goto_0
    sget v3, Lcom/k4/dressroom/EditXf;->tx:F

    mul-float/2addr v3, v2

    sput v3, Lcom/k4/dressroom/EditXf;->tx:F

    sget v3, Lcom/k4/dressroom/EditXf;->ty:F

    mul-float/2addr v3, v2

    sput v3, Lcom/k4/dressroom/EditXf;->ty:F

    sput v1, Lcom/k4/dressroom/EditXf;->s:F

    invoke-static {p0}, Lcom/k4/dressroom/EditXf;->redraw(Landroid/view/View;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return v0

    :catchall_0
    move-exception p0

    const-string v0, "K4HomeClock"

    const-string v1, "scale"

    invoke-static {v0, v1, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_4
    :goto_1
    return p1
.end method

.method static screen(Ljava/lang/Object;)Landroid/util/Size;
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    const-string v0, "f"

    invoke-static {p0, v0}, Lcom/k4/dressroom/HomeClock;->field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Landroid/util/Size;

    return-object p0
.end method

.method static set(Ljava/lang/Object;Ljava/lang/String;Ljava/lang/Object;)V
    .locals 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v0

    const/4 v1, 0x0

    :goto_0
    if-eqz v0, :cond_0

    if-nez v1, :cond_0

    :try_start_0
    invoke-virtual {v0, p1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v1
    :try_end_0
    .catch Ljava/lang/NoSuchFieldException; {:try_start_0 .. :try_end_0} :catch_0

    :catch_0
    invoke-virtual {v0}, Ljava/lang/Class;->getSuperclass()Ljava/lang/Class;

    move-result-object v0

    goto :goto_0

    :cond_0
    if-eqz v1, :cond_1

    const/4 p1, 0x1

    invoke-virtual {v1, p1}, Ljava/lang/reflect/Field;->setAccessible(Z)V

    invoke-virtual {v1, p0, p2}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V

    return-void

    :cond_1
    new-instance p0, Ljava/lang/NoSuchFieldException;

    invoke-direct {p0, p1}, Ljava/lang/NoSuchFieldException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method static shownDeg()F
    .locals 3

    sget v0, Lcom/k4/dressroom/EditXf;->deg:F

    invoke-static {v0}, Ljava/lang/Math;->abs(F)F

    move-result v1

    const/high16 v2, 0x40000000    # 2.0f

    cmpg-float v1, v1, v2

    if-gez v1, :cond_0

    const/4 v0, 0x0

    :cond_0
    return v0
.end method

.method static state([FI)V
    .locals 2

    sget v0, Lcom/k4/dressroom/EditXf;->s:F

    aput v0, p0, p1

    add-int/lit8 v0, p1, 0x1

    invoke-static {}, Lcom/k4/dressroom/EditXf;->shownDeg()F

    move-result v1

    aput v1, p0, v0

    add-int/lit8 v0, p1, 0x2

    sget v1, Lcom/k4/dressroom/EditXf;->tx:F

    aput v1, p0, v0

    add-int/lit8 p1, p1, 0x3

    sget v0, Lcom/k4/dressroom/EditXf;->ty:F

    aput v0, p0, p1

    return-void
.end method

.method public static thumbnail(Ljava/lang/Object;Landroid/graphics/Bitmap;)Landroid/graphics/Bitmap;
    .locals 2

    sget-object v0, Lcom/k4/dressroom/EditXf;->sBakedBg:Landroid/graphics/Bitmap;

    if-eqz p0, :cond_0

    sget-object v1, Lcom/k4/dressroom/EditXf;->sBaked:Ljava/lang/ref/WeakReference;

    invoke-virtual {v1}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v1

    if-ne v1, p0, :cond_0

    if-eqz v0, :cond_0

    return-object v0

    :cond_0
    return-object p1
.end method

.method public static touch(Landroid/view/View;Landroid/view/MotionEvent;)Landroid/view/MotionEvent;
    .locals 14

    const-string v0, "K4HomeClock"

    sget-boolean v1, Lcom/k4/dressroom/HomeClock;->active:Z

    if-eqz v1, :cond_1f

    if-eqz p0, :cond_1f

    if-eqz p1, :cond_1f

    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Class;->getName()Ljava/lang/String;

    move-result-object v1

    const-string v2, "com.samsung.android.app.dressroom.presentation.preview.widget.CropImageView"

    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_0

    goto/16 :goto_9

    :cond_0
    :try_start_0
    invoke-static {p0}, Lcom/k4/dressroom/EditXf;->handles(Landroid/view/View;)Z

    move-result v1

    if-nez v1, :cond_1

    goto/16 :goto_9

    :cond_1
    sget-object v1, Lcom/k4/dressroom/EditXf;->sView:Ljava/lang/ref/WeakReference;

    invoke-virtual {v1}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v1

    if-eq v1, p0, :cond_3

    sget-object v1, Lcom/k4/dressroom/EditXf;->sView:Ljava/lang/ref/WeakReference;

    invoke-virtual {v1}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v1

    if-eqz v1, :cond_2

    invoke-static {}, Lcom/k4/dressroom/EditXf;->identity()Z

    move-result v1

    if-nez v1, :cond_2

    goto/16 :goto_9

    :cond_2
    new-instance v1, Ljava/lang/ref/WeakReference;

    invoke-direct {v1, p0}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v1, Lcom/k4/dressroom/EditXf;->sView:Ljava/lang/ref/WeakReference;

    :cond_3
    invoke-virtual {p1}, Landroid/view/MotionEvent;->getActionMasked()I

    move-result v1

    const/4 v2, -0x1

    const/4 v3, 0x6

    const/4 v4, 0x1

    if-eq v1, v3, :cond_5

    if-ne v1, v4, :cond_4

    goto :goto_0

    :cond_4
    move v5, v2

    goto :goto_1

    :cond_5
    :goto_0
    invoke-virtual {p1}, Landroid/view/MotionEvent;->getActionIndex()I

    move-result v5

    :goto_1
    const/4 v6, 0x0

    const/4 v7, 0x0

    move v8, v6

    move v9, v8

    move v10, v7

    move v11, v10

    :goto_2
    invoke-virtual {p1}, Landroid/view/MotionEvent;->getPointerCount()I

    move-result v12

    if-ge v8, v12, :cond_7

    if-eq v8, v5, :cond_6

    invoke-virtual {p1, v8}, Landroid/view/MotionEvent;->getX(I)F

    move-result v12

    add-float/2addr v10, v12

    invoke-virtual {p1, v8}, Landroid/view/MotionEvent;->getY(I)F

    move-result v12

    add-float/2addr v11, v12

    add-int/lit8 v9, v9, 0x1

    :cond_6
    add-int/lit8 v8, v8, 0x1

    goto :goto_2

    :cond_7
    if-lez v9, :cond_8

    int-to-float v8, v9

    div-float/2addr v10, v8

    div-float/2addr v11, v8

    :cond_8
    if-nez v1, :cond_9

    sput-boolean v6, Lcom/k4/dressroom/EditXf;->sRotating:Z

    sput v6, Lcom/k4/dressroom/EditXf;->sCount:I

    :cond_9
    sget v8, Lcom/k4/dressroom/EditXf;->sCount:I

    const/high16 v12, 0x3f800000    # 1.0f

    const/4 v13, 0x2

    if-ne v9, v8, :cond_10

    if-eq v1, v13, :cond_a

    goto/16 :goto_4

    :cond_a
    sget v5, Lcom/k4/dressroom/EditXf;->s:F

    cmpg-float v5, v5, v12

    if-gez v5, :cond_c

    sget v5, Lcom/k4/dressroom/EditXf;->sFx:F

    cmpl-float v5, v10, v5

    if-nez v5, :cond_b

    sget v5, Lcom/k4/dressroom/EditXf;->sFy:F

    cmpl-float v5, v11, v5

    if-eqz v5, :cond_c

    :cond_b
    sget v5, Lcom/k4/dressroom/EditXf;->tx:F

    sget v8, Lcom/k4/dressroom/EditXf;->sFx:F

    sub-float v8, v10, v8

    add-float/2addr v5, v8

    sput v5, Lcom/k4/dressroom/EditXf;->tx:F

    sget v5, Lcom/k4/dressroom/EditXf;->ty:F

    sget v8, Lcom/k4/dressroom/EditXf;->sFy:F

    sub-float v8, v11, v8

    add-float/2addr v5, v8

    sput v5, Lcom/k4/dressroom/EditXf;->ty:F

    invoke-static {p0}, Lcom/k4/dressroom/EditXf;->clampT(Landroid/view/View;)V

    move v5, v4

    goto :goto_3

    :cond_c
    move v5, v6

    :goto_3
    sput v10, Lcom/k4/dressroom/EditXf;->sFx:F

    sput v11, Lcom/k4/dressroom/EditXf;->sFy:F

    if-lt v9, v13, :cond_12

    invoke-static {p1, v2}, Lcom/k4/dressroom/EditXf;->angle(Landroid/view/MotionEvent;I)F

    move-result v2

    sget-boolean v8, Lcom/k4/dressroom/EditXf;->sRotating:Z

    if-nez v8, :cond_d

    sget v8, Lcom/k4/dressroom/EditXf;->sRotStart:F

    sub-float v8, v2, v8

    invoke-static {v8}, Lcom/k4/dressroom/EditXf;->norm(F)F

    move-result v8

    invoke-static {v8}, Ljava/lang/Math;->abs(F)F

    move-result v8

    const/high16 v10, 0x40c00000    # 6.0f

    cmpl-float v8, v8, v10

    if-lez v8, :cond_d

    sput-boolean v4, Lcom/k4/dressroom/EditXf;->sRotating:Z

    sput v2, Lcom/k4/dressroom/EditXf;->sRotStart:F

    sget v8, Lcom/k4/dressroom/EditXf;->deg:F

    sput v8, Lcom/k4/dressroom/EditXf;->sRotBase:F

    invoke-static {p0, v4}, Lcom/k4/dressroom/EditXf;->guide(Landroid/view/View;Z)V

    :cond_d
    sget-boolean v8, Lcom/k4/dressroom/EditXf;->sRotating:Z

    if-eqz v8, :cond_12

    invoke-static {}, Lcom/k4/dressroom/EditXf;->shownDeg()F

    move-result v8

    sget v10, Lcom/k4/dressroom/EditXf;->sRotBase:F

    sget v11, Lcom/k4/dressroom/EditXf;->sRotStart:F

    sub-float/2addr v2, v11

    invoke-static {v2}, Lcom/k4/dressroom/EditXf;->norm(F)F

    move-result v2

    add-float/2addr v10, v2

    const/high16 v2, 0x42340000    # 45.0f

    invoke-static {v2, v10}, Ljava/lang/Math;->min(FF)F

    move-result v2

    const/high16 v10, -0x3dcc0000    # -45.0f

    invoke-static {v10, v2}, Ljava/lang/Math;->max(FF)F

    move-result v2

    sput v2, Lcom/k4/dressroom/EditXf;->deg:F

    invoke-static {}, Lcom/k4/dressroom/EditXf;->shownDeg()F

    move-result v2

    cmpl-float v10, v2, v8

    if-eqz v10, :cond_12

    cmpl-float v5, v2, v7

    if-eqz v5, :cond_e

    cmpl-float v5, v8, v7

    if-eqz v5, :cond_f

    invoke-static {v2}, Ljava/lang/Math;->signum(F)F

    move-result v2

    invoke-static {v8}, Ljava/lang/Math;->signum(F)F

    move-result v5

    cmpl-float v2, v2, v5

    if-eqz v2, :cond_f

    :cond_e
    invoke-static {p0}, Lcom/k4/dressroom/EditXf;->haptic(Landroid/view/View;)V

    :cond_f
    move v5, v4

    goto :goto_5

    :cond_10
    :goto_4
    sput v10, Lcom/k4/dressroom/EditXf;->sFx:F

    sput v11, Lcom/k4/dressroom/EditXf;->sFy:F

    sput v9, Lcom/k4/dressroom/EditXf;->sCount:I

    if-lt v9, v13, :cond_11

    invoke-static {p1, v5}, Lcom/k4/dressroom/EditXf;->angle(Landroid/view/MotionEvent;I)F

    move-result v2

    sput v2, Lcom/k4/dressroom/EditXf;->sRotStart:F

    sget v2, Lcom/k4/dressroom/EditXf;->deg:F

    sput v2, Lcom/k4/dressroom/EditXf;->sRotBase:F

    :cond_11
    move v5, v6

    :cond_12
    :goto_5
    if-eq v1, v4, :cond_14

    const/4 v2, 0x3

    if-ne v1, v2, :cond_13

    goto :goto_6

    :cond_13
    move v2, v6

    goto :goto_7

    :cond_14
    :goto_6
    move v2, v4

    :goto_7
    if-nez v2, :cond_15

    if-ne v1, v3, :cond_1a

    if-ge v9, v13, :cond_1a

    :cond_15
    sget-boolean v1, Lcom/k4/dressroom/EditXf;->sRotating:Z

    if-eqz v1, :cond_16

    sput-boolean v6, Lcom/k4/dressroom/EditXf;->sRotating:Z

    invoke-static {p0, v6}, Lcom/k4/dressroom/EditXf;->guide(Landroid/view/View;Z)V

    :cond_16
    sget v1, Lcom/k4/dressroom/EditXf;->deg:F

    invoke-static {v1}, Ljava/lang/Math;->abs(F)F

    move-result v1

    const/high16 v3, 0x40000000    # 2.0f

    cmpg-float v1, v1, v3

    if-gez v1, :cond_17

    sget v1, Lcom/k4/dressroom/EditXf;->deg:F

    cmpl-float v1, v1, v7

    if-eqz v1, :cond_17

    sput v7, Lcom/k4/dressroom/EditXf;->deg:F

    :cond_17
    if-eqz v2, :cond_18

    sget v1, Lcom/k4/dressroom/EditXf;->s:F

    cmpg-float v1, v1, v12

    if-gez v1, :cond_18

    sget v1, Lcom/k4/dressroom/EditXf;->s:F

    const v3, 0x3f7851ec    # 0.97f

    cmpl-float v1, v1, v3

    if-lez v1, :cond_18

    sput v12, Lcom/k4/dressroom/EditXf;->s:F

    sput v7, Lcom/k4/dressroom/EditXf;->tx:F

    sput v7, Lcom/k4/dressroom/EditXf;->ty:F

    goto :goto_8

    :cond_18
    move v4, v5

    :goto_8
    if-eqz v2, :cond_19

    sget-object v1, Ljava/util/Locale;->US:Ljava/util/Locale;

    const-string v2, "home picture: scale %.3f, %.1f deg, offset %.0f,%.0f"

    sget v3, Lcom/k4/dressroom/EditXf;->s:F

    invoke-static {v3}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v3

    invoke-static {}, Lcom/k4/dressroom/EditXf;->shownDeg()F

    move-result v5

    invoke-static {v5}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v5

    sget v6, Lcom/k4/dressroom/EditXf;->tx:F

    invoke-static {v6}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v6

    sget v7, Lcom/k4/dressroom/EditXf;->ty:F

    invoke-static {v7}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v7

    filled-new-array {v3, v5, v6, v7}, [Ljava/lang/Object;

    move-result-object v3

    invoke-static {v1, v2, v3}, Ljava/lang/String;->format(Ljava/util/Locale;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    :cond_19
    move v5, v4

    :cond_1a
    if-eqz v5, :cond_1b

    invoke-static {p0}, Lcom/k4/dressroom/EditXf;->redraw(Landroid/view/View;)V

    :cond_1b
    sget-object v1, Lcom/k4/dressroom/EditXf;->sGuide:Lcom/k4/dressroom/EditXf$Guide;

    if-eqz v1, :cond_1c

    invoke-virtual {v1}, Lcom/k4/dressroom/EditXf$Guide;->invalidateSelf()V

    :cond_1c
    invoke-static {}, Lcom/k4/dressroom/EditXf;->identity()Z

    move-result v1

    if-eqz v1, :cond_1d

    goto :goto_9

    :cond_1d
    new-instance v1, Landroid/graphics/Matrix;

    invoke-direct {v1}, Landroid/graphics/Matrix;-><init>()V

    invoke-static {p0}, Lcom/k4/dressroom/EditXf;->matrix(Landroid/view/View;)Landroid/graphics/Matrix;

    move-result-object p0

    invoke-virtual {p0, v1}, Landroid/graphics/Matrix;->invert(Landroid/graphics/Matrix;)Z

    invoke-static {p1}, Landroid/view/MotionEvent;->obtain(Landroid/view/MotionEvent;)Landroid/view/MotionEvent;

    move-result-object p0

    invoke-virtual {p0, v1}, Landroid/view/MotionEvent;->transform(Landroid/graphics/Matrix;)V

    sget-object v1, Lcom/k4/dressroom/EditXf;->sCopy:Landroid/view/MotionEvent;

    if-eqz v1, :cond_1e

    invoke-virtual {v1}, Landroid/view/MotionEvent;->recycle()V

    :cond_1e
    sput-object p0, Lcom/k4/dressroom/EditXf;->sCopy:Landroid/view/MotionEvent;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return-object p0

    :catchall_0
    move-exception p0

    const-string v1, "touch"

    invoke-static {v0, v1, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_1f
    :goto_9
    return-object p1
.end method
