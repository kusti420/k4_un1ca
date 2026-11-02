.class public final Lcom/k4/settingsintelligence/K4SearchSpeed;
.super Ljava/lang/Object;
.source "K4SearchSpeed.java"


# static fields
.field private static final DYNAMIC_TABLE:Ljava/lang/String; = "sec_dynamic_prefs_index"

.field private static final TAG:Ljava/lang/String; = "K4SearchSpeed"

.field private static final sDynamicClearPending:Ljava/lang/ThreadLocal;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/lang/ThreadLocal<",
            "Ljava/lang/Boolean;",
            ">;"
        }
    .end annotation
.end field

.field private static volatile sIndexUsable:Z


# direct methods
.method static constructor <clinit>()V
    .registers 1

    .line 36
    new-instance v0, Ljava/lang/ThreadLocal;

    invoke-direct {v0}, Ljava/lang/ThreadLocal;-><init>()V

    sput-object v0, Lcom/k4/settingsintelligence/K4SearchSpeed;->sDynamicClearPending:Ljava/lang/ThreadLocal;

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 38
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static insertDynamic(Lcom/android/settings/intelligence/search/indexing/DatabaseIndexingManager;Landroid/database/sqlite/SQLiteDatabase;Ljava/util/List;Ljava/lang/String;)V
    .registers 7

    .line 76
    sget-object v0, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    sget-object v1, Lcom/k4/settingsintelligence/K4SearchSpeed;->sDynamicClearPending:Ljava/lang/ThreadLocal;

    invoke-virtual {v1}, Ljava/lang/ThreadLocal;->get()Ljava/lang/Object;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_4f

    const-string v0, "sec_dynamic_prefs_index"

    invoke-virtual {v0, p3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_4f

    .line 77
    sget-object v0, Lcom/k4/settingsintelligence/K4SearchSpeed;->sDynamicClearPending:Ljava/lang/ThreadLocal;

    sget-object v1, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    invoke-virtual {v0, v1}, Ljava/lang/ThreadLocal;->set(Ljava/lang/Object;)V

    .line 79
    :try_start_1d
    const-string v0, "DELETE FROM sec_dynamic_prefs_index"

    invoke-virtual {p1, v0}, Landroid/database/sqlite/SQLiteDatabase;->execSQL(Ljava/lang/String;)V
    :try_end_22
    .catch Landroid/database/sqlite/SQLiteException; {:try_start_1d .. :try_end_22} :catch_23

    .line 83
    goto :goto_4f

    .line 80
    :catch_23
    move-exception v0

    .line 81
    invoke-static {v0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "in-transaction clear failed ("

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "), recreating the table"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "K4SearchSpeed"

    invoke-static {v1, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 82
    iget-object v0, p0, Lcom/android/settings/intelligence/search/indexing/DatabaseIndexingManager;->mContext:Landroid/content/Context;

    invoke-static {v0}, Lcom/android/settings/intelligence/search/indexing/IndexDatabaseHelper;->getInstance(Landroid/content/Context;)Lcom/android/settings/intelligence/search/indexing/IndexDatabaseHelper;

    move-result-object v0

    invoke-virtual {v0, p1}, Lcom/android/settings/intelligence/search/indexing/IndexDatabaseHelper;->reconstructDynamicIndexDb(Landroid/database/sqlite/SQLiteDatabase;)V

    .line 85
    :cond_4f
    :goto_4f
    invoke-virtual {p0, p1, p2, p3}, Lcom/android/settings/intelligence/search/indexing/DatabaseIndexingManager;->insertIndexData(Landroid/database/sqlite/SQLiteDatabase;Ljava/util/List;Ljava/lang/String;)V

    .line 86
    return-void
.end method

.method public static isIndexingComplete(Lcom/android/settings/intelligence/search/SearchFeatureProvider;Landroid/content/Context;)Z
    .registers 5

    .line 90
    invoke-interface {p0, p1}, Lcom/android/settings/intelligence/search/SearchFeatureProvider;->isIndexingComplete(Landroid/content/Context;)Z

    move-result v0

    const/4 v1, 0x1

    if-eqz v0, :cond_8

    .line 91
    return v1

    .line 93
    :cond_8
    sget-boolean v0, Lcom/k4/settingsintelligence/K4SearchSpeed;->sIndexUsable:Z

    const/4 v2, 0x0

    if-eqz v0, :cond_29

    if-nez p1, :cond_10

    goto :goto_29

    .line 97
    :cond_10
    :try_start_10
    invoke-interface {p0, p1}, Lcom/android/settings/intelligence/search/SearchFeatureProvider;->getIndexingManager(Landroid/content/Context;)Lcom/android/settings/intelligence/search/indexing/DatabaseIndexingManager;

    move-result-object p0

    .line 98
    if-eqz p0, :cond_26

    invoke-virtual {p0}, Lcom/android/settings/intelligence/search/indexing/DatabaseIndexingManager;->isLocaleChanged()Z

    move-result p0
    :try_end_1a
    .catch Ljava/lang/RuntimeException; {:try_start_10 .. :try_end_1a} :catch_27

    if-eqz p0, :cond_1d

    goto :goto_26

    .line 103
    :cond_1d
    nop

    .line 104
    const-string p0, "K4SearchSpeed"

    const-string p1, "refresh running: querying the existing index"

    invoke-static {p0, p1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 105
    return v1

    .line 99
    :cond_26
    :goto_26
    return v2

    .line 101
    :catch_27
    move-exception p0

    .line 102
    return v2

    .line 94
    :cond_29
    :goto_29
    return v2
.end method

.method public static onIndexingQueued()V
    .registers 1

    .line 47
    const/4 v0, 0x0

    sput-boolean v0, Lcom/k4/settingsintelligence/K4SearchSpeed;->sIndexUsable:Z

    .line 48
    return-void
.end method

.method public static onIndexingStart(Lcom/android/settings/intelligence/search/indexing/DatabaseIndexingManager;Z)V
    .registers 5

    .line 52
    sget-object v0, Lcom/k4/settingsintelligence/K4SearchSpeed;->sDynamicClearPending:Ljava/lang/ThreadLocal;

    sget-object v1, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    invoke-virtual {v0, v1}, Ljava/lang/ThreadLocal;->set(Ljava/lang/Object;)V

    .line 53
    nop

    .line 54
    const-string v0, "K4SearchSpeed"

    if-nez p1, :cond_30

    .line 56
    :try_start_c
    iget-object p0, p0, Lcom/android/settings/intelligence/search/indexing/DatabaseIndexingManager;->mContext:Landroid/content/Context;

    const-string v1, "essential_indexing_finished"

    invoke-static {p0, v1}, Lcom/android/settings/intelligence/search/indexing/IndexDatabaseHelper;->isIndexingFinished(Landroid/content/Context;Ljava/lang/String;)Z

    move-result p0
    :try_end_14
    .catch Ljava/lang/RuntimeException; {:try_start_c .. :try_end_14} :catch_15

    .line 59
    goto :goto_31

    .line 57
    :catch_15
    move-exception p0

    .line 58
    invoke-static {p0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "isIndexingFinished failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v0, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 61
    :cond_30
    const/4 p0, 0x0

    :goto_31
    sput-boolean p0, Lcom/k4/settingsintelligence/K4SearchSpeed;->sIndexUsable:Z

    .line 62
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "refresh start: fullIndex="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v1, " queryExistingIndex="

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, p0}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v0, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 63
    return-void
.end method

.method public static rebuildDynamic(Lcom/android/settings/intelligence/search/indexing/DatabaseIndexingManager;)V
    .registers 2

    .line 67
    sget-boolean v0, Lcom/k4/settingsintelligence/K4SearchSpeed;->sIndexUsable:Z

    if-eqz v0, :cond_c

    .line 68
    sget-object p0, Lcom/k4/settingsintelligence/K4SearchSpeed;->sDynamicClearPending:Ljava/lang/ThreadLocal;

    sget-object v0, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    invoke-virtual {p0, v0}, Ljava/lang/ThreadLocal;->set(Ljava/lang/Object;)V

    goto :goto_f

    .line 70
    :cond_c
    invoke-virtual {p0}, Lcom/android/settings/intelligence/search/indexing/DatabaseIndexingManager;->rebuildDynamicIndexDatabase()V

    .line 72
    :goto_f
    return-void
.end method
