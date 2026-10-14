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

    .line 66
    sget-object v0, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    sget-object v1, Lcom/k4/settingsintelligence/K4SearchSpeed;->sDynamicClearPending:Ljava/lang/ThreadLocal;

    invoke-virtual {v1}, Ljava/lang/ThreadLocal;->get()Ljava/lang/Object;

    move-result-object v2

    invoke-virtual {v0, v2}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_47

    const-string v0, "sec_dynamic_prefs_index"

    invoke-virtual {v0, p3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_47

    .line 67
    sget-object v0, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    invoke-virtual {v1, v0}, Ljava/lang/ThreadLocal;->set(Ljava/lang/Object;)V

    .line 69
    :try_start_1b
    const-string v0, "DELETE FROM sec_dynamic_prefs_index"

    invoke-virtual {p1, v0}, Landroid/database/sqlite/SQLiteDatabase;->execSQL(Ljava/lang/String;)V
    :try_end_20
    .catch Landroid/database/sqlite/SQLiteException; {:try_start_1b .. :try_end_20} :catch_21

    goto :goto_47

    :catch_21
    move-exception v0

    .line 71
    invoke-static {v0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "in-transaction clear failed ("

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v0, "), recreating the table"

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "K4SearchSpeed"

    invoke-static {v1, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 72
    iget-object v0, p0, Lcom/android/settings/intelligence/search/indexing/DatabaseIndexingManager;->mContext:Landroid/content/Context;

    invoke-static {v0}, Lcom/android/settings/intelligence/search/indexing/IndexDatabaseHelper;->getInstance(Landroid/content/Context;)Lcom/android/settings/intelligence/search/indexing/IndexDatabaseHelper;

    move-result-object v0

    invoke-virtual {v0, p1}, Lcom/android/settings/intelligence/search/indexing/IndexDatabaseHelper;->reconstructDynamicIndexDb(Landroid/database/sqlite/SQLiteDatabase;)V

    .line 75
    :cond_47
    :goto_47
    invoke-virtual {p0, p1, p2, p3}, Lcom/android/settings/intelligence/search/indexing/DatabaseIndexingManager;->insertIndexData(Landroid/database/sqlite/SQLiteDatabase;Ljava/util/List;Ljava/lang/String;)V

    return-void
.end method

.method public static isIndexingComplete(Lcom/android/settings/intelligence/search/SearchFeatureProvider;Landroid/content/Context;)Z
    .registers 5

    .line 80
    invoke-interface {p0, p1}, Lcom/android/settings/intelligence/search/SearchFeatureProvider;->isIndexingComplete(Landroid/content/Context;)Z

    move-result v0

    const/4 v1, 0x1

    if-eqz v0, :cond_8

    return v1

    .line 83
    :cond_8
    sget-boolean v0, Lcom/k4/settingsintelligence/K4SearchSpeed;->sIndexUsable:Z

    const/4 v2, 0x0

    if-eqz v0, :cond_25

    if-nez p1, :cond_10

    goto :goto_25

    .line 87
    :cond_10
    :try_start_10
    invoke-interface {p0, p1}, Lcom/android/settings/intelligence/search/SearchFeatureProvider;->getIndexingManager(Landroid/content/Context;)Lcom/android/settings/intelligence/search/indexing/DatabaseIndexingManager;

    move-result-object p0

    if-eqz p0, :cond_25

    .line 88
    invoke-virtual {p0}, Lcom/android/settings/intelligence/search/indexing/DatabaseIndexingManager;->isLocaleChanged()Z

    move-result p0
    :try_end_1a
    .catch Ljava/lang/RuntimeException; {:try_start_10 .. :try_end_1a} :catch_25

    if-eqz p0, :cond_1d

    goto :goto_25

    .line 94
    :cond_1d
    const-string p0, "K4SearchSpeed"

    const-string p1, "refresh running: querying the existing index"

    invoke-static {p0, p1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    return v1

    :catch_25
    :cond_25
    :goto_25
    return v2
.end method

.method public static onIndexingStart(Lcom/android/settings/intelligence/search/indexing/DatabaseIndexingManager;Z)V
    .registers 5

    .line 42
    sget-object v0, Lcom/k4/settingsintelligence/K4SearchSpeed;->sDynamicClearPending:Ljava/lang/ThreadLocal;

    sget-object v1, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    invoke-virtual {v0, v1}, Ljava/lang/ThreadLocal;->set(Ljava/lang/Object;)V

    .line 44
    const-string v0, "K4SearchSpeed"

    if-nez p1, :cond_2a

    .line 46
    :try_start_b
    iget-object p0, p0, Lcom/android/settings/intelligence/search/indexing/DatabaseIndexingManager;->mContext:Landroid/content/Context;

    const-string v1, "essential_indexing_finished"

    invoke-static {p0, v1}, Lcom/android/settings/intelligence/search/indexing/IndexDatabaseHelper;->isIndexingFinished(Landroid/content/Context;Ljava/lang/String;)Z

    move-result p0
    :try_end_13
    .catch Ljava/lang/RuntimeException; {:try_start_b .. :try_end_13} :catch_14

    goto :goto_2b

    :catch_14
    move-exception p0

    .line 48
    invoke-static {p0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "isIndexingFinished failed: "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v0, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    :cond_2a
    const/4 p0, 0x0

    .line 51
    :goto_2b
    sput-boolean p0, Lcom/k4/settingsintelligence/K4SearchSpeed;->sIndexUsable:Z

    .line 52
    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "refresh start: fullIndex="

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    const-string p1, " queryExistingIndex="

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v0, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    return-void
.end method

.method public static rebuildDynamic(Lcom/android/settings/intelligence/search/indexing/DatabaseIndexingManager;)V
    .registers 2

    .line 57
    sget-boolean v0, Lcom/k4/settingsintelligence/K4SearchSpeed;->sIndexUsable:Z

    if-eqz v0, :cond_c

    .line 58
    sget-object p0, Lcom/k4/settingsintelligence/K4SearchSpeed;->sDynamicClearPending:Ljava/lang/ThreadLocal;

    sget-object v0, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    invoke-virtual {p0, v0}, Ljava/lang/ThreadLocal;->set(Ljava/lang/Object;)V

    return-void

    .line 60
    :cond_c
    invoke-virtual {p0}, Lcom/android/settings/intelligence/search/indexing/DatabaseIndexingManager;->rebuildDynamicIndexDatabase()V

    return-void
.end method
