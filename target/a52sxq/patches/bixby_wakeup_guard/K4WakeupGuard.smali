.class public final Lcom/k4/soundtrigger/K4WakeupGuard;
.super Ljava/lang/Object;
.source "K4WakeupGuard.java"


# static fields
.field private static final APP:Ljava/lang/String; = "com.samsung.android.bixby.wakeup"

.field private static final ASSETS:Ljava/lang/String; = "assets/kwdModel/"

.field private static final MODEL_DIR:Ljava/lang/String; = "/system/etc/k4wakeup/"

.field private static final SAMSUNG_UUID:Ljava/lang/String; = "a1757552-af10-11e7-985a-a3754010baa2"

.field private static final TAG:Ljava/lang/String; = "K4WakeupGuard"

.field private static final sNames:Ljava/util/HashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/HashMap<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method static constructor <clinit>()V
    .registers 1

    .line 38
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    sput-object v0, Lcom/k4/soundtrigger/K4WakeupGuard;->sNames:Ljava/util/HashMap;

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 40
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private static a52sModel(Ljava/lang/String;)[B
    .registers 9
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 88
    const-string v0, "/"

    invoke-virtual {p0, v0}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object p0

    .line 89
    array-length v1, p0

    const/4 v2, 0x3

    const/4 v3, 0x0

    if-ne v1, v2, :cond_f3

    const/4 v1, 0x2

    aget-object v2, p0, v1

    const-string v4, "hibixby_"

    invoke-virtual {v2, v4}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_f3

    const/4 v2, 0x1

    aget-object v4, p0, v2

    invoke-virtual {v4}, Ljava/lang/String;->length()I

    move-result v4

    const/4 v5, 0x4

    if-eq v4, v5, :cond_22

    goto/16 :goto_f3

    .line 90
    :cond_22
    aget-object v4, p0, v2

    const/4 v5, 0x0

    invoke-virtual {v4, v5, v1}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v4

    sget-object v5, Ljava/util/Locale;->US:Ljava/util/Locale;

    invoke-virtual {v4, v5}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v4

    aget-object p0, p0, v2

    .line 91
    invoke-virtual {p0, v1}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object p0

    sget-object v1, Ljava/util/Locale;->US:Ljava/util/Locale;

    invoke-virtual {p0, v1}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object p0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "_"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    .line 92
    const-string v1, "persist.sys.k4.wakeup_dsp_bits"

    const-string v2, "32bit"

    invoke-static {v1, v2}, Landroid/os/SystemProperties;->get(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 93
    new-instance v2, Ljava/io/File;

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "/system/etc/k4wakeup/"

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v6, "/hibixby_dsp_net_"

    invoke-virtual {v4, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v6, ".bin"

    invoke-virtual {v4, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-direct {v2, v4}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 94
    new-instance v4, Ljava/io/File;

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v7, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "/hibixby_dsp_grammar_"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-direct {v4, p0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 95
    invoke-virtual {v2}, Ljava/io/File;->isFile()Z

    move-result p0

    if-eqz p0, :cond_f2

    invoke-virtual {v4}, Ljava/io/File;->isFile()Z

    move-result p0

    if-nez p0, :cond_c3

    goto :goto_f2

    .line 96
    :cond_c3
    invoke-static {v2}, Lcom/k4/soundtrigger/K4WakeupGuard;->readFile(Ljava/io/File;)[B

    move-result-object p0

    invoke-static {v4}, Lcom/k4/soundtrigger/K4WakeupGuard;->readFile(Ljava/io/File;)[B

    move-result-object v0

    .line 97
    array-length v1, p0

    add-int/lit8 v1, v1, 0x8

    array-length v2, v0

    add-int/2addr v1, v2

    invoke-static {v1}, Ljava/nio/ByteBuffer;->allocate(I)Ljava/nio/ByteBuffer;

    move-result-object v1

    invoke-static {}, Ljava/nio/ByteOrder;->nativeOrder()Ljava/nio/ByteOrder;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/nio/ByteBuffer;->order(Ljava/nio/ByteOrder;)Ljava/nio/ByteBuffer;

    move-result-object v1

    .line 98
    array-length v2, p0

    invoke-virtual {v1, v2}, Ljava/nio/ByteBuffer;->putInt(I)Ljava/nio/ByteBuffer;

    move-result-object v2

    invoke-virtual {v2, p0}, Ljava/nio/ByteBuffer;->put([B)Ljava/nio/ByteBuffer;

    move-result-object p0

    array-length v2, v0

    invoke-virtual {p0, v2}, Ljava/nio/ByteBuffer;->putInt(I)Ljava/nio/ByteBuffer;

    move-result-object p0

    invoke-virtual {p0, v0}, Ljava/nio/ByteBuffer;->put([B)Ljava/nio/ByteBuffer;

    .line 99
    invoke-virtual {v1}, Ljava/nio/ByteBuffer;->array()[B

    move-result-object p0

    return-object p0

    .line 95
    :cond_f2
    :goto_f2
    return-object v3

    .line 89
    :cond_f3
    :goto_f3
    return-object v3
.end method

.method private static appApks()Ljava/util/List;
    .registers 11
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Ljava/io/File;",
            ">;"
        }
    .end annotation

    .line 132
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    .line 133
    new-instance v1, Ljava/io/File;

    const-string v2, "/data/app"

    invoke-direct {v1, v2}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1}, Ljava/io/File;->listFiles()[Ljava/io/File;

    move-result-object v1

    .line 134
    if-eqz v1, :cond_42

    .line 135
    array-length v2, v1

    const/4 v3, 0x0

    move v4, v3

    :goto_15
    if-ge v4, v2, :cond_42

    aget-object v5, v1, v4

    .line 136
    invoke-virtual {v5}, Ljava/io/File;->listFiles()[Ljava/io/File;

    move-result-object v5

    .line 137
    if-nez v5, :cond_20

    goto :goto_3f

    .line 138
    :cond_20
    array-length v6, v5

    move v7, v3

    :goto_22
    if-ge v7, v6, :cond_3f

    aget-object v8, v5, v7

    .line 139
    invoke-virtual {v8}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object v9

    const-string v10, "com.samsung.android.bixby.wakeup-"

    invoke-virtual {v9, v10}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v9

    if-eqz v9, :cond_3c

    new-instance v9, Ljava/io/File;

    const-string v10, "base.apk"

    invoke-direct {v9, v8, v10}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-virtual {v0, v9}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 138
    :cond_3c
    add-int/lit8 v7, v7, 0x1

    goto :goto_22

    .line 135
    :cond_3f
    :goto_3f
    add-int/lit8 v4, v4, 0x1

    goto :goto_15

    .line 143
    :cond_42
    new-instance v1, Ljava/io/File;

    const-string v2, "/system/app/BixbyWakeup/BixbyWakeup.apk"

    invoke-direct {v1, v2}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 144
    return-object v0
.end method

.method public static check(Landroid/media/soundtrigger/PhraseSoundModel;)V
    .registers 8

    .line 43
    if-eqz p0, :cond_d8

    iget-object v0, p0, Landroid/media/soundtrigger/PhraseSoundModel;->common:Landroid/media/soundtrigger/SoundModel;

    if-nez v0, :cond_8

    goto/16 :goto_d8

    .line 44
    :cond_8
    iget-object p0, p0, Landroid/media/soundtrigger/PhraseSoundModel;->common:Landroid/media/soundtrigger/SoundModel;

    .line 45
    const-string v0, "a1757552-af10-11e7-985a-a3754010baa2"

    iget-object v1, p0, Landroid/media/soundtrigger/SoundModel;->vendorUuid:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_15

    return-void

    .line 46
    :cond_15
    const-string v0, "persist.sys.k4.samsung_wakeup"

    const/4 v1, 0x0

    invoke-static {v0, v1}, Landroid/os/SystemProperties;->getInt(Ljava/lang/String;I)I

    move-result v0

    .line 47
    const/4 v1, 0x1

    const-string v2, "K4WakeupGuard"

    if-ne v0, v1, :cond_27

    .line 48
    const-string p0, "passing a Samsung voice wake-up model through unchanged (persist.sys.k4.samsung_wakeup=1)"

    invoke-static {v2, p0}, Landroid/util/Slog;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 49
    return-void

    .line 51
    :cond_27
    const/4 v1, 0x2

    if-eq v0, v1, :cond_cb

    .line 55
    nop

    .line 56
    nop

    .line 58
    const/4 v0, 0x0

    :try_start_2d
    iget-object v3, p0, Landroid/media/soundtrigger/SoundModel;->data:Landroid/os/ParcelFileDescriptor;

    invoke-virtual {v3}, Landroid/os/ParcelFileDescriptor;->dup()Landroid/os/ParcelFileDescriptor;

    move-result-object v3

    iget v4, p0, Landroid/media/soundtrigger/SoundModel;->dataSize:I

    invoke-static {v3, v4}, Landroid/hardware/soundtrigger/ConversionUtil;->sharedMemoryToByteArray(Landroid/os/ParcelFileDescriptor;I)[B

    move-result-object v3

    .line 59
    invoke-static {v3}, Lcom/k4/soundtrigger/K4WakeupGuard;->sha256([B)Ljava/lang/String;

    move-result-object v4
    :try_end_3d
    .catchall {:try_start_2d .. :try_end_3d} :catchall_4f

    .line 60
    :try_start_3d
    array-length v3, v3

    invoke-static {v4, v3}, Lcom/k4/soundtrigger/K4WakeupGuard;->modelName(Ljava/lang/String;I)Ljava/lang/String;

    move-result-object v3
    :try_end_42
    .catchall {:try_start_3d .. :try_end_42} :catchall_4c

    .line 61
    if-eqz v3, :cond_4b

    :try_start_44
    invoke-static {v3}, Lcom/k4/soundtrigger/K4WakeupGuard;->a52sModel(Ljava/lang/String;)[B

    move-result-object v0
    :try_end_48
    .catchall {:try_start_44 .. :try_end_48} :catchall_49

    goto :goto_4b

    .line 62
    :catchall_49
    move-exception v5

    goto :goto_52

    .line 64
    :cond_4b
    :goto_4b
    goto :goto_57

    .line 62
    :catchall_4c
    move-exception v5

    move-object v3, v0

    goto :goto_52

    :catchall_4f
    move-exception v5

    move-object v3, v0

    move-object v4, v3

    .line 63
    :goto_52
    const-string v6, "cannot read the Samsung voice wake-up model"

    invoke-static {v2, v6, v5}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 65
    :goto_57
    if-nez v0, :cond_8d

    .line 66
    if-eqz v3, :cond_5c

    goto :goto_5d

    :cond_5c
    move-object v3, v4

    :goto_5d
    iget p0, p0, Landroid/media/soundtrigger/SoundModel;->dataSize:I

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "refusing Samsung voice wake-up model "

    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v3, " ("

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string v0, " bytes): no A52s counterpart, the ADSP firmware may crash on it"

    invoke-virtual {p0, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v2, p0}, Landroid/util/Slog;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 68
    new-instance p0, Lcom/android/server/soundtrigger_middleware/RecoverableException;

    const-string v0, "This Samsung voice wake-up model is not supported on this device"

    invoke-direct {p0, v1, v0}, Lcom/android/server/soundtrigger_middleware/RecoverableException;-><init>(ILjava/lang/String;)V

    throw p0

    .line 71
    :cond_8d
    iget-object v1, p0, Landroid/media/soundtrigger/SoundModel;->data:Landroid/os/ParcelFileDescriptor;

    .line 72
    const-string v4, "K4WakeupModel"

    invoke-static {v0, v4}, Landroid/hardware/soundtrigger/ConversionUtil;->byteArrayToSharedMemory([BLjava/lang/String;)Landroid/os/ParcelFileDescriptor;

    move-result-object v4

    iput-object v4, p0, Landroid/media/soundtrigger/SoundModel;->data:Landroid/os/ParcelFileDescriptor;

    .line 73
    array-length v4, v0

    iput v4, p0, Landroid/media/soundtrigger/SoundModel;->dataSize:I

    .line 75
    if-eqz v1, :cond_a2

    :try_start_9c
    invoke-virtual {v1}, Landroid/os/ParcelFileDescriptor;->close()V
    :try_end_9f
    .catchall {:try_start_9c .. :try_end_9f} :catchall_a0

    goto :goto_a2

    .line 76
    :catchall_a0
    move-exception p0

    goto :goto_a3

    .line 77
    :cond_a2
    :goto_a2
    nop

    .line 78
    :goto_a3
    array-length p0, v0

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "Samsung voice wake-up model "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " -> A52s model ("

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string v0, " bytes)"

    invoke-virtual {p0, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v2, p0}, Landroid/util/Slog;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 79
    return-void

    .line 52
    :cond_cb
    const-string p0, "refusing every Samsung voice wake-up model (persist.sys.k4.samsung_wakeup=2)"

    invoke-static {v2, p0}, Landroid/util/Slog;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 53
    new-instance p0, Lcom/android/server/soundtrigger_middleware/RecoverableException;

    const-string v0, "Samsung voice wake-up is turned off"

    invoke-direct {p0, v1, v0}, Lcom/android/server/soundtrigger_middleware/RecoverableException;-><init>(ILjava/lang/String;)V

    throw p0

    .line 43
    :cond_d8
    :goto_d8
    return-void
.end method

.method private static declared-synchronized modelName(Ljava/lang/String;I)Ljava/lang/String;
    .registers 15
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    const-class v0, Lcom/k4/soundtrigger/K4WakeupGuard;

    monitor-enter v0

    .line 104
    :try_start_3
    sget-object v1, Lcom/k4/soundtrigger/K4WakeupGuard;->sNames:Ljava/util/HashMap;

    invoke-virtual {v1, p0}, Ljava/util/HashMap;->containsKey(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_15

    sget-object p1, Lcom/k4/soundtrigger/K4WakeupGuard;->sNames:Ljava/util/HashMap;

    invoke-virtual {p1, p0}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/String;
    :try_end_13
    .catchall {:try_start_3 .. :try_end_13} :catchall_da

    monitor-exit v0

    return-object p0

    .line 105
    :cond_15
    nop

    .line 106
    nop

    .line 107
    :try_start_17
    invoke-static {}, Lcom/k4/soundtrigger/K4WakeupGuard;->appApks()Ljava/util/List;

    move-result-object v1

    invoke-interface {v1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    const/4 v2, 0x0

    const/4 v3, 0x1

    :goto_21
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v4

    if-eqz v4, :cond_cf

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/io/File;
    :try_end_2d
    .catchall {:try_start_17 .. :try_end_2d} :catchall_da

    .line 108
    :try_start_2d
    new-instance v5, Ljava/util/zip/ZipFile;

    invoke-direct {v5, v4}, Ljava/util/zip/ZipFile;-><init>(Ljava/io/File;)V
    :try_end_32
    .catchall {:try_start_2d .. :try_end_32} :catchall_9e

    .line 109
    :try_start_32
    invoke-virtual {v5}, Ljava/util/zip/ZipFile;->entries()Ljava/util/Enumeration;

    move-result-object v6

    .line 110
    :cond_36
    :goto_36
    if-nez v2, :cond_90

    invoke-interface {v6}, Ljava/util/Enumeration;->hasMoreElements()Z

    move-result v7

    if-eqz v7, :cond_90

    .line 111
    invoke-interface {v6}, Ljava/util/Enumeration;->nextElement()Ljava/lang/Object;

    move-result-object v7

    check-cast v7, Ljava/util/zip/ZipEntry;

    .line 112
    invoke-virtual {v7}, Ljava/util/zip/ZipEntry;->getName()Ljava/lang/String;

    move-result-object v8

    .line 113
    const-string v9, "assets/kwdModel/"

    invoke-virtual {v8, v9}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v9

    if-eqz v9, :cond_36

    const-string v9, ".bin"

    invoke-virtual {v8, v9}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v9

    if-eqz v9, :cond_36

    invoke-virtual {v7}, Ljava/util/zip/ZipEntry;->getSize()J

    move-result-wide v9

    int-to-long v11, p1

    cmp-long v9, v9, v11

    if-eqz v9, :cond_62

    goto :goto_36

    .line 114
    :cond_62
    invoke-virtual {v5, v7}, Ljava/util/zip/ZipFile;->getInputStream(Ljava/util/zip/ZipEntry;)Ljava/io/InputStream;

    move-result-object v7
    :try_end_66
    .catchall {:try_start_32 .. :try_end_66} :catchall_94

    .line 115
    :try_start_66
    invoke-virtual {v7}, Ljava/io/InputStream;->readAllBytes()[B

    move-result-object v9

    invoke-static {v9}, Lcom/k4/soundtrigger/K4WakeupGuard;->sha256([B)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {p0, v9}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v9

    if-eqz v9, :cond_7e

    const-string v9, "assets/kwdModel/"

    invoke-virtual {v9}, Ljava/lang/String;->length()I

    move-result v9

    invoke-virtual {v8, v9}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v2
    :try_end_7e
    .catchall {:try_start_66 .. :try_end_7e} :catchall_84

    .line 116
    :cond_7e
    if-eqz v7, :cond_83

    :try_start_80
    invoke-virtual {v7}, Ljava/io/InputStream;->close()V
    :try_end_83
    .catchall {:try_start_80 .. :try_end_83} :catchall_94

    .line 117
    :cond_83
    goto :goto_36

    .line 114
    :catchall_84
    move-exception v3

    if-eqz v7, :cond_8f

    :try_start_87
    invoke-virtual {v7}, Ljava/io/InputStream;->close()V
    :try_end_8a
    .catchall {:try_start_87 .. :try_end_8a} :catchall_8b

    goto :goto_8f

    :catchall_8b
    move-exception v6

    :try_start_8c
    invoke-virtual {v3, v6}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_8f
    :goto_8f
    throw v3
    :try_end_90
    .catchall {:try_start_8c .. :try_end_90} :catchall_94

    .line 118
    :cond_90
    :try_start_90
    invoke-virtual {v5}, Ljava/util/zip/ZipFile;->close()V
    :try_end_93
    .catchall {:try_start_90 .. :try_end_93} :catchall_9e

    .line 121
    goto :goto_ca

    .line 108
    :catchall_94
    move-exception v3

    :try_start_95
    invoke-virtual {v5}, Ljava/util/zip/ZipFile;->close()V
    :try_end_98
    .catchall {:try_start_95 .. :try_end_98} :catchall_99

    goto :goto_9d

    :catchall_99
    move-exception v5

    :try_start_9a
    invoke-virtual {v3, v5}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :goto_9d
    throw v3
    :try_end_9e
    .catchall {:try_start_9a .. :try_end_9e} :catchall_9e

    .line 118
    :catchall_9e
    move-exception v3

    .line 119
    :try_start_9f
    const-string v5, "K4WakeupGuard"

    invoke-static {v4}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v4

    invoke-static {v3}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v3

    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "cannot read "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v6, ": "

    invoke-virtual {v4, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v5, v3}, Landroid/util/Slog;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 120
    const/4 v3, 0x0

    .line 122
    :goto_ca
    if-eqz v2, :cond_cd

    goto :goto_cf

    .line 123
    :cond_cd
    goto/16 :goto_21

    .line 126
    :cond_cf
    :goto_cf
    if-nez v2, :cond_d3

    if-eqz v3, :cond_d8

    :cond_d3
    sget-object p1, Lcom/k4/soundtrigger/K4WakeupGuard;->sNames:Ljava/util/HashMap;

    invoke-virtual {p1, p0, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_d8
    .catchall {:try_start_9f .. :try_end_d8} :catchall_da

    .line 127
    :cond_d8
    monitor-exit v0

    return-object v2

    .line 103
    :catchall_da
    move-exception p0

    :try_start_db
    monitor-exit v0
    :try_end_dc
    .catchall {:try_start_db .. :try_end_dc} :catchall_da

    throw p0
.end method

.method private static readFile(Ljava/io/File;)[B
    .registers 6
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 148
    invoke-virtual {p0}, Ljava/io/File;->length()J

    move-result-wide v0

    long-to-int v0, v0

    new-array v1, v0, [B

    .line 149
    new-instance v2, Ljava/io/FileInputStream;

    invoke-direct {v2, p0}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    .line 150
    const/4 v3, 0x0

    .line 151
    :goto_d
    if-ge v3, v0, :cond_2d

    .line 152
    sub-int v4, v0, v3

    :try_start_11
    invoke-virtual {v2, v1, v3, v4}, Ljava/io/FileInputStream;->read([BII)I

    move-result v4

    .line 153
    if-ltz v4, :cond_19

    .line 154
    add-int/2addr v3, v4

    .line 155
    goto :goto_d

    .line 153
    :cond_19
    new-instance v0, Ljava/io/EOFException;

    invoke-virtual {p0}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object p0

    invoke-direct {v0, p0}, Ljava/io/EOFException;-><init>(Ljava/lang/String;)V

    throw v0
    :try_end_23
    .catchall {:try_start_11 .. :try_end_23} :catchall_23

    .line 149
    :catchall_23
    move-exception p0

    :try_start_24
    invoke-virtual {v2}, Ljava/io/FileInputStream;->close()V
    :try_end_27
    .catchall {:try_start_24 .. :try_end_27} :catchall_28

    goto :goto_2c

    :catchall_28
    move-exception v0

    invoke-virtual {p0, v0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :goto_2c
    throw p0

    .line 156
    :cond_2d
    invoke-virtual {v2}, Ljava/io/FileInputStream;->close()V

    .line 157
    return-object v1
.end method

.method private static sha256([B)Ljava/lang/String;
    .registers 7
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 161
    const-string v0, "SHA-256"

    invoke-static {v0}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

    move-result-object v0

    invoke-virtual {v0, p0}, Ljava/security/MessageDigest;->digest([B)[B

    move-result-object p0

    .line 162
    new-instance v0, Ljava/lang/StringBuilder;

    const/16 v1, 0x40

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(I)V

    .line 163
    array-length v1, p0

    const/4 v2, 0x0

    :goto_13
    if-ge v2, v1, :cond_31

    aget-byte v3, p0, v2

    shr-int/lit8 v4, v3, 0x4

    and-int/lit8 v4, v4, 0xf

    const/16 v5, 0x10

    invoke-static {v4, v5}, Ljava/lang/Character;->forDigit(II)C

    move-result v4

    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v4

    and-int/lit8 v3, v3, 0xf

    invoke-static {v3, v5}, Ljava/lang/Character;->forDigit(II)C

    move-result v3

    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    add-int/lit8 v2, v2, 0x1

    goto :goto_13

    .line 164
    :cond_31
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method
