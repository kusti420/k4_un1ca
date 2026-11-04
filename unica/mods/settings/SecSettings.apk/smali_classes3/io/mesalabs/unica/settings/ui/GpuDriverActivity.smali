.class public Lio/mesalabs/unica/settings/ui/GpuDriverActivity;
.super Landroid/app/Activity;
.source "GpuDriverActivity.java"


# static fields
.field static final ACTION_ADD:Ljava/lang/String; = "io.mesalabs.unica.action.GPU_DRIVER_ADD"

.field static final ACTION_REMOVE:Ljava/lang/String; = "io.mesalabs.unica.action.GPU_DRIVER_REMOVE"

.field private static final BASE:Ljava/lang/String; = "/data/k4gpu"

.field private static final REQUEST_PICK:I = 0x1


# instance fields
.field private mBusy:Z

.field private mDialog:Landroid/app/AlertDialog;

.field private mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;


# direct methods
.method public constructor <init>()V
    .registers 1

    .line 36
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V

    return-void
.end method

.method private builder()Landroid/app/AlertDialog$Builder;
    .registers 3

    .line 254
    invoke-virtual {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/res/Resources;->getConfiguration()Landroid/content/res/Configuration;

    move-result-object v0

    iget v0, v0, Landroid/content/res/Configuration;->uiMode:I

    and-int/lit8 v0, v0, 0x30

    const/16 v1, 0x20

    if-ne v0, v1, :cond_12

    const/4 v0, 0x1

    goto :goto_13

    :cond_12
    const/4 v0, 0x0

    .line 256
    :goto_13
    new-instance v1, Landroid/app/AlertDialog$Builder;

    if-eqz v0, :cond_1b

    const v0, 0x10302d1

    goto :goto_1e

    :cond_1b
    const v0, 0x10302d2

    .line 257
    :goto_1e
    invoke-direct {v1, p0, v0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;I)V

    return-object v1
.end method

.method private static chmod(Ljava/io/File;I)V
    .registers 2

    .line 294
    :try_start_0
    invoke-virtual {p0}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object p0

    invoke-static {p0, p1}, Landroid/system/Os;->chmod(Ljava/lang/String;I)V
    :try_end_7
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_7} :catch_7

    :catch_7
    return-void
.end method

.method private confirmRemove(Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;)V
    .registers 10

    .line 218
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {v0}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->root()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    const/4 v1, 0x0

    if-eqz v0, :cond_16

    const-string v0, "k4_gpu_driver_root_unknown"

    new-array v2, v1, [Ljava/lang/Object;

    invoke-direct {p0, v0, v2}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    goto :goto_1c

    :cond_16
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {v0}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->root()Ljava/lang/String;

    move-result-object v0

    .line 219
    :goto_1c
    invoke-direct {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->builder()Landroid/app/AlertDialog$Builder;

    move-result-object v2

    const-string v3, "k4_gpu_driver_remove_title"

    new-array v4, v1, [Ljava/lang/Object;

    invoke-direct {p0, v3, v4}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    .line 220
    iget-boolean v3, p1, Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;->external:Z

    const/4 v4, 0x0

    if-eqz v3, :cond_55

    .line 221
    iget-object v3, p1, Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;->label:Ljava/lang/String;

    iget-object v5, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    iget-object p1, p1, Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;->id:Ljava/lang/String;

    invoke-virtual {v5, p1}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->moduleOf(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    filled-new-array {v3, v0, p1}, [Ljava/lang/Object;

    move-result-object p1

    const-string v0, "k4_gpu_driver_remove_external_msg"

    invoke-direct {p0, v0, p1}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v2, p1}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object p1

    const-string v0, "k4_gpu_driver_failed_button"

    new-array v1, v1, [Ljava/lang/Object;

    .line 222
    invoke-direct {p0, v0, v1}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p1, v0, v4}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    goto :goto_c1

    .line 223
    :cond_55
    iget v3, p1, Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;->kind:I

    const/4 v5, 0x1

    const-string v6, "k4_gpu_driver_cancel"

    if-ne v3, v5, :cond_8f

    .line 224
    iget-object v3, p1, Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;->label:Ljava/lang/String;

    iget-object v5, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    iget-object v7, p1, Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;->id:Ljava/lang/String;

    invoke-virtual {v5, v7}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->moduleOf(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    filled-new-array {v3, v0, v5}, [Ljava/lang/Object;

    move-result-object v0

    const-string v3, "k4_gpu_driver_remove_module_msg"

    invoke-direct {p0, v3, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v2, v0}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    const-string v3, "k4_gpu_driver_remove_hide"

    new-array v5, v1, [Ljava/lang/Object;

    .line 225
    invoke-direct {p0, v3, v5}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v3

    new-instance v5, Lio/mesalabs/unica/settings/ui/GpuDriverActivity$$3;

    invoke-direct {v5, p0, p1}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity$$3;-><init>(Lio/mesalabs/unica/settings/ui/GpuDriverActivity;Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;)V

    invoke-virtual {v0, v3, v5}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object p1

    new-array v0, v1, [Ljava/lang/Object;

    .line 226
    invoke-direct {p0, v6, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p1, v0, v4}, Landroid/app/AlertDialog$Builder;->setNegativeButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    goto :goto_c1

    .line 228
    :cond_8f
    iget v0, p1, Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;->kind:I

    const/4 v3, 0x3

    if-ne v0, v3, :cond_97

    const-string v0, "k4_gpu_driver_remove_staged_msg"

    goto :goto_99

    .line 229
    :cond_97
    const-string v0, "k4_gpu_driver_remove_added_msg"

    :goto_99
    iget-object v3, p1, Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;->label:Ljava/lang/String;

    filled-new-array {v3}, [Ljava/lang/Object;

    move-result-object v3

    .line 228
    invoke-direct {p0, v0, v3}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v2, v0}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    const-string v3, "k4_gpu_driver_remove_delete"

    new-array v5, v1, [Ljava/lang/Object;

    .line 230
    invoke-direct {p0, v3, v5}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v3

    new-instance v5, Lio/mesalabs/unica/settings/ui/GpuDriverActivity$$4;

    invoke-direct {v5, p0, p1}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity$$4;-><init>(Lio/mesalabs/unica/settings/ui/GpuDriverActivity;Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;)V

    invoke-virtual {v0, v3, v5}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object p1

    new-array v0, v1, [Ljava/lang/Object;

    .line 231
    invoke-direct {p0, v6, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p1, v0, v4}, Landroid/app/AlertDialog$Builder;->setNegativeButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    .line 233
    :goto_c1
    invoke-virtual {v2}, Landroid/app/AlertDialog$Builder;->create()Landroid/app/AlertDialog;

    move-result-object p1

    iput-object p1, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mDialog:Landroid/app/AlertDialog;

    .line 234
    new-instance v0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity$$5;

    invoke-direct {v0, p0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity$$5;-><init>(Lio/mesalabs/unica/settings/ui/GpuDriverActivity;)V

    invoke-virtual {p1, v0}, Landroid/app/AlertDialog;->setOnDismissListener(Landroid/content/DialogInterface$OnDismissListener;)V

    .line 235
    iget-object p0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mDialog:Landroid/app/AlertDialog;

    invoke-virtual {p0}, Landroid/app/AlertDialog;->show()V

    return-void
.end method

.method private static copy(Ljava/io/InputStream;Ljava/io/File;J)J
    .registers 11
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    if-eqz p0, :cond_4f

    .line 303
    :try_start_2
    new-instance v0, Ljava/io/FileOutputStream;

    invoke-direct {v0, p1}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
    :try_end_7
    .catchall {:try_start_2 .. :try_end_7} :catchall_24

    const/high16 v1, 0x10000

    .line 304
    :try_start_9
    new-array v1, v1, [B

    const-wide/16 v2, 0x0

    .line 306
    :goto_d
    invoke-virtual {p0, v1}, Ljava/io/InputStream;->read([B)I

    move-result v4
    :try_end_11
    .catchall {:try_start_9 .. :try_end_11} :catchall_2b

    if-lez v4, :cond_2d

    int-to-long v5, v4

    add-long/2addr v2, v5

    cmp-long v5, v2, p2

    if-lez v5, :cond_26

    .line 311
    :try_start_19
    invoke-virtual {v0}, Ljava/io/OutputStream;->close()V
    :try_end_1c
    .catchall {:try_start_19 .. :try_end_1c} :catchall_24

    const-wide/16 p1, -0x1

    if-eqz p0, :cond_23

    invoke-virtual {p0}, Ljava/io/InputStream;->close()V

    :cond_23
    return-wide p1

    :catchall_24
    move-exception p1

    goto :goto_44

    :cond_26
    const/4 v5, 0x0

    .line 309
    :try_start_27
    invoke-virtual {v0, v1, v5, v4}, Ljava/io/OutputStream;->write([BII)V
    :try_end_2a
    .catchall {:try_start_27 .. :try_end_2a} :catchall_2b

    goto :goto_d

    :catchall_2b
    move-exception p1

    goto :goto_3b

    .line 311
    :cond_2d
    :try_start_2d
    invoke-virtual {v0}, Ljava/io/OutputStream;->close()V
    :try_end_30
    .catchall {:try_start_2d .. :try_end_30} :catchall_24

    if-eqz p0, :cond_35

    invoke-virtual {p0}, Ljava/io/InputStream;->close()V

    :cond_35
    const/16 p0, 0x1b0

    .line 312
    invoke-static {p1, p0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->chmod(Ljava/io/File;I)V

    return-wide v2

    .line 303
    :goto_3b
    :try_start_3b
    invoke-virtual {v0}, Ljava/io/OutputStream;->close()V
    :try_end_3e
    .catchall {:try_start_3b .. :try_end_3e} :catchall_3f

    goto :goto_43

    :catchall_3f
    move-exception p2

    :try_start_40
    invoke-virtual {p1, p2}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :goto_43
    throw p1
    :try_end_44
    .catchall {:try_start_40 .. :try_end_44} :catchall_24

    :goto_44
    if-eqz p0, :cond_4e

    :try_start_46
    invoke-virtual {p0}, Ljava/io/InputStream;->close()V
    :try_end_49
    .catchall {:try_start_46 .. :try_end_49} :catchall_4a

    goto :goto_4e

    :catchall_4a
    move-exception p0

    invoke-virtual {p1, p0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_4e
    :goto_4e
    throw p1

    .line 301
    :cond_4f
    new-instance p0, Ljava/io/IOException;

    const-string p1, "no input"

    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method private displayName(Landroid/net/Uri;)Ljava/lang/String;
    .registers 11

    const/4 v1, 0x0

    const/4 v2, 0x0

    .line 270
    :try_start_2
    invoke-virtual {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v3

    const-string p0, "_display_name"

    filled-new-array {p0}, [Ljava/lang/String;

    move-result-object v5
    :try_end_c
    .catch Ljava/lang/RuntimeException; {:try_start_2 .. :try_end_c} :catch_35

    const/4 v7, 0x0

    const/4 v8, 0x0

    const/4 v6, 0x0

    move-object v4, p1

    :try_start_10
    invoke-virtual/range {v3 .. v8}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;

    move-result-object p0
    :try_end_14
    .catch Ljava/lang/RuntimeException; {:try_start_10 .. :try_end_14} :catch_36

    if-eqz p0, :cond_2f

    .line 271
    :try_start_16
    invoke-interface {p0}, Landroid/database/Cursor;->moveToFirst()Z

    move-result p1

    if-eqz p1, :cond_2f

    invoke-interface {p0, v1}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v2
    :try_end_20
    .catchall {:try_start_16 .. :try_end_20} :catchall_21

    goto :goto_2f

    :catchall_21
    move-exception v0

    move-object p1, v0

    if-eqz p0, :cond_2e

    .line 270
    :try_start_25
    invoke-interface {p0}, Landroid/database/Cursor;->close()V
    :try_end_28
    .catchall {:try_start_25 .. :try_end_28} :catchall_29

    goto :goto_2e

    :catchall_29
    move-exception v0

    move-object p0, v0

    :try_start_2b
    invoke-virtual {p1, p0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_2e
    :goto_2e
    throw p1

    :cond_2f
    :goto_2f
    if-eqz p0, :cond_36

    .line 272
    invoke-interface {p0}, Landroid/database/Cursor;->close()V
    :try_end_34
    .catch Ljava/lang/RuntimeException; {:try_start_2b .. :try_end_34} :catch_36

    goto :goto_36

    :catch_35
    move-object v4, p1

    :catch_36
    :cond_36
    :goto_36
    if-nez v2, :cond_3c

    .line 274
    invoke-virtual {v4}, Landroid/net/Uri;->getLastPathSegment()Ljava/lang/String;

    move-result-object v2

    :cond_3c
    if-nez v2, :cond_40

    .line 275
    const-string v2, "zip"

    .line 276
    :cond_40
    sget-object p0, Ljava/util/Locale;->ROOT:Ljava/util/Locale;

    invoke-virtual {v2, p0}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object p0

    const-string p1, ".zip"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p0

    if-eqz p0, :cond_58

    invoke-virtual {v2}, Ljava/lang/String;->length()I

    move-result p0

    add-int/lit8 p0, p0, -0x4

    invoke-virtual {v2, v1, p0}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v2

    .line 277
    :cond_58
    invoke-static {v2}, Lio/mesalabs/unica/settings/ui/GpuDriverPackage;->sanitize(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method private doRemove(Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;)V
    .registers 3

    .line 239
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    iget-object p1, p1, Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;->id:Ljava/lang/String;

    invoke-virtual {v0, p1}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->remove(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_19

    const-string p1, ""

    filled-new-array {p1}, [Ljava/lang/Object;

    move-result-object p1

    const-string v0, "k4_gpu_driver_err_io"

    invoke-direct {p0, v0, p1}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->toast(Ljava/lang/String;)V

    :cond_19
    return-void
.end method

.method private fail(Ljava/lang/String;Ljava/lang/String;)[Ljava/lang/String;
    .registers 5

    .line 174
    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "k4_gpu_driver_err_"

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    filled-new-array {p2}, [Ljava/lang/Object;

    move-result-object p2

    invoke-direct {p0, p1, p2}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    const/4 p1, 0x0

    filled-new-array {p1, p0}, [Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method private label(Ljava/lang/String;)Ljava/lang/String;
    .registers 3

    .line 250
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-static {p0, v0, p1}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController;->label(Landroid/content/Context;Lio/mesalabs/unica/settings/ui/GpuDriverModel;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method private lockedMessage()Ljava/lang/String;
    .registers 5

    .line 243
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {v0}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->external()Ljava/lang/String;

    move-result-object v0

    .line 244
    iget-object v1, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {v1, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->entry(Ljava/lang/String;)Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;

    move-result-object v1

    .line 245
    iget-object v2, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {v2}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->root()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/String;->isEmpty()Z

    move-result v2

    if-eqz v2, :cond_22

    const/4 v2, 0x0

    new-array v2, v2, [Ljava/lang/Object;

    const-string v3, "k4_gpu_driver_root_unknown"

    invoke-direct {p0, v3, v2}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v2

    goto :goto_28

    :cond_22
    iget-object v2, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {v2}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->root()Ljava/lang/String;

    move-result-object v2

    :goto_28
    if-eqz v1, :cond_2d

    .line 246
    iget-object v1, v1, Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;->label:Ljava/lang/String;

    goto :goto_2e

    :cond_2d
    move-object v1, v0

    :goto_2e
    iget-object v3, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {v3, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->moduleOf(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    filled-new-array {v1, v2, v0}, [Ljava/lang/Object;

    move-result-object v0

    const-string v1, "k4_gpu_driver_locked"

    invoke-direct {p0, v1, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method private static mkdir(Ljava/io/File;)Z
    .registers 4

    const/4 v0, 0x0

    if-nez p0, :cond_4

    return v0

    .line 286
    :cond_4
    invoke-virtual {p0}, Ljava/io/File;->isDirectory()Z

    move-result v1

    const/4 v2, 0x1

    if-eqz v1, :cond_c

    return v2

    .line 287
    :cond_c
    invoke-virtual {p0}, Ljava/io/File;->getParentFile()Ljava/io/File;

    move-result-object v1

    invoke-static {v1}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mkdir(Ljava/io/File;)Z

    move-result v1

    if-eqz v1, :cond_29

    invoke-virtual {p0}, Ljava/io/File;->mkdir()Z

    move-result v1

    if-nez v1, :cond_23

    invoke-virtual {p0}, Ljava/io/File;->isDirectory()Z

    move-result v1

    if-nez v1, :cond_23

    goto :goto_29

    :cond_23
    const/16 v0, 0x1f8

    .line 288
    invoke-static {p0, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->chmod(Ljava/io/File;I)V

    return v2

    :cond_29
    :goto_29
    return v0
.end method

.method private static readAll(Ljava/io/InputStream;I)[B
    .registers 6
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 317
    new-instance v0, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    const/16 v1, 0x1000

    .line 318
    new-array v1, v1, [B

    .line 320
    :goto_9
    invoke-virtual {p0, v1}, Ljava/io/InputStream;->read([B)I

    move-result v2

    if-lez v2, :cond_1a

    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->size()I

    move-result v3

    if-ge v3, p1, :cond_1a

    const/4 v3, 0x0

    invoke-virtual {v0, v1, v3, v2}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    goto :goto_9

    .line 321
    :cond_1a
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object p0

    return-object p0
.end method

.method private showRemoveList()V
    .registers 7

    .line 199
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    .line 200
    iget-object v1, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {v1}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->entries()Ljava/util/List;

    move-result-object v1

    invoke-interface {v1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :cond_f
    :goto_f
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_23

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;

    iget v3, v2, Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;->kind:I

    if-eqz v3, :cond_f

    invoke-interface {v0, v2}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_f

    .line 201
    :cond_23
    invoke-interface {v0}, Ljava/util/List;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_2d

    .line 202
    invoke-virtual {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->finish()V

    return-void

    .line 205
    :cond_2d
    invoke-interface {v0}, Ljava/util/List;->size()I

    move-result v1

    new-array v2, v1, [Ljava/lang/CharSequence;

    const/4 v3, 0x0

    move v4, v3

    :goto_35
    if-ge v4, v1, :cond_44

    .line 206
    invoke-interface {v0, v4}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;

    iget-object v5, v5, Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;->label:Ljava/lang/String;

    aput-object v5, v2, v4

    add-int/lit8 v4, v4, 0x1

    goto :goto_35

    .line 207
    :cond_44
    invoke-direct {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->builder()Landroid/app/AlertDialog$Builder;

    move-result-object v1

    const-string v4, "k4_gpu_driver_remove_title"

    new-array v5, v3, [Ljava/lang/Object;

    invoke-direct {p0, v4, v5}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v1, v4}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    new-instance v4, Lio/mesalabs/unica/settings/ui/GpuDriverActivity$$6;

    invoke-direct {v4, p0, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity$$6;-><init>(Lio/mesalabs/unica/settings/ui/GpuDriverActivity;Ljava/util/List;)V

    .line 208
    invoke-virtual {v1, v2, v4}, Landroid/app/AlertDialog$Builder;->setItems([Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    const-string v1, "k4_gpu_driver_cancel"

    new-array v2, v3, [Ljava/lang/Object;

    .line 212
    invoke-direct {p0, v1, v2}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v1

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setNegativeButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    invoke-virtual {v0}, Landroid/app/AlertDialog$Builder;->create()Landroid/app/AlertDialog;

    move-result-object v0

    iput-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mDialog:Landroid/app/AlertDialog;

    .line 213
    new-instance v1, Lio/mesalabs/unica/settings/ui/GpuDriverActivity$$7;

    invoke-direct {v1, p0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity$$7;-><init>(Lio/mesalabs/unica/settings/ui/GpuDriverActivity;)V

    invoke-virtual {v0, v1}, Landroid/app/AlertDialog;->setOnDismissListener(Landroid/content/DialogInterface$OnDismissListener;)V

    .line 214
    iget-object p0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mDialog:Landroid/app/AlertDialog;

    invoke-virtual {p0}, Landroid/app/AlertDialog;->show()V

    return-void
.end method

.method private showResult([Ljava/lang/String;)V
    .registers 8

    const/4 v0, 0x0

    .line 178
    iput-boolean v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mBusy:Z

    .line 179
    iget-object v1, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mDialog:Landroid/app/AlertDialog;

    if-eqz v1, :cond_a

    invoke-virtual {v1}, Landroid/app/AlertDialog;->dismiss()V

    .line 180
    :cond_a
    invoke-virtual {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->isFinishing()Z

    move-result v1

    if-nez v1, :cond_aa

    invoke-virtual {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->isDestroyed()Z

    move-result v1

    if-eqz v1, :cond_18

    goto/16 :goto_aa

    .line 181
    :cond_18
    iget-object v1, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {v1}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->reload()V

    .line 182
    aget-object v1, p1, v0

    const/4 v2, 0x0

    const/4 v3, 0x1

    if-nez v1, :cond_4c

    .line 183
    invoke-direct {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->builder()Landroid/app/AlertDialog$Builder;

    move-result-object v1

    const-string v4, "k4_gpu_driver_add_failed_title"

    new-array v5, v0, [Ljava/lang/Object;

    invoke-direct {p0, v4, v5}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v1, v4}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    aget-object p1, p1, v3

    invoke-virtual {v1, p1}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object p1

    const-string v1, "k4_gpu_driver_failed_button"

    new-array v0, v0, [Ljava/lang/Object;

    .line 184
    invoke-direct {p0, v1, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p1, v0, v2}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object p1

    invoke-virtual {p1}, Landroid/app/AlertDialog$Builder;->create()Landroid/app/AlertDialog;

    move-result-object p1

    iput-object p1, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mDialog:Landroid/app/AlertDialog;

    goto :goto_9b

    .line 187
    :cond_4c
    invoke-direct {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->builder()Landroid/app/AlertDialog$Builder;

    move-result-object v4

    aget-object p1, p1, v3

    filled-new-array {p1}, [Ljava/lang/Object;

    move-result-object p1

    const-string v3, "k4_gpu_driver_add_done_title"

    invoke-direct {p0, v3, p1}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v4, p1}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object p1

    iget-object v3, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    .line 188
    invoke-virtual {v3}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->stockDriver()Ljava/lang/String;

    move-result-object v3

    invoke-direct {p0, v3}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->label(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    filled-new-array {v3}, [Ljava/lang/Object;

    move-result-object v3

    const-string v4, "k4_gpu_driver_add_done_msg"

    invoke-direct {p0, v4, v3}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {p1, v3}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object p1

    const-string v3, "k4_gpu_driver_add_use"

    new-array v4, v0, [Ljava/lang/Object;

    .line 189
    invoke-direct {p0, v3, v4}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v3

    new-instance v4, Lio/mesalabs/unica/settings/ui/GpuDriverActivity$$1;

    invoke-direct {v4, p0, v1}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity$$1;-><init>(Lio/mesalabs/unica/settings/ui/GpuDriverActivity;Ljava/lang/String;)V

    invoke-virtual {p1, v3, v4}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object p1

    const-string v1, "k4_gpu_driver_add_later"

    new-array v0, v0, [Ljava/lang/Object;

    .line 192
    invoke-direct {p0, v1, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p1, v0, v2}, Landroid/app/AlertDialog$Builder;->setNegativeButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object p1

    invoke-virtual {p1}, Landroid/app/AlertDialog$Builder;->create()Landroid/app/AlertDialog;

    move-result-object p1

    iput-object p1, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mDialog:Landroid/app/AlertDialog;

    .line 194
    :goto_9b
    iget-object p1, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mDialog:Landroid/app/AlertDialog;

    new-instance v0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity$$2;

    invoke-direct {v0, p0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity$$2;-><init>(Lio/mesalabs/unica/settings/ui/GpuDriverActivity;)V

    invoke-virtual {p1, v0}, Landroid/app/AlertDialog;->setOnDismissListener(Landroid/content/DialogInterface$OnDismissListener;)V

    .line 195
    iget-object p0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mDialog:Landroid/app/AlertDialog;

    invoke-virtual {p0}, Landroid/app/AlertDialog;->show()V

    :cond_aa
    :goto_aa
    return-void
.end method

.method private stage(Landroid/net/Uri;)[Ljava/lang/String;
    .registers 22

    move-object/from16 v1, p0

    .line 100
    const-string v2, "io"

    const-string v3, ""

    iget-object v0, v1, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {v0}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->incoming()Ljava/io/File;

    move-result-object v0

    .line 101
    invoke-virtual {v0}, Ljava/io/File;->list()[Ljava/lang/String;

    move-result-object v4

    .line 102
    const-string v5, ".tmp-"

    if-eqz v4, :cond_2b

    array-length v6, v4

    const/4 v7, 0x0

    :goto_16
    if-ge v7, v6, :cond_2b

    aget-object v8, v4, v7

    invoke-virtual {v8, v5}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v9

    if-eqz v9, :cond_28

    new-instance v9, Ljava/io/File;

    invoke-direct {v9, v0, v8}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-static {v9}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->deleteTree(Ljava/io/File;)Z

    :cond_28
    add-int/lit8 v7, v7, 0x1

    goto :goto_16

    .line 103
    :cond_2b
    new-instance v4, Ljava/io/File;

    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v6

    const/16 v8, 0x24

    invoke-static {v6, v7, v8}, Ljava/lang/Long;->toString(JI)Ljava/lang/String;

    move-result-object v6

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7, v5}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v7, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-direct {v4, v0, v5}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 105
    :try_start_46
    invoke-static {v4}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mkdir(Ljava/io/File;)Z

    move-result v5

    if-nez v5, :cond_54

    invoke-direct {v1, v2, v3}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->fail(Ljava/lang/String;Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0
    :try_end_50
    .catch Ljava/io/IOException; {:try_start_46 .. :try_end_50} :catch_260
    .catch Ljava/lang/RuntimeException; {:try_start_46 .. :try_end_50} :catch_260
    .catchall {:try_start_46 .. :try_end_50} :catchall_25e

    .line 169
    invoke-static {v4}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->deleteTree(Ljava/io/File;)Z

    return-object v0

    .line 106
    :cond_54
    :try_start_54
    new-instance v5, Ljava/io/File;

    const-string v6, "src.zip"

    invoke-direct {v5, v4, v6}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 107
    invoke-virtual {v1}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v6

    move-object/from16 v7, p1

    invoke-virtual {v6, v7}, Landroid/content/ContentResolver;->openInputStream(Landroid/net/Uri;)Ljava/io/InputStream;

    move-result-object v6

    const-wide/32 v9, 0x25800000

    invoke-static {v6, v5, v9, v10}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->copy(Ljava/io/InputStream;Ljava/io/File;J)J

    move-result-wide v9
    :try_end_6c
    .catch Ljava/io/IOException; {:try_start_54 .. :try_end_6c} :catch_260
    .catch Ljava/lang/RuntimeException; {:try_start_54 .. :try_end_6c} :catch_260
    .catchall {:try_start_54 .. :try_end_6c} :catchall_25e

    const-wide/16 v11, 0x0

    cmp-long v6, v9, v11

    .line 108
    const-string v13, "too_large"

    if-gez v6, :cond_82

    const-wide/16 v5, 0x258

    :try_start_76
    invoke-static {v5, v6}, Ljava/lang/String;->valueOf(J)Ljava/lang/String;

    move-result-object v0

    invoke-direct {v1, v13, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->fail(Ljava/lang/String;Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0
    :try_end_7e
    .catch Ljava/io/IOException; {:try_start_76 .. :try_end_7e} :catch_260
    .catch Ljava/lang/RuntimeException; {:try_start_76 .. :try_end_7e} :catch_260
    .catchall {:try_start_76 .. :try_end_7e} :catchall_25e

    .line 169
    invoke-static {v4}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->deleteTree(Ljava/io/File;)Z

    return-object v0

    .line 109
    :cond_82
    :try_start_82
    invoke-virtual {v0}, Ljava/io/File;->getUsableSpace()J

    move-result-wide v14

    const-wide/16 v16, 0x3

    mul-long v9, v9, v16

    cmp-long v6, v14, v9

    if-gez v6, :cond_98

    const-string v0, "space"

    invoke-direct {v1, v0, v3}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->fail(Ljava/lang/String;Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0
    :try_end_94
    .catch Ljava/io/IOException; {:try_start_82 .. :try_end_94} :catch_260
    .catch Ljava/lang/RuntimeException; {:try_start_82 .. :try_end_94} :catch_260
    .catchall {:try_start_82 .. :try_end_94} :catchall_25e

    .line 169
    invoke-static {v4}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->deleteTree(Ljava/io/File;)Z

    return-object v0

    .line 110
    :cond_98
    :try_start_98
    invoke-direct/range {p0 .. p1}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->displayName(Landroid/net/Uri;)Ljava/lang/String;

    move-result-object v6
    :try_end_9c
    .catch Ljava/io/IOException; {:try_start_98 .. :try_end_9c} :catch_260
    .catch Ljava/lang/RuntimeException; {:try_start_98 .. :try_end_9c} :catch_260
    .catchall {:try_start_98 .. :try_end_9c} :catchall_25e

    .line 113
    :try_start_9c
    new-instance v7, Ljava/util/zip/ZipFile;

    invoke-direct {v7, v5}, Ljava/util/zip/ZipFile;-><init>(Ljava/io/File;)V
    :try_end_a1
    .catch Ljava/io/IOException; {:try_start_9c .. :try_end_a1} :catch_254
    .catch Ljava/lang/RuntimeException; {:try_start_9c .. :try_end_a1} :catch_260
    .catchall {:try_start_9c .. :try_end_a1} :catchall_25e

    .line 118
    :try_start_a1
    new-instance v9, Ljava/util/ArrayList;

    invoke-direct {v9}, Ljava/util/ArrayList;-><init>()V

    .line 119
    invoke-virtual {v7}, Ljava/util/zip/ZipFile;->entries()Ljava/util/Enumeration;

    move-result-object v10

    .line 120
    :cond_aa
    :goto_aa
    invoke-interface {v10}, Ljava/util/Enumeration;->hasMoreElements()Z

    move-result v14

    if-eqz v14, :cond_c4

    .line 121
    invoke-interface {v10}, Ljava/util/Enumeration;->nextElement()Ljava/lang/Object;

    move-result-object v14

    check-cast v14, Ljava/util/zip/ZipEntry;

    .line 122
    invoke-virtual {v14}, Ljava/util/zip/ZipEntry;->isDirectory()Z

    move-result v15

    if-nez v15, :cond_aa

    invoke-virtual {v14}, Ljava/util/zip/ZipEntry;->getName()Ljava/lang/String;

    move-result-object v14

    invoke-interface {v9, v14}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_aa

    .line 124
    :cond_c4
    const-string v10, "module.prop"

    invoke-virtual {v7, v10}, Ljava/util/zip/ZipFile;->getEntry(Ljava/lang/String;)Ljava/util/zip/ZipEntry;

    move-result-object v10

    if-eqz v10, :cond_fb

    .line 125
    invoke-virtual {v10}, Ljava/util/zip/ZipEntry;->getSize()J

    move-result-wide v14

    const-wide/32 v16, 0x10000

    cmp-long v14, v14, v16

    if-gez v14, :cond_fb

    .line 126
    invoke-virtual {v7, v10}, Ljava/util/zip/ZipFile;->getInputStream(Ljava/util/zip/ZipEntry;)Ljava/io/InputStream;

    move-result-object v10
    :try_end_db
    .catchall {:try_start_a1 .. :try_end_db} :catchall_24f

    const/high16 v14, 0x10000

    .line 127
    :try_start_dd
    invoke-static {v10, v14}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->readAll(Ljava/io/InputStream;I)[B

    move-result-object v14

    invoke-static {v14}, Lio/mesalabs/unica/settings/ui/GpuDriverPackage;->moduleId([B)Ljava/lang/String;

    move-result-object v14
    :try_end_e5
    .catchall {:try_start_dd .. :try_end_e5} :catchall_ee

    if-eqz v14, :cond_e8

    move-object v6, v14

    :cond_e8
    if-eqz v10, :cond_fb

    .line 129
    :try_start_ea
    invoke-virtual {v10}, Ljava/io/InputStream;->close()V
    :try_end_ed
    .catchall {:try_start_ea .. :try_end_ed} :catchall_24f

    goto :goto_fb

    :catchall_ee
    move-exception v0

    move-object v5, v0

    if-eqz v10, :cond_fa

    .line 126
    :try_start_f2
    invoke-virtual {v10}, Ljava/io/InputStream;->close()V
    :try_end_f5
    .catchall {:try_start_f2 .. :try_end_f5} :catchall_f6

    goto :goto_fa

    :catchall_f6
    move-exception v0

    :try_start_f7
    invoke-virtual {v5, v0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_fa
    :goto_fa
    throw v5

    .line 131
    :cond_fb
    :goto_fb
    invoke-static {v9}, Lio/mesalabs/unica/settings/ui/GpuDriverPackage;->plan(Ljava/util/List;)Lio/mesalabs/unica/settings/ui/GpuDriverPackage$Plan;

    move-result-object v9

    .line 132
    iget-object v10, v9, Lio/mesalabs/unica/settings/ui/GpuDriverPackage$Plan;->error:Ljava/lang/String;

    if-eqz v10, :cond_112

    iget-object v0, v9, Lio/mesalabs/unica/settings/ui/GpuDriverPackage$Plan;->error:Ljava/lang/String;

    iget-object v5, v9, Lio/mesalabs/unica/settings/ui/GpuDriverPackage$Plan;->detail:Ljava/lang/String;

    invoke-direct {v1, v0, v5}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->fail(Ljava/lang/String;Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0
    :try_end_10b
    .catchall {:try_start_f7 .. :try_end_10b} :catchall_24f

    .line 142
    :try_start_10b
    invoke-virtual {v7}, Ljava/util/zip/ZipFile;->close()V
    :try_end_10e
    .catch Ljava/io/IOException; {:try_start_10b .. :try_end_10e} :catch_260
    .catch Ljava/lang/RuntimeException; {:try_start_10b .. :try_end_10e} :catch_260
    .catchall {:try_start_10b .. :try_end_10e} :catchall_25e

    .line 169
    invoke-static {v4}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->deleteTree(Ljava/io/File;)Z

    return-object v0

    .line 134
    :cond_112
    :try_start_112
    iget-object v9, v9, Lio/mesalabs/unica/settings/ui/GpuDriverPackage$Plan;->files:Ljava/util/Map;

    invoke-interface {v9}, Ljava/util/Map;->entrySet()Ljava/util/Set;

    move-result-object v9

    invoke-interface {v9}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v9

    move-wide v14, v11

    :goto_11d
    invoke-interface {v9}, Ljava/util/Iterator;->hasNext()Z

    move-result v10

    if-eqz v10, :cond_181

    invoke-interface {v9}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v10

    check-cast v10, Ljava/util/Map$Entry;

    move-wide/from16 v16, v11

    .line 135
    new-instance v11, Ljava/io/File;

    invoke-interface {v10}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v12

    check-cast v12, Ljava/lang/String;

    invoke-direct {v11, v4, v12}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 136
    invoke-virtual {v11}, Ljava/io/File;->getParentFile()Ljava/io/File;

    move-result-object v12

    invoke-static {v12}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mkdir(Ljava/io/File;)Z

    move-result v12

    if-nez v12, :cond_14b

    invoke-direct {v1, v2, v3}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->fail(Ljava/lang/String;Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0
    :try_end_144
    .catchall {:try_start_112 .. :try_end_144} :catchall_24f

    .line 142
    :try_start_144
    invoke-virtual {v7}, Ljava/util/zip/ZipFile;->close()V
    :try_end_147
    .catch Ljava/io/IOException; {:try_start_144 .. :try_end_147} :catch_260
    .catch Ljava/lang/RuntimeException; {:try_start_144 .. :try_end_147} :catch_260
    .catchall {:try_start_144 .. :try_end_147} :catchall_25e

    .line 169
    invoke-static {v4}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->deleteTree(Ljava/io/File;)Z

    return-object v0

    .line 137
    :cond_14b
    :try_start_14b
    invoke-interface {v10}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v10

    check-cast v10, Ljava/lang/String;

    invoke-virtual {v7, v10}, Ljava/util/zip/ZipFile;->getEntry(Ljava/lang/String;)Ljava/util/zip/ZipEntry;

    move-result-object v10

    invoke-virtual {v7, v10}, Ljava/util/zip/ZipFile;->getInputStream(Ljava/util/zip/ZipEntry;)Ljava/io/InputStream;

    move-result-object v10

    const-wide/32 v18, 0x12c00000

    move-object/from16 p1, v9

    sub-long v8, v18, v14

    invoke-static {v10, v11, v8, v9}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->copy(Ljava/io/InputStream;Ljava/io/File;J)J

    move-result-wide v8

    cmp-long v10, v8, v16

    if-gez v10, :cond_179

    const-wide/16 v5, 0x12c

    .line 138
    invoke-static {v5, v6}, Ljava/lang/String;->valueOf(J)Ljava/lang/String;

    move-result-object v0

    invoke-direct {v1, v13, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->fail(Ljava/lang/String;Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0
    :try_end_172
    .catchall {:try_start_14b .. :try_end_172} :catchall_24f

    .line 142
    :try_start_172
    invoke-virtual {v7}, Ljava/util/zip/ZipFile;->close()V
    :try_end_175
    .catch Ljava/io/IOException; {:try_start_172 .. :try_end_175} :catch_260
    .catch Ljava/lang/RuntimeException; {:try_start_172 .. :try_end_175} :catch_260
    .catchall {:try_start_172 .. :try_end_175} :catchall_25e

    .line 169
    invoke-static {v4}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->deleteTree(Ljava/io/File;)Z

    return-object v0

    :cond_179
    add-long/2addr v14, v8

    move-object/from16 v9, p1

    move-wide/from16 v11, v16

    const/16 v8, 0x24

    goto :goto_11d

    .line 142
    :cond_181
    :try_start_181
    invoke-virtual {v7}, Ljava/util/zip/ZipFile;->close()V

    .line 144
    invoke-virtual {v5}, Ljava/io/File;->delete()Z

    .line 145
    invoke-static {v4}, Lio/mesalabs/unica/settings/ui/GpuDriverPackage;->check(Ljava/io/File;)Lio/mesalabs/unica/settings/ui/GpuDriverPackage$Result;

    move-result-object v5

    .line 146
    iget-object v7, v5, Lio/mesalabs/unica/settings/ui/GpuDriverPackage$Result;->error:Ljava/lang/String;

    if-eqz v7, :cond_19b

    iget-object v0, v5, Lio/mesalabs/unica/settings/ui/GpuDriverPackage$Result;->error:Ljava/lang/String;

    iget-object v5, v5, Lio/mesalabs/unica/settings/ui/GpuDriverPackage$Result;->detail:Ljava/lang/String;

    invoke-direct {v1, v0, v5}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->fail(Ljava/lang/String;Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0
    :try_end_197
    .catch Ljava/io/IOException; {:try_start_181 .. :try_end_197} :catch_260
    .catch Ljava/lang/RuntimeException; {:try_start_181 .. :try_end_197} :catch_260
    .catchall {:try_start_181 .. :try_end_197} :catchall_25e

    .line 169
    invoke-static {v4}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->deleteTree(Ljava/io/File;)Z

    return-object v0

    .line 147
    :cond_19b
    :try_start_19b
    iget-object v7, v1, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    iget-object v8, v5, Lio/mesalabs/unica/settings/ui/GpuDriverPackage$Result;->version:Ljava/lang/String;

    invoke-virtual {v7, v8, v6}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->duplicateOf(Ljava/lang/String;Ljava/lang/String;)Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;

    move-result-object v7

    if-eqz v7, :cond_1b5

    .line 148
    const-string v0, "duplicate"

    iget-object v5, v5, Lio/mesalabs/unica/settings/ui/GpuDriverPackage$Result;->version:Ljava/lang/String;

    invoke-static {v5, v6}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->addedLabel(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    invoke-direct {v1, v0, v5}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->fail(Ljava/lang/String;Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0
    :try_end_1b1
    .catch Ljava/io/IOException; {:try_start_19b .. :try_end_1b1} :catch_260
    .catch Ljava/lang/RuntimeException; {:try_start_19b .. :try_end_1b1} :catch_260
    .catchall {:try_start_19b .. :try_end_1b1} :catchall_25e

    .line 169
    invoke-static {v4}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->deleteTree(Ljava/io/File;)Z

    return-object v0

    .line 150
    :cond_1b5
    :try_start_1b5
    iget-object v7, v5, Lio/mesalabs/unica/settings/ui/GpuDriverPackage$Result;->version:Ljava/lang/String;

    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v8

    const-wide/32 v10, 0x19a100

    rem-long/2addr v8, v10

    const/16 v12, 0x24

    invoke-static {v8, v9, v12}, Ljava/lang/Long;->toString(JI)Ljava/lang/String;

    move-result-object v8

    invoke-static {v7, v8}, Lio/mesalabs/unica/settings/ui/GpuDriverPackage;->slotFor(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v7

    .line 151
    new-instance v8, Ljava/io/File;

    invoke-direct {v8, v0, v7}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 152
    new-instance v0, Ljava/io/File;

    const-string v9, "info"

    invoke-direct {v0, v4, v9}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 153
    new-instance v9, Ljava/io/FileOutputStream;

    invoke-direct {v9, v0}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
    :try_end_1da
    .catch Ljava/io/IOException; {:try_start_1b5 .. :try_end_1da} :catch_260
    .catch Ljava/lang/RuntimeException; {:try_start_1b5 .. :try_end_1da} :catch_260
    .catchall {:try_start_1b5 .. :try_end_1da} :catchall_25e

    .line 154
    :try_start_1da
    iget-object v10, v5, Lio/mesalabs/unica/settings/ui/GpuDriverPackage$Result;->version:Ljava/lang/String;

    new-instance v11, Ljava/lang/StringBuilder;

    invoke-direct {v11}, Ljava/lang/StringBuilder;-><init>()V

    const-string v12, "version="

    invoke-virtual {v11, v12}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v11, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v10, "\nname="

    invoke-virtual {v11, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v11, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v10, "\n"

    invoke-virtual {v11, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v11}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v10

    sget-object v11, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    invoke-virtual {v10, v11}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    move-result-object v10

    invoke-virtual {v9, v10}, Ljava/io/OutputStream;->write([B)V
    :try_end_203
    .catchall {:try_start_1da .. :try_end_203} :catchall_244

    .line 155
    :try_start_203
    invoke-virtual {v9}, Ljava/io/OutputStream;->close()V

    const/16 v9, 0x1b0

    .line 156
    invoke-static {v0, v9}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->chmod(Ljava/io/File;I)V

    .line 157
    invoke-virtual {v8}, Ljava/io/File;->exists()Z

    move-result v0

    if-nez v0, :cond_23c

    invoke-virtual {v4, v8}, Ljava/io/File;->renameTo(Ljava/io/File;)Z

    move-result v0

    if-nez v0, :cond_218

    goto :goto_23c

    :cond_218
    const/4 v4, 0x0

    .line 159
    new-instance v0, Ljava/io/File;

    const-string v10, "ready"

    invoke-direct {v0, v8, v10}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 160
    invoke-static {v0}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->touch(Ljava/io/File;)Z

    move-result v10

    if-nez v10, :cond_22e

    .line 161
    invoke-static {v8}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->deleteTree(Ljava/io/File;)Z

    .line 162
    invoke-direct {v1, v2, v3}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->fail(Ljava/lang/String;Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0

    return-object v0

    .line 164
    :cond_22e
    invoke-static {v0, v9}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->chmod(Ljava/io/File;I)V

    .line 165
    iget-object v0, v5, Lio/mesalabs/unica/settings/ui/GpuDriverPackage$Result;->version:Ljava/lang/String;

    invoke-static {v0, v6}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->addedLabel(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    filled-new-array {v7, v0}, [Ljava/lang/String;

    move-result-object v0

    return-object v0

    .line 157
    :cond_23c
    :goto_23c
    invoke-direct {v1, v2, v3}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->fail(Ljava/lang/String;Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0
    :try_end_240
    .catch Ljava/io/IOException; {:try_start_203 .. :try_end_240} :catch_260
    .catch Ljava/lang/RuntimeException; {:try_start_203 .. :try_end_240} :catch_260
    .catchall {:try_start_203 .. :try_end_240} :catchall_25e

    .line 169
    invoke-static {v4}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->deleteTree(Ljava/io/File;)Z

    return-object v0

    :catchall_244
    move-exception v0

    move-object v5, v0

    .line 153
    :try_start_246
    invoke-virtual {v9}, Ljava/io/OutputStream;->close()V
    :try_end_249
    .catchall {:try_start_246 .. :try_end_249} :catchall_24a

    goto :goto_24e

    :catchall_24a
    move-exception v0

    :try_start_24b
    invoke-virtual {v5, v0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :goto_24e
    throw v5

    :catchall_24f
    move-exception v0

    .line 142
    invoke-virtual {v7}, Ljava/util/zip/ZipFile;->close()V

    .line 143
    throw v0

    .line 115
    :catch_254
    const-string v0, "not_zip"

    invoke-direct {v1, v0, v3}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->fail(Ljava/lang/String;Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0
    :try_end_25a
    .catch Ljava/io/IOException; {:try_start_24b .. :try_end_25a} :catch_260
    .catch Ljava/lang/RuntimeException; {:try_start_24b .. :try_end_25a} :catch_260
    .catchall {:try_start_24b .. :try_end_25a} :catchall_25e

    .line 169
    invoke-static {v4}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->deleteTree(Ljava/io/File;)Z

    return-object v0

    :catchall_25e
    move-exception v0

    goto :goto_26a

    .line 167
    :catch_260
    :try_start_260
    invoke-direct {v1, v2, v3}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->fail(Ljava/lang/String;Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0
    :try_end_264
    .catchall {:try_start_260 .. :try_end_264} :catchall_25e

    if-eqz v4, :cond_269

    .line 169
    invoke-static {v4}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->deleteTree(Ljava/io/File;)Z

    :cond_269
    return-object v0

    :goto_26a
    if-eqz v4, :cond_26f

    invoke-static {v4}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->deleteTree(Ljava/io/File;)Z

    .line 170
    :cond_26f
    throw v0
.end method

.method private varargs str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;
    .registers 4

    .line 265
    const-string v0, "string"

    invoke-static {v0, p1}, Lio/mesalabs/unica/utils/Utils;->getResourceId(Ljava/lang/String;Ljava/lang/String;)I

    move-result p1

    invoke-virtual {p0, p1, p2}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->getString(I[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method private toast(Ljava/lang/String;)V
    .registers 3

    const/4 v0, 0x1

    .line 261
    invoke-static {p0, p1, v0}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object p0

    invoke-virtual {p0}, Landroid/widget/Toast;->show()V

    return-void
.end method


# virtual methods
.method synthetic lambda$confirmRemove$6$io-mesalabs-unica-settings-ui-GpuDriverActivity(Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;Landroid/content/DialogInterface;I)V
    .registers 4

    .line 225
    invoke-direct {p0, p1}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->doRemove(Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;)V

    return-void
.end method

.method synthetic lambda$confirmRemove$7$io-mesalabs-unica-settings-ui-GpuDriverActivity(Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;Landroid/content/DialogInterface;I)V
    .registers 4

    .line 230
    invoke-direct {p0, p1}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->doRemove(Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;)V

    return-void
.end method

.method synthetic lambda$confirmRemove$8$io-mesalabs-unica-settings-ui-GpuDriverActivity(Landroid/content/DialogInterface;)V
    .registers 2

    .line 234
    invoke-virtual {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->finish()V

    return-void
.end method

.method synthetic lambda$onActivityResult$0$io-mesalabs-unica-settings-ui-GpuDriverActivity([Ljava/lang/String;)V
    .registers 2

    .line 88
    invoke-direct {p0, p1}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->showResult([Ljava/lang/String;)V

    return-void
.end method

.method synthetic lambda$onActivityResult$1$io-mesalabs-unica-settings-ui-GpuDriverActivity(Landroid/net/Uri;)V
    .registers 3

    .line 87
    invoke-direct {p0, p1}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->stage(Landroid/net/Uri;)[Ljava/lang/String;

    move-result-object p1

    .line 88
    new-instance v0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity$$8;

    invoke-direct {v0, p0, p1}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity$$8;-><init>(Lio/mesalabs/unica/settings/ui/GpuDriverActivity;[Ljava/lang/String;)V

    invoke-virtual {p0, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->runOnUiThread(Ljava/lang/Runnable;)V

    return-void
.end method

.method synthetic lambda$showRemoveList$4$io-mesalabs-unica-settings-ui-GpuDriverActivity(Ljava/util/List;Landroid/content/DialogInterface;I)V
    .registers 5

    .line 209
    iget-object p2, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mDialog:Landroid/app/AlertDialog;

    const/4 v0, 0x0

    invoke-virtual {p2, v0}, Landroid/app/AlertDialog;->setOnDismissListener(Landroid/content/DialogInterface$OnDismissListener;)V

    .line 210
    invoke-interface {p1, p3}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;

    invoke-direct {p0, p1}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->confirmRemove(Lio/mesalabs/unica/settings/ui/GpuDriverModel$Entry;)V

    return-void
.end method

.method synthetic lambda$showRemoveList$5$io-mesalabs-unica-settings-ui-GpuDriverActivity(Landroid/content/DialogInterface;)V
    .registers 2

    .line 213
    invoke-virtual {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->finish()V

    return-void
.end method

.method synthetic lambda$showResult$2$io-mesalabs-unica-settings-ui-GpuDriverActivity(Ljava/lang/String;Landroid/content/DialogInterface;I)V
    .registers 4

    .line 190
    iget-object p2, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    invoke-virtual {p2, p1}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->select(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_f

    invoke-direct {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->lockedMessage()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->toast(Ljava/lang/String;)V

    :cond_f
    return-void
.end method

.method synthetic lambda$showResult$3$io-mesalabs-unica-settings-ui-GpuDriverActivity(Landroid/content/DialogInterface;)V
    .registers 2

    .line 194
    invoke-virtual {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->finish()V

    return-void
.end method

.method protected onActivityResult(IILandroid/content/Intent;)V
    .registers 6

    .line 76
    invoke-super {p0, p1, p2, p3}, Landroid/app/Activity;->onActivityResult(IILandroid/content/Intent;)V

    const/4 v0, 0x1

    if-eq p1, v0, :cond_7

    return-void

    :cond_7
    if-eqz p3, :cond_e

    .line 78
    invoke-virtual {p3}, Landroid/content/Intent;->getData()Landroid/net/Uri;

    move-result-object p1

    goto :goto_f

    :cond_e
    const/4 p1, 0x0

    :goto_f
    const/4 p3, -0x1

    if-ne p2, p3, :cond_45

    if-nez p1, :cond_15

    goto :goto_45

    .line 83
    :cond_15
    iput-boolean v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mBusy:Z

    .line 84
    invoke-direct {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->builder()Landroid/app/AlertDialog$Builder;

    move-result-object p2

    const-string p3, "k4_gpu_driver_add_checking"

    const/4 v0, 0x0

    new-array v1, v0, [Ljava/lang/Object;

    invoke-direct {p0, p3, v1}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->str(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p3

    invoke-virtual {p2, p3}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object p2

    invoke-virtual {p2, v0}, Landroid/app/AlertDialog$Builder;->setCancelable(Z)Landroid/app/AlertDialog$Builder;

    move-result-object p2

    invoke-virtual {p2}, Landroid/app/AlertDialog$Builder;->create()Landroid/app/AlertDialog;

    move-result-object p2

    iput-object p2, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mDialog:Landroid/app/AlertDialog;

    .line 85
    invoke-virtual {p2}, Landroid/app/AlertDialog;->show()V

    .line 86
    new-instance p2, Ljava/lang/Thread;

    new-instance p3, Lio/mesalabs/unica/settings/ui/GpuDriverActivity$$0;

    invoke-direct {p3, p0, p1}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity$$0;-><init>(Lio/mesalabs/unica/settings/ui/GpuDriverActivity;Landroid/net/Uri;)V

    const-string p0, "k4-gpu-driver-add"

    invoke-direct {p2, p3, p0}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;Ljava/lang/String;)V

    .line 89
    invoke-virtual {p2}, Ljava/lang/Thread;->start()V

    return-void

    .line 80
    :cond_45
    :goto_45
    invoke-virtual {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->finish()V

    return-void
.end method

.method public onBackPressed()V
    .registers 2

    .line 326
    iget-boolean v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mBusy:Z

    if-nez v0, :cond_7

    invoke-super {p0}, Landroid/app/Activity;->onBackPressed()V

    :cond_7
    return-void
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .registers 6

    .line 48
    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    .line 49
    new-instance v0, Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    new-instance v1, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController$SystemProps;

    invoke-direct {v1}, Lio/mesalabs/unica/settings/ui/GpuDriverPreferenceController$SystemProps;-><init>()V

    new-instance v2, Ljava/io/File;

    const-string v3, "/data/k4gpu"

    invoke-direct {v2, v3}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-direct {v0, v1, v2}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;-><init>(Lio/mesalabs/unica/settings/ui/GpuDriverModel$Props;Ljava/io/File;)V

    iput-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mModel:Lio/mesalabs/unica/settings/ui/GpuDriverModel;

    if-eqz p1, :cond_19

    goto :goto_6a

    .line 51
    :cond_19
    invoke-virtual {v0}, Lio/mesalabs/unica/settings/ui/GpuDriverModel;->available()Z

    move-result p1

    if-nez p1, :cond_23

    .line 52
    invoke-virtual {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->finish()V

    return-void

    .line 55
    :cond_23
    invoke-virtual {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->getIntent()Landroid/content/Intent;

    move-result-object p1

    invoke-virtual {p1}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object p1

    const-string v0, "io.mesalabs.unica.action.GPU_DRIVER_REMOVE"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_37

    .line 56
    invoke-direct {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->showRemoveList()V

    return-void

    .line 59
    :cond_37
    const-string p1, "application/x-zip-compressed"

    const-string v0, "application/octet-stream"

    const-string v1, "application/zip"

    filled-new-array {v1, p1, v0}, [Ljava/lang/String;

    move-result-object p1

    const-string v0, "zip"

    filled-new-array {v0}, [Ljava/lang/String;

    move-result-object v0

    invoke-static {p0, p1, v0}, Lio/mesalabs/unica/utils/Utils;->getFilePickerOpenIntent(Landroid/content/Context;[Ljava/lang/String;[Ljava/lang/String;)Landroid/content/Intent;

    move-result-object p1

    const/4 v0, 0x1

    .line 63
    :try_start_4c
    invoke-virtual {p0, p1, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->startActivityForResult(Landroid/content/Intent;I)V
    :try_end_4f
    .catch Ljava/lang/RuntimeException; {:try_start_4c .. :try_end_4f} :catch_50

    return-void

    .line 65
    :catch_50
    new-instance p1, Landroid/content/Intent;

    const-string v1, "android.intent.action.OPEN_DOCUMENT"

    invoke-direct {p1, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    const-string v1, "android.intent.category.OPENABLE"

    invoke-virtual {p1, v1}, Landroid/content/Intent;->addCategory(Ljava/lang/String;)Landroid/content/Intent;

    move-result-object p1

    const-string v1, "*/*"

    invoke-virtual {p1, v1}, Landroid/content/Intent;->setType(Ljava/lang/String;)Landroid/content/Intent;

    move-result-object p1

    .line 67
    :try_start_63
    invoke-virtual {p0, p1, v0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->startActivityForResult(Landroid/content/Intent;I)V
    :try_end_66
    .catch Ljava/lang/RuntimeException; {:try_start_63 .. :try_end_66} :catch_67

    goto :goto_6a

    .line 69
    :catch_67
    invoke-virtual {p0}, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->finish()V

    :goto_6a
    return-void
.end method

.method protected onDestroy()V
    .registers 2

    .line 94
    iget-object v0, p0, Lio/mesalabs/unica/settings/ui/GpuDriverActivity;->mDialog:Landroid/app/AlertDialog;

    if-eqz v0, :cond_7

    invoke-virtual {v0}, Landroid/app/AlertDialog;->dismiss()V

    .line 95
    :cond_7
    invoke-super {p0}, Landroid/app/Activity;->onDestroy()V

    return-void
.end method
