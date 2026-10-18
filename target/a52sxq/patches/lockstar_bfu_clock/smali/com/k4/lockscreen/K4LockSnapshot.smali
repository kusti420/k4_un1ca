.class public final Lcom/k4/lockscreen/K4LockSnapshot;
.super Ljava/lang/Object;
.source "K4LockSnapshot.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/k4/lockscreen/K4LockSnapshot$Writer;
    }
.end annotation


# static fields
.field private static final blacklist AUTHORITY:Ljava/lang/String; = "com.samsung.systemui.lockstar.provider.LockScreenDataContent"

.field private static final blacklist FILE_NAME:Ljava/lang/String; = "k4_lockstar_snapshot.json"

.field private static final blacklist FORMAT:I = 0x1

.field private static final blacklist MAX_ENTRIES:I = 0x100

.field private static final blacklist PROP:Ljava/lang/String; = "persist.sys.k4.lock_bfu_snapshot"

.field static final blacklist TAG:Ljava/lang/String; = "K4LockSnap"

.field private static final blacklist WRITE_DELAY_MS:J = 0x3e8L

.field private static blacklist sEntries:Ljava/util/LinkedHashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/LinkedHashMap<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field private static blacklist sHandler:Landroid/os/Handler;

.field private static final blacklist sInCall:Ljava/lang/ThreadLocal;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/lang/ThreadLocal<",
            "Ljava/lang/Boolean;",
            ">;"
        }
    .end annotation
.end field

.field private static final blacklist sLock:Ljava/lang/Object;

.field private static volatile blacklist sProcess:I

.field private static blacklist sWritePending:Z


# direct methods
.method static constructor blacklist <clinit>()V
    .registers 1

    .line 56
    new-instance v0, Ljava/lang/ThreadLocal;

    invoke-direct {v0}, Ljava/lang/ThreadLocal;-><init>()V

    sput-object v0, Lcom/k4/lockscreen/K4LockSnapshot;->sInCall:Ljava/lang/ThreadLocal;

    .line 60
    new-instance v0, Ljava/lang/Object;

    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    sput-object v0, Lcom/k4/lockscreen/K4LockSnapshot;->sLock:Ljava/lang/Object;

    return-void
.end method

.method private constructor blacklist <init>()V
    .registers 1

    .line 66
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 67
    return-void
.end method

.method public static blacklist call(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Landroid/os/Bundle;)Landroid/os/Bundle;
    .registers 10

    .line 91
    invoke-static {}, Lcom/k4/lockscreen/K4LockSnapshot;->mode()I

    move-result v0

    invoke-static {v0, p2, p3, p4}, Lcom/k4/lockscreen/K4LockSnapshot;->key(ILjava/lang/String;Ljava/lang/String;Landroid/os/Bundle;)Ljava/lang/String;

    move-result-object v0

    .line 92
    if-nez v0, :cond_f

    .line 93
    invoke-static {p0, p1, p2, p3, p4}, Lcom/k4/lockscreen/K4LockSnapshot;->real(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Landroid/os/Bundle;)Landroid/os/Bundle;

    move-result-object p0

    return-object p0

    .line 95
    :cond_f
    invoke-static {}, Landroid/app/ActivityThread;->currentApplication()Landroid/app/Application;

    move-result-object v1

    .line 96
    if-nez v1, :cond_1a

    .line 97
    invoke-static {p0, p1, p2, p3, p4}, Lcom/k4/lockscreen/K4LockSnapshot;->real(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Landroid/os/Bundle;)Landroid/os/Bundle;

    move-result-object p0

    return-object p0

    .line 99
    :cond_1a
    invoke-static {v1}, Lcom/k4/lockscreen/K4LockSnapshot;->unlocked(Landroid/content/Context;)Z

    move-result v2

    const-string v3, "K4LockSnap"

    if-nez v2, :cond_66

    .line 100
    invoke-static {v1, v0}, Lcom/k4/lockscreen/K4LockSnapshot;->lookup(Landroid/content/Context;Ljava/lang/String;)Landroid/os/Bundle;

    move-result-object v1

    .line 101
    const/16 v2, 0x20

    const/16 v4, 0xa

    if-eqz v1, :cond_47

    .line 102
    invoke-virtual {v0, v4, v2}, Ljava/lang/String;->replace(CC)Ljava/lang/String;

    move-result-object p0

    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    const-string p2, "locked: stored answer for "

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v3, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 103
    return-object v1

    .line 105
    :cond_47
    invoke-virtual {v0, v4, v2}, Ljava/lang/String;->replace(CC)Ljava/lang/String;

    move-result-object v0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "locked: nothing stored for "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v3, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 106
    invoke-static {p0, p1, p2, p3, p4}, Lcom/k4/lockscreen/K4LockSnapshot;->real(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Landroid/os/Bundle;)Landroid/os/Bundle;

    move-result-object p0

    return-object p0

    .line 108
    :cond_66
    invoke-static {p0, p1, p2, p3, p4}, Lcom/k4/lockscreen/K4LockSnapshot;->real(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Landroid/os/Bundle;)Landroid/os/Bundle;

    move-result-object p0

    .line 110
    :try_start_6a
    invoke-static {v1, v0, p0}, Lcom/k4/lockscreen/K4LockSnapshot;->record(Landroid/content/Context;Ljava/lang/String;Landroid/os/Bundle;)V
    :try_end_6d
    .catchall {:try_start_6a .. :try_end_6d} :catchall_6e

    .line 113
    goto :goto_74

    .line 111
    :catchall_6e
    move-exception p1

    .line 112
    const-string p2, "record failed"

    invoke-static {v3, p2, p1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 114
    :goto_74
    return-object p0
.end method

.method private static blacklist file(Landroid/content/Context;)Ljava/io/File;
    .registers 3

    .line 234
    new-instance v0, Ljava/io/File;

    invoke-virtual {p0}, Landroid/content/Context;->createDeviceProtectedStorageContext()Landroid/content/Context;

    move-result-object p0

    invoke-virtual {p0}, Landroid/content/Context;->getFilesDir()Ljava/io/File;

    move-result-object p0

    const-string v1, "k4_lockstar_snapshot.json"

    invoke-direct {v0, p0, v1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    return-object v0
.end method

.method public static blacklist handles(Ljava/lang/String;)Z
    .registers 4

    .line 71
    const-string v0, "com.samsung.systemui.lockstar.provider.LockScreenDataContent"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    const/4 v0, 0x0

    if-nez p0, :cond_a

    .line 72
    return v0

    .line 74
    :cond_a
    sget-object p0, Lcom/k4/lockscreen/K4LockSnapshot;->sInCall:Ljava/lang/ThreadLocal;

    invoke-virtual {p0}, Ljava/lang/ThreadLocal;->get()Ljava/lang/Object;

    move-result-object p0

    if-eqz p0, :cond_13

    .line 75
    return v0

    .line 77
    :cond_13
    sget p0, Lcom/k4/lockscreen/K4LockSnapshot;->sProcess:I

    .line 78
    const/4 v1, 0x1

    if-nez p0, :cond_30

    .line 79
    invoke-static {}, Landroid/app/ActivityThread;->currentApplication()Landroid/app/Application;

    move-result-object p0

    .line 80
    if-nez p0, :cond_1f

    .line 81
    return v0

    .line 83
    :cond_1f
    const-string v2, "com.android.systemui"

    invoke-virtual {p0}, Landroid/app/Application;->getPackageName()Ljava/lang/String;

    move-result-object p0

    invoke-virtual {v2, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_2d

    move p0, v1

    goto :goto_2e

    :cond_2d
    const/4 p0, -0x1

    .line 84
    :goto_2e
    sput p0, Lcom/k4/lockscreen/K4LockSnapshot;->sProcess:I

    .line 86
    :cond_30
    if-ne p0, v1, :cond_39

    invoke-static {}, Lcom/k4/lockscreen/K4LockSnapshot;->mode()I

    move-result p0

    if-eqz p0, :cond_39

    move v0, v1

    :cond_39
    return v0
.end method

.method static blacklist key(ILjava/lang/String;Ljava/lang/String;Landroid/os/Bundle;)Ljava/lang/String;
    .registers 8

    .line 145
    const/4 v0, 0x0

    if-nez p2, :cond_4

    .line 146
    return-object v0

    .line 148
    :cond_4
    const-string v1, "get"

    invoke-virtual {v1, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_2d

    .line 149
    const-string p0, "item"

    invoke-virtual {p0, p2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-nez p0, :cond_42

    const-string p0, "items"

    invoke-virtual {p0, p2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-nez p0, :cond_42

    const-string p0, "lock_data_bundle"

    invoke-virtual {p0, p2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-nez p0, :cond_42

    .line 150
    const-string p0, "all_item_keys"

    invoke-virtual {p0, p2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-nez p0, :cond_42

    .line 151
    return-object v0

    .line 153
    :cond_2d
    const-string v1, "lock-star-get"

    invoke-virtual {v1, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_bf

    .line 154
    const/4 v1, 0x2

    if-lt p0, v1, :cond_be

    const-string p0, "lock_star_enabled"

    invoke-virtual {p0, p2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-nez p0, :cond_42

    goto/16 :goto_be

    .line 160
    :cond_42
    new-instance p0, Ljava/lang/StringBuilder;

    invoke-direct {p0, p1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    const/16 p1, 0xa

    invoke-virtual {p0, p1}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    .line 161
    if-eqz p3, :cond_b9

    .line 162
    new-instance p2, Ljava/util/ArrayList;

    invoke-virtual {p3}, Landroid/os/Bundle;->keySet()Ljava/util/Set;

    move-result-object v1

    invoke-direct {p2, v1}, Ljava/util/ArrayList;-><init>(Ljava/util/Collection;)V

    .line 163
    invoke-static {p2}, Ljava/util/Collections;->sort(Ljava/util/List;)V

    .line 164
    invoke-virtual {p2}, Ljava/util/ArrayList;->iterator()Ljava/util/Iterator;

    move-result-object p2

    :cond_63
    :goto_63
    invoke-interface {p2}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_b9

    invoke-interface {p2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/String;

    .line 167
    const-string v2, "primary_result"

    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-nez v2, :cond_63

    const-string v2, "request_from"

    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_80

    .line 168
    goto :goto_63

    .line 170
    :cond_80
    invoke-virtual {p3, v1}, Landroid/os/Bundle;->get(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v2

    .line 172
    if-eqz v2, :cond_a3

    instance-of v3, v2, Ljava/lang/String;

    if-nez v3, :cond_a3

    instance-of v3, v2, Ljava/lang/Boolean;

    if-nez v3, :cond_a3

    instance-of v3, v2, Ljava/lang/Integer;

    if-nez v3, :cond_a3

    instance-of v3, v2, Ljava/lang/Long;

    if-eqz v3, :cond_97

    goto :goto_a3

    .line 175
    :cond_97
    instance-of v3, v2, [Ljava/lang/String;

    if-eqz v3, :cond_a2

    .line 176
    check-cast v2, [Ljava/lang/String;

    invoke-static {v2}, Ljava/util/Arrays;->toString([Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v2

    goto :goto_a7

    .line 178
    :cond_a2
    return-object v0

    .line 174
    :cond_a3
    :goto_a3
    invoke-static {v2}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v2

    .line 180
    :goto_a7
    invoke-virtual {p0, p1}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const/16 v3, 0x3d

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 181
    goto :goto_63

    .line 183
    :cond_b9
    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 155
    :cond_be
    :goto_be
    return-object v0

    .line 158
    :cond_bf
    return-object v0
.end method

.method private static blacklist load(Landroid/content/Context;)V
    .registers 6

    .line 239
    const-string v0, "format"

    const-string v1, "K4LockSnap"

    sget-object v2, Lcom/k4/lockscreen/K4LockSnapshot;->sEntries:Ljava/util/LinkedHashMap;

    if-eqz v2, :cond_9

    .line 240
    return-void

    .line 242
    :cond_9
    new-instance v2, Ljava/util/LinkedHashMap;

    invoke-direct {v2}, Ljava/util/LinkedHashMap;-><init>()V

    sput-object v2, Lcom/k4/lockscreen/K4LockSnapshot;->sEntries:Ljava/util/LinkedHashMap;

    .line 244
    :try_start_10
    invoke-static {p0}, Lcom/k4/lockscreen/K4LockSnapshot;->file(Landroid/content/Context;)Ljava/io/File;

    move-result-object p0

    .line 245
    invoke-virtual {p0}, Ljava/io/File;->exists()Z

    move-result v2

    if-nez v2, :cond_1b

    .line 246
    return-void

    .line 248
    :cond_1b
    new-instance v2, Lorg/json/JSONObject;

    new-instance v3, Ljava/lang/String;

    new-instance v4, Landroid/util/AtomicFile;

    invoke-direct {v4, p0}, Landroid/util/AtomicFile;-><init>(Ljava/io/File;)V

    invoke-virtual {v4}, Landroid/util/AtomicFile;->readFully()[B

    move-result-object p0

    sget-object v4, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    invoke-direct {v3, p0, v4}, Ljava/lang/String;-><init>([BLjava/nio/charset/Charset;)V

    invoke-direct {v2, v3}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    .line 249
    invoke-virtual {v2, v0}, Lorg/json/JSONObject;->optInt(Ljava/lang/String;)I

    move-result p0

    const/4 v3, 0x1

    if-eq p0, v3, :cond_52

    .line 250
    invoke-virtual {v2, v0}, Lorg/json/JSONObject;->optInt(Ljava/lang/String;)I

    move-result p0

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "ignoring snapshot with format "

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v1, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 251
    return-void

    .line 253
    :cond_52
    const-string p0, "entries"

    invoke-virtual {v2, p0}, Lorg/json/JSONObject;->getJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object p0

    .line 254
    invoke-virtual {p0}, Lorg/json/JSONObject;->keys()Ljava/util/Iterator;

    move-result-object v0

    .line 255
    :goto_5c
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_76

    .line 256
    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/String;

    .line 257
    sget-object v3, Lcom/k4/lockscreen/K4LockSnapshot;->sEntries:Ljava/util/LinkedHashMap;

    invoke-virtual {p0, v2}, Lorg/json/JSONObject;->getJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object v4

    invoke-virtual {v4}, Lorg/json/JSONObject;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v2, v4}, Ljava/util/LinkedHashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 258
    goto :goto_5c

    .line 259
    :cond_76
    sget-object p0, Lcom/k4/lockscreen/K4LockSnapshot;->sEntries:Ljava/util/LinkedHashMap;

    invoke-virtual {p0}, Ljava/util/LinkedHashMap;->size()I

    move-result p0

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "loaded "

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string v0, " stored answers"

    invoke-virtual {p0, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v1, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_98
    .catchall {:try_start_10 .. :try_end_98} :catchall_99

    .line 263
    goto :goto_b9

    .line 260
    :catchall_99
    move-exception p0

    .line 261
    invoke-static {p0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "snapshot unreadable, starting empty: "

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v1, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 262
    sget-object p0, Lcom/k4/lockscreen/K4LockSnapshot;->sEntries:Ljava/util/LinkedHashMap;

    invoke-virtual {p0}, Ljava/util/LinkedHashMap;->clear()V

    .line 264
    :goto_b9
    return-void
.end method

.method private static blacklist lookup(Landroid/content/Context;Ljava/lang/String;)Landroid/os/Bundle;
    .registers 5

    .line 188
    sget-object v0, Lcom/k4/lockscreen/K4LockSnapshot;->sLock:Ljava/lang/Object;

    monitor-enter v0

    .line 189
    :try_start_3
    invoke-static {p0}, Lcom/k4/lockscreen/K4LockSnapshot;->load(Landroid/content/Context;)V

    .line 190
    sget-object p0, Lcom/k4/lockscreen/K4LockSnapshot;->sEntries:Ljava/util/LinkedHashMap;

    invoke-virtual {p0, p1}, Ljava/util/LinkedHashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/String;

    .line 191
    monitor-exit v0
    :try_end_f
    .catchall {:try_start_3 .. :try_end_f} :catchall_3b

    .line 192
    const/4 p1, 0x0

    if-nez p0, :cond_13

    .line 193
    return-object p1

    .line 196
    :cond_13
    :try_start_13
    new-instance v0, Lorg/json/JSONObject;

    invoke-direct {v0, p0}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    invoke-static {v0}, Lcom/k4/lockscreen/K4LockSnapshot;->toBundle(Lorg/json/JSONObject;)Landroid/os/Bundle;

    move-result-object p0
    :try_end_1c
    .catchall {:try_start_13 .. :try_end_1c} :catchall_1d

    return-object p0

    .line 197
    :catchall_1d
    move-exception p0

    .line 198
    const-string v0, "K4LockSnap"

    invoke-static {p0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "stored answer unreadable: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v0, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 199
    return-object p1

    .line 191
    :catchall_3b
    move-exception p0

    :try_start_3c
    monitor-exit v0
    :try_end_3d
    .catchall {:try_start_3c .. :try_end_3d} :catchall_3b

    throw p0
.end method

.method private static blacklist mode()I
    .registers 2

    .line 119
    const/4 v0, 0x1

    :try_start_1
    const-string v1, "persist.sys.k4.lock_bfu_snapshot"

    invoke-static {v1, v0}, Landroid/os/SystemProperties;->getInt(Ljava/lang/String;I)I

    move-result v0
    :try_end_7
    .catchall {:try_start_1 .. :try_end_7} :catchall_8

    return v0

    .line 120
    :catchall_8
    move-exception v1

    .line 121
    return v0
.end method

.method private static blacklist real(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Landroid/os/Bundle;)Landroid/os/Bundle;
    .registers 7

    .line 126
    sget-object v0, Lcom/k4/lockscreen/K4LockSnapshot;->sInCall:Ljava/lang/ThreadLocal;

    sget-object v1, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    invoke-virtual {v0, v1}, Ljava/lang/ThreadLocal;->set(Ljava/lang/Object;)V

    .line 128
    :try_start_7
    invoke-virtual {p0, p1, p2, p3, p4}, Landroid/content/ContentResolver;->call(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Landroid/os/Bundle;)Landroid/os/Bundle;

    move-result-object p0
    :try_end_b
    .catchall {:try_start_7 .. :try_end_b} :catchall_11

    .line 130
    sget-object p1, Lcom/k4/lockscreen/K4LockSnapshot;->sInCall:Ljava/lang/ThreadLocal;

    invoke-virtual {p1}, Ljava/lang/ThreadLocal;->remove()V

    .line 128
    return-object p0

    .line 130
    :catchall_11
    move-exception p0

    sget-object p1, Lcom/k4/lockscreen/K4LockSnapshot;->sInCall:Ljava/lang/ThreadLocal;

    invoke-virtual {p1}, Ljava/lang/ThreadLocal;->remove()V

    .line 131
    throw p0
.end method

.method private static blacklist record(Landroid/content/Context;Ljava/lang/String;Landroid/os/Bundle;)V
    .registers 7

    .line 204
    nop

    .line 205
    const/4 v0, 0x0

    if-eqz p2, :cond_10

    .line 206
    invoke-static {p2}, Lcom/k4/lockscreen/K4LockSnapshot;->toJson(Landroid/os/Bundle;)Lorg/json/JSONObject;

    move-result-object p2

    .line 207
    if-nez p2, :cond_b

    goto :goto_10

    :cond_b
    invoke-virtual {p2}, Lorg/json/JSONObject;->toString()Ljava/lang/String;

    move-result-object p2

    move-object v0, p2

    .line 209
    :cond_10
    :goto_10
    sget-object p2, Lcom/k4/lockscreen/K4LockSnapshot;->sLock:Ljava/lang/Object;

    monitor-enter p2

    .line 210
    :try_start_13
    invoke-static {p0}, Lcom/k4/lockscreen/K4LockSnapshot;->load(Landroid/content/Context;)V

    .line 211
    sget-object v1, Lcom/k4/lockscreen/K4LockSnapshot;->sEntries:Ljava/util/LinkedHashMap;

    invoke-virtual {v1, p1}, Ljava/util/LinkedHashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/String;

    .line 212
    if-nez v0, :cond_23

    if-nez v1, :cond_2b

    goto :goto_29

    :cond_23
    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_2b

    .line 213
    :goto_29
    monitor-exit p2

    return-void

    .line 215
    :cond_2b
    if-nez v0, :cond_33

    .line 216
    sget-object v1, Lcom/k4/lockscreen/K4LockSnapshot;->sEntries:Ljava/util/LinkedHashMap;

    invoke-virtual {v1, p1}, Ljava/util/LinkedHashMap;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    goto :goto_58

    .line 218
    :cond_33
    sget-object v1, Lcom/k4/lockscreen/K4LockSnapshot;->sEntries:Ljava/util/LinkedHashMap;

    invoke-virtual {v1, p1}, Ljava/util/LinkedHashMap;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    .line 219
    sget-object v1, Lcom/k4/lockscreen/K4LockSnapshot;->sEntries:Ljava/util/LinkedHashMap;

    invoke-virtual {v1, p1, v0}, Ljava/util/LinkedHashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 220
    :goto_3d
    sget-object v1, Lcom/k4/lockscreen/K4LockSnapshot;->sEntries:Ljava/util/LinkedHashMap;

    invoke-virtual {v1}, Ljava/util/LinkedHashMap;->size()I

    move-result v1

    const/16 v2, 0x100

    if-le v1, v2, :cond_58

    .line 221
    sget-object v1, Lcom/k4/lockscreen/K4LockSnapshot;->sEntries:Ljava/util/LinkedHashMap;

    invoke-virtual {v1}, Ljava/util/LinkedHashMap;->keySet()Ljava/util/Set;

    move-result-object v1

    invoke-interface {v1}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v1

    .line 222
    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    .line 223
    invoke-interface {v1}, Ljava/util/Iterator;->remove()V

    .line 224
    goto :goto_3d

    .line 226
    :cond_58
    :goto_58
    const-string v1, "K4LockSnap"

    if-nez v0, :cond_5f

    const-string v0, "dropped "

    goto :goto_61

    :cond_5f
    const-string v0, "stored "

    :goto_61
    const/16 v2, 0xa

    const/16 v3, 0x20

    invoke-virtual {p1, v2, v3}, Ljava/lang/String;->replace(CC)Ljava/lang/String;

    move-result-object p1

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v1, p1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 227
    invoke-static {p0}, Lcom/k4/lockscreen/K4LockSnapshot;->scheduleWrite(Landroid/content/Context;)V

    .line 228
    monitor-exit p2

    .line 229
    return-void

    .line 228
    :catchall_82
    move-exception p0

    monitor-exit p2
    :try_end_84
    .catchall {:try_start_13 .. :try_end_84} :catchall_82

    throw p0
.end method

.method private static blacklist scheduleWrite(Landroid/content/Context;)V
    .registers 5

    .line 268
    sget-boolean v0, Lcom/k4/lockscreen/K4LockSnapshot;->sWritePending:Z

    if-eqz v0, :cond_5

    .line 269
    return-void

    .line 271
    :cond_5
    sget-object v0, Lcom/k4/lockscreen/K4LockSnapshot;->sHandler:Landroid/os/Handler;

    if-nez v0, :cond_20

    .line 272
    new-instance v0, Landroid/os/HandlerThread;

    const-string v1, "K4LockSnap"

    const/16 v2, 0xa

    invoke-direct {v0, v1, v2}, Landroid/os/HandlerThread;-><init>(Ljava/lang/String;I)V

    .line 273
    invoke-virtual {v0}, Landroid/os/HandlerThread;->start()V

    .line 274
    new-instance v1, Landroid/os/Handler;

    invoke-virtual {v0}, Landroid/os/HandlerThread;->getLooper()Landroid/os/Looper;

    move-result-object v0

    invoke-direct {v1, v0}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    sput-object v1, Lcom/k4/lockscreen/K4LockSnapshot;->sHandler:Landroid/os/Handler;

    .line 276
    :cond_20
    const/4 v0, 0x1

    sput-boolean v0, Lcom/k4/lockscreen/K4LockSnapshot;->sWritePending:Z

    .line 277
    sget-object v0, Lcom/k4/lockscreen/K4LockSnapshot;->sHandler:Landroid/os/Handler;

    new-instance v1, Lcom/k4/lockscreen/K4LockSnapshot$Writer;

    invoke-direct {v1, p0}, Lcom/k4/lockscreen/K4LockSnapshot$Writer;-><init>(Landroid/content/Context;)V

    const-wide/16 v2, 0x3e8

    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    .line 278
    return-void
.end method

.method static blacklist toBundle(Lorg/json/JSONObject;)Landroid/os/Bundle;
    .registers 10
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 374
    new-instance v0, Landroid/os/Bundle;

    invoke-direct {v0}, Landroid/os/Bundle;-><init>()V

    .line 375
    invoke-virtual {p0}, Lorg/json/JSONObject;->keys()Ljava/util/Iterator;

    move-result-object v1

    .line 376
    :goto_9
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_113

    .line 377
    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/String;

    .line 378
    invoke-virtual {p0, v2}, Lorg/json/JSONObject;->getJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object v3

    .line 379
    const-string v4, "t"

    invoke-virtual {v3, v4}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    .line 380
    invoke-virtual {v4}, Ljava/lang/String;->hashCode()I

    move-result v5

    const/4 v6, 0x0

    sparse-switch v5, :sswitch_data_114

    :cond_27
    goto :goto_83

    :sswitch_28
    const-string v5, "z"

    invoke-virtual {v4, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v5

    if-eqz v5, :cond_27

    const/4 v5, 0x2

    goto :goto_84

    :sswitch_32
    const-string v5, "s"

    invoke-virtual {v4, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v5

    if-eqz v5, :cond_27

    const/4 v5, 0x1

    goto :goto_84

    :sswitch_3c
    const-string v5, "n"

    invoke-virtual {v4, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v5

    if-eqz v5, :cond_27

    move v5, v6

    goto :goto_84

    :sswitch_46
    const-string v5, "l"

    invoke-virtual {v4, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v5

    if-eqz v5, :cond_27

    const/4 v5, 0x4

    goto :goto_84

    :sswitch_50
    const-string v5, "i"

    invoke-virtual {v4, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v5

    if-eqz v5, :cond_27

    const/4 v5, 0x3

    goto :goto_84

    :sswitch_5a
    const-string v5, "f"

    invoke-virtual {v4, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v5

    if-eqz v5, :cond_27

    const/4 v5, 0x5

    goto :goto_84

    :sswitch_64
    const-string v5, "d"

    invoke-virtual {v4, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v5

    if-eqz v5, :cond_27

    const/4 v5, 0x6

    goto :goto_84

    :sswitch_6e
    const-string v5, "S"

    invoke-virtual {v4, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v5

    if-eqz v5, :cond_27

    const/4 v5, 0x7

    goto :goto_84

    :sswitch_78
    const-string v5, "B"

    invoke-virtual {v4, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v5

    if-eqz v5, :cond_27

    const/16 v5, 0x8

    goto :goto_84

    :goto_83
    const/4 v5, -0x1

    :goto_84
    const/4 v7, 0x0

    const-string v8, "v"

    packed-switch v5, :pswitch_data_13a

    .line 415
    new-instance p0, Ljava/lang/IllegalArgumentException;

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "type "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-direct {p0, v0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 412
    :pswitch_a3
    invoke-virtual {v3, v8}, Lorg/json/JSONObject;->getJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object v3

    invoke-static {v3}, Lcom/k4/lockscreen/K4LockSnapshot;->toBundle(Lorg/json/JSONObject;)Landroid/os/Bundle;

    move-result-object v3

    invoke-virtual {v0, v2, v3}, Landroid/os/Bundle;->putBundle(Ljava/lang/String;Landroid/os/Bundle;)V

    .line 413
    goto :goto_111

    .line 403
    :pswitch_af
    invoke-virtual {v3, v8}, Lorg/json/JSONObject;->getJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;

    move-result-object v3

    .line 404
    invoke-virtual {v3}, Lorg/json/JSONArray;->length()I

    move-result v4

    new-array v5, v4, [Ljava/lang/String;

    .line 405
    nop

    :goto_ba
    if-ge v6, v4, :cond_cd

    .line 406
    invoke-virtual {v3, v6}, Lorg/json/JSONArray;->isNull(I)Z

    move-result v8

    if-eqz v8, :cond_c4

    move-object v8, v7

    goto :goto_c8

    :cond_c4
    invoke-virtual {v3, v6}, Lorg/json/JSONArray;->getString(I)Ljava/lang/String;

    move-result-object v8

    :goto_c8
    aput-object v8, v5, v6

    .line 405
    add-int/lit8 v6, v6, 0x1

    goto :goto_ba

    .line 408
    :cond_cd
    invoke-virtual {v0, v2, v5}, Landroid/os/Bundle;->putStringArray(Ljava/lang/String;[Ljava/lang/String;)V

    .line 409
    goto :goto_111

    .line 400
    :pswitch_d1
    invoke-virtual {v3, v8}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    invoke-static {v3}, Ljava/lang/Double;->parseDouble(Ljava/lang/String;)D

    move-result-wide v3

    invoke-virtual {v0, v2, v3, v4}, Landroid/os/Bundle;->putDouble(Ljava/lang/String;D)V

    .line 401
    goto :goto_111

    .line 397
    :pswitch_dd
    invoke-virtual {v3, v8}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    invoke-static {v3}, Ljava/lang/Float;->parseFloat(Ljava/lang/String;)F

    move-result v3

    invoke-virtual {v0, v2, v3}, Landroid/os/Bundle;->putFloat(Ljava/lang/String;F)V

    .line 398
    goto :goto_111

    .line 394
    :pswitch_e9
    invoke-virtual {v3, v8}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    invoke-static {v3}, Ljava/lang/Long;->parseLong(Ljava/lang/String;)J

    move-result-wide v3

    invoke-virtual {v0, v2, v3, v4}, Landroid/os/Bundle;->putLong(Ljava/lang/String;J)V

    .line 395
    goto :goto_111

    .line 391
    :pswitch_f5
    invoke-virtual {v3, v8}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result v3

    invoke-virtual {v0, v2, v3}, Landroid/os/Bundle;->putInt(Ljava/lang/String;I)V

    .line 392
    goto :goto_111

    .line 388
    :pswitch_fd
    invoke-virtual {v3, v8}, Lorg/json/JSONObject;->getBoolean(Ljava/lang/String;)Z

    move-result v3

    invoke-virtual {v0, v2, v3}, Landroid/os/Bundle;->putBoolean(Ljava/lang/String;Z)V

    .line 389
    goto :goto_111

    .line 385
    :pswitch_105
    invoke-virtual {v3, v8}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v0, v2, v3}, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V

    .line 386
    goto :goto_111

    .line 382
    :pswitch_10d
    invoke-virtual {v0, v2, v7}, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V

    .line 383
    nop

    .line 417
    :goto_111
    goto/16 :goto_9

    .line 418
    :cond_113
    return-object v0

    :sswitch_data_114
    .sparse-switch
        0x42 -> :sswitch_78
        0x53 -> :sswitch_6e
        0x64 -> :sswitch_64
        0x66 -> :sswitch_5a
        0x69 -> :sswitch_50
        0x6c -> :sswitch_46
        0x6e -> :sswitch_3c
        0x73 -> :sswitch_32
        0x7a -> :sswitch_28
    .end sparse-switch

    :pswitch_data_13a
    .packed-switch 0x0
        :pswitch_10d
        :pswitch_105
        :pswitch_fd
        :pswitch_f5
        :pswitch_e9
        :pswitch_dd
        :pswitch_d1
        :pswitch_af
        :pswitch_a3
    .end packed-switch
.end method

.method static blacklist toJson(Landroid/os/Bundle;)Lorg/json/JSONObject;
    .registers 14

    .line 330
    const-string v0, "K4LockSnap"

    const/4 v1, 0x0

    :try_start_3
    new-instance v2, Lorg/json/JSONObject;

    invoke-direct {v2}, Lorg/json/JSONObject;-><init>()V

    .line 331
    invoke-virtual {p0}, Landroid/os/Bundle;->keySet()Ljava/util/Set;

    move-result-object v3

    invoke-interface {v3}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v3

    :goto_10
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    move-result v4

    if-eqz v4, :cond_ff

    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/String;

    .line 332
    invoke-virtual {p0, v4}, Landroid/os/Bundle;->get(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v5

    .line 333
    new-instance v6, Lorg/json/JSONObject;

    invoke-direct {v6}, Lorg/json/JSONObject;-><init>()V
    :try_end_25
    .catchall {:try_start_3 .. :try_end_25} :catchall_100

    .line 334
    const-string v7, "t"

    if-nez v5, :cond_30

    .line 335
    :try_start_29
    const-string v5, "n"

    invoke-virtual {v6, v7, v5}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    goto/16 :goto_d1

    .line 336
    :cond_30
    instance-of v8, v5, Ljava/lang/String;
    :try_end_32
    .catchall {:try_start_29 .. :try_end_32} :catchall_100

    const-string v9, "v"

    if-eqz v8, :cond_41

    .line 337
    :try_start_36
    const-string v8, "s"

    invoke-virtual {v6, v7, v8}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    move-result-object v7

    invoke-virtual {v7, v9, v5}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    goto/16 :goto_d1

    .line 338
    :cond_41
    instance-of v8, v5, Ljava/lang/Boolean;

    if-eqz v8, :cond_50

    .line 339
    const-string v8, "z"

    invoke-virtual {v6, v7, v8}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    move-result-object v7

    invoke-virtual {v7, v9, v5}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    goto/16 :goto_d1

    .line 340
    :cond_50
    instance-of v8, v5, Ljava/lang/Integer;

    if-eqz v8, :cond_5f

    .line 341
    const-string v8, "i"

    invoke-virtual {v6, v7, v8}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    move-result-object v7

    invoke-virtual {v7, v9, v5}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    goto/16 :goto_d1

    .line 342
    :cond_5f
    instance-of v8, v5, Ljava/lang/Long;

    if-eqz v8, :cond_71

    .line 343
    const-string v8, "l"

    invoke-virtual {v6, v7, v8}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    move-result-object v7

    invoke-static {v5}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v7, v9, v5}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    goto :goto_d1

    .line 344
    :cond_71
    instance-of v8, v5, Ljava/lang/Float;

    if-eqz v8, :cond_83

    .line 345
    const-string v8, "f"

    invoke-virtual {v6, v7, v8}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    move-result-object v7

    invoke-static {v5}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v7, v9, v5}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    goto :goto_d1

    .line 346
    :cond_83
    instance-of v8, v5, Ljava/lang/Double;

    if-eqz v8, :cond_95

    .line 347
    const-string v8, "d"

    invoke-virtual {v6, v7, v8}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    move-result-object v7

    invoke-static {v5}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v7, v9, v5}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    goto :goto_d1

    .line 348
    :cond_95
    instance-of v8, v5, [Ljava/lang/String;

    if-eqz v8, :cond_ba

    .line 349
    new-instance v8, Lorg/json/JSONArray;

    invoke-direct {v8}, Lorg/json/JSONArray;-><init>()V

    .line 350
    check-cast v5, [Ljava/lang/String;

    array-length v10, v5

    const/4 v11, 0x0

    :goto_a2
    if-ge v11, v10, :cond_b0

    aget-object v12, v5, v11

    .line 351
    if-nez v12, :cond_aa

    sget-object v12, Lorg/json/JSONObject;->NULL:Ljava/lang/Object;

    :cond_aa
    invoke-virtual {v8, v12}, Lorg/json/JSONArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;

    .line 350
    add-int/lit8 v11, v11, 0x1

    goto :goto_a2

    .line 353
    :cond_b0
    const-string v5, "S"

    invoke-virtual {v6, v7, v5}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    move-result-object v5

    invoke-virtual {v5, v9, v8}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 354
    goto :goto_d1

    :cond_ba
    instance-of v8, v5, Landroid/os/Bundle;

    if-eqz v8, :cond_d6

    .line 355
    check-cast v5, Landroid/os/Bundle;

    invoke-static {v5}, Lcom/k4/lockscreen/K4LockSnapshot;->toJson(Landroid/os/Bundle;)Lorg/json/JSONObject;

    move-result-object v5

    .line 356
    if-nez v5, :cond_c7

    .line 357
    return-object v1

    .line 359
    :cond_c7
    const-string v8, "B"

    invoke-virtual {v6, v7, v8}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    move-result-object v7

    invoke-virtual {v7, v9, v5}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 360
    nop

    .line 364
    :goto_d1
    invoke-virtual {v2, v4, v6}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 365
    goto/16 :goto_10

    .line 361
    :cond_d6
    invoke-virtual {v5}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/Class;->getName()Ljava/lang/String;

    move-result-object p0

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "not storable: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, " is "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v0, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_fe
    .catchall {:try_start_36 .. :try_end_fe} :catchall_100

    .line 362
    return-object v1

    .line 366
    :cond_ff
    return-object v2

    .line 367
    :catchall_100
    move-exception p0

    .line 368
    invoke-static {p0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "toJson failed: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v0, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 369
    return-object v1
.end method

.method private static blacklist unlocked(Landroid/content/Context;)Z
    .registers 3

    .line 136
    const/4 v0, 0x1

    :try_start_1
    const-class v1, Landroid/os/UserManager;

    invoke-virtual {p0, v1}, Landroid/content/Context;->getSystemService(Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Landroid/os/UserManager;

    .line 137
    if-eqz p0, :cond_13

    invoke-virtual {p0}, Landroid/os/UserManager;->isUserUnlocked()Z

    move-result p0
    :try_end_f
    .catchall {:try_start_1 .. :try_end_f} :catchall_14

    if-eqz p0, :cond_12

    goto :goto_13

    :cond_12
    const/4 v0, 0x0

    :cond_13
    :goto_13
    return v0

    .line 138
    :catchall_14
    move-exception p0

    .line 139
    return v0
.end method

.method static blacklist write(Landroid/content/Context;)V
    .registers 7

    .line 282
    sget-object v0, Lcom/k4/lockscreen/K4LockSnapshot;->sLock:Ljava/lang/Object;

    monitor-enter v0

    .line 283
    const/4 v1, 0x0

    :try_start_4
    sput-boolean v1, Lcom/k4/lockscreen/K4LockSnapshot;->sWritePending:Z
    :try_end_6
    .catchall {:try_start_4 .. :try_end_6} :catchall_82

    .line 285
    :try_start_6
    new-instance v1, Lorg/json/JSONObject;

    invoke-direct {v1}, Lorg/json/JSONObject;-><init>()V

    .line 286
    sget-object v2, Lcom/k4/lockscreen/K4LockSnapshot;->sEntries:Ljava/util/LinkedHashMap;

    invoke-virtual {v2}, Ljava/util/LinkedHashMap;->entrySet()Ljava/util/Set;

    move-result-object v2

    invoke-interface {v2}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v2

    :goto_15
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_36

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/util/Map$Entry;

    .line 287
    invoke-interface {v3}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/String;

    new-instance v5, Lorg/json/JSONObject;

    invoke-interface {v3}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/lang/String;

    invoke-direct {v5, v3}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, v4, v5}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 288
    goto :goto_15

    .line 289
    :cond_36
    new-instance v2, Lorg/json/JSONObject;

    invoke-direct {v2}, Lorg/json/JSONObject;-><init>()V

    .line 290
    const-string v3, "format"

    const/4 v4, 0x1

    invoke-virtual {v2, v3, v4}, Lorg/json/JSONObject;->put(Ljava/lang/String;I)Lorg/json/JSONObject;

    .line 291
    const-string v3, "entries"

    invoke-virtual {v2, v3, v1}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 292
    invoke-virtual {v2}, Lorg/json/JSONObject;->toString()Ljava/lang/String;

    move-result-object v1
    :try_end_4a
    .catchall {:try_start_6 .. :try_end_4a} :catchall_78

    .line 296
    nop

    .line 297
    :try_start_4b
    monitor-exit v0
    :try_end_4c
    .catchall {:try_start_4b .. :try_end_4c} :catchall_82

    .line 298
    new-instance v0, Landroid/util/AtomicFile;

    invoke-static {p0}, Lcom/k4/lockscreen/K4LockSnapshot;->file(Landroid/content/Context;)Ljava/io/File;

    move-result-object p0

    invoke-direct {v0, p0}, Landroid/util/AtomicFile;-><init>(Ljava/io/File;)V

    .line 299
    nop

    .line 301
    :try_start_56
    invoke-virtual {v0}, Landroid/util/AtomicFile;->startWrite()Ljava/io/FileOutputStream;

    move-result-object p0
    :try_end_5a
    .catchall {:try_start_56 .. :try_end_5a} :catchall_69

    .line 302
    :try_start_5a
    sget-object v2, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    invoke-virtual {v1, v2}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    move-result-object v1

    invoke-virtual {p0, v1}, Ljava/io/FileOutputStream;->write([B)V

    .line 303
    invoke-virtual {v0, p0}, Landroid/util/AtomicFile;->finishWrite(Ljava/io/FileOutputStream;)V
    :try_end_66
    .catchall {:try_start_5a .. :try_end_66} :catchall_67

    .line 309
    goto :goto_77

    .line 304
    :catchall_67
    move-exception v1

    goto :goto_6b

    :catchall_69
    move-exception v1

    const/4 p0, 0x0

    .line 305
    :goto_6b
    const-string v2, "K4LockSnap"

    const-string v3, "snapshot write failed"

    invoke-static {v2, v3, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 306
    if-eqz p0, :cond_77

    .line 307
    invoke-virtual {v0, p0}, Landroid/util/AtomicFile;->failWrite(Ljava/io/FileOutputStream;)V

    .line 310
    :cond_77
    :goto_77
    return-void

    .line 293
    :catchall_78
    move-exception p0

    .line 294
    :try_start_79
    const-string v1, "K4LockSnap"

    const-string v2, "snapshot serialize failed"

    invoke-static {v1, v2, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 295
    monitor-exit v0

    return-void

    .line 297
    :catchall_82
    move-exception p0

    monitor-exit v0
    :try_end_84
    .catchall {:try_start_79 .. :try_end_84} :catchall_82

    throw p0
.end method
