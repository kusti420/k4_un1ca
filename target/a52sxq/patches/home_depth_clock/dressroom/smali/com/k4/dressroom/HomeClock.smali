.class public final Lcom/k4/dressroom/HomeClock;
.super Ljava/lang/Object;
.source "HomeClock.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/k4/dressroom/HomeClock$SubjectView;
    }
.end annotation


# static fields
.field static final BUNDLE_CLASS:Ljava/lang/String; = "com.samsung.android.lockscreen.editor.item.domain.entity.item.clock.wallpaperbundle.WallpaperClockBundle"

.field static final BUNDLE_CONVERT:Ljava/lang/String; = "yc.b0"

.field private static final CLOCK_DATA_PROVIDER:Ljava/lang/String; = "mf.o0"

.field static final ITEM_CLASS:Ljava/lang/String; = "com.samsung.android.sdk.aodservice.entities.item.LockScreenItem"

.field static final KEY_BUNDLE:Ljava/lang/String; = "k4_home_clock_bundle"

.field static final KEY_ITEM:Ljava/lang/String; = "k4_home_clock_item"

.field static final MENU_TAG:Ljava/lang/String; = "homeClock"

.field static final PROP:Ljava/lang/String; = "persist.sys.k4.home_depth_clock"

.field static final TAG:Ljava/lang/String; = "K4HomeClock"

.field public static volatile active:Z

.field static on:Z

.field private static sBundle:Ljava/lang/Object;

.field private static sBundleRead:Z

.field private static sController:Ljava/lang/ref/WeakReference;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/lang/ref/WeakReference<",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation
.end field

.field static volatile sDepth:Z

.field private static sEnforced:Ljava/lang/ref/WeakReference;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/lang/ref/WeakReference<",
            "Landroid/view/View;",
            ">;"
        }
    .end annotation
.end field

.field private static sIcon:I

.field private static sIconOn:I

.field private static sItem:Ljava/lang/ref/WeakReference;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/lang/ref/WeakReference<",
            "Lk6/m;",
            ">;"
        }
    .end annotation
.end field

.field private static sMediator:Ljava/lang/ref/WeakReference;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/lang/ref/WeakReference<",
            "Lp8/a;",
            ">;"
        }
    .end annotation
.end field

.field private static final sPut:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/Object;",
            "Ljava/util/Set<",
            "Ljava/lang/String;",
            ">;>;"
        }
    .end annotation
.end field

.field private static sRestored:Z

.field private static sResult:Ljava/lang/ref/WeakReference;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/lang/ref/WeakReference<",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation
.end field

.field private static sSavedStretch:Ljava/lang/Boolean;

.field private static sStore:Ljava/lang/ref/WeakReference;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/lang/ref/WeakReference<",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation
.end field

.field private static sStretchHeld:Z

.field private static sStretchWanted:Ljava/lang/Boolean;

.field private static sStyleField:Ljava/lang/reflect/Field;

.field private static sStyleItemField:Ljava/lang/reflect/Field;

.field static sSubjectView:Ljava/lang/ref/WeakReference;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/lang/ref/WeakReference<",
            "Lcom/k4/dressroom/HomeClock$SubjectView;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method static bridge synthetic -$$Nest$sfgetsEnforced()Ljava/lang/ref/WeakReference;
    .locals 1

    sget-object v0, Lcom/k4/dressroom/HomeClock;->sEnforced:Ljava/lang/ref/WeakReference;

    return-object v0
.end method

.method static bridge synthetic -$$Nest$sfgetsMediator()Ljava/lang/ref/WeakReference;
    .locals 1

    sget-object v0, Lcom/k4/dressroom/HomeClock;->sMediator:Ljava/lang/ref/WeakReference;

    return-object v0
.end method

.method static constructor <clinit>()V
    .locals 2

    new-instance v0, Ljava/lang/ref/WeakReference;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/dressroom/HomeClock;->sMediator:Ljava/lang/ref/WeakReference;

    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, v1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/dressroom/HomeClock;->sEnforced:Ljava/lang/ref/WeakReference;

    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, v1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/dressroom/HomeClock;->sItem:Ljava/lang/ref/WeakReference;

    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, v1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/dressroom/HomeClock;->sController:Ljava/lang/ref/WeakReference;

    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, v1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/dressroom/HomeClock;->sResult:Ljava/lang/ref/WeakReference;

    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, v1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/dressroom/HomeClock;->sSubjectView:Ljava/lang/ref/WeakReference;

    const/4 v0, 0x1

    sput-boolean v0, Lcom/k4/dressroom/HomeClock;->sDepth:Z

    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, v1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/dressroom/HomeClock;->sStore:Ljava/lang/ref/WeakReference;

    new-instance v0, Ljava/util/WeakHashMap;

    invoke-direct {v0}, Ljava/util/WeakHashMap;-><init>()V

    sput-object v0, Lcom/k4/dressroom/HomeClock;->sPut:Ljava/util/Map;

    return-void
.end method

.method private constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method static activity(Lp8/a;)Landroid/app/Activity;
    .locals 2

    iget-object p0, p0, Lp8/a;->g:Landroid/view/View;

    const/4 v0, 0x0

    if-nez p0, :cond_0

    return-object v0

    :cond_0
    invoke-virtual {p0}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object p0

    :goto_0
    instance-of v1, p0, Landroid/content/ContextWrapper;

    if-eqz v1, :cond_1

    instance-of v1, p0, Landroid/app/Activity;

    if-nez v1, :cond_1

    check-cast p0, Landroid/content/ContextWrapper;

    invoke-virtual {p0}, Landroid/content/ContextWrapper;->getBaseContext()Landroid/content/Context;

    move-result-object p0

    goto :goto_0

    :cond_1
    instance-of v1, p0, Landroid/app/Activity;

    if-eqz v1, :cond_2

    check-cast p0, Landroid/app/Activity;

    return-object p0

    :cond_2
    return-object v0
.end method

.method public static addMenu(Lo6/e0;[Lk6/m;)V
    .locals 9

    const-string v0, "drawable"

    const-string v1, "K4HomeClock"

    sget-boolean v2, Lcom/k4/dressroom/HomeClock;->active:Z

    if-eqz v2, :cond_6

    if-nez p1, :cond_0

    goto/16 :goto_2

    :cond_0
    const/4 v2, 0x0

    :goto_0
    :try_start_0
    array-length v3, p1

    const/4 v4, -0x1

    if-ge v2, v3, :cond_2

    aget-object v3, p1, v2

    if-nez v3, :cond_1

    goto :goto_1

    :cond_1
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    :cond_2
    move v2, v4

    :goto_1
    if-gez v2, :cond_3

    array-length p0, p1

    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v0, "addMenu: no free slot in "

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v1, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    return-void

    :cond_3
    iget-object v3, p0, Lo6/e0;->M:Landroid/app/Activity;

    const-string v5, "string"

    const-string v6, "clock_item_name"

    invoke-static {v3, v5, v6}, Lcom/k4/dressroom/HomeClock;->id(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)I

    move-result v5

    const-string v6, "preview_selector_icon_clock"

    invoke-static {v3, v0, v6}, Lcom/k4/dressroom/HomeClock;->id(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)I

    move-result v6

    new-instance v7, Lk6/m;

    if-eqz v5, :cond_4

    move v4, v5

    :cond_4
    new-instance v5, Lcom/k4/dressroom/HomeClock$2;

    invoke-direct {v5, p0}, Lcom/k4/dressroom/HomeClock$2;-><init>(Lo6/e0;)V

    const-string v8, "homeClock"

    invoke-direct {v7, v4, v6, v5, v8}, Lk6/m;-><init>(IILjava/lang/Runnable;Ljava/lang/String;)V

    sget-boolean v4, Lcom/k4/dressroom/HomeClock;->on:Z

    iput-boolean v4, v7, Lk6/m;->j:Z

    sput v6, Lcom/k4/dressroom/HomeClock;->sIcon:I

    const-string v4, "preview_menu_icon_clock_activated"

    invoke-static {v3, v0, v4}, Lcom/k4/dressroom/HomeClock;->id(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)I

    move-result v0

    sput v0, Lcom/k4/dressroom/HomeClock;->sIconOn:I

    sget-boolean v3, Lcom/k4/dressroom/HomeClock;->on:Z

    if-eqz v3, :cond_5

    if-eqz v0, :cond_5

    iput v0, v7, Lk6/m;->b:I

    :cond_5
    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, v7}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/dressroom/HomeClock;->sItem:Ljava/lang/ref/WeakReference;

    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, p0}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/dressroom/HomeClock;->sController:Ljava/lang/ref/WeakReference;

    aput-object v7, p1, v2
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return-void

    :catchall_0
    move-exception p0

    const-string p1, "addMenu"

    invoke-static {v1, p1, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_6
    :goto_2
    return-void
.end method

.method public static afterComponents(Lp8/a;)V
    .locals 2

    sget-boolean v0, Lcom/k4/dressroom/HomeClock;->active:Z

    if-nez v0, :cond_0

    goto :goto_0

    :cond_0
    :try_start_0
    invoke-static {p0}, Lcom/k4/dressroom/HomeClock;->applyVisibility(Lp8/a;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return-void

    :catchall_0
    move-exception p0

    const-string v0, "K4HomeClock"

    const-string v1, "afterComponents"

    invoke-static {v0, v1, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :goto_0
    return-void
.end method

.method static applyVisibility(Lp8/a;)V
    .locals 7

    iget-object v0, p0, Lp8/a;->g:Landroid/view/View;

    if-nez v0, :cond_0

    goto :goto_2

    :cond_0
    const/high16 v1, 0x3f800000    # 1.0f

    invoke-virtual {v0, v1}, Landroid/view/View;->setAlpha(F)V

    sget-boolean v1, Lcom/k4/dressroom/HomeClock;->on:Z

    const/4 v2, 0x0

    const/16 v3, 0x8

    if-eqz v1, :cond_1

    move v1, v2

    goto :goto_0

    :cond_1
    move v1, v3

    :goto_0
    invoke-virtual {v0, v1}, Landroid/view/View;->setVisibility(I)V

    invoke-static {p0}, Lcom/k4/dressroom/HomeClock;->hideLauncher(Lp8/a;)V

    sget-object p0, Lcom/k4/dressroom/HomeClock;->sEnforced:Ljava/lang/ref/WeakReference;

    invoke-virtual {p0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object p0

    if-eq p0, v0, :cond_2

    instance-of p0, v0, Landroid/view/ViewGroup;

    if-eqz p0, :cond_2

    new-instance p0, Ljava/lang/ref/WeakReference;

    invoke-direct {p0, v0}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object p0, Lcom/k4/dressroom/HomeClock;->sEnforced:Ljava/lang/ref/WeakReference;

    move-object p0, v0

    check-cast p0, Landroid/view/ViewGroup;

    invoke-virtual {v0}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object v1

    const-string v4, "lockstar_preview_container"

    const-string v5, "id"

    invoke-static {v1, v5, v4}, Lcom/k4/dressroom/HomeClock;->id(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)I

    move-result v1

    invoke-virtual {v0}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object v4

    const-string v6, "clock_preview"

    invoke-static {v4, v5, v6}, Lcom/k4/dressroom/HomeClock;->id(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)I

    move-result v4

    invoke-virtual {v0}, Landroid/view/View;->getViewTreeObserver()Landroid/view/ViewTreeObserver;

    move-result-object v0

    new-instance v5, Lcom/k4/dressroom/HomeClock$1;

    invoke-direct {v5, p0, v1, v4}, Lcom/k4/dressroom/HomeClock$1;-><init>(Landroid/view/ViewGroup;II)V

    invoke-virtual {v0, v5}, Landroid/view/ViewTreeObserver;->addOnPreDrawListener(Landroid/view/ViewTreeObserver$OnPreDrawListener;)V

    :cond_2
    sget-object p0, Lcom/k4/dressroom/HomeClock;->sSubjectView:Ljava/lang/ref/WeakReference;

    invoke-virtual {p0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Lcom/k4/dressroom/HomeClock$SubjectView;

    if-eqz p0, :cond_4

    sget-boolean v0, Lcom/k4/dressroom/HomeClock;->on:Z

    if-eqz v0, :cond_3

    sget-boolean v0, Lcom/k4/dressroom/HomeClock;->sDepth:Z

    if-eqz v0, :cond_3

    goto :goto_1

    :cond_3
    move v2, v3

    :goto_1
    invoke-virtual {p0, v2}, Lcom/k4/dressroom/HomeClock$SubjectView;->setVisibility(I)V

    :cond_4
    :goto_2
    return-void
.end method

.method public static begin(Lp8/a;)V
    .locals 6

    const-string v0, "editor which="

    const/4 v1, 0x0

    :try_start_0
    iget v2, p0, Lp8/a;->h:I

    and-int/lit8 v2, v2, 0x3

    const/4 v3, 0x1

    if-ne v2, v3, :cond_0

    iget-boolean v2, p0, Lp8/a;->j:Z

    if-nez v2, :cond_0

    move v2, v3

    goto :goto_0

    :cond_0
    move v2, v1

    :goto_0
    sput-boolean v2, Lcom/k4/dressroom/HomeClock;->active:Z

    sget-boolean v2, Lcom/k4/dressroom/HomeClock;->active:Z

    if-eqz v2, :cond_1

    invoke-static {}, Lcom/k4/dressroom/HomeClock;->propOn()Z

    move-result v2

    if-eqz v2, :cond_1

    move v2, v3

    goto :goto_1

    :cond_1
    move v2, v1

    :goto_1
    sput-boolean v2, Lcom/k4/dressroom/HomeClock;->on:Z

    new-instance v2, Ljava/lang/ref/WeakReference;

    invoke-direct {v2, p0}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v2, Lcom/k4/dressroom/HomeClock;->sMediator:Ljava/lang/ref/WeakReference;

    const/4 v2, 0x0

    sput-object v2, Lcom/k4/dressroom/HomeClock;->sBundle:Ljava/lang/Object;

    sput-boolean v1, Lcom/k4/dressroom/HomeClock;->sBundleRead:Z

    sput-boolean v1, Lcom/k4/dressroom/HomeClock;->sRestored:Z

    sput-object v2, Lcom/k4/dressroom/HomeClock;->sSavedStretch:Ljava/lang/Boolean;

    sput-boolean v1, Lcom/k4/dressroom/HomeClock;->sStretchHeld:Z

    sput-object v2, Lcom/k4/dressroom/HomeClock;->sStretchWanted:Ljava/lang/Boolean;

    sput-boolean v3, Lcom/k4/dressroom/HomeClock;->sDepth:Z

    sget-object v2, Lcom/k4/dressroom/HomeClock;->sPut:Ljava/util/Map;

    monitor-enter v2
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_1

    :try_start_1
    invoke-interface {v2}, Ljava/util/Map;->clear()V

    monitor-exit v2
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    :try_start_2
    invoke-static {}, Lcom/k4/dressroom/EditXf;->reset()V

    const-string v2, "K4HomeClock"

    iget v3, p0, Lp8/a;->h:I

    iget-boolean p0, p0, Lp8/a;->j:Z

    sget-boolean v4, Lcom/k4/dressroom/HomeClock;->active:Z

    if-eqz v4, :cond_3

    sget-boolean v4, Lcom/k4/dressroom/HomeClock;->on:Z

    if-eqz v4, :cond_2

    const-string v4, "on"

    goto :goto_2

    :cond_2
    const-string v4, "off"

    goto :goto_2

    :cond_3
    const-string v4, "not offered"

    :goto_2
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v0, " cover="

    invoke-virtual {v5, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5, p0}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    const-string p0, " -> home clock "

    invoke-virtual {v5, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v2, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_1

    return-void

    :catchall_0
    move-exception p0

    :try_start_3
    monitor-exit v2
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    :try_start_4
    throw p0
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_1

    :catchall_1
    move-exception p0

    sput-boolean v1, Lcom/k4/dressroom/HomeClock;->active:Z

    const-string v0, "K4HomeClock"

    const-string v1, "begin"

    invoke-static {v0, v1, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    return-void
.end method

.method public static bundle(Ljava/lang/Object;Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/Object;
    .locals 10

    const-string v0, "saved clock stretch unreadable, Samsung decides it: "

    const-string v1, "editor starts from the saved home clock place: "

    invoke-static {}, Lcom/k4/dressroom/HomeClock;->live()Z

    move-result v2

    if-nez v2, :cond_0

    goto/16 :goto_3

    :cond_0
    :try_start_0
    sget-object v2, Lcom/k4/dressroom/HomeClock;->sPut:Ljava/util/Map;

    monitor-enter v2
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_2

    :try_start_1
    invoke-interface {v2, p0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/util/Set;

    if-eqz p0, :cond_1

    invoke-static {p1}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p1

    invoke-interface {p0, p1}, Ljava/util/Set;->contains(Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_1

    monitor-exit v2

    return-object p2

    :cond_1
    monitor-exit v2
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    :try_start_2
    sget-boolean p0, Lcom/k4/dressroom/HomeClock;->sBundleRead:Z

    const/4 p1, 0x1

    if-nez p0, :cond_8

    sput-boolean p1, Lcom/k4/dressroom/HomeClock;->sBundleRead:Z

    sget-object p0, Lcom/k4/dressroom/HomeClock;->sStore:Ljava/lang/ref/WeakReference;

    invoke-virtual {p0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object p0

    const/4 v2, 0x0

    if-eqz p0, :cond_2

    const-string v3, "a"

    invoke-static {p0, v3}, Lcom/k4/dressroom/HomeClock;->field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Landroid/content/Context;

    goto :goto_0

    :cond_2
    sget-object p0, Lcom/k4/dressroom/HomeClock;->sMediator:Ljava/lang/ref/WeakReference;

    invoke-virtual {p0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object p0

    if-eqz p0, :cond_3

    sget-object p0, Lcom/k4/dressroom/HomeClock;->sMediator:Ljava/lang/ref/WeakReference;

    invoke-virtual {p0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Lp8/a;

    iget-object p0, p0, Lp8/a;->g:Landroid/view/View;

    if-eqz p0, :cond_3

    sget-object p0, Lcom/k4/dressroom/HomeClock;->sMediator:Ljava/lang/ref/WeakReference;

    invoke-virtual {p0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Lp8/a;

    iget-object p0, p0, Lp8/a;->g:Landroid/view/View;

    invoke-virtual {p0}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object p0

    goto :goto_0

    :cond_3
    move-object p0, v2

    :goto_0
    if-nez p0, :cond_4

    move-object v3, v2

    goto :goto_1

    :cond_4
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v3

    const-string v4, "k4_home_clock_bundle"

    invoke-static {v3, v4}, Landroid/provider/Settings$System;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    :goto_1
    const/4 v4, 0x0

    if-eqz v3, :cond_7

    invoke-virtual {v3}, Ljava/lang/String;->isEmpty()Z

    move-result v5

    if-nez v5, :cond_7

    const-class p0, Lcom/k4/dressroom/HomeClock;

    invoke-virtual {p0}, Ljava/lang/Class;->getClassLoader()Ljava/lang/ClassLoader;

    move-result-object p0

    const-string v5, "com.google.gson.Gson"

    invoke-static {v5, p1, p0}, Ljava/lang/Class;->forName(Ljava/lang/String;ZLjava/lang/ClassLoader;)Ljava/lang/Class;

    move-result-object v5

    invoke-virtual {v5, v2}, Ljava/lang/Class;->getConstructor([Ljava/lang/Class;)Ljava/lang/reflect/Constructor;

    move-result-object v5

    invoke-virtual {v5, v2}, Ljava/lang/reflect/Constructor;->newInstance([Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v6

    const-string v7, "fromJson"

    const-class v8, Ljava/lang/String;

    const-class v9, Ljava/lang/Class;

    filled-new-array {v8, v9}, [Ljava/lang/Class;

    move-result-object v8

    invoke-virtual {v6, v7, v8}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v6

    const-string v7, "com.samsung.android.lockscreen.editor.item.domain.entity.item.clock.wallpaperbundle.WallpaperClockBundle"

    invoke-static {v7, p1, p0}, Ljava/lang/Class;->forName(Ljava/lang/String;ZLjava/lang/ClassLoader;)Ljava/lang/Class;

    move-result-object p0

    filled-new-array {v3, p0}, [Ljava/lang/Object;

    move-result-object p0

    invoke-virtual {v6, v5, p0}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    sput-object p0, Lcom/k4/dressroom/HomeClock;->sBundle:Ljava/lang/Object;

    const-string v5, "K4HomeClock"

    invoke-static {p0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v6, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v5, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_2

    :try_start_3
    sget-object p0, Lcom/k4/dressroom/HomeClock;->sBundle:Ljava/lang/Object;

    const-string v1, "supportStretch"

    invoke-static {p0, v1}, Lcom/k4/dressroom/HomeClock;->field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p0

    instance-of v1, p0, Ljava/lang/Boolean;

    if-eqz v1, :cond_5

    const-string v1, "\"supportStretch\""

    invoke-virtual {v3, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v1

    if-eqz v1, :cond_5

    move-object v2, p0

    check-cast v2, Ljava/lang/Boolean;

    :cond_5
    sput-object v2, Lcom/k4/dressroom/HomeClock;->sSavedStretch:Ljava/lang/Boolean;

    if-eqz v2, :cond_6

    move v4, p1

    :cond_6
    sput-boolean v4, Lcom/k4/dressroom/HomeClock;->sStretchHeld:Z
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    goto :goto_2

    :catchall_0
    move-exception p0

    :try_start_4
    const-string v1, "K4HomeClock"

    invoke-static {p0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v1, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_2

    :cond_7
    if-nez p0, :cond_8

    sput-boolean v4, Lcom/k4/dressroom/HomeClock;->sBundleRead:Z

    :cond_8
    :goto_2
    sget-object p0, Lcom/k4/dressroom/HomeClock;->sBundle:Ljava/lang/Object;

    if-eqz p0, :cond_9

    sput-boolean p1, Lcom/k4/dressroom/HomeClock;->sRestored:Z
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_2

    return-object p0

    :cond_9
    :goto_3
    return-object p2

    :catchall_1
    move-exception p0

    :try_start_5
    monitor-exit v2
    :try_end_5
    .catchall {:try_start_5 .. :try_end_5} :catchall_1

    :try_start_6
    throw p0
    :try_end_6
    .catchall {:try_start_6 .. :try_end_6} :catchall_2

    :catchall_2
    move-exception p0

    const-string p1, "K4HomeClock"

    const-string v0, "bundle"

    invoke-static {p1, v0, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    return-object p2
.end method

.method public static bundlePut(Ljava/lang/Object;Ljava/lang/String;)V
    .locals 2

    invoke-static {}, Lcom/k4/dressroom/HomeClock;->live()Z

    move-result v0

    if-nez v0, :cond_0

    return-void

    :cond_0
    sget-object v0, Lcom/k4/dressroom/HomeClock;->sPut:Ljava/util/Map;

    monitor-enter v0

    :try_start_0
    invoke-interface {v0, p0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/util/Set;

    if-nez v1, :cond_1

    new-instance v1, Ljava/util/HashSet;

    invoke-direct {v1}, Ljava/util/HashSet;-><init>()V

    invoke-interface {v0, p0, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    :cond_1
    invoke-static {p1}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    invoke-interface {v1, p0}, Ljava/util/Set;->add(Ljava/lang/Object;)Z

    monitor-exit v0

    return-void

    :catchall_0
    move-exception p0

    monitor-exit v0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw p0
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

    const/4 v0, 0x1

    invoke-virtual {p1, v0}, Ljava/lang/reflect/Method;->setAccessible(Z)V

    invoke-virtual {p1, p0, v1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    return-object p0
.end method

.method static clockOnly(Landroid/view/ViewGroup;II)V
    .locals 17

    move-object/from16 v0, p0

    move/from16 v1, p2

    if-eqz p1, :cond_0

    invoke-virtual/range {p0 .. p1}, Landroid/view/ViewGroup;->findViewById(I)Landroid/view/View;

    move-result-object v2

    invoke-static {v2}, Lcom/k4/dressroom/HomeClock;->hide(Landroid/view/View;)V

    :cond_0
    const/4 v2, 0x0

    if-eqz v1, :cond_1

    invoke-virtual {v0, v1}, Landroid/view/ViewGroup;->findViewById(I)Landroid/view/View;

    move-result-object v1

    goto :goto_0

    :cond_1
    move-object v1, v2

    :goto_0
    instance-of v3, v1, Landroid/view/ViewGroup;

    const/4 v4, 0x0

    if-eqz v3, :cond_2

    move-object v3, v1

    check-cast v3, Landroid/view/ViewGroup;

    invoke-virtual {v3}, Landroid/view/ViewGroup;->getChildCount()I

    move-result v5

    if-lez v5, :cond_2

    invoke-virtual {v3, v4}, Landroid/view/ViewGroup;->getChildAt(I)Landroid/view/View;

    move-result-object v1

    :cond_2
    move-object v5, v2

    move v3, v4

    :goto_1
    invoke-virtual {v0}, Landroid/view/ViewGroup;->getChildCount()I

    move-result v6

    if-ge v3, v6, :cond_4

    invoke-virtual {v0, v3}, Landroid/view/ViewGroup;->getChildAt(I)Landroid/view/View;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/Class;->getName()Ljava/lang/String;

    move-result-object v6

    const-string v7, "ItemEditorContainer"

    invoke-virtual {v6, v7}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v6

    if-eqz v6, :cond_3

    invoke-virtual {v0, v3}, Landroid/view/ViewGroup;->getChildAt(I)Landroid/view/View;

    move-result-object v5

    check-cast v5, Landroid/view/ViewGroup;

    :cond_3
    add-int/lit8 v3, v3, 0x1

    goto :goto_1

    :cond_4
    if-eqz v5, :cond_b

    if-eqz v1, :cond_b

    invoke-virtual {v1}, Landroid/view/View;->getWidth()I

    move-result v0

    if-nez v0, :cond_5

    goto/16 :goto_5

    :cond_5
    const/4 v0, 0x2

    new-array v0, v0, [I

    invoke-virtual {v1, v0}, Landroid/view/View;->getLocationOnScreen([I)V

    new-instance v3, Landroid/graphics/Rect;

    aget v6, v0, v4

    const/4 v7, 0x1

    aget v8, v0, v7

    invoke-virtual {v1}, Landroid/view/View;->getWidth()I

    move-result v9

    int-to-float v9, v9

    invoke-static {v1}, Lcom/k4/dressroom/HomeClock;->scale(Landroid/view/View;)F

    move-result v10

    mul-float/2addr v9, v10

    invoke-static {v9}, Ljava/lang/Math;->round(F)I

    move-result v9

    add-int/2addr v9, v6

    aget v10, v0, v7

    invoke-virtual {v1}, Landroid/view/View;->getHeight()I

    move-result v11

    int-to-float v11, v11

    invoke-static {v1}, Lcom/k4/dressroom/HomeClock;->scale(Landroid/view/View;)F

    move-result v1

    mul-float/2addr v11, v1

    invoke-static {v11}, Ljava/lang/Math;->round(F)I

    move-result v1

    add-int/2addr v10, v1

    invoke-direct {v3, v6, v8, v9, v10}, Landroid/graphics/Rect;-><init>(IIII)V

    const-wide/16 v8, 0x0

    move v1, v4

    :goto_2
    invoke-virtual {v5}, Landroid/view/ViewGroup;->getChildCount()I

    move-result v6

    if-ge v1, v6, :cond_8

    invoke-virtual {v5, v1}, Landroid/view/ViewGroup;->getChildAt(I)Landroid/view/View;

    move-result-object v6

    invoke-virtual {v6}, Landroid/view/View;->getWidth()I

    move-result v10

    if-nez v10, :cond_6

    goto :goto_3

    :cond_6
    invoke-virtual {v6, v0}, Landroid/view/View;->getLocationOnScreen([I)V

    new-instance v10, Landroid/graphics/Rect;

    aget v11, v0, v4

    aget v12, v0, v7

    invoke-virtual {v6}, Landroid/view/View;->getWidth()I

    move-result v13

    int-to-float v13, v13

    invoke-static {v6}, Lcom/k4/dressroom/HomeClock;->scale(Landroid/view/View;)F

    move-result v14

    mul-float/2addr v13, v14

    invoke-static {v13}, Ljava/lang/Math;->round(F)I

    move-result v13

    add-int/2addr v13, v11

    aget v14, v0, v7

    invoke-virtual {v6}, Landroid/view/View;->getHeight()I

    move-result v15

    int-to-float v15, v15

    invoke-static {v6}, Lcom/k4/dressroom/HomeClock;->scale(Landroid/view/View;)F

    move-result v16

    mul-float v15, v15, v16

    invoke-static {v15}, Ljava/lang/Math;->round(F)I

    move-result v15

    add-int/2addr v14, v15

    invoke-direct {v10, v11, v12, v13, v14}, Landroid/graphics/Rect;-><init>(IIII)V

    invoke-virtual {v10, v3}, Landroid/graphics/Rect;->intersect(Landroid/graphics/Rect;)Z

    move-result v11

    if-eqz v11, :cond_7

    invoke-virtual {v10}, Landroid/graphics/Rect;->width()I

    move-result v11

    int-to-long v11, v11

    invoke-virtual {v10}, Landroid/graphics/Rect;->height()I

    move-result v10

    int-to-long v13, v10

    mul-long/2addr v11, v13

    cmp-long v10, v11, v8

    if-lez v10, :cond_7

    move-object v2, v6

    move-wide v8, v11

    :cond_7
    :goto_3
    add-int/lit8 v1, v1, 0x1

    goto :goto_2

    :cond_8
    if-nez v2, :cond_9

    goto :goto_5

    :cond_9
    :goto_4
    invoke-virtual {v5}, Landroid/view/ViewGroup;->getChildCount()I

    move-result v0

    if-ge v4, v0, :cond_b

    invoke-virtual {v5, v4}, Landroid/view/ViewGroup;->getChildAt(I)Landroid/view/View;

    move-result-object v0

    if-eq v0, v2, :cond_a

    invoke-virtual {v5, v4}, Landroid/view/ViewGroup;->getChildAt(I)Landroid/view/View;

    move-result-object v0

    invoke-static {v0}, Lcom/k4/dressroom/HomeClock;->hide(Landroid/view/View;)V

    :cond_a
    add-int/lit8 v4, v4, 0x1

    goto :goto_4

    :cond_b
    :goto_5
    return-void
.end method

.method static debug()Ljava/lang/String;
    .locals 2

    const-string v0, ""

    :try_start_0
    const-string v1, "persist.sys.k4.home_depth_clock_debug"

    invoke-static {v1}, Landroid/os/SemSystemProperties;->get(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-nez v1, :cond_0

    return-object v0

    :cond_0
    return-object v1

    :catchall_0
    return-object v0
.end method

.method static drawableBounds(Landroid/view/View;)Landroid/graphics/RectF;
    .locals 3

    const/4 v0, 0x0

    :try_start_0
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v1

    const-string v2, "getDrawableBounds"

    invoke-virtual {v1, v2, v0}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v1

    invoke-virtual {v1, p0, v0}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Landroid/graphics/RectF;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return-object p0

    :catchall_0
    return-object v0
.end method

.method static field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;
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

    invoke-virtual {v1, p0}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    return-object p0

    :cond_1
    new-instance p0, Ljava/lang/NoSuchFieldException;

    invoke-direct {p0, p1}, Ljava/lang/NoSuchFieldException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method public static filter(Ljava/util/Set;)Ljava/util/Set;
    .locals 6

    const-string v0, "K4HomeClock"

    if-eqz p0, :cond_4

    invoke-static {}, Lcom/k4/dressroom/HomeClock;->live()Z

    move-result v1

    if-nez v1, :cond_0

    goto :goto_1

    :cond_0
    :try_start_0
    new-instance v1, Ljava/util/HashSet;

    invoke-direct {v1}, Ljava/util/HashSet;-><init>()V

    invoke-interface {p0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v2

    :cond_1
    :goto_0
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_2

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    if-eqz v3, :cond_1

    const-string v4, "mf.o0"

    invoke-virtual {v3}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/Class;->getName()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_1

    invoke-interface {v1, v3}, Ljava/util/Set;->add(Ljava/lang/Object;)Z

    goto :goto_0

    :cond_2
    invoke-interface {v1}, Ljava/util/Set;->isEmpty()Z

    move-result v2

    if-eqz v2, :cond_3

    invoke-interface {p0}, Ljava/util/Set;->size()I

    move-result v1

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "filter: no clock item in "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, " items, leaving them"

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    return-object p0

    :cond_3
    invoke-interface {p0}, Ljava/util/Set;->size()I

    move-result v2

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "filter: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v2, " lock items -> clock only"

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v0, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return-object v1

    :catchall_0
    move-exception v1

    const-string v2, "filter"

    invoke-static {v0, v2, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_4
    :goto_1
    return-object p0
.end method

.method static findField(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/reflect/Field;
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/Class<",
            "*>;",
            "Ljava/lang/String;",
            ")",
            "Ljava/lang/reflect/Field;"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/NoSuchFieldException;
        }
    .end annotation

    :goto_0
    if-eqz p0, :cond_0

    :try_start_0
    invoke-virtual {p0, p1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v0

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Ljava/lang/reflect/Field;->setAccessible(Z)V
    :try_end_0
    .catch Ljava/lang/NoSuchFieldException; {:try_start_0 .. :try_end_0} :catch_0

    return-object v0

    :catch_0
    invoke-virtual {p0}, Ljava/lang/Class;->getSuperclass()Ljava/lang/Class;

    move-result-object p0

    goto :goto_0

    :cond_0
    new-instance p0, Ljava/lang/NoSuchFieldException;

    invoke-direct {p0, p1}, Ljava/lang/NoSuchFieldException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method static gson(Ljava/lang/Object;)Ljava/lang/Object;
    .locals 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    const-string v0, "c"

    invoke-static {p0, v0}, Lcom/k4/dressroom/HomeClock;->field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p0

    const-string v1, "get"

    invoke-static {p0, v1}, Lcom/k4/dressroom/HomeClock;->call(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p0

    const-string v2, "b"

    invoke-static {p0, v2}, Lcom/k4/dressroom/HomeClock;->field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p0

    invoke-static {p0, v1}, Lcom/k4/dressroom/HomeClock;->call(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p0

    invoke-static {p0, v0}, Lcom/k4/dressroom/HomeClock;->field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p0

    invoke-static {p0, v1}, Lcom/k4/dressroom/HomeClock;->call(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p0

    invoke-static {p0, v2}, Lcom/k4/dressroom/HomeClock;->field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p0

    return-object p0
.end method

.method static hide(Landroid/view/View;)V
    .locals 2

    if-eqz p0, :cond_0

    invoke-virtual {p0}, Landroid/view/View;->getVisibility()I

    move-result v0

    const/16 v1, 0x8

    if-eq v0, v1, :cond_0

    invoke-virtual {p0, v1}, Landroid/view/View;->setVisibility(I)V

    :cond_0
    return-void
.end method

.method static hideLauncher(Lp8/a;)V
    .locals 2

    iget-object p0, p0, Lp8/a;->f:Landroid/view/View;

    sget-boolean v0, Lcom/k4/dressroom/HomeClock;->active:Z

    if-eqz v0, :cond_0

    if-eqz p0, :cond_0

    invoke-virtual {p0}, Landroid/view/View;->getVisibility()I

    move-result v0

    const/4 v1, 0x4

    if-eq v0, v1, :cond_0

    invoke-virtual {p0}, Landroid/view/View;->animate()Landroid/view/ViewPropertyAnimator;

    move-result-object v0

    invoke-virtual {v0}, Landroid/view/ViewPropertyAnimator;->cancel()V

    invoke-virtual {p0, v1}, Landroid/view/View;->setVisibility(I)V

    const-string p0, "K4HomeClock"

    const-string v0, "launcher preview hidden"

    invoke-static {p0, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    :cond_0
    return-void
.end method

.method static id(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)I
    .locals 1

    invoke-virtual {p0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    invoke-virtual {p0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object p0

    invoke-virtual {v0, p2, p1, p0}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I

    move-result p0

    return p0
.end method

.method static live()Z
    .locals 3

    sget-boolean v0, Lcom/k4/dressroom/HomeClock;->active:Z

    const/4 v1, 0x0

    if-nez v0, :cond_0

    return v1

    :cond_0
    sget-object v0, Lcom/k4/dressroom/HomeClock;->sMediator:Ljava/lang/ref/WeakReference;

    invoke-virtual {v0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lp8/a;

    if-eqz v0, :cond_1

    invoke-static {v0}, Lcom/k4/dressroom/HomeClock;->activity(Lp8/a;)Landroid/app/Activity;

    move-result-object v2

    goto :goto_0

    :cond_1
    const/4 v2, 0x0

    :goto_0
    if-eqz v0, :cond_5

    if-eqz v2, :cond_2

    invoke-virtual {v2}, Landroid/app/Activity;->isDestroyed()Z

    move-result v0

    if-eqz v0, :cond_2

    goto :goto_2

    :cond_2
    if-eqz v2, :cond_4

    invoke-virtual {v2}, Landroid/app/Activity;->isFinishing()Z

    move-result v0

    if-nez v0, :cond_3

    goto :goto_1

    :cond_3
    return v1

    :cond_4
    :goto_1
    const/4 v0, 0x1

    return v0

    :cond_5
    :goto_2
    sput-boolean v1, Lcom/k4/dressroom/HomeClock;->active:Z

    sput-boolean v1, Lcom/k4/dressroom/HomeClock;->on:Z

    const-string v0, "K4HomeClock"

    const-string v2, "home editor closed: lock clock data for everything else again"

    invoke-static {v0, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    return v1
.end method

.method public static menuScrolls()Z
    .locals 1

    sget-boolean v0, Lcom/k4/dressroom/HomeClock;->active:Z

    xor-int/lit8 v0, v0, 0x1

    return v0
.end method

.method public static menuSize(I)I
    .locals 1

    sget-boolean v0, Lcom/k4/dressroom/HomeClock;->active:Z

    if-eqz v0, :cond_0

    if-lez p0, :cond_0

    add-int/lit8 p0, p0, 0x1

    :cond_0
    return p0
.end method

.method public static onHomeSave(Ljava/lang/Object;)V
    .locals 22

    const-string v1, "0"

    const-string v2, "1"

    const-string v3, "com.google.gson.Gson"

    const-string v0, "a"

    const-string v4, "toJson"

    const-string v5, ""

    const-string v6, ","

    const-string v7, "K4HomeClock"

    sget-boolean v8, Lcom/k4/dressroom/HomeClock;->active:Z

    if-nez v8, :cond_0

    goto/16 :goto_11

    :cond_0
    :try_start_0
    const-string v8, "g0"

    move-object/from16 v9, p0

    invoke-static {v9, v8}, Lcom/k4/dressroom/HomeClock;->field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v8

    invoke-static {v8, v0}, Lcom/k4/dressroom/HomeClock;->field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v8

    const-string v9, "getData"

    invoke-static {v8, v9}, Lcom/k4/dressroom/HomeClock;->call(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v8

    sget-object v9, Lcom/k4/dressroom/HomeClock;->sStore:Ljava/lang/ref/WeakReference;

    invoke-virtual {v9}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v9

    if-eqz v9, :cond_1

    invoke-static {v9, v0}, Lcom/k4/dressroom/HomeClock;->field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/content/Context;

    move-object v11, v0

    goto :goto_0

    :cond_1
    const/4 v11, 0x0

    :goto_0
    if-eqz v8, :cond_10

    if-eqz v9, :cond_10

    if-nez v11, :cond_2

    goto/16 :goto_10

    :cond_2
    invoke-virtual {v9}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Class;->getMethods()[Ljava/lang/reflect/Method;

    move-result-object v0

    array-length v12, v0

    const/4 v14, 0x0

    const/4 v15, 0x0

    :goto_1
    if-ge v14, v12, :cond_4

    aget-object v16, v0, v14

    const/16 p0, 0x0

    invoke-virtual/range {v16 .. v16}, Ljava/lang/reflect/Method;->getName()Ljava/lang/String;

    move-result-object v13

    const-string v10, "d"

    invoke-virtual {v13, v10}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v10

    if-eqz v10, :cond_3

    invoke-virtual/range {v16 .. v16}, Ljava/lang/reflect/Method;->getParameterTypes()[Ljava/lang/Class;

    move-result-object v10

    array-length v10, v10

    const/4 v13, 0x3

    if-ne v10, v13, :cond_3

    invoke-virtual/range {v16 .. v16}, Ljava/lang/reflect/Method;->getParameterTypes()[Ljava/lang/Class;

    move-result-object v10

    const/4 v13, 0x2

    aget-object v10, v10, v13

    const-class v13, Landroid/os/Bundle;

    if-ne v10, v13, :cond_3

    move-object/from16 v15, v16

    :cond_3
    add-int/lit8 v14, v14, 0x1

    goto :goto_1

    :cond_4
    const/16 p0, 0x0

    new-instance v10, Landroid/os/Bundle;

    invoke-direct {v10}, Landroid/os/Bundle;-><init>()V

    invoke-virtual {v9}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Class;->getClassLoader()Ljava/lang/ClassLoader;

    move-result-object v12
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_d

    const/4 v13, 0x1

    :try_start_1
    const-string v0, "com.samsung.android.lockscreen.editor.item.domain.entity.item.clock.ClockMarginData"

    invoke-static {v0, v13, v12}, Ljava/lang/Class;->forName(Ljava/lang/String;ZLjava/lang/ClassLoader;)Ljava/lang/Class;

    move-result-object v0

    sget-object v14, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    sget-object v13, Ljava/lang/Float;->TYPE:Ljava/lang/Class;
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_2

    move-object/from16 v17, v1

    :try_start_2
    sget-object v1, Ljava/lang/Float;->TYPE:Ljava/lang/Class;
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_1

    move-object/from16 v18, v2

    :try_start_3
    const-class v2, Landroid/graphics/RectF;

    filled-new-array {v14, v13, v1, v2}, [Ljava/lang/Class;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/Class;->getConstructor([Ljava/lang/Class;)Ljava/lang/reflect/Constructor;

    move-result-object v0

    const-string v1, "getGravity"

    invoke-static {v8, v1}, Lcom/k4/dressroom/HomeClock;->call(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v1

    const-string v2, "getHorizontalMarginRatio"

    invoke-static {v8, v2}, Lcom/k4/dressroom/HomeClock;->call(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v2

    const-string v13, "getBottomMarginRatio"

    invoke-static {v8, v13}, Lcom/k4/dressroom/HomeClock;->call(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v13

    const-string v14, "getMovableAreaRatioRect"

    invoke-static {v8, v14}, Lcom/k4/dressroom/HomeClock;->call(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v14

    filled-new-array {v1, v2, v13, v14}, [Ljava/lang/Object;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/reflect/Constructor;->newInstance([Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    const/4 v1, 0x1

    invoke-static {v3, v1, v12}, Ljava/lang/Class;->forName(Ljava/lang/String;ZLjava/lang/ClassLoader;)Ljava/lang/Class;

    move-result-object v2

    const/4 v1, 0x0

    invoke-virtual {v2, v1}, Ljava/lang/Class;->getConstructor([Ljava/lang/Class;)Ljava/lang/reflect/Constructor;

    move-result-object v2

    invoke-virtual {v2, v1}, Ljava/lang/reflect/Constructor;->newInstance([Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    const-string v1, "clock_position_data"

    invoke-virtual {v2}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v13

    const-class v14, Ljava/lang/Object;

    filled-new-array {v14}, [Ljava/lang/Class;

    move-result-object v14

    invoke-virtual {v13, v4, v14}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v13

    filled-new-array {v0}, [Ljava/lang/Object;

    move-result-object v0

    invoke-virtual {v13, v2, v0}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/String;

    invoke-virtual {v10, v1, v0}, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V

    const-string v0, "clock_movable_area"

    const-string v1, "getMovableArea"

    invoke-static {v8, v1}, Lcom/k4/dressroom/HomeClock;->call(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/graphics/Rect;

    invoke-virtual {v10, v0, v1}, Landroid/os/Bundle;->putParcelable(Ljava/lang/String;Landroid/os/Parcelable;)V
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    goto :goto_4

    :catchall_0
    move-exception v0

    goto :goto_3

    :catchall_1
    move-exception v0

    goto :goto_2

    :catchall_2
    move-exception v0

    move-object/from16 v17, v1

    :goto_2
    move-object/from16 v18, v2

    :goto_3
    :try_start_4
    const-string v1, "home apply: clock position"

    invoke-static {v7, v1, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :goto_4
    const/4 v1, 0x0

    filled-new-array {v8, v1, v10}, [Ljava/lang/Object;

    move-result-object v0

    invoke-virtual {v15, v9, v0}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_d

    :try_start_5
    const-string v0, "getClockPositionRect"

    invoke-static {v8, v0}, Lcom/k4/dressroom/HomeClock;->call(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/graphics/Rect;

    const-string v2, "getScale"

    invoke-static {v8, v2}, Lcom/k4/dressroom/HomeClock;->call(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v2
    :try_end_5
    .catchall {:try_start_5 .. :try_end_5} :catchall_b

    :try_start_6
    const-string v10, "getFontColorType"

    invoke-static {v8, v10}, Lcom/k4/dressroom/HomeClock;->call(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v10

    instance-of v13, v10, Ljava/lang/Enum;

    if-eqz v13, :cond_6

    const-string v13, "BLACK"

    move-object v14, v10

    check-cast v14, Ljava/lang/Enum;

    invoke-virtual {v14}, Ljava/lang/Enum;->name()Ljava/lang/String;

    move-result-object v14

    invoke-virtual {v13, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v13

    if-eqz v13, :cond_5

    move-object/from16 v10, v18

    goto :goto_5

    :cond_5
    const-string v13, "WHITE"

    check-cast v10, Ljava/lang/Enum;

    invoke-virtual {v10}, Ljava/lang/Enum;->name()Ljava/lang/String;

    move-result-object v10

    invoke-virtual {v13, v10}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v10
    :try_end_6
    .catchall {:try_start_6 .. :try_end_6} :catchall_3

    if-eqz v10, :cond_6

    move-object/from16 v10, v17

    goto :goto_5

    :catchall_3
    :cond_6
    move-object v10, v5

    :goto_5
    :try_start_7
    invoke-virtual {v8}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v13

    invoke-virtual {v13}, Ljava/lang/Class;->getMethods()[Ljava/lang/reflect/Method;

    move-result-object v13

    array-length v14, v13
    :try_end_7
    .catchall {:try_start_7 .. :try_end_7} :catchall_4

    move/from16 v15, p0

    :goto_6
    if-ge v15, v14, :cond_9

    move-object/from16 v19, v2

    :try_start_8
    aget-object v2, v13, v15
    :try_end_8
    .catchall {:try_start_8 .. :try_end_8} :catchall_5

    move-object/from16 v20, v5

    :try_start_9
    invoke-virtual {v2}, Ljava/lang/reflect/Method;->getParameterTypes()[Ljava/lang/Class;

    move-result-object v5

    array-length v5, v5

    if-nez v5, :cond_7

    invoke-virtual {v2}, Ljava/lang/reflect/Method;->getReturnType()Ljava/lang/Class;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/Class;->getName()Ljava/lang/String;

    move-result-object v5
    :try_end_9
    .catchall {:try_start_9 .. :try_end_9} :catchall_6

    move-object/from16 v21, v9

    :try_start_a
    const-string v9, ".ClockColorData"

    invoke-virtual {v5, v9}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v5

    if-eqz v5, :cond_8

    const/4 v5, 0x0

    invoke-virtual {v2, v8, v5}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    if-eqz v2, :cond_a

    sget-object v5, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    const-string v9, "isAdaptiveColor"

    invoke-static {v2, v9}, Lcom/k4/dressroom/HomeClock;->call(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v9

    invoke-virtual {v5, v9}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v5

    if-eqz v5, :cond_a

    const-string v5, "getAdaptiveColor"

    invoke-static {v2, v5}, Lcom/k4/dressroom/HomeClock;->call(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/Integer;

    invoke-virtual {v2}, Ljava/lang/Integer;->intValue()I

    move-result v2

    invoke-static {v2}, Ljava/lang/Integer;->toString(I)Ljava/lang/String;

    move-result-object v2
    :try_end_a
    .catchall {:try_start_a .. :try_end_a} :catchall_7

    move-object v5, v2

    goto :goto_8

    :cond_7
    move-object/from16 v21, v9

    :cond_8
    add-int/lit8 v15, v15, 0x1

    move-object/from16 v2, v19

    move-object/from16 v5, v20

    move-object/from16 v9, v21

    goto :goto_6

    :cond_9
    move-object/from16 v19, v2

    move-object/from16 v20, v5

    goto :goto_7

    :catchall_4
    move-object/from16 v19, v2

    :catchall_5
    move-object/from16 v20, v5

    :catchall_6
    :goto_7
    move-object/from16 v21, v9

    :catchall_7
    :cond_a
    move-object/from16 v5, v20

    :goto_8
    :try_start_b
    invoke-virtual {v11}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v2

    const-string v9, "k4_home_clock_item_rect"

    iget v13, v0, Landroid/graphics/Rect;->left:I

    iget v14, v0, Landroid/graphics/Rect;->top:I

    iget v15, v0, Landroid/graphics/Rect;->right:I

    iget v0, v0, Landroid/graphics/Rect;->bottom:I
    :try_end_b
    .catchall {:try_start_b .. :try_end_b} :catchall_a

    move-object/from16 v20, v11

    :try_start_c
    invoke-static/range {v19 .. v19}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v11
    :try_end_c
    .catchall {:try_start_c .. :try_end_c} :catchall_9

    move-object/from16 v19, v1

    :try_start_d
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v13}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v14}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v15}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v2, v9, v0}, Landroid/provider/Settings$System;->putString(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z
    :try_end_d
    .catchall {:try_start_d .. :try_end_d} :catchall_8

    goto :goto_b

    :catchall_8
    move-exception v0

    goto :goto_a

    :catchall_9
    move-exception v0

    move-object/from16 v19, v1

    goto :goto_a

    :catchall_a
    move-exception v0

    move-object/from16 v19, v1

    goto :goto_9

    :catchall_b
    move-exception v0

    move-object/from16 v19, v1

    move-object/from16 v21, v9

    :goto_9
    move-object/from16 v20, v11

    :goto_a
    :try_start_e
    const-string v1, "home apply: clock rect"

    invoke-static {v7, v1, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    :try_end_e
    .catchall {:try_start_e .. :try_end_e} :catchall_d

    :goto_b
    :try_start_f
    const-string v0, "yc.b0"

    const/4 v1, 0x1

    invoke-static {v0, v1, v12}, Ljava/lang/Class;->forName(Ljava/lang/String;ZLjava/lang/ClassLoader;)Ljava/lang/Class;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Class;->getMethods()[Ljava/lang/reflect/Method;

    move-result-object v0

    array-length v1, v0

    const/4 v2, 0x0

    move/from16 v5, p0

    :goto_c
    if-ge v5, v1, :cond_c

    aget-object v6, v0, v5

    invoke-virtual {v6}, Ljava/lang/reflect/Method;->getName()Ljava/lang/String;

    move-result-object v9

    const-string v10, "b"

    invoke-virtual {v9, v10}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v9

    if-eqz v9, :cond_b

    invoke-virtual {v6}, Ljava/lang/reflect/Method;->getModifiers()I

    move-result v9

    invoke-static {v9}, Ljava/lang/reflect/Modifier;->isStatic(I)Z

    move-result v9

    if-eqz v9, :cond_b

    invoke-virtual {v6}, Ljava/lang/reflect/Method;->getParameterTypes()[Ljava/lang/Class;

    move-result-object v9

    array-length v9, v9

    const/4 v10, 0x1

    if-ne v9, v10, :cond_b

    invoke-virtual {v6}, Ljava/lang/reflect/Method;->getParameterTypes()[Ljava/lang/Class;

    move-result-object v9

    aget-object v9, v9, p0

    invoke-virtual {v9, v8}, Ljava/lang/Class;->isInstance(Ljava/lang/Object;)Z

    move-result v9

    if-eqz v9, :cond_b

    invoke-virtual {v6}, Ljava/lang/reflect/Method;->getReturnType()Ljava/lang/Class;

    move-result-object v9

    invoke-virtual {v9}, Ljava/lang/Class;->getName()Ljava/lang/String;

    move-result-object v9

    const-string v10, "com.samsung.android.lockscreen.editor.item.domain.entity.item.clock.wallpaperbundle.WallpaperClockBundle"

    invoke-virtual {v9, v10}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v9

    if-eqz v9, :cond_b

    filled-new-array {v8}, [Ljava/lang/Object;

    move-result-object v2

    const/4 v9, 0x0

    invoke-virtual {v6, v9, v2}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    :cond_b
    add-int/lit8 v5, v5, 0x1

    goto :goto_c

    :cond_c
    if-eqz v2, :cond_d

    const/4 v1, 0x1

    invoke-static {v3, v1, v12}, Ljava/lang/Class;->forName(Ljava/lang/String;ZLjava/lang/ClassLoader;)Ljava/lang/Class;

    move-result-object v0

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Ljava/lang/Class;->getConstructor([Ljava/lang/Class;)Ljava/lang/reflect/Constructor;

    move-result-object v0

    invoke-virtual {v0, v1}, Ljava/lang/reflect/Constructor;->newInstance([Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v1

    const-class v3, Ljava/lang/Object;

    filled-new-array {v3}, [Ljava/lang/Class;

    move-result-object v3

    invoke-virtual {v1, v4, v3}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v1

    filled-new-array {v2}, [Ljava/lang/Object;

    move-result-object v2

    invoke-virtual {v1, v0, v2}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/String;

    invoke-virtual/range {v20 .. v20}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v1

    const-string v2, "k4_home_clock_bundle"

    invoke-static {v1, v2, v0}, Landroid/provider/Settings$System;->putString(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "home apply: clock bundle "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v7, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_d

    :cond_d
    const-string v0, "home apply: no clock bundle converter"

    invoke-static {v7, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_f
    .catchall {:try_start_f .. :try_end_f} :catchall_c

    goto :goto_d

    :catchall_c
    move-exception v0

    :try_start_10
    const-string v1, "home apply: clock bundle"

    invoke-static {v7, v1, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :goto_d
    invoke-static/range {v21 .. v21}, Lcom/k4/dressroom/HomeClock;->gson(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    const-string v1, "com.samsung.android.sdk.aodservice.entities.item.LockScreenItem"

    invoke-virtual/range {v21 .. v21}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/Class;->getClassLoader()Ljava/lang/ClassLoader;

    move-result-object v2

    move/from16 v3, p0

    invoke-static {v1, v3, v2}, Ljava/lang/Class;->forName(Ljava/lang/String;ZLjava/lang/ClassLoader;)Ljava/lang/Class;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v2

    const-class v3, Ljava/lang/Object;

    const-class v5, Ljava/lang/reflect/Type;

    filled-new-array {v3, v5}, [Ljava/lang/Class;

    move-result-object v3

    invoke-virtual {v2, v4, v3}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v2

    move-object/from16 v3, v19

    filled-new-array {v3, v1}, [Ljava/lang/Object;

    move-result-object v1

    invoke-virtual {v2, v0, v1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/String;

    invoke-virtual/range {v20 .. v20}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v1

    const-string v2, "k4_home_clock_item"

    invoke-static {v1, v2, v0}, Landroid/provider/Settings$System;->putString(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z

    const-string v1, "persist.sys.k4.home_depth_clock"

    sget-boolean v2, Lcom/k4/dressroom/HomeClock;->on:Z

    if-eqz v2, :cond_e

    move-object/from16 v2, v18

    goto :goto_e

    :cond_e
    move-object/from16 v2, v17

    :goto_e
    invoke-static {v1, v2}, Landroid/os/SemSystemProperties;->set(Ljava/lang/String;Ljava/lang/String;)V

    new-instance v1, Landroid/content/Intent;

    const-string v2, "com.k4.homeclock.action.RELOAD"

    invoke-direct {v1, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    const-string v2, "com.k4.homeclock.extra.WALLPAPER_PENDING"

    const/4 v10, 0x1

    invoke-virtual {v1, v2, v10}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Z)Landroid/content/Intent;

    move-result-object v1

    const-string v2, "com.samsung.android.wallpaper.live"

    invoke-virtual {v1, v2}, Landroid/content/Intent;->setPackage(Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v1

    const/high16 v2, 0x10000000

    invoke-virtual {v1, v2}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    move-result-object v1

    move-object/from16 v10, v20

    invoke-virtual {v10, v1}, Landroid/content/Context;->sendBroadcast(Landroid/content/Intent;)V

    sget-boolean v1, Lcom/k4/dressroom/HomeClock;->on:Z

    if-eqz v1, :cond_f

    const-string v1, "on"

    goto :goto_f

    :cond_f
    const-string v1, "off"

    :goto_f
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "home apply: clock "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, ", item="

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v7, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_11

    :cond_10
    :goto_10
    const-string v0, "home apply: no clock data/store"

    invoke-static {v7, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_10
    .catchall {:try_start_10 .. :try_end_10} :catchall_d

    return-void

    :catchall_d
    move-exception v0

    const-string v1, "onHomeSave"

    invoke-static {v7, v1, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :goto_11
    return-void
.end method

.method public static onObject(Landroid/view/View;Ljava/lang/Object;Landroid/graphics/Bitmap;)V
    .locals 7

    const-string v0, "a"

    sget-boolean v1, Lcom/k4/dressroom/HomeClock;->active:Z

    if-nez v1, :cond_0

    goto/16 :goto_3

    :cond_0
    const/4 v1, 0x0

    :try_start_0
    invoke-static {p1, v0}, Lcom/k4/dressroom/HomeClock;->field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    :try_start_1
    const-string v2, "k"

    invoke-static {p1, v2}, Lcom/k4/dressroom/HomeClock;->field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Landroid/graphics/Bitmap;
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    goto :goto_0

    :catchall_0
    move-object p1, v1

    :catchall_1
    move-object v2, v1

    :goto_0
    const-string v3, "K4HomeClock"

    const/4 v4, 0x1

    if-eqz p1, :cond_1

    :try_start_2
    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v5

    const-class v6, Ljava/lang/Boolean;

    filled-new-array {v6}, [Ljava/lang/Class;

    move-result-object v6

    invoke-virtual {v5, v0, v6}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    filled-new-array {v1}, [Ljava/lang/Object;

    move-result-object v1

    invoke-virtual {v0, p1, v1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Boolean;

    invoke-virtual {v0}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v0
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_2

    move v4, v0

    goto :goto_1

    :catchall_2
    move-exception v0

    :try_start_3
    const-string v1, "subject: save check"

    invoke-static {v3, v1, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_1
    :goto_1
    sput-boolean v4, Lcom/k4/dressroom/HomeClock;->sDepth:Z

    if-eqz p1, :cond_2

    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, p1}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/dressroom/HomeClock;->sResult:Ljava/lang/ref/WeakReference;

    :cond_2
    if-nez v4, :cond_3

    const-string p1, "subject not saved by Samsung for this picture: clock drawn over the whole picture"

    invoke-static {v3, p1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    :cond_3
    if-nez v2, :cond_4

    goto :goto_2

    :cond_4
    move-object p2, v2

    :goto_2
    sget-object p1, Lcom/k4/dressroom/HomeClock;->sMediator:Ljava/lang/ref/WeakReference;

    invoke-virtual {p1}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Lp8/a;

    if-eqz p2, :cond_6

    if-eqz p0, :cond_6

    if-eqz p1, :cond_6

    iget-object v0, p1, Lp8/a;->g:Landroid/view/View;

    instance-of v0, v0, Landroid/view/ViewGroup;

    if-nez v0, :cond_5

    goto :goto_3

    :cond_5
    iget-object p1, p1, Lp8/a;->g:Landroid/view/View;

    check-cast p1, Landroid/view/ViewGroup;

    new-instance v0, Lcom/k4/dressroom/HomeClock$3;

    invoke-direct {v0, p1, p0, p2}, Lcom/k4/dressroom/HomeClock$3;-><init>(Landroid/view/ViewGroup;Landroid/view/View;Landroid/graphics/Bitmap;)V

    invoke-virtual {p1, v0}, Landroid/view/ViewGroup;->post(Ljava/lang/Runnable;)Z
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_3

    goto :goto_3

    :catchall_3
    move-exception p0

    const-string p1, "onObject"

    invoke-static {v3, p1, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_6
    :goto_3
    return-void
.end method

.method static placeSubject(Landroid/view/ViewGroup;Landroid/view/View;Landroid/graphics/Bitmap;)V
    .locals 6

    instance-of v0, p1, Landroid/widget/ImageView;

    if-nez v0, :cond_0

    return-void

    :cond_0
    check-cast p1, Landroid/widget/ImageView;

    sget-object v0, Lcom/k4/dressroom/HomeClock;->sSubjectView:Ljava/lang/ref/WeakReference;

    invoke-virtual {v0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/k4/dressroom/HomeClock$SubjectView;

    const/4 v1, 0x0

    if-eqz v0, :cond_1

    invoke-virtual {v0}, Lcom/k4/dressroom/HomeClock$SubjectView;->getParent()Landroid/view/ViewParent;

    move-result-object v2

    if-ne v2, p0, :cond_1

    iget-object v2, v0, Lcom/k4/dressroom/HomeClock$SubjectView;->crop:Landroid/widget/ImageView;

    if-eq v2, p1, :cond_5

    :cond_1
    if-eqz v0, :cond_2

    invoke-virtual {v0}, Lcom/k4/dressroom/HomeClock$SubjectView;->getParent()Landroid/view/ViewParent;

    move-result-object v2

    instance-of v2, v2, Landroid/view/ViewGroup;

    if-eqz v2, :cond_2

    invoke-virtual {v0}, Lcom/k4/dressroom/HomeClock$SubjectView;->getParent()Landroid/view/ViewParent;

    move-result-object v2

    check-cast v2, Landroid/view/ViewGroup;

    invoke-virtual {v2, v0}, Landroid/view/ViewGroup;->removeView(Landroid/view/View;)V

    :cond_2
    new-instance v0, Lcom/k4/dressroom/HomeClock$SubjectView;

    invoke-virtual {p0}, Landroid/view/ViewGroup;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-direct {v0, v2, p1}, Lcom/k4/dressroom/HomeClock$SubjectView;-><init>(Landroid/content/Context;Landroid/widget/ImageView;)V

    invoke-virtual {p0}, Landroid/view/ViewGroup;->getChildCount()I

    move-result v2

    move v3, v1

    :goto_0
    invoke-virtual {p0}, Landroid/view/ViewGroup;->getChildCount()I

    move-result v4

    if-ge v3, v4, :cond_4

    invoke-virtual {p0, v3}, Landroid/view/ViewGroup;->getChildAt(I)Landroid/view/View;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/Class;->getName()Ljava/lang/String;

    move-result-object v4

    const-string v5, "ItemEditorContainer"

    invoke-virtual {v4, v5}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_3

    move v2, v3

    goto :goto_1

    :cond_3
    add-int/lit8 v3, v3, 0x1

    goto :goto_0

    :cond_4
    :goto_1
    new-instance v3, Landroid/widget/FrameLayout$LayoutParams;

    invoke-virtual {p1}, Landroid/widget/ImageView;->getWidth()I

    move-result v4

    invoke-virtual {p1}, Landroid/widget/ImageView;->getHeight()I

    move-result v5

    invoke-direct {v3, v4, v5}, Landroid/widget/FrameLayout$LayoutParams;-><init>(II)V

    invoke-virtual {p0, v0, v2, v3}, Landroid/view/ViewGroup;->addView(Landroid/view/View;ILandroid/view/ViewGroup$LayoutParams;)V

    new-instance v2, Ljava/lang/ref/WeakReference;

    invoke-direct {v2, v0}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v2, Lcom/k4/dressroom/HomeClock;->sSubjectView:Ljava/lang/ref/WeakReference;

    invoke-virtual {p1}, Landroid/widget/ImageView;->getViewTreeObserver()Landroid/view/ViewTreeObserver;

    move-result-object v3

    new-instance v4, Lcom/k4/dressroom/HomeClock$4;

    invoke-direct {v4, v2, p1}, Lcom/k4/dressroom/HomeClock$4;-><init>(Ljava/lang/ref/WeakReference;Landroid/widget/ImageView;)V

    invoke-virtual {v3, v4}, Landroid/view/ViewTreeObserver;->addOnPreDrawListener(Landroid/view/ViewTreeObserver$OnPreDrawListener;)V

    :cond_5
    new-instance v2, Landroid/graphics/drawable/BitmapDrawable;

    invoke-virtual {p0}, Landroid/view/ViewGroup;->getResources()Landroid/content/res/Resources;

    move-result-object p0

    invoke-direct {v2, p0, p2}, Landroid/graphics/drawable/BitmapDrawable;-><init>(Landroid/content/res/Resources;Landroid/graphics/Bitmap;)V

    iput-object v2, v0, Lcom/k4/dressroom/HomeClock$SubjectView;->subject:Landroid/graphics/drawable/BitmapDrawable;

    iget-object p0, v0, Lcom/k4/dressroom/HomeClock$SubjectView;->subject:Landroid/graphics/drawable/BitmapDrawable;

    const/4 v2, 0x1

    invoke-virtual {p0, v2}, Landroid/graphics/drawable/BitmapDrawable;->setFilterBitmap(Z)V

    :try_start_0
    invoke-static {}, Lcom/k4/dressroom/HomeClock;->debug()Ljava/lang/String;

    move-result-object p0

    const-string v2, "1"

    invoke-virtual {v2, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_6

    const v2, 0x3eb33333    # 0.35f

    goto :goto_2

    :cond_6
    const/high16 v2, 0x3f800000    # 1.0f

    :goto_2
    invoke-virtual {v0, v2}, Lcom/k4/dressroom/HomeClock$SubjectView;->setAlpha(F)V

    const-string v2, "tint"

    invoke-virtual {p0, v2}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result p0

    if-eqz p0, :cond_7

    iget-object p0, v0, Lcom/k4/dressroom/HomeClock$SubjectView;->subject:Landroid/graphics/drawable/BitmapDrawable;

    new-instance v2, Landroid/graphics/PorterDuffColorFilter;

    sget-object v3, Landroid/graphics/PorterDuff$Mode;->SRC_IN:Landroid/graphics/PorterDuff$Mode;

    const v4, -0xff01

    invoke-direct {v2, v4, v3}, Landroid/graphics/PorterDuffColorFilter;-><init>(ILandroid/graphics/PorterDuff$Mode;)V

    invoke-virtual {p0, v2}, Landroid/graphics/drawable/BitmapDrawable;->setColorFilter(Landroid/graphics/ColorFilter;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    :catchall_0
    :cond_7
    sget-boolean p0, Lcom/k4/dressroom/HomeClock;->on:Z

    if-eqz p0, :cond_8

    sget-boolean p0, Lcom/k4/dressroom/HomeClock;->sDepth:Z

    if-eqz p0, :cond_8

    goto :goto_3

    :cond_8
    const/16 v1, 0x8

    :goto_3
    invoke-virtual {v0, v1}, Lcom/k4/dressroom/HomeClock$SubjectView;->setVisibility(I)V

    invoke-virtual {v0}, Lcom/k4/dressroom/HomeClock$SubjectView;->invalidate()V

    invoke-virtual {p1}, Landroid/widget/ImageView;->getDrawable()Landroid/graphics/drawable/Drawable;

    move-result-object p0

    invoke-virtual {p2}, Landroid/graphics/Bitmap;->getWidth()I

    move-result p1

    invoke-virtual {p2}, Landroid/graphics/Bitmap;->getHeight()I

    move-result p2

    const-string v0, "x"

    if-eqz p0, :cond_9

    invoke-virtual {p0}, Landroid/graphics/drawable/Drawable;->getIntrinsicWidth()I

    move-result v1

    invoke-virtual {p0}, Landroid/graphics/drawable/Drawable;->getIntrinsicHeight()I

    move-result v2

    invoke-virtual {p0}, Landroid/graphics/drawable/Drawable;->getBounds()Landroid/graphics/Rect;

    move-result-object p0

    invoke-static {p0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    new-instance v3, Ljava/lang/StringBuilder;

    const-string v4, " (wallpaper drawable "

    invoke-direct {v3, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, ", bounds "

    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string p0, ")"

    invoke-virtual {v3, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    goto :goto_4

    :cond_9
    const-string p0, ""

    :goto_4
    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "subject above clock: "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    const-string p1, "K4HomeClock"

    invoke-static {p1, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    return-void
.end method

.method static propOn()Z
    .locals 3

    const/4 v0, 0x0

    :try_start_0
    const-string v1, "persist.sys.k4.home_depth_clock"

    invoke-static {v1}, Landroid/os/SemSystemProperties;->get(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    const-string v2, "1"

    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-nez v2, :cond_1

    const-string v2, "true"

    invoke-virtual {v2, v1}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-eqz v1, :cond_0

    goto :goto_0

    :cond_0
    return v0

    :cond_1
    :goto_0
    const/4 v0, 0x1

    :catchall_0
    return v0
.end method

.method public static reedit(Z)Z
    .locals 0

    if-nez p0, :cond_1

    sget-boolean p0, Lcom/k4/dressroom/HomeClock;->sRestored:Z

    if-eqz p0, :cond_0

    invoke-static {}, Lcom/k4/dressroom/HomeClock;->live()Z

    move-result p0

    if-eqz p0, :cond_0

    goto :goto_0

    :cond_0
    const/4 p0, 0x0

    return p0

    :cond_1
    :goto_0
    const/4 p0, 0x1

    return p0
.end method

.method static scale(Landroid/view/View;)F
    .locals 2

    const/high16 v0, 0x3f800000    # 1.0f

    :goto_0
    instance-of v1, p0, Landroid/view/View;

    if-eqz v1, :cond_0

    check-cast p0, Landroid/view/View;

    invoke-virtual {p0}, Landroid/view/View;->getScaleX()F

    move-result v1

    mul-float/2addr v0, v1

    invoke-virtual {p0}, Landroid/view/View;->getParent()Landroid/view/ViewParent;

    move-result-object p0

    goto :goto_0

    :cond_0
    return v0
.end method

.method public static seedItem(Ljava/lang/Object;)Ljava/lang/Object;
    .locals 9

    const-string v0, "K4HomeClock"

    invoke-static {}, Lcom/k4/dressroom/HomeClock;->live()Z

    move-result v1

    if-nez v1, :cond_0

    goto/16 :goto_0

    :cond_0
    :try_start_0
    sget-object v1, Lcom/k4/dressroom/HomeClock;->sStore:Ljava/lang/ref/WeakReference;

    invoke-virtual {v1}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v1

    if-nez v1, :cond_1

    goto/16 :goto_0

    :cond_1
    const-string v2, "a"

    invoke-static {v1, v2}, Lcom/k4/dressroom/HomeClock;->field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Landroid/content/Context;

    invoke-virtual {v2}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v2

    const-string v3, "k4_home_clock_item"

    invoke-static {v2, v3}, Landroid/provider/Settings$System;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-static {v1}, Lcom/k4/dressroom/HomeClock;->gson(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    const-string v4, "com.samsung.android.sdk.aodservice.entities.item.LockScreenItem"

    invoke-virtual {v1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Class;->getClassLoader()Ljava/lang/ClassLoader;

    move-result-object v1

    const/4 v5, 0x0

    invoke-static {v4, v5, v1}, Ljava/lang/Class;->forName(Ljava/lang/String;ZLjava/lang/ClassLoader;)Ljava/lang/Class;

    move-result-object v1

    if-eqz v2, :cond_2

    invoke-virtual {v2}, Ljava/lang/String;->isEmpty()Z

    move-result v4

    if-eqz v4, :cond_4

    :cond_2
    if-eqz p0, :cond_4

    new-instance v2, Lorg/json/JSONObject;

    invoke-virtual {v3}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v4

    const-string v6, "toJson"

    const-class v7, Ljava/lang/Object;

    const-class v8, Ljava/lang/reflect/Type;

    filled-new-array {v7, v8}, [Ljava/lang/Class;

    move-result-object v7

    invoke-virtual {v4, v6, v7}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v4

    filled-new-array {p0, v1}, [Ljava/lang/Object;

    move-result-object v6

    invoke-virtual {v4, v3, v6}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/String;

    invoke-direct {v2, v4}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    const-string v4, "font"

    invoke-virtual {v2, v4}, Lorg/json/JSONObject;->optJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object v4

    if-eqz v4, :cond_3

    const-string v6, "presetFontIndex"

    const/16 v7, 0x320

    invoke-virtual {v4, v6, v7}, Lorg/json/JSONObject;->put(Ljava/lang/String;I)Lorg/json/JSONObject;

    const-string v6, "fontWeight"

    const/16 v7, 0x190

    invoke-virtual {v4, v6, v7}, Lorg/json/JSONObject;->put(Ljava/lang/String;I)Lorg/json/JSONObject;

    :cond_3
    new-instance v4, Lorg/json/JSONObject;

    invoke-direct {v4}, Lorg/json/JSONObject;-><init>()V

    const-string v6, "presetIndex"

    invoke-virtual {v4, v6, v5}, Lorg/json/JSONObject;->put(Ljava/lang/String;I)Lorg/json/JSONObject;

    const-string v5, "_type_"

    const-string v6, "com.samsung.android.sdk.aodservice.factory.ClockPresetColorImpl"

    invoke-virtual {v4, v5, v6}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    const-string v5, "color"

    invoke-virtual {v2, v5, v4}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    const-string v4, "isDefaultPosition"

    const/4 v5, 0x1

    invoke-virtual {v2, v4, v5}, Lorg/json/JSONObject;->put(Ljava/lang/String;Z)Lorg/json/JSONObject;

    const-string v4, "scaleX"

    const-wide/high16 v5, 0x3ff0000000000000L    # 1.0

    invoke-virtual {v2, v4, v5, v6}, Lorg/json/JSONObject;->put(Ljava/lang/String;D)Lorg/json/JSONObject;

    const-string v4, "scaleY"

    invoke-virtual {v2, v4, v5, v6}, Lorg/json/JSONObject;->put(Ljava/lang/String;D)Lorg/json/JSONObject;

    invoke-virtual {v2}, Lorg/json/JSONObject;->toString()Ljava/lang/String;

    move-result-object v2

    const-string v4, "editor starts from the default home clock"

    invoke-static {v0, v4}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    :cond_4
    if-eqz v2, :cond_7

    invoke-virtual {v2}, Ljava/lang/String;->isEmpty()Z

    move-result v4

    if-eqz v4, :cond_5

    goto :goto_0

    :cond_5
    invoke-virtual {v3}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v4

    const-string v5, "fromJson"

    const-class v6, Ljava/lang/String;

    const-class v7, Ljava/lang/Class;

    filled-new-array {v6, v7}, [Ljava/lang/Class;

    move-result-object v6

    invoke-virtual {v4, v5, v6}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v4

    filled-new-array {v2, v1}, [Ljava/lang/Object;

    move-result-object v1

    invoke-virtual {v4, v3, v1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    if-eqz v1, :cond_7

    if-eqz p0, :cond_6

    invoke-virtual {v1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v2

    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v3

    if-ne v2, v3, :cond_7

    :cond_6
    const-string v2, "editor starts from the saved home clock"

    invoke-static {v0, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return-object v1

    :catchall_0
    move-exception v1

    const-string v2, "seedItem"

    invoke-static {v0, v2, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_7
    :goto_0
    return-object p0
.end method

.method public static storeSeen(Ljava/lang/Object;)V
    .locals 1

    new-instance v0, Ljava/lang/ref/WeakReference;

    invoke-direct {v0, p0}, Ljava/lang/ref/WeakReference;-><init>(Ljava/lang/Object;)V

    sput-object v0, Lcom/k4/dressroom/HomeClock;->sStore:Ljava/lang/ref/WeakReference;

    return-void
.end method

.method public static stretchReset(Ljava/lang/Object;)V
    .locals 6

    const-string v0, "K4HomeClock"

    const-string v1, "clock changed: stretch "

    sget-boolean v2, Lcom/k4/dressroom/HomeClock;->sStretchHeld:Z

    if-nez v2, :cond_0

    goto :goto_1

    :cond_0
    const/4 v2, 0x0

    sput-boolean v2, Lcom/k4/dressroom/HomeClock;->sStretchHeld:Z

    :try_start_0
    sget-object v2, Lcom/k4/dressroom/HomeClock;->sStretchWanted:Ljava/lang/Boolean;

    if-eqz v2, :cond_3

    sget-object v3, Lcom/k4/dressroom/HomeClock;->sSavedStretch:Ljava/lang/Boolean;

    invoke-virtual {v2, v3}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-nez v3, :cond_3

    invoke-static {}, Lcom/k4/dressroom/HomeClock;->live()Z

    move-result v3

    if-nez v3, :cond_1

    goto :goto_1

    :cond_1
    const-string v3, "a"

    invoke-static {p0, v3}, Lcom/k4/dressroom/HomeClock;->field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p0

    const-string v3, "getData"

    invoke-static {p0, v3}, Lcom/k4/dressroom/HomeClock;->call(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p0

    if-eqz p0, :cond_3

    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v3

    const-string v4, "setSupportStretch"

    sget-object v5, Ljava/lang/Boolean;->TYPE:Ljava/lang/Class;

    filled-new-array {v5}, [Ljava/lang/Class;

    move-result-object v5

    invoke-virtual {v3, v4, v5}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v3

    filled-new-array {v2}, [Ljava/lang/Object;

    move-result-object v4

    invoke-virtual {v3, p0, v4}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    invoke-virtual {v2}, Ljava/lang/Boolean;->booleanValue()Z

    move-result p0

    if-eqz p0, :cond_2

    const-string p0, "on"

    goto :goto_0

    :cond_2
    const-string p0, "off"

    :goto_0
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string p0, " from the wallpaper check again"

    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v0, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return-void

    :catchall_0
    move-exception p0

    const-string v1, "stretchReset"

    invoke-static {v0, v1, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_3
    :goto_1
    return-void
.end method

.method public static stretchable(Z)Z
    .locals 5

    const-string v0, "K4HomeClock"

    const-string v1, "clock stretch kept "

    :try_start_0
    sget-object v2, Lcom/k4/dressroom/HomeClock;->sSavedStretch:Ljava/lang/Boolean;

    sget-boolean v3, Lcom/k4/dressroom/HomeClock;->sStretchHeld:Z

    if-eqz v3, :cond_3

    if-eqz v2, :cond_3

    sget-boolean v3, Lcom/k4/dressroom/HomeClock;->sRestored:Z

    if-eqz v3, :cond_3

    invoke-static {}, Lcom/k4/dressroom/HomeClock;->live()Z

    move-result v3

    if-nez v3, :cond_0

    goto :goto_1

    :cond_0
    invoke-static {p0}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v3

    sput-object v3, Lcom/k4/dressroom/HomeClock;->sStretchWanted:Ljava/lang/Boolean;

    invoke-virtual {v2}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v3

    if-eq p0, v3, :cond_2

    invoke-virtual {v2}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v3

    if-eqz v3, :cond_1

    const-string v3, "on"

    goto :goto_0

    :cond_1
    const-string v3, "off"

    :goto_0
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, " as saved (wallpaper check: "

    invoke-virtual {v4, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4, p0}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    const-string v1, ")"

    invoke-virtual {v4, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    :cond_2
    invoke-virtual {v2}, Ljava/lang/Boolean;->booleanValue()Z

    move-result p0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    :cond_3
    :goto_1
    return p0

    :catchall_0
    move-exception v1

    const-string v2, "stretchable"

    invoke-static {v0, v2, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    return p0
.end method

.method static styleName()Ljava/lang/String;
    .locals 4

    const/4 v0, 0x0

    :try_start_0
    sget-object v1, Lcom/k4/dressroom/HomeClock;->sController:Ljava/lang/ref/WeakReference;

    invoke-virtual {v1}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v1

    if-nez v1, :cond_0

    return-object v0

    :cond_0
    sget-object v2, Lcom/k4/dressroom/HomeClock;->sStyleField:Ljava/lang/reflect/Field;

    if-nez v2, :cond_1

    invoke-virtual {v1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v2

    const-string v3, "f2"

    invoke-static {v2, v3}, Lcom/k4/dressroom/HomeClock;->findField(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v2

    sput-object v2, Lcom/k4/dressroom/HomeClock;->sStyleField:Ljava/lang/reflect/Field;

    :cond_1
    sget-object v2, Lcom/k4/dressroom/HomeClock;->sStyleField:Ljava/lang/reflect/Field;

    invoke-virtual {v2, v1}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    if-nez v1, :cond_2

    return-object v0

    :cond_2
    sget-object v2, Lcom/k4/dressroom/HomeClock;->sStyleItemField:Ljava/lang/reflect/Field;

    if-nez v2, :cond_3

    invoke-virtual {v1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v2

    const-string v3, "N"

    invoke-static {v2, v3}, Lcom/k4/dressroom/HomeClock;->findField(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v2

    sput-object v2, Lcom/k4/dressroom/HomeClock;->sStyleItemField:Ljava/lang/reflect/Field;

    :cond_3
    sget-object v2, Lcom/k4/dressroom/HomeClock;->sStyleItemField:Ljava/lang/reflect/Field;

    invoke-virtual {v2, v1}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    instance-of v2, v1, Ljava/lang/Enum;

    if-eqz v2, :cond_4

    check-cast v1, Ljava/lang/Enum;

    invoke-virtual {v1}, Ljava/lang/Enum;->name()Ljava/lang/String;

    move-result-object v0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    :catchall_0
    :cond_4
    return-object v0
.end method

.method static styledSubject()Landroid/graphics/Bitmap;
    .locals 5

    sget-object v0, Lcom/k4/dressroom/HomeClock;->sResult:Ljava/lang/ref/WeakReference;

    invoke-virtual {v0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v0

    const/4 v1, 0x0

    if-nez v0, :cond_0

    return-object v1

    :cond_0
    :try_start_0
    invoke-static {}, Lcom/k4/dressroom/HomeClock;->styleName()Ljava/lang/String;

    move-result-object v2

    const-string v3, "GrayScale"

    invoke-virtual {v3, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    const-string v4, "k"

    if-nez v3, :cond_3

    :try_start_1
    const-string v3, "Shadow"

    invoke-virtual {v3, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_1

    goto :goto_0

    :cond_1
    const-string v3, "BlurAll"

    invoke-virtual {v3, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_2

    const-string v2, "m"

    goto :goto_1

    :cond_2
    move-object v2, v4

    goto :goto_1

    :cond_3
    :goto_0
    const-string v2, "l"

    :goto_1
    invoke-static {v0, v2}, Lcom/k4/dressroom/HomeClock;->field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Landroid/graphics/Bitmap;

    if-eqz v2, :cond_4

    return-object v2

    :cond_4
    invoke-static {v0, v4}, Lcom/k4/dressroom/HomeClock;->field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/graphics/Bitmap;
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    return-object v0

    :catchall_0
    return-object v1
.end method

.method static toggle(Lo6/e0;)V
    .locals 5

    sget-boolean v0, Lcom/k4/dressroom/HomeClock;->on:Z

    xor-int/lit8 v1, v0, 0x1

    sput-boolean v1, Lcom/k4/dressroom/HomeClock;->on:Z

    if-nez v0, :cond_0

    const-string v0, "on"

    goto :goto_0

    :cond_0
    const-string v0, "off"

    :goto_0
    const-string v1, "clock "

    invoke-virtual {v1, v0}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    const-string v1, "K4HomeClock"

    invoke-static {v1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    sget-object v0, Lcom/k4/dressroom/HomeClock;->sMediator:Ljava/lang/ref/WeakReference;

    invoke-virtual {v0}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lp8/a;

    if-eqz v0, :cond_1

    invoke-static {v0}, Lcom/k4/dressroom/HomeClock;->applyVisibility(Lp8/a;)V

    :cond_1
    iget-object v0, p0, Lo6/e0;->T0:Lp8/i;

    const-string v2, "homeClock"

    if-eqz v0, :cond_2

    iget-object v0, p0, Lo6/e0;->T0:Lp8/i;

    sget-boolean v3, Lcom/k4/dressroom/HomeClock;->on:Z

    invoke-virtual {v0, v2, v3}, Lp8/i;->g(Ljava/lang/String;Z)V

    :cond_2
    sget-boolean v0, Lcom/k4/dressroom/HomeClock;->on:Z

    if-eqz v0, :cond_3

    sget v0, Lcom/k4/dressroom/HomeClock;->sIconOn:I

    if-eqz v0, :cond_3

    goto :goto_1

    :cond_3
    sget v0, Lcom/k4/dressroom/HomeClock;->sIcon:I

    :goto_1
    sget-object v3, Lcom/k4/dressroom/HomeClock;->sItem:Ljava/lang/ref/WeakReference;

    invoke-virtual {v3}, Ljava/lang/ref/WeakReference;->get()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Lk6/m;

    if-eqz v3, :cond_4

    if-eqz v0, :cond_4

    iput v0, v3, Lk6/m;->b:I

    :cond_4
    :try_start_0
    iget-object v3, p0, Lo6/e0;->M:Landroid/app/Activity;

    invoke-virtual {v3}, Landroid/app/Activity;->getWindow()Landroid/view/Window;

    move-result-object v3

    invoke-virtual {v3}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v3

    invoke-virtual {v3, v2}, Landroid/view/View;->findViewWithTag(Ljava/lang/Object;)Landroid/view/View;

    move-result-object v2

    iget-object p0, p0, Lo6/e0;->M:Landroid/app/Activity;

    const-string v3, "id"

    const-string v4, "menu_icon"

    invoke-static {p0, v3, v4}, Lcom/k4/dressroom/HomeClock;->id(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)I

    move-result p0

    if-eqz v2, :cond_5

    if-eqz p0, :cond_5

    invoke-virtual {v2, p0}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object p0

    goto :goto_2

    :cond_5
    const/4 p0, 0x0

    :goto_2
    if-eqz p0, :cond_6

    if-eqz v0, :cond_6

    invoke-virtual {p0, v0}, Landroid/view/View;->setBackgroundResource(I)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return-void

    :catchall_0
    move-exception p0

    const-string v0, "menu icon"

    invoke-static {v1, v0, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_6
    return-void
.end method
