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

.field static final FILL_BLUR:I = 0x1

.field static final FILL_COLOR:I = 0x0

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

.field private static sBlur:Landroid/graphics/Bitmap;

.field private static sBlurFor:Landroid/graphics/Bitmap;

.field private static sBlurLabel:Ljava/lang/ref/WeakReference;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/lang/ref/WeakReference<",
            "Landroid/widget/TextView;",
            ">;"
        }
    .end annotation
.end field

.field private static sColor:I

.field private static sColorFor:Landroid/graphics/Bitmap;

.field private static sColorLabel:Ljava/lang/ref/WeakReference;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/lang/ref/WeakReference<",
            "Landroid/widget/TextView;",
            ">;"
        }
    .end annotation
.end field

.field private static sColorMask:Landroid/graphics/Bitmap;

.field private static sCopy:Landroid/view/MotionEvent;

.field private static sCount:I

.field private static sEdge:Ljava/lang/reflect/Field;

.field static volatile sFill:I

.field private static sFx:F

.field private static sFy:F

.field private static sGuide:Lcom/k4/dressroom/EditXf$Guide;

.field private static sKeepStretch:Ljava/lang/Boolean;

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

.field private static sSlot:Ljava/lang/ref/WeakReference;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/lang/ref/WeakReference<",
            "Landroid/view/View;",
            ">;"
        }
    .end annotation
.end field

.field private static sSpanNow:F

.field private static sSpanPrev:F

.field private static sSwitch:Ljava/lang/ref/WeakReference;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/lang/ref/WeakReference<",
            "Landroid/view/View;",
            ">;"
        }
    .end annotation
.end field

.field static sTick:I

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

    const/4 v0, -0x1

    sput v0, Lcom/k4/dressroom/EditXf;->sTick:I

    const/4 v0, 0x0

    sput v0, Lcom/k4/dressroom/EditXf;->sFill:I

    const/high16 v0, -0x1000000

    sput v0, Lcom/k4/dressroom/EditXf;->sColor:I

    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, v1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/dressroom/EditXf;->sBaked:Ljava/lang/ref/WeakReference;

    new-instance v0, Ljava/lang/ThreadLocal;

    invoke-direct {v0}, Ljava/lang/ThreadLocal;-><init>()V

    sput-object v0, Lcom/k4/dressroom/EditXf;->sObjBaked:Ljava/lang/ThreadLocal;

    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, v1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/dressroom/EditXf;->sSwitch:Ljava/lang/ref/WeakReference;

    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, v1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/dressroom/EditXf;->sSlot:Ljava/lang/ref/WeakReference;

    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, v1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/dressroom/EditXf;->sColorLabel:Ljava/lang/ref/WeakReference;

    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, v1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/dressroom/EditXf;->sBlurLabel:Ljava/lang/ref/WeakReference;

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

.method static declared-synchronized blurred(Landroid/graphics/Bitmap;)Landroid/graphics/Bitmap;
    .locals 14

    const-class v1, Lcom/k4/dressroom/EditXf;

    monitor-enter v1

    const/4 v2, 0x0

    if-nez p0, :cond_0

    monitor-exit v1

    return-object v2

    :cond_0
    :try_start_0
    sget-object v0, Lcom/k4/dressroom/EditXf;->sBlurFor:Landroid/graphics/Bitmap;

    if-ne p0, v0, :cond_1

    sget-object v0, Lcom/k4/dressroom/EditXf;->sBlur:Landroid/graphics/Bitmap;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_1

    if-eqz v0, :cond_1

    monitor-exit v1

    return-object v0

    :cond_1
    :try_start_1
    invoke-static {p0}, Lcom/k4/dressroom/EditXf;->software(Landroid/graphics/Bitmap;)Landroid/graphics/Bitmap;

    move-result-object v0

    invoke-virtual {v0}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v3

    int-to-float v3, v3

    const/high16 v4, 0x42900000    # 72.0f

    mul-float/2addr v3, v4

    invoke-virtual {v0}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v4

    int-to-float v4, v4

    div-float/2addr v3, v4

    invoke-static {v3}, Ljava/lang/Math;->round(F)I

    move-result v3

    const/4 v4, 0x1

    invoke-static {v4, v3}, Ljava/lang/Math;->max(II)I

    move-result v12

    sget-object v3, Landroid/graphics/Bitmap$Config;->ARGB_8888:Landroid/graphics/Bitmap$Config;

    const/16 v8, 0x48

    invoke-static {v8, v12, v3}, Landroid/graphics/Bitmap;->createBitmap(IILandroid/graphics/Bitmap$Config;)Landroid/graphics/Bitmap;

    move-result-object v5

    new-instance v3, Landroid/graphics/Canvas;

    invoke-direct {v3, v5}, Landroid/graphics/Canvas;-><init>(Landroid/graphics/Bitmap;)V

    const/high16 v4, -0x1000000

    invoke-virtual {v3, v4}, Landroid/graphics/Canvas;->drawColor(I)V

    new-instance v4, Landroid/graphics/Paint;

    const/4 v6, 0x2

    invoke-direct {v4, v6}, Landroid/graphics/Paint;-><init>(I)V

    new-instance v6, Landroid/graphics/Rect;

    const/4 v13, 0x0

    invoke-direct {v6, v13, v13, v8, v12}, Landroid/graphics/Rect;-><init>(IIII)V

    invoke-virtual {v3, v0, v2, v6, v4}, Landroid/graphics/Canvas;->drawBitmap(Landroid/graphics/Bitmap;Landroid/graphics/Rect;Landroid/graphics/Rect;Landroid/graphics/Paint;)V

    mul-int/lit8 v0, v12, 0x48

    new-array v6, v0, [I

    const/4 v9, 0x0

    const/4 v10, 0x0

    const/4 v7, 0x0

    move v11, v8

    invoke-virtual/range {v5 .. v12}, Landroid/graphics/Bitmap;->getPixels([IIIIIII)V

    :goto_0
    const/4 v0, 0x3

    if-ge v13, v0, :cond_2

    const/4 v0, 0x4

    invoke-static {v6, v8, v12, v0}, Lcom/k4/dressroom/EditXf;->boxBlur([IIII)V

    add-int/lit8 v13, v13, 0x1

    goto :goto_0

    :cond_2
    const/4 v9, 0x0

    const/4 v10, 0x0

    const/4 v7, 0x0

    move v11, v8

    invoke-virtual/range {v5 .. v12}, Landroid/graphics/Bitmap;->setPixels([IIIIIII)V

    sput-object v5, Lcom/k4/dressroom/EditXf;->sBlur:Landroid/graphics/Bitmap;

    sput-object p0, Lcom/k4/dressroom/EditXf;->sBlurFor:Landroid/graphics/Bitmap;
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    goto :goto_1

    :catchall_0
    move-exception v0

    move-object p0, v0

    :try_start_2
    const-string v0, "K4HomeClock"

    const-string v3, "blur"

    invoke-static {v0, v3, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    sput-object v2, Lcom/k4/dressroom/EditXf;->sBlur:Landroid/graphics/Bitmap;

    :goto_1
    sget-object p0, Lcom/k4/dressroom/EditXf;->sBlur:Landroid/graphics/Bitmap;
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_1

    monitor-exit v1

    return-object p0

    :catchall_1
    move-exception v0

    move-object p0, v0

    :try_start_3
    monitor-exit v1
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_1

    throw p0
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

.method static declared-synchronized borderColor(Landroid/graphics/Bitmap;)I
    .locals 28

    move-object/from16 v0, p0

    const-class v1, Lcom/k4/dressroom/EditXf;

    monitor-enter v1

    :try_start_0
    invoke-static {}, Lcom/k4/dressroom/EditXf;->subjectMask()Landroid/graphics/Bitmap;

    move-result-object v2
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_3

    const/high16 v3, -0x1000000

    if-nez v0, :cond_0

    monitor-exit v1

    return v3

    :cond_0
    :try_start_1
    sget-object v4, Lcom/k4/dressroom/EditXf;->sColorFor:Landroid/graphics/Bitmap;

    if-ne v0, v4, :cond_1

    sget-object v4, Lcom/k4/dressroom/EditXf;->sColorMask:Landroid/graphics/Bitmap;

    if-ne v2, v4, :cond_1

    sget v0, Lcom/k4/dressroom/EditXf;->sColor:I
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_3

    monitor-exit v1

    return v0

    :cond_1
    :try_start_2
    invoke-static {v0}, Lcom/k4/dressroom/EditXf;->software(Landroid/graphics/Bitmap;)Landroid/graphics/Bitmap;

    move-result-object v4

    invoke-static {v2}, Lcom/k4/dressroom/EditXf;->software(Landroid/graphics/Bitmap;)Landroid/graphics/Bitmap;

    move-result-object v12

    invoke-virtual {v4}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v7

    invoke-virtual {v4}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v13

    invoke-static {v7, v13}, Ljava/lang/Math;->min(II)I

    move-result v5

    int-to-float v5, v5

    const v6, 0x3cf5c28f    # 0.03f

    mul-float/2addr v5, v6

    invoke-static {v5}, Ljava/lang/Math;->round(F)I

    move-result v5

    const/4 v6, 0x2

    invoke-static {v6, v5}, Ljava/lang/Math;->max(II)I

    move-result v14

    const/16 v15, 0x1000

    new-array v5, v15, [I

    new-array v6, v15, [J

    new-array v8, v15, [J

    new-array v9, v15, [J

    move-object v10, v5

    new-array v5, v7, [I

    if-eqz v12, :cond_2

    invoke-virtual {v12}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v11

    new-array v11, v11, [I
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_2

    goto :goto_0

    :cond_2
    const/4 v11, 0x0

    :goto_0
    move-object/from16 v16, v11

    const/16 v17, 0x0

    move/from16 v18, v3

    move-object v11, v9

    move/from16 v9, v17

    :goto_1
    if-ge v9, v13, :cond_a

    const/16 v19, 0x1

    if-lt v9, v14, :cond_4

    sub-int v3, v13, v14

    if-lt v9, v3, :cond_3

    goto :goto_2

    :cond_3
    move/from16 v3, v17

    goto :goto_3

    :cond_4
    :goto_2
    move/from16 v3, v19

    :goto_3
    move-object/from16 v20, v8

    const/4 v8, 0x0

    move-object/from16 v21, v11

    const/4 v11, 0x1

    move-object/from16 v22, v6

    const/4 v6, 0x0

    move-object/from16 v23, v10

    move v10, v7

    :try_start_3
    invoke-virtual/range {v4 .. v11}, Landroid/graphics/Bitmap;->getPixels([IIIIIII)V

    move-object/from16 v24, v5

    move/from16 v25, v9

    if-eqz v12, :cond_5

    invoke-virtual {v12}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v5

    add-int/lit8 v5, v5, -0x1

    invoke-virtual {v12}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v6

    mul-int v9, v25, v6

    div-int/2addr v9, v13

    invoke-static {v5, v9}, Ljava/lang/Math;->min(II)I

    move-result v5

    move v10, v5

    goto :goto_4

    :cond_5
    move/from16 v10, v17

    :goto_4
    if-eqz v12, :cond_6

    invoke-virtual {v12}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v8

    invoke-virtual {v12}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v11

    move-object v5, v12

    const/4 v12, 0x1

    move v6, v7

    const/4 v7, 0x0

    const/4 v9, 0x0

    move v15, v6

    move-object/from16 v6, v16

    invoke-virtual/range {v5 .. v12}, Landroid/graphics/Bitmap;->getPixels([IIIIIII)V

    goto :goto_5

    :cond_6
    move v15, v7

    move-object v5, v12

    move-object/from16 v6, v16

    :goto_5
    move/from16 v7, v17

    :goto_6
    if-ge v7, v15, :cond_9

    if-nez v3, :cond_7

    if-lt v7, v14, :cond_7

    sub-int v8, v15, v14

    if-ge v7, v8, :cond_7

    add-int/lit8 v7, v8, -0x1

    :goto_7
    move-object v12, v1

    goto :goto_8

    :cond_7
    if-eqz v5, :cond_8

    invoke-virtual {v5}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v8

    add-int/lit8 v8, v8, -0x1

    invoke-virtual {v5}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v9

    mul-int/2addr v9, v7

    div-int/2addr v9, v15

    invoke-static {v8, v9}, Ljava/lang/Math;->min(II)I

    move-result v8

    aget v8, v6, v8

    invoke-static {v8}, Landroid/graphics/Color;->alpha(I)I

    move-result v8

    if-lez v8, :cond_8

    goto :goto_7

    :cond_8
    aget v8, v24, v7

    invoke-static {v8}, Landroid/graphics/Color;->alpha(I)I

    move-result v9

    invoke-static {v8}, Landroid/graphics/Color;->red(I)I

    move-result v10

    mul-int/2addr v10, v9

    div-int/lit16 v10, v10, 0xff

    invoke-static {v8}, Landroid/graphics/Color;->green(I)I

    move-result v11

    mul-int/2addr v11, v9

    div-int/lit16 v11, v11, 0xff

    invoke-static {v8}, Landroid/graphics/Color;->blue(I)I

    move-result v8

    mul-int/2addr v8, v9

    div-int/lit16 v8, v8, 0xff

    shr-int/lit8 v9, v10, 0x4

    shl-int/lit8 v9, v9, 0x8

    shr-int/lit8 v12, v11, 0x4

    shl-int/lit8 v12, v12, 0x4

    or-int/2addr v9, v12

    shr-int/lit8 v12, v8, 0x4

    or-int/2addr v9, v12

    aget v12, v23, v9

    add-int/lit8 v12, v12, 0x1

    aput v12, v23, v9

    aget-wide v26, v22, v9
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    move-object v12, v1

    int-to-long v0, v10

    add-long v26, v26, v0

    :try_start_4
    aput-wide v26, v22, v9

    aget-wide v0, v20, v9

    int-to-long v10, v11

    add-long/2addr v0, v10

    aput-wide v0, v20, v9

    aget-wide v0, v21, v9

    int-to-long v10, v8

    add-long/2addr v0, v10

    aput-wide v0, v21, v9

    :goto_8
    add-int/lit8 v7, v7, 0x1

    move-object/from16 v0, p0

    move-object v1, v12

    goto :goto_6

    :cond_9
    move-object v12, v1

    add-int/lit8 v9, v25, 0x1

    move-object/from16 v0, p0

    move-object/from16 v16, v6

    move v7, v15

    move-object/from16 v8, v20

    move-object/from16 v11, v21

    move-object/from16 v6, v22

    move-object/from16 v10, v23

    const/16 v15, 0x1000

    move-object v12, v5

    move-object/from16 v5, v24

    goto/16 :goto_1

    :catchall_0
    move-exception v0

    move-object v12, v1

    goto/16 :goto_c

    :cond_a
    move-object/from16 v22, v6

    move-object/from16 v20, v8

    move-object/from16 v23, v10

    move-object/from16 v21, v11

    move-object v5, v12

    const/16 v19, 0x1

    move-object v12, v1

    move v1, v15

    move/from16 v0, v19

    :goto_9
    if-ge v0, v1, :cond_c

    aget v3, v23, v0

    aget v4, v23, v17

    if-le v3, v4, :cond_b

    move/from16 v17, v0

    :cond_b
    add-int/lit8 v0, v0, 0x1

    goto :goto_9

    :cond_c
    aget v0, v23, v17

    move/from16 v1, v19

    invoke-static {v1, v0}, Ljava/lang/Math;->max(II)I

    move-result v0

    aget v1, v23, v17

    if-nez v1, :cond_d

    move/from16 v0, v18

    goto :goto_a

    :cond_d
    aget-wide v3, v22, v17

    int-to-long v0, v0

    div-long/2addr v3, v0

    long-to-int v3, v3

    aget-wide v6, v20, v17

    div-long/2addr v6, v0

    long-to-int v4, v6

    aget-wide v6, v21, v17

    div-long/2addr v6, v0

    long-to-int v0, v6

    invoke-static {v3, v4, v0}, Landroid/graphics/Color;->rgb(III)I

    move-result v0

    :goto_a
    sput v0, Lcom/k4/dressroom/EditXf;->sColor:I

    sput-object p0, Lcom/k4/dressroom/EditXf;->sColorFor:Landroid/graphics/Bitmap;

    sput-object v2, Lcom/k4/dressroom/EditXf;->sColorMask:Landroid/graphics/Bitmap;

    const-string v1, "K4HomeClock"

    const-string v2, "fill colour #%06x (%d of the border ring\'s pixels%s)"

    const v3, 0xffffff

    and-int/2addr v0, v3

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    aget v3, v23, v17

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    if-eqz v5, :cond_e

    const-string v4, ", subject skipped"

    goto :goto_b

    :cond_e
    const-string v4, ""

    :goto_b
    filled-new-array {v0, v3, v4}, [Ljava/lang/Object;

    move-result-object v0

    invoke-static {v2, v0}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    invoke-static {v1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_1

    goto :goto_d

    :catchall_1
    move-exception v0

    goto :goto_c

    :catchall_2
    move-exception v0

    move-object v12, v1

    move/from16 v18, v3

    :goto_c
    :try_start_5
    const-string v1, "K4HomeClock"

    const-string v2, "border colour"

    invoke-static {v1, v2, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    sput v18, Lcom/k4/dressroom/EditXf;->sColor:I

    :goto_d
    sget v0, Lcom/k4/dressroom/EditXf;->sColor:I
    :try_end_5
    .catchall {:try_start_5 .. :try_end_5} :catchall_4

    monitor-exit v12

    return v0

    :catchall_3
    move-exception v0

    move-object v12, v1

    :goto_e
    :try_start_6
    monitor-exit v12
    :try_end_6
    .catchall {:try_start_6 .. :try_end_6} :catchall_4

    throw v0

    :catchall_4
    move-exception v0

    goto :goto_e
.end method

.method static boxBlur([IIII)V
    .locals 18

    move-object/from16 v0, p0

    move/from16 v1, p3

    array-length v2, v0

    new-array v2, v2, [I

    const/4 v4, 0x0

    :goto_0
    const/4 v5, 0x2

    if-ge v4, v5, :cond_a

    if-nez v4, :cond_0

    const/4 v5, 0x1

    goto :goto_1

    :cond_0
    const/4 v5, 0x0

    :goto_1
    if-eqz v5, :cond_1

    move/from16 v6, p1

    goto :goto_2

    :cond_1
    move/from16 v6, p2

    :goto_2
    if-eqz v5, :cond_2

    move/from16 v7, p2

    goto :goto_3

    :cond_2
    move/from16 v7, p1

    :goto_3
    if-eqz v5, :cond_3

    move-object v8, v0

    goto :goto_4

    :cond_3
    move-object v8, v2

    :goto_4
    if-eqz v5, :cond_4

    move-object v9, v2

    goto :goto_5

    :cond_4
    move-object v9, v0

    :goto_5
    const/4 v10, 0x0

    :goto_6
    if-ge v10, v7, :cond_9

    const/4 v11, 0x0

    :goto_7
    if-ge v11, v6, :cond_8

    neg-int v12, v1

    const/4 v13, 0x0

    const/4 v14, 0x0

    const/4 v15, 0x0

    const/16 v16, 0x0

    :goto_8
    if-gt v12, v1, :cond_6

    add-int/lit8 v3, v6, -0x1

    add-int v0, v11, v12

    invoke-static {v3, v0}, Ljava/lang/Math;->min(II)I

    move-result v0

    const/4 v3, 0x0

    invoke-static {v3, v0}, Ljava/lang/Math;->max(II)I

    move-result v0

    if-eqz v5, :cond_5

    mul-int v17, v10, p1

    add-int v17, v17, v0

    goto :goto_9

    :cond_5
    mul-int v0, v0, p1

    add-int v17, v0, v10

    :goto_9
    aget v0, v8, v17

    shr-int/lit8 v3, v0, 0x10

    and-int/lit16 v3, v3, 0xff

    add-int/2addr v13, v3

    shr-int/lit8 v3, v0, 0x8

    and-int/lit16 v3, v3, 0xff

    add-int/2addr v15, v3

    and-int/lit16 v0, v0, 0xff

    add-int v16, v16, v0

    add-int/lit8 v14, v14, 0x1

    add-int/lit8 v12, v12, 0x1

    move-object/from16 v0, p0

    goto :goto_8

    :cond_6
    if-eqz v5, :cond_7

    mul-int v0, v10, p1

    add-int/2addr v0, v11

    goto :goto_a

    :cond_7
    mul-int v0, v11, p1

    add-int/2addr v0, v10

    :goto_a
    div-int/2addr v13, v14

    shl-int/lit8 v3, v13, 0x10

    const/high16 v12, -0x1000000

    or-int/2addr v3, v12

    div-int/2addr v15, v14

    shl-int/lit8 v12, v15, 0x8

    or-int/2addr v3, v12

    div-int v16, v16, v14

    or-int v3, v3, v16

    aput v3, v9, v0

    add-int/lit8 v11, v11, 0x1

    move-object/from16 v0, p0

    goto :goto_7

    :cond_8
    add-int/lit8 v10, v10, 0x1

    move-object/from16 v0, p0

    goto :goto_6

    :cond_9
    add-int/lit8 v4, v4, 0x1

    move-object/from16 v0, p0

    goto/16 :goto_0

    :cond_a
    return-void
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

.method static fill(Landroid/view/View;Landroid/graphics/Canvas;Landroid/graphics/Bitmap;)V
    .locals 7

    const/high16 v0, -0x1000000

    invoke-virtual {p1, v0}, Landroid/graphics/Canvas;->drawColor(I)V

    sget v0, Lcom/k4/dressroom/EditXf;->sFill:I

    const/4 v1, 0x1

    if-ne v0, v1, :cond_0

    invoke-static {p2}, Lcom/k4/dressroom/EditXf;->blurred(Landroid/graphics/Bitmap;)Landroid/graphics/Bitmap;

    move-result-object v0

    if-eqz v0, :cond_0

    invoke-virtual {p0}, Landroid/view/View;->getWidth()I

    move-result p2

    int-to-float p2, p2

    invoke-virtual {p0}, Landroid/view/View;->getHeight()I

    move-result p0

    int-to-float p0, p0

    invoke-virtual {v0}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v1

    int-to-float v1, v1

    div-float v1, p2, v1

    invoke-virtual {v0}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v2

    int-to-float v2, v2

    div-float v2, p0, v2

    invoke-static {v1, v2}, Ljava/lang/Math;->max(FF)F

    move-result v1

    invoke-virtual {v0}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v2

    int-to-float v2, v2

    mul-float/2addr v2, v1

    invoke-virtual {v0}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v3

    int-to-float v3, v3

    mul-float/2addr v3, v1

    new-instance v1, Landroid/graphics/RectF;

    sub-float v4, p2, v2

    const/high16 v5, 0x40000000    # 2.0f

    div-float/2addr v4, v5

    sub-float v6, p0, v3

    div-float/2addr v6, v5

    add-float/2addr p2, v2

    div-float/2addr p2, v5

    add-float/2addr p0, v3

    div-float/2addr p0, v5

    invoke-direct {v1, v4, v6, p2, p0}, Landroid/graphics/RectF;-><init>(FFFF)V

    new-instance p0, Landroid/graphics/Paint;

    const/4 p2, 0x2

    invoke-direct {p0, p2}, Landroid/graphics/Paint;-><init>(I)V

    const/4 p2, 0x0

    invoke-virtual {p1, v0, p2, v1, p0}, Landroid/graphics/Canvas;->drawBitmap(Landroid/graphics/Bitmap;Landroid/graphics/Rect;Landroid/graphics/RectF;Landroid/graphics/Paint;)V

    const/high16 p0, 0x66000000

    invoke-virtual {p1, p0}, Landroid/graphics/Canvas;->drawColor(I)V

    return-void

    :cond_0
    invoke-static {p2}, Lcom/k4/dressroom/EditXf;->borderColor(Landroid/graphics/Bitmap;)I

    move-result p0

    invoke-virtual {p1, p0}, Landroid/graphics/Canvas;->drawColor(I)V

    return-void
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
    .locals 3

    invoke-static {p0}, Lcom/k4/dressroom/EditXf;->tickConstant(Landroid/view/View;)I

    move-result v0

    invoke-virtual {p0, v0}, Landroid/view/View;->performHapticFeedback(I)Z

    move-result p0

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "level: haptic constant "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v0, " -> "

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    const-string v0, "K4HomeClock"

    invoke-static {v0, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

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

.method static keepSwitch()V
    .locals 4

    sget-object v0, Lcom/k4/dressroom/EditXf;->sView:Ljava/lang/ref/WeakReference;

    invoke-virtual {v0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/view/View;

    sget-object v1, Lcom/k4/dressroom/EditXf;->sSwitch:Ljava/lang/ref/WeakReference;

    invoke-virtual {v1}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/view/View;

    sget-object v2, Lcom/k4/dressroom/EditXf;->sSlot:Ljava/lang/ref/WeakReference;

    invoke-virtual {v2}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Landroid/view/View;

    if-eqz v0, :cond_0

    if-eqz v1, :cond_0

    if-eqz v2, :cond_0

    invoke-static {v0}, Lcom/k4/dressroom/EditXf;->mine(Landroid/view/View;)Z

    move-result v3

    if-eqz v3, :cond_0

    invoke-static {}, Lcom/k4/dressroom/EditXf;->identity()Z

    move-result v3

    if-nez v3, :cond_0

    invoke-virtual {v1}, Landroid/view/View;->isAttachedToWindow()Z

    move-result v1

    if-eqz v1, :cond_0

    invoke-virtual {v2}, Landroid/view/View;->getVisibility()I

    move-result v1

    if-eqz v1, :cond_0

    const/4 v1, 0x1

    invoke-static {v0, v1}, Lcom/k4/dressroom/EditXf;->showSwitch(Landroid/view/View;Z)V

    :cond_0
    return-void
.end method

.method static label(Landroid/content/Context;ILjava/lang/String;ILandroid/view/View;)Landroid/widget/TextView;
    .locals 2

    new-instance v0, Landroid/widget/TextView;

    invoke-direct {v0, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    if-eqz p1, :cond_0

    invoke-virtual {p0, p1}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object p2

    :cond_0
    invoke-virtual {v0, p2}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    const-string p1, "drawable"

    const-string p2, "preview_selector_text_set"

    invoke-static {p0, p1, p2}, Lcom/k4/dressroom/HomeClock;->id(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)I

    move-result p1

    :try_start_0
    invoke-virtual {p0, p1}, Landroid/content/Context;->getColorStateList(I)Landroid/content/res/ColorStateList;

    move-result-object p1

    invoke-virtual {v0, p1}, Landroid/widget/TextView;->setTextColor(Landroid/content/res/ColorStateList;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    const p1, -0x50506

    invoke-virtual {v0, p1}, Landroid/widget/TextView;->setTextColor(I)V

    :goto_0
    const-string p1, "dimen"

    const-string p2, "edit_switch_preview_title_text_size"

    invoke-static {p0, p1, p2}, Lcom/k4/dressroom/HomeClock;->id(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)I

    move-result p1

    if-eqz p1, :cond_1

    invoke-virtual {p0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object p2

    invoke-virtual {p2, p1}, Landroid/content/res/Resources;->getDimension(I)F

    move-result p1

    goto :goto_1

    :cond_1
    invoke-virtual {p0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object p1

    invoke-virtual {p1}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object p1

    iget p1, p1, Landroid/util/DisplayMetrics;->density:F

    const/high16 p2, 0x41400000    # 12.0f

    mul-float/2addr p1, p2

    :goto_1
    const/4 p2, 0x0

    invoke-virtual {v0, p2, p1}, Landroid/widget/TextView;->setTextSize(IF)V

    const-string p1, "sec"

    invoke-static {p1, p2}, Landroid/graphics/Typeface;->create(Ljava/lang/String;I)Landroid/graphics/Typeface;

    move-result-object p1

    const/16 v1, 0x258

    invoke-static {p1, v1, p2}, Landroid/graphics/Typeface;->create(Landroid/graphics/Typeface;IZ)Landroid/graphics/Typeface;

    move-result-object p1

    invoke-virtual {v0, p1}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V

    const/4 p1, 0x1

    invoke-virtual {v0, p1}, Landroid/widget/TextView;->setMaxLines(I)V

    const/16 p1, 0x11

    invoke-virtual {v0, p1}, Landroid/widget/TextView;->setGravity(I)V

    invoke-virtual {p0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object p0

    invoke-virtual {p0}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object p0

    iget p0, p0, Landroid/util/DisplayMetrics;->density:F

    const/high16 p1, 0x41200000    # 10.0f

    mul-float/2addr p1, p0

    invoke-static {p1}, Ljava/lang/Math;->round(F)I

    move-result v1

    invoke-static {p1}, Ljava/lang/Math;->round(F)I

    move-result p1

    invoke-virtual {v0, v1, p2, p1, p2}, Landroid/widget/TextView;->setPadding(IIII)V

    const/high16 p1, 0x42080000    # 34.0f

    mul-float/2addr p0, p1

    invoke-static {p0}, Ljava/lang/Math;->round(F)I

    move-result p0

    invoke-virtual {v0, p0}, Landroid/widget/TextView;->setMinHeight(I)V

    new-instance p0, Lcom/k4/dressroom/EditXf$3;

    invoke-direct {p0, p3, p4}, Lcom/k4/dressroom/EditXf$3;-><init>(ILandroid/view/View;)V

    invoke-virtual {v0, p0}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    return-object v0
.end method

.method static makeSwitch(Landroid/view/View;)Landroid/view/View;
    .locals 11

    invoke-virtual {p0}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {p0}, Landroid/view/View;->getRootView()Landroid/view/View;

    move-result-object v1

    const-string v2, "id"

    const-string v3, "preview_switch_title_layout"

    invoke-static {v0, v2, v3}, Lcom/k4/dressroom/HomeClock;->id(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)I

    move-result v2

    const/4 v3, 0x0

    if-eqz v2, :cond_0

    invoke-virtual {v1, v2}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v1

    goto :goto_0

    :cond_0
    move-object v1, v3

    :goto_0
    const-string v2, "K4HomeClock"

    if-eqz v1, :cond_6

    invoke-virtual {v1}, Landroid/view/View;->getParent()Landroid/view/ViewParent;

    move-result-object v4

    instance-of v4, v4, Landroid/view/ViewGroup;

    if-nez v4, :cond_1

    goto/16 :goto_3

    :cond_1
    new-instance v4, Landroid/widget/LinearLayout;

    invoke-direct {v4, v0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    const/4 v5, 0x0

    invoke-virtual {v4, v5}, Landroid/widget/LinearLayout;->setOrientation(I)V

    const/16 v6, 0x11

    invoke-virtual {v4, v6}, Landroid/widget/LinearLayout;->setGravity(I)V

    const-string v7, "drawable"

    const-string v8, "set_wallpaper_btn_bg"

    invoke-static {v0, v7, v8}, Lcom/k4/dressroom/HomeClock;->id(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)I

    move-result v7

    if-eqz v7, :cond_2

    invoke-virtual {v0, v7}, Landroid/content/Context;->getDrawable(I)Landroid/graphics/drawable/Drawable;

    move-result-object v7

    invoke-virtual {v4, v7}, Landroid/widget/LinearLayout;->setBackground(Landroid/graphics/drawable/Drawable;)V

    :cond_2
    invoke-virtual {v0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v7

    invoke-virtual {v7}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object v7

    iget v7, v7, Landroid/util/DisplayMetrics;->density:F

    const/high16 v8, 0x40800000    # 4.0f

    mul-float/2addr v8, v7

    invoke-static {v8}, Ljava/lang/Math;->round(F)I

    move-result v9

    const/high16 v10, 0x40000000    # 2.0f

    mul-float/2addr v7, v10

    invoke-static {v7}, Ljava/lang/Math;->round(F)I

    move-result v10

    invoke-static {v8}, Ljava/lang/Math;->round(F)I

    move-result v8

    invoke-static {v7}, Ljava/lang/Math;->round(F)I

    move-result v7

    invoke-virtual {v4, v9, v10, v8, v7}, Landroid/widget/LinearLayout;->setPadding(IIII)V

    const-string v7, "tab_color"

    const-string v8, "string"

    invoke-static {v0, v8, v7}, Lcom/k4/dressroom/HomeClock;->id(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)I

    move-result v7

    const-string v9, "Color"

    invoke-static {v0, v7, v9, v5, p0}, Lcom/k4/dressroom/EditXf;->label(Landroid/content/Context;ILjava/lang/String;ILandroid/view/View;)Landroid/widget/TextView;

    move-result-object v7

    const-string v9, "style_item_blur"

    invoke-static {v0, v8, v9}, Lcom/k4/dressroom/HomeClock;->id(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)I

    move-result v8

    const-string v9, "Blur"

    const/4 v10, 0x1

    invoke-static {v0, v8, v9, v10, p0}, Lcom/k4/dressroom/EditXf;->label(Landroid/content/Context;ILjava/lang/String;ILandroid/view/View;)Landroid/widget/TextView;

    move-result-object v0

    invoke-virtual {v4, v7}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    invoke-virtual {v4, v0}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    new-instance v8, Ljava/lang/ref/WeakReference;

    invoke-direct {v8, v7}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v8, Lcom/k4/dressroom/EditXf;->sColorLabel:Ljava/lang/ref/WeakReference;

    new-instance v7, Ljava/lang/ref/WeakReference;

    invoke-direct {v7, v0}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v7, Lcom/k4/dressroom/EditXf;->sBlurLabel:Ljava/lang/ref/WeakReference;

    instance-of v0, v1, Landroid/view/ViewGroup;

    if-eqz v0, :cond_3

    check-cast v1, Landroid/view/ViewGroup;

    goto :goto_1

    :cond_3
    move-object v1, v3

    :goto_1
    if-nez v1, :cond_4

    const-string p0, "fill switch: preview_switch_title_layout is not a ViewGroup"

    invoke-static {v2, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    return-object v3

    :cond_4
    :goto_2
    invoke-virtual {v1}, Landroid/view/ViewGroup;->getChildCount()I

    move-result v0

    const/16 v3, 0x8

    if-ge v5, v0, :cond_5

    invoke-virtual {v1, v5}, Landroid/view/ViewGroup;->getChildAt(I)Landroid/view/View;

    move-result-object v0

    invoke-virtual {v0, v3}, Landroid/view/View;->setVisibility(I)V

    add-int/lit8 v5, v5, 0x1

    goto :goto_2

    :cond_5
    new-instance v0, Landroid/widget/FrameLayout$LayoutParams;

    const/4 v5, -0x2

    const/4 v7, -0x1

    invoke-direct {v0, v5, v7, v6}, Landroid/widget/FrameLayout$LayoutParams;-><init>(III)V

    invoke-virtual {v1, v4, v0}, Landroid/view/ViewGroup;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, v1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/dressroom/EditXf;->sSlot:Ljava/lang/ref/WeakReference;

    invoke-virtual {v4, v3}, Landroid/widget/LinearLayout;->setVisibility(I)V

    sget v0, Lcom/k4/dressroom/EditXf;->sFill:I

    invoke-static {v0, p0}, Lcom/k4/dressroom/EditXf;->select(ILandroid/view/View;)V

    const-string p0, "fill switch added"

    invoke-static {v2, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    return-object v4

    :cond_6
    :goto_3
    const-string p0, "fill switch: no preview_switch_title_layout"

    invoke-static {v2, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    return-object v3
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

.method static noStretch(Landroid/view/View;)V
    .locals 3

    const-string v0, "K4HomeClock"

    :try_start_0
    sget-object v1, Lcom/k4/dressroom/EditXf;->sKeepStretch:Ljava/lang/Boolean;

    if-nez v1, :cond_0

    invoke-static {}, Lcom/k4/dressroom/HomeClock;->debug()Ljava/lang/String;

    move-result-object v1

    const-string v2, "stretch"

    invoke-virtual {v1, v2}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v1

    invoke-static {v1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v1

    sput-object v1, Lcom/k4/dressroom/EditXf;->sKeepStretch:Ljava/lang/Boolean;

    :cond_0
    sget-object v1, Lcom/k4/dressroom/EditXf;->sKeepStretch:Ljava/lang/Boolean;

    invoke-virtual {v1}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v1

    if-eqz v1, :cond_1

    goto :goto_1

    :cond_1
    sget-object v1, Lcom/k4/dressroom/EditXf;->sEdge:Ljava/lang/reflect/Field;

    if-nez v1, :cond_4

    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v1

    :goto_0
    if-eqz v1, :cond_2

    sget-object v2, Lcom/k4/dressroom/EditXf;->sEdge:Ljava/lang/reflect/Field;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-nez v2, :cond_2

    :try_start_1
    const-string v2, "R"

    invoke-virtual {v1, v2}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v2

    sput-object v2, Lcom/k4/dressroom/EditXf;->sEdge:Ljava/lang/reflect/Field;
    :try_end_1
    .catch Ljava/lang/NoSuchFieldException; {:try_start_1 .. :try_end_1} :catch_0
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    :catch_0
    :try_start_2
    invoke-virtual {v1}, Ljava/lang/Class;->getSuperclass()Ljava/lang/Class;

    move-result-object v1

    goto :goto_0

    :cond_2
    sget-object v1, Lcom/k4/dressroom/EditXf;->sEdge:Ljava/lang/reflect/Field;

    if-nez v1, :cond_3

    goto :goto_1

    :cond_3
    const/4 v2, 0x1

    invoke-virtual {v1, v2}, Ljava/lang/reflect/Field;->setAccessible(Z)V

    :cond_4
    sget-object v1, Lcom/k4/dressroom/EditXf;->sEdge:Ljava/lang/reflect/Field;

    invoke-virtual {v1, p0}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    if-eqz v1, :cond_5

    sget-object v1, Lcom/k4/dressroom/EditXf;->sEdge:Ljava/lang/reflect/Field;

    const/4 v2, 0x0

    invoke-virtual {v1, p0, v2}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V

    const-string p0, "overscroll stretch off in the Home editor"

    invoke-static {v0, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    goto :goto_1

    :catchall_0
    move-exception p0

    const-string v1, "overscroll"

    invoke-static {v0, v1, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_5
    :goto_1
    return-void
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

.method static paint(Landroid/view/View;Landroid/graphics/Canvas;ZZ)V
    .locals 9

    move-object v0, p0

    check-cast v0, Landroid/widget/ImageView;

    invoke-static {p0}, Lcom/k4/dressroom/EditXf;->outer(Landroid/view/View;)Landroid/graphics/drawable/Drawable;

    move-result-object v1

    invoke-virtual {v0}, Landroid/widget/ImageView;->getDrawable()Landroid/graphics/drawable/Drawable;

    move-result-object v2

    const/4 v3, 0x0

    if-ne v2, v1, :cond_0

    instance-of v4, v1, Landroid/graphics/drawable/LayerDrawable;

    if-eqz v4, :cond_0

    move-object v4, v1

    check-cast v4, Landroid/graphics/drawable/LayerDrawable;

    invoke-virtual {v4}, Landroid/graphics/drawable/LayerDrawable;->getNumberOfLayers()I

    move-result v5

    if-lez v5, :cond_0

    invoke-virtual {v4, v3}, Landroid/graphics/drawable/LayerDrawable;->getDrawable(I)Landroid/graphics/drawable/Drawable;

    move-result-object v2

    :cond_0
    if-eqz v1, :cond_a

    if-nez v2, :cond_1

    goto/16 :goto_2

    :cond_1
    new-instance v4, Landroid/graphics/Rect;

    invoke-virtual {v1}, Landroid/graphics/drawable/Drawable;->getBounds()Landroid/graphics/Rect;

    move-result-object v5

    invoke-direct {v4, v5}, Landroid/graphics/Rect;-><init>(Landroid/graphics/Rect;)V

    invoke-static {v0}, Lcom/k4/dressroom/EditXf;->imageMatrix(Landroid/widget/ImageView;)Landroid/graphics/Matrix;

    move-result-object v5

    invoke-static {p0}, Lcom/k4/dressroom/EditXf;->matrix(Landroid/view/View;)Landroid/graphics/Matrix;

    move-result-object v6

    invoke-static {v2}, Lcom/k4/dressroom/EditXf;->bitmapOf(Landroid/graphics/drawable/Drawable;)Landroid/graphics/Bitmap;

    move-result-object v7

    invoke-static {p0, p1, v7}, Lcom/k4/dressroom/EditXf;->fill(Landroid/view/View;Landroid/graphics/Canvas;Landroid/graphics/Bitmap;)V

    if-eqz p2, :cond_4

    if-eqz v7, :cond_2

    invoke-virtual {v7}, Landroid/graphics/Bitmap;->getConfig()Landroid/graphics/Bitmap$Config;

    move-result-object v2

    sget-object v8, Landroid/graphics/Bitmap$Config;->HARDWARE:Landroid/graphics/Bitmap$Config;

    if-ne v2, v8, :cond_2

    sget-object v2, Landroid/graphics/Bitmap$Config;->ARGB_8888:Landroid/graphics/Bitmap$Config;

    invoke-virtual {v7, v2, v3}, Landroid/graphics/Bitmap;->copy(Landroid/graphics/Bitmap$Config;Z)Landroid/graphics/Bitmap;

    move-result-object v7

    :cond_2
    if-eqz v7, :cond_3

    new-instance v2, Landroid/graphics/drawable/BitmapDrawable;

    invoke-virtual {p0}, Landroid/view/View;->getResources()Landroid/content/res/Resources;

    move-result-object p0

    invoke-direct {v2, p0, v7}, Landroid/graphics/drawable/BitmapDrawable;-><init>(Landroid/content/res/Resources;Landroid/graphics/Bitmap;)V

    goto :goto_0

    :cond_3
    const/4 p0, 0x0

    move-object v2, p0

    :cond_4
    :goto_0
    invoke-virtual {p1}, Landroid/graphics/Canvas;->save()I

    move-result p0

    invoke-virtual {p1, v6}, Landroid/graphics/Canvas;->concat(Landroid/graphics/Matrix;)V

    invoke-virtual {p1, v5}, Landroid/graphics/Canvas;->concat(Landroid/graphics/Matrix;)V

    invoke-virtual {v0}, Landroid/widget/ImageView;->getColorFilter()Landroid/graphics/ColorFilter;

    move-result-object v0

    if-eqz v0, :cond_5

    new-instance v3, Landroid/graphics/Paint;

    invoke-direct {v3}, Landroid/graphics/Paint;-><init>()V

    invoke-virtual {v3, v0}, Landroid/graphics/Paint;->setColorFilter(Landroid/graphics/ColorFilter;)Landroid/graphics/ColorFilter;

    new-instance v0, Landroid/graphics/RectF;

    invoke-direct {v0, v4}, Landroid/graphics/RectF;-><init>(Landroid/graphics/Rect;)V

    invoke-virtual {p1, v0, v3}, Landroid/graphics/Canvas;->saveLayer(Landroid/graphics/RectF;Landroid/graphics/Paint;)I

    :cond_5
    const/4 v0, 0x1

    if-eqz v2, :cond_7

    instance-of v3, v2, Landroid/graphics/drawable/BitmapDrawable;

    if-eqz v3, :cond_6

    move-object v3, v2

    check-cast v3, Landroid/graphics/drawable/BitmapDrawable;

    invoke-virtual {v3, v0}, Landroid/graphics/drawable/BitmapDrawable;->setFilterBitmap(Z)V

    :cond_6
    invoke-virtual {v2, v4}, Landroid/graphics/drawable/Drawable;->setBounds(Landroid/graphics/Rect;)V

    invoke-virtual {v2, p1}, Landroid/graphics/drawable/Drawable;->draw(Landroid/graphics/Canvas;)V

    :cond_7
    if-eqz p3, :cond_9

    if-nez p2, :cond_9

    instance-of p2, v1, Landroid/graphics/drawable/LayerDrawable;

    if-eqz p2, :cond_9

    check-cast v1, Landroid/graphics/drawable/LayerDrawable;

    :goto_1
    invoke-virtual {v1}, Landroid/graphics/drawable/LayerDrawable;->getNumberOfLayers()I

    move-result p2

    if-ge v0, p2, :cond_9

    invoke-virtual {v1, v0}, Landroid/graphics/drawable/LayerDrawable;->getDrawable(I)Landroid/graphics/drawable/Drawable;

    move-result-object p2

    if-eqz p2, :cond_8

    invoke-virtual {p2}, Landroid/graphics/drawable/Drawable;->getAlpha()I

    move-result p3

    if-lez p3, :cond_8

    invoke-virtual {p2, p1}, Landroid/graphics/drawable/Drawable;->draw(Landroid/graphics/Canvas;)V

    :cond_8
    add-int/lit8 v0, v0, 0x1

    goto :goto_1

    :cond_9
    invoke-virtual {p1, p0}, Landroid/graphics/Canvas;->restoreToCount(I)V

    :cond_a
    :goto_2
    return-void
.end method

.method static rawFactor()F
    .locals 3

    sget v0, Lcom/k4/dressroom/EditXf;->sCount:I

    const/4 v1, 0x2

    if-lt v0, v1, :cond_0

    sget v0, Lcom/k4/dressroom/EditXf;->sSpanPrev:F

    const/high16 v1, 0x3f800000    # 1.0f

    cmpl-float v2, v0, v1

    if-lez v2, :cond_0

    sget v2, Lcom/k4/dressroom/EditXf;->sSpanNow:F

    cmpl-float v1, v2, v1

    if-lez v1, :cond_0

    div-float/2addr v2, v0

    return v2

    :cond_0
    const/high16 v0, 0x7fc00000    # Float.NaN

    return v0
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
    .locals 3

    const/high16 v0, 0x3f800000    # 1.0f

    sput v0, Lcom/k4/dressroom/EditXf;->s:F

    const/4 v0, 0x0

    sput v0, Lcom/k4/dressroom/EditXf;->deg:F

    sput v0, Lcom/k4/dressroom/EditXf;->tx:F

    sput v0, Lcom/k4/dressroom/EditXf;->ty:F

    const/4 v0, 0x0

    sput-boolean v0, Lcom/k4/dressroom/EditXf;->sRotating:Z

    sput v0, Lcom/k4/dressroom/EditXf;->sCount:I

    new-instance v1, Ljava/lang/ref/WeakReference;

    const/4 v2, 0x0

    invoke-direct {v1, v2}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v1, Lcom/k4/dressroom/EditXf;->sView:Ljava/lang/ref/WeakReference;

    sput-object v2, Lcom/k4/dressroom/EditXf;->sGuide:Lcom/k4/dressroom/EditXf$Guide;

    new-instance v1, Ljava/lang/ref/WeakReference;

    invoke-direct {v1, v2}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v1, Lcom/k4/dressroom/EditXf;->sBaked:Ljava/lang/ref/WeakReference;

    sput-object v2, Lcom/k4/dressroom/EditXf;->sBakedBg:Landroid/graphics/Bitmap;

    sput v0, Lcom/k4/dressroom/EditXf;->sFill:I

    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, v2}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/dressroom/EditXf;->sSwitch:Ljava/lang/ref/WeakReference;

    sput-object v2, Lcom/k4/dressroom/EditXf;->sKeepStretch:Ljava/lang/Boolean;

    return-void
.end method

.method public static scale(Landroid/view/View;F)F
    .locals 4

    invoke-static {p0}, Lcom/k4/dressroom/EditXf;->mine(Landroid/view/View;)Z

    move-result v0

    if-eqz v0, :cond_7

    const/high16 v0, 0x3f800000    # 1.0f

    cmpl-float v1, p1, v0

    if-eqz v1, :cond_7

    invoke-static {p1}, Ljava/lang/Float;->isNaN(F)Z

    move-result v1

    if-eqz v1, :cond_0

    goto :goto_1

    :cond_0
    :try_start_0
    invoke-static {}, Lcom/k4/dressroom/EditXf;->rawFactor()F

    move-result v1

    invoke-static {}, Lcom/k4/dressroom/EditXf;->identity()Z

    move-result v2

    if-nez v2, :cond_2

    invoke-static {v1}, Ljava/lang/Float;->isNaN(F)Z

    move-result v2

    if-nez v2, :cond_2

    cmpl-float p1, v1, v0

    if-nez p1, :cond_1

    return v0

    :cond_1
    move p1, v1

    :cond_2
    cmpg-float v1, p1, v0

    if-gez v1, :cond_4

    sget v1, Lcom/k4/dressroom/EditXf;->s:F

    cmpg-float v1, v1, v0

    if-ltz v1, :cond_3

    invoke-static {p0}, Lcom/k4/dressroom/EditXf;->atMin(Landroid/view/View;)Z

    move-result v1

    if-eqz v1, :cond_6

    :cond_3
    sget v1, Lcom/k4/dressroom/EditXf;->s:F

    mul-float/2addr v1, p1

    const/high16 v2, 0x3f000000    # 0.5f

    invoke-static {v2, v1}, Ljava/lang/Math;->max(FF)F

    move-result v1

    sput v1, Lcom/k4/dressroom/EditXf;->s:F

    invoke-static {p0}, Lcom/k4/dressroom/EditXf;->redraw(Landroid/view/View;)V

    return v0

    :cond_4
    sget v1, Lcom/k4/dressroom/EditXf;->s:F

    cmpg-float v1, v1, v0

    if-gez v1, :cond_6

    sget v1, Lcom/k4/dressroom/EditXf;->s:F

    mul-float/2addr v1, p1

    invoke-static {v0, v1}, Ljava/lang/Math;->min(FF)F

    move-result v1

    cmpl-float v2, v1, v0

    if-ltz v2, :cond_5

    const/4 v2, 0x0

    goto :goto_0

    :cond_5
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

    :cond_6
    return p1

    :catchall_0
    move-exception p0

    const-string v0, "K4HomeClock"

    const-string v1, "scale"

    invoke-static {v0, v1, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_7
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

.method static select(ILandroid/view/View;)V
    .locals 6

    sput p0, Lcom/k4/dressroom/EditXf;->sFill:I

    sget-object v0, Lcom/k4/dressroom/EditXf;->sColorLabel:Ljava/lang/ref/WeakReference;

    invoke-virtual {v0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/widget/TextView;

    sget-object v1, Lcom/k4/dressroom/EditXf;->sBlurLabel:Ljava/lang/ref/WeakReference;

    invoke-virtual {v1}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/widget/TextView;

    const/4 v2, 0x1

    if-eqz v0, :cond_4

    if-eqz v1, :cond_4

    const/high16 v3, 0x3f800000    # 1.0f

    const v4, 0x3ee66666    # 0.45f

    if-nez p0, :cond_0

    move v5, v3

    goto :goto_0

    :cond_0
    move v5, v4

    :goto_0
    invoke-virtual {v0, v5}, Landroid/widget/TextView;->setAlpha(F)V

    if-ne p0, v2, :cond_1

    goto :goto_1

    :cond_1
    move v3, v4

    :goto_1
    invoke-virtual {v1, v3}, Landroid/widget/TextView;->setAlpha(F)V

    const/4 v3, 0x0

    if-nez p0, :cond_2

    move v4, v2

    goto :goto_2

    :cond_2
    move v4, v3

    :goto_2
    invoke-virtual {v0, v4}, Landroid/widget/TextView;->setSelected(Z)V

    if-ne p0, v2, :cond_3

    move v3, v2

    :cond_3
    invoke-virtual {v1, v3}, Landroid/widget/TextView;->setSelected(Z)V

    :cond_4
    if-ne p0, v2, :cond_5

    const-string p0, "blur"

    goto :goto_3

    :cond_5
    const-string p0, "colour"

    :goto_3
    const-string v0, "fill: "

    invoke-virtual {v0, p0}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    const-string v0, "K4HomeClock"

    invoke-static {v0, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    invoke-static {p1}, Lcom/k4/dressroom/EditXf;->redraw(Landroid/view/View;)V

    return-void
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

.method static showSwitch(Landroid/view/View;Z)V
    .locals 4

    :try_start_0
    sget-object v0, Lcom/k4/dressroom/EditXf;->sSwitch:Ljava/lang/ref/WeakReference;

    invoke-virtual {v0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/view/View;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Landroid/view/View;->isAttachedToWindow()Z

    move-result v1

    if-nez v1, :cond_3

    :cond_0
    if-nez p1, :cond_1

    goto/16 :goto_1

    :cond_1
    invoke-static {p0}, Lcom/k4/dressroom/EditXf;->makeSwitch(Landroid/view/View;)Landroid/view/View;

    move-result-object v0

    if-nez v0, :cond_2

    goto/16 :goto_1

    :cond_2
    new-instance p0, Ljava/lang/ref/WeakReference;

    invoke-direct {p0, v0}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object p0, Lcom/k4/dressroom/EditXf;->sSwitch:Ljava/lang/ref/WeakReference;

    :cond_3
    sget-object p0, Lcom/k4/dressroom/EditXf;->sSlot:Ljava/lang/ref/WeakReference;

    invoke-virtual {p0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Landroid/view/View;

    invoke-virtual {v0}, Landroid/view/View;->getVisibility()I

    move-result v1

    const/4 v2, 0x0

    const/4 v3, 0x0

    if-nez v1, :cond_5

    invoke-virtual {v0}, Landroid/view/View;->getAlpha()F

    move-result v1

    cmpl-float v1, v1, v2

    if-lez v1, :cond_5

    if-eqz p0, :cond_4

    invoke-virtual {p0}, Landroid/view/View;->getVisibility()I

    move-result v1

    if-nez v1, :cond_5

    :cond_4
    const/4 v1, 0x1

    goto :goto_0

    :cond_5
    move v1, v3

    :goto_0
    if-ne p1, v1, :cond_6

    goto :goto_1

    :cond_6
    invoke-virtual {v0}, Landroid/view/View;->animate()Landroid/view/ViewPropertyAnimator;

    move-result-object v1

    invoke-virtual {v1}, Landroid/view/ViewPropertyAnimator;->cancel()V

    if-eqz p1, :cond_8

    if-eqz p0, :cond_7

    invoke-virtual {p0, v3}, Landroid/view/View;->setVisibility(I)V

    :cond_7
    invoke-virtual {v0, v2}, Landroid/view/View;->setAlpha(F)V

    invoke-virtual {v0, v3}, Landroid/view/View;->setVisibility(I)V

    invoke-virtual {v0}, Landroid/view/View;->animate()Landroid/view/ViewPropertyAnimator;

    move-result-object p0

    const/high16 p1, 0x3f800000    # 1.0f

    invoke-virtual {p0, p1}, Landroid/view/ViewPropertyAnimator;->alpha(F)Landroid/view/ViewPropertyAnimator;

    move-result-object p0

    const-wide/16 v0, 0x190

    invoke-virtual {p0, v0, v1}, Landroid/view/ViewPropertyAnimator;->setDuration(J)Landroid/view/ViewPropertyAnimator;

    move-result-object p0

    invoke-virtual {p0}, Landroid/view/ViewPropertyAnimator;->start()V

    return-void

    :cond_8
    invoke-virtual {v0}, Landroid/view/View;->animate()Landroid/view/ViewPropertyAnimator;

    move-result-object p1

    invoke-virtual {p1, v2}, Landroid/view/ViewPropertyAnimator;->alpha(F)Landroid/view/ViewPropertyAnimator;

    move-result-object p1

    const-wide/16 v1, 0x96

    invoke-virtual {p1, v1, v2}, Landroid/view/ViewPropertyAnimator;->setDuration(J)Landroid/view/ViewPropertyAnimator;

    move-result-object p1

    new-instance v1, Lcom/k4/dressroom/EditXf$2;

    invoke-direct {v1, v0, p0}, Lcom/k4/dressroom/EditXf$2;-><init>(Landroid/view/View;Landroid/view/View;)V

    invoke-virtual {p1, v1}, Landroid/view/ViewPropertyAnimator;->withEndAction(Ljava/lang/Runnable;)Landroid/view/ViewPropertyAnimator;

    move-result-object p0

    invoke-virtual {p0}, Landroid/view/ViewPropertyAnimator;->start()V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return-void

    :catchall_0
    move-exception p0

    const-string p1, "K4HomeClock"

    const-string v0, "fill switch"

    invoke-static {p1, v0, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :goto_1
    return-void
.end method

.method static showSwitchLater(Landroid/view/View;)V
    .locals 1

    new-instance v0, Lcom/k4/dressroom/EditXf$1;

    invoke-direct {v0, p0}, Lcom/k4/dressroom/EditXf$1;-><init>(Landroid/view/View;)V

    invoke-virtual {p0, v0}, Landroid/view/View;->post(Ljava/lang/Runnable;)Z

    return-void
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

.method static software(Landroid/graphics/Bitmap;)Landroid/graphics/Bitmap;
    .locals 2

    if-eqz p0, :cond_0

    invoke-virtual {p0}, Landroid/graphics/Bitmap;->getConfig()Landroid/graphics/Bitmap$Config;

    move-result-object v0

    sget-object v1, Landroid/graphics/Bitmap$Config;->HARDWARE:Landroid/graphics/Bitmap$Config;

    if-ne v0, v1, :cond_0

    sget-object v0, Landroid/graphics/Bitmap$Config;->ARGB_8888:Landroid/graphics/Bitmap$Config;

    const/4 v1, 0x0

    invoke-virtual {p0, v0, v1}, Landroid/graphics/Bitmap;->copy(Landroid/graphics/Bitmap$Config;Z)Landroid/graphics/Bitmap;

    move-result-object p0

    :cond_0
    return-object p0
.end method

.method static span(Landroid/view/MotionEvent;I)F
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
    invoke-virtual {p0, v0}, Landroid/view/MotionEvent;->getX(I)F

    move-result p1

    invoke-virtual {p0, v1}, Landroid/view/MotionEvent;->getX(I)F

    move-result v2

    sub-float/2addr p1, v2

    float-to-double v2, p1

    invoke-virtual {p0, v0}, Landroid/view/MotionEvent;->getY(I)F

    move-result p1

    invoke-virtual {p0, v1}, Landroid/view/MotionEvent;->getY(I)F

    move-result p0

    sub-float/2addr p1, p0

    float-to-double p0, p1

    invoke-static {v2, v3, p0, p1}, Ljava/lang/Math;->hypot(DD)D

    move-result-wide p0

    double-to-float p0, p0

    return p0
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

.method static subjectMask()Landroid/graphics/Bitmap;
    .locals 2

    sget-object v0, Lcom/k4/dressroom/HomeClock;->sSubjectView:Ljava/lang/ref/WeakReference;

    invoke-virtual {v0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/k4/dressroom/HomeClock$SubjectView;

    if-eqz v0, :cond_0

    iget-object v1, v0, Lcom/k4/dressroom/HomeClock$SubjectView;->subject:Landroid/graphics/drawable/BitmapDrawable;

    if-eqz v1, :cond_0

    iget-object v0, v0, Lcom/k4/dressroom/HomeClock$SubjectView;->subject:Landroid/graphics/drawable/BitmapDrawable;

    invoke-virtual {v0}, Landroid/graphics/drawable/BitmapDrawable;->getBitmap()Landroid/graphics/Bitmap;

    move-result-object v0

    return-object v0

    :cond_0
    const/4 v0, 0x0

    return-object v0
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

.method static tickConstant(Landroid/view/View;)I
    .locals 5

    const-string v0, "K4HomeClock"

    sget v1, Lcom/k4/dressroom/EditXf;->sTick:I

    const/4 v2, -0x1

    if-eq v1, v2, :cond_0

    return v1

    :cond_0
    const/4 v1, 0x1

    :try_start_0
    sget-object v2, Lcom/k4/dressroom/EditXf;->sSemIndex:Ljava/lang/reflect/Method;

    if-nez v2, :cond_1

    const-class v2, Landroid/view/HapticFeedbackConstants;

    const-string v3, "semGetVibrationIndex"

    sget-object v4, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    filled-new-array {v4}, [Ljava/lang/Class;

    move-result-object v4

    invoke-virtual {v2, v3, v4}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v2

    sput-object v2, Lcom/k4/dressroom/EditXf;->sSemIndex:Ljava/lang/reflect/Method;

    :cond_1
    sget-object v2, Lcom/k4/dressroom/EditXf;->sSemIndex:Ljava/lang/reflect/Method;

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    filled-new-array {v3}, [Ljava/lang/Object;

    move-result-object v3

    const/4 v4, 0x0

    invoke-virtual {v2, v4, v3}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/Integer;

    invoke-virtual {v2}, Ljava/lang/Integer;->intValue()I

    move-result v2
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    move-exception v2

    const-string v3, "level: no semGetVibrationIndex"

    invoke-static {v0, v3, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    const/4 v2, 0x4

    :goto_0
    :try_start_1
    invoke-virtual {p0}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object p0

    const-class v3, Landroid/os/Vibrator;

    invoke-virtual {p0, v3}, Landroid/content/Context;->getSystemService(Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Landroid/os/Vibrator;

    if-eqz p0, :cond_2

    const/4 v3, 0x2

    filled-new-array {v3}, [I

    move-result-object v3

    invoke-virtual {p0, v3}, Landroid/os/Vibrator;->areAllEffectsSupported([I)I

    move-result p0
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    if-eq p0, v1, :cond_2

    const/4 p0, 0x0

    move v2, p0

    goto :goto_1

    :catchall_1
    move-exception p0

    const-string v1, "level: vibrator info"

    invoke-static {v0, v1, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_2
    :goto_1
    sput v2, Lcom/k4/dressroom/EditXf;->sTick:I

    return v2
.end method

.method public static touch(Landroid/view/View;Landroid/view/MotionEvent;)Landroid/view/MotionEvent;
    .locals 17

    move-object/from16 v0, p0

    move-object/from16 v1, p1

    const-string v2, "K4HomeClock"

    sget-boolean v3, Lcom/k4/dressroom/HomeClock;->active:Z

    if-eqz v3, :cond_1f

    if-eqz v0, :cond_1f

    if-eqz v1, :cond_1f

    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/Class;->getName()Ljava/lang/String;

    move-result-object v3

    const-string v4, "com.samsung.android.app.dressroom.presentation.preview.widget.CropImageView"

    invoke-virtual {v4, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-nez v3, :cond_0

    goto/16 :goto_9

    :cond_0
    :try_start_0
    invoke-static {v0}, Lcom/k4/dressroom/EditXf;->handles(Landroid/view/View;)Z

    move-result v3

    if-nez v3, :cond_1

    goto/16 :goto_9

    :cond_1
    invoke-static {v0}, Lcom/k4/dressroom/EditXf;->noStretch(Landroid/view/View;)V

    sget-object v3, Lcom/k4/dressroom/EditXf;->sView:Ljava/lang/ref/WeakReference;

    invoke-virtual {v3}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v3

    if-eq v3, v0, :cond_3

    sget-object v3, Lcom/k4/dressroom/EditXf;->sView:Ljava/lang/ref/WeakReference;

    invoke-virtual {v3}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v3

    if-eqz v3, :cond_2

    invoke-static {}, Lcom/k4/dressroom/EditXf;->identity()Z

    move-result v3

    if-nez v3, :cond_2

    goto/16 :goto_9

    :cond_2
    new-instance v3, Ljava/lang/ref/WeakReference;

    invoke-direct {v3, v0}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v3, Lcom/k4/dressroom/EditXf;->sView:Ljava/lang/ref/WeakReference;

    :cond_3
    invoke-virtual {v1}, Landroid/view/MotionEvent;->getActionMasked()I

    move-result v3

    const/4 v4, -0x1

    const/4 v5, 0x6

    const/4 v6, 0x1

    if-eq v3, v5, :cond_5

    if-ne v3, v6, :cond_4

    goto :goto_0

    :cond_4
    move v7, v4

    goto :goto_1

    :cond_5
    :goto_0
    invoke-virtual {v1}, Landroid/view/MotionEvent;->getActionIndex()I

    move-result v7

    :goto_1
    const/4 v8, 0x0

    move v10, v8

    move v11, v10

    const/4 v12, 0x0

    const/4 v13, 0x0

    :goto_2
    invoke-virtual {v1}, Landroid/view/MotionEvent;->getPointerCount()I

    move-result v14

    if-ge v10, v14, :cond_7

    if-eq v10, v7, :cond_6

    invoke-virtual {v1, v10}, Landroid/view/MotionEvent;->getX(I)F

    move-result v14

    add-float/2addr v12, v14

    invoke-virtual {v1, v10}, Landroid/view/MotionEvent;->getY(I)F

    move-result v14

    add-float/2addr v13, v14

    add-int/lit8 v11, v11, 0x1

    :cond_6
    add-int/lit8 v10, v10, 0x1

    goto :goto_2

    :cond_7
    if-lez v11, :cond_8

    int-to-float v10, v11

    div-float/2addr v12, v10

    div-float/2addr v13, v10

    :cond_8
    if-nez v3, :cond_9

    sput-boolean v8, Lcom/k4/dressroom/EditXf;->sRotating:Z

    sput v8, Lcom/k4/dressroom/EditXf;->sCount:I

    :cond_9
    invoke-static {v1, v7}, Lcom/k4/dressroom/EditXf;->span(Landroid/view/MotionEvent;I)F

    move-result v10

    sget v14, Lcom/k4/dressroom/EditXf;->sCount:I

    const/high16 v15, 0x3f800000    # 1.0f

    const/16 v16, 0x0

    const/4 v9, 0x2

    if-ne v11, v14, :cond_10

    if-eq v3, v9, :cond_a

    goto/16 :goto_4

    :cond_a
    sget v7, Lcom/k4/dressroom/EditXf;->sSpanNow:F

    sput v7, Lcom/k4/dressroom/EditXf;->sSpanPrev:F

    sput v10, Lcom/k4/dressroom/EditXf;->sSpanNow:F

    sget v7, Lcom/k4/dressroom/EditXf;->s:F

    cmpg-float v7, v7, v15

    if-gez v7, :cond_c

    sget v7, Lcom/k4/dressroom/EditXf;->sFx:F

    cmpl-float v7, v12, v7

    if-nez v7, :cond_b

    sget v7, Lcom/k4/dressroom/EditXf;->sFy:F

    cmpl-float v7, v13, v7

    if-eqz v7, :cond_c

    :cond_b
    sget v7, Lcom/k4/dressroom/EditXf;->tx:F

    sget v10, Lcom/k4/dressroom/EditXf;->sFx:F

    sub-float v10, v12, v10

    add-float/2addr v7, v10

    sput v7, Lcom/k4/dressroom/EditXf;->tx:F

    sget v7, Lcom/k4/dressroom/EditXf;->ty:F

    sget v10, Lcom/k4/dressroom/EditXf;->sFy:F

    sub-float v10, v13, v10

    add-float/2addr v7, v10

    sput v7, Lcom/k4/dressroom/EditXf;->ty:F

    invoke-static {v0}, Lcom/k4/dressroom/EditXf;->clampT(Landroid/view/View;)V

    move v7, v6

    goto :goto_3

    :cond_c
    move v7, v8

    :goto_3
    sput v12, Lcom/k4/dressroom/EditXf;->sFx:F

    sput v13, Lcom/k4/dressroom/EditXf;->sFy:F

    if-lt v11, v9, :cond_12

    invoke-static {v1, v4}, Lcom/k4/dressroom/EditXf;->angle(Landroid/view/MotionEvent;I)F

    move-result v4

    sget-boolean v10, Lcom/k4/dressroom/EditXf;->sRotating:Z

    if-nez v10, :cond_d

    sget v10, Lcom/k4/dressroom/EditXf;->sRotStart:F

    sub-float v10, v4, v10

    invoke-static {v10}, Lcom/k4/dressroom/EditXf;->norm(F)F

    move-result v10

    invoke-static {v10}, Ljava/lang/Math;->abs(F)F

    move-result v10

    const/high16 v12, 0x40c00000    # 6.0f

    cmpl-float v10, v10, v12

    if-lez v10, :cond_d

    sput-boolean v6, Lcom/k4/dressroom/EditXf;->sRotating:Z

    sput v4, Lcom/k4/dressroom/EditXf;->sRotStart:F

    sget v10, Lcom/k4/dressroom/EditXf;->deg:F

    sput v10, Lcom/k4/dressroom/EditXf;->sRotBase:F

    invoke-static {v0, v6}, Lcom/k4/dressroom/EditXf;->guide(Landroid/view/View;Z)V

    :cond_d
    sget-boolean v10, Lcom/k4/dressroom/EditXf;->sRotating:Z

    if-eqz v10, :cond_12

    invoke-static {}, Lcom/k4/dressroom/EditXf;->shownDeg()F

    move-result v10

    sget v12, Lcom/k4/dressroom/EditXf;->sRotBase:F

    sget v13, Lcom/k4/dressroom/EditXf;->sRotStart:F

    sub-float/2addr v4, v13

    invoke-static {v4}, Lcom/k4/dressroom/EditXf;->norm(F)F

    move-result v4

    add-float/2addr v12, v4

    const/high16 v4, 0x42340000    # 45.0f

    invoke-static {v4, v12}, Ljava/lang/Math;->min(FF)F

    move-result v4

    const/high16 v12, -0x3dcc0000    # -45.0f

    invoke-static {v12, v4}, Ljava/lang/Math;->max(FF)F

    move-result v4

    sput v4, Lcom/k4/dressroom/EditXf;->deg:F

    invoke-static {}, Lcom/k4/dressroom/EditXf;->shownDeg()F

    move-result v4

    cmpl-float v12, v4, v10

    if-eqz v12, :cond_12

    cmpl-float v7, v4, v16

    if-eqz v7, :cond_e

    cmpl-float v7, v10, v16

    if-eqz v7, :cond_f

    invoke-static {v4}, Ljava/lang/Math;->signum(F)F

    move-result v4

    invoke-static {v10}, Ljava/lang/Math;->signum(F)F

    move-result v7

    cmpl-float v4, v4, v7

    if-eqz v4, :cond_f

    :cond_e
    invoke-static {v0}, Lcom/k4/dressroom/EditXf;->haptic(Landroid/view/View;)V

    :cond_f
    move v7, v6

    goto :goto_5

    :cond_10
    :goto_4
    sput v12, Lcom/k4/dressroom/EditXf;->sFx:F

    sput v13, Lcom/k4/dressroom/EditXf;->sFy:F

    sput v11, Lcom/k4/dressroom/EditXf;->sCount:I

    sput v10, Lcom/k4/dressroom/EditXf;->sSpanPrev:F

    sput v10, Lcom/k4/dressroom/EditXf;->sSpanNow:F

    if-lt v11, v9, :cond_11

    invoke-static {v1, v7}, Lcom/k4/dressroom/EditXf;->angle(Landroid/view/MotionEvent;I)F

    move-result v4

    sput v4, Lcom/k4/dressroom/EditXf;->sRotStart:F

    sget v4, Lcom/k4/dressroom/EditXf;->deg:F

    sput v4, Lcom/k4/dressroom/EditXf;->sRotBase:F

    :cond_11
    move v7, v8

    :cond_12
    :goto_5
    if-eq v3, v6, :cond_14

    const/4 v4, 0x3

    if-ne v3, v4, :cond_13

    goto :goto_6

    :cond_13
    move v4, v8

    goto :goto_7

    :cond_14
    :goto_6
    move v4, v6

    :goto_7
    if-nez v4, :cond_15

    if-ne v3, v5, :cond_1a

    if-ge v11, v9, :cond_1a

    :cond_15
    sget-boolean v3, Lcom/k4/dressroom/EditXf;->sRotating:Z

    if-eqz v3, :cond_16

    sput-boolean v8, Lcom/k4/dressroom/EditXf;->sRotating:Z

    invoke-static {v0, v8}, Lcom/k4/dressroom/EditXf;->guide(Landroid/view/View;Z)V

    :cond_16
    sget v3, Lcom/k4/dressroom/EditXf;->deg:F

    invoke-static {v3}, Ljava/lang/Math;->abs(F)F

    move-result v3

    const/high16 v5, 0x40000000    # 2.0f

    cmpg-float v3, v3, v5

    if-gez v3, :cond_17

    sget v3, Lcom/k4/dressroom/EditXf;->deg:F

    cmpl-float v3, v3, v16

    if-eqz v3, :cond_17

    sput v16, Lcom/k4/dressroom/EditXf;->deg:F

    :cond_17
    if-eqz v4, :cond_18

    sget v3, Lcom/k4/dressroom/EditXf;->s:F

    cmpg-float v3, v3, v15

    if-gez v3, :cond_18

    sget v3, Lcom/k4/dressroom/EditXf;->s:F

    const v5, 0x3f7851ec    # 0.97f

    cmpl-float v3, v3, v5

    if-lez v3, :cond_18

    sput v15, Lcom/k4/dressroom/EditXf;->s:F

    sput v16, Lcom/k4/dressroom/EditXf;->tx:F

    sput v16, Lcom/k4/dressroom/EditXf;->ty:F

    goto :goto_8

    :cond_18
    move v6, v7

    :goto_8
    if-eqz v4, :cond_19

    invoke-static {v0}, Lcom/k4/dressroom/EditXf;->showSwitchLater(Landroid/view/View;)V

    sget-object v3, Ljava/util/Locale;->US:Ljava/util/Locale;

    const-string v4, "home picture: scale %.3f, %.1f deg, offset %.0f,%.0f"

    sget v5, Lcom/k4/dressroom/EditXf;->s:F

    invoke-static {v5}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v5

    invoke-static {}, Lcom/k4/dressroom/EditXf;->shownDeg()F

    move-result v7

    invoke-static {v7}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v7

    sget v8, Lcom/k4/dressroom/EditXf;->tx:F

    invoke-static {v8}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v8

    sget v9, Lcom/k4/dressroom/EditXf;->ty:F

    invoke-static {v9}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v9

    filled-new-array {v5, v7, v8, v9}, [Ljava/lang/Object;

    move-result-object v5

    invoke-static {v3, v4, v5}, Ljava/lang/String;->format(Ljava/util/Locale;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v3

    invoke-static {v2, v3}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    :cond_19
    move v7, v6

    :cond_1a
    if-eqz v7, :cond_1b

    invoke-static {v0}, Lcom/k4/dressroom/EditXf;->redraw(Landroid/view/View;)V

    :cond_1b
    sget-object v3, Lcom/k4/dressroom/EditXf;->sGuide:Lcom/k4/dressroom/EditXf$Guide;

    if-eqz v3, :cond_1c

    invoke-virtual {v3}, Lcom/k4/dressroom/EditXf$Guide;->invalidateSelf()V

    :cond_1c
    invoke-static {}, Lcom/k4/dressroom/EditXf;->identity()Z

    move-result v3

    if-eqz v3, :cond_1d

    goto :goto_9

    :cond_1d
    new-instance v3, Landroid/graphics/Matrix;

    invoke-direct {v3}, Landroid/graphics/Matrix;-><init>()V

    invoke-static {v0}, Lcom/k4/dressroom/EditXf;->matrix(Landroid/view/View;)Landroid/graphics/Matrix;

    move-result-object v0

    invoke-virtual {v0, v3}, Landroid/graphics/Matrix;->invert(Landroid/graphics/Matrix;)Z

    invoke-static {v1}, Landroid/view/MotionEvent;->obtain(Landroid/view/MotionEvent;)Landroid/view/MotionEvent;

    move-result-object v0

    invoke-virtual {v0, v3}, Landroid/view/MotionEvent;->transform(Landroid/graphics/Matrix;)V

    sget-object v3, Lcom/k4/dressroom/EditXf;->sCopy:Landroid/view/MotionEvent;

    if-eqz v3, :cond_1e

    invoke-virtual {v3}, Landroid/view/MotionEvent;->recycle()V

    :cond_1e
    sput-object v0, Lcom/k4/dressroom/EditXf;->sCopy:Landroid/view/MotionEvent;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return-object v0

    :catchall_0
    move-exception v0

    const-string v3, "touch"

    invoke-static {v2, v3, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_1f
    :goto_9
    return-object v1
.end method
