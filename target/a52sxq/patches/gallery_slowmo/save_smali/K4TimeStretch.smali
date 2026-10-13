.class public final Lcom/k4/media/K4TimeStretch;
.super Ljava/lang/Object;


# direct methods
.method private constructor blacklist <init>()V
    .registers 1

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static blacklist main([Ljava/lang/String;)V
    .registers 11
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    const/4 v0, 0x0

    aget-object v1, p0, v0

    new-array v2, v0, [Ljava/lang/String;

    invoke-static {v1, v2}, Ljava/nio/file/Paths;->get(Ljava/lang/String;[Ljava/lang/String;)Ljava/nio/file/Path;

    move-result-object v1

    invoke-static {v1}, Ljava/nio/file/Files;->readAllBytes(Ljava/nio/file/Path;)[B

    move-result-object v1

    array-length v2, v1

    const/4 v3, 0x2

    div-int/2addr v2, v3

    new-array v4, v2, [S

    invoke-static {v1}, Ljava/nio/ByteBuffer;->wrap([B)Ljava/nio/ByteBuffer;

    move-result-object v1

    sget-object v5, Ljava/nio/ByteOrder;->LITTLE_ENDIAN:Ljava/nio/ByteOrder;

    invoke-virtual {v1, v5}, Ljava/nio/ByteBuffer;->order(Ljava/nio/ByteOrder;)Ljava/nio/ByteBuffer;

    move-result-object v1

    invoke-virtual {v1}, Ljava/nio/ByteBuffer;->asShortBuffer()Ljava/nio/ShortBuffer;

    move-result-object v1

    invoke-virtual {v1, v4}, Ljava/nio/ShortBuffer;->get([S)Ljava/nio/ShortBuffer;

    invoke-static {}, Ljava/lang/System;->nanoTime()J

    move-result-wide v5

    const/4 v1, 0x1

    aget-object v1, p0, v1

    invoke-static {v1}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v1

    aget-object v7, p0, v3

    invoke-static {v7}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v7

    const/4 v8, 0x3

    aget-object v8, p0, v8

    invoke-static {v8}, Ljava/lang/Double;->parseDouble(Ljava/lang/String;)D

    move-result-wide v8

    invoke-static {v4, v1, v7, v8, v9}, Lcom/k4/media/K4TimeStretch;->stretch([SIID)[S

    move-result-object v1

    sget-object v4, Ljava/lang/System;->out:Ljava/io/PrintStream;

    new-instance v7, Ljava/lang/StringBuilder;

    const-string v8, "stretched "

    invoke-direct {v7, v8}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v7, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v2, " -> "

    invoke-virtual {v7, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    array-length v2, v1

    invoke-virtual {v7, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v2, " samples in "

    invoke-virtual {v7, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-static {}, Ljava/lang/System;->nanoTime()J

    move-result-wide v8

    sub-long/2addr v8, v5

    const-wide/32 v5, 0xf4240

    div-long/2addr v8, v5

    invoke-virtual {v7, v8, v9}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    const-string v2, " ms"

    invoke-virtual {v7, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v4, v2}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V

    array-length v2, v1

    mul-int/2addr v2, v3

    invoke-static {v2}, Ljava/nio/ByteBuffer;->allocate(I)Ljava/nio/ByteBuffer;

    move-result-object v2

    sget-object v3, Ljava/nio/ByteOrder;->LITTLE_ENDIAN:Ljava/nio/ByteOrder;

    invoke-virtual {v2, v3}, Ljava/nio/ByteBuffer;->order(Ljava/nio/ByteOrder;)Ljava/nio/ByteBuffer;

    move-result-object v2

    invoke-virtual {v2}, Ljava/nio/ByteBuffer;->asShortBuffer()Ljava/nio/ShortBuffer;

    move-result-object v3

    invoke-virtual {v3, v1}, Ljava/nio/ShortBuffer;->put([S)Ljava/nio/ShortBuffer;

    const/4 v1, 0x4

    aget-object p0, p0, v1

    new-array v1, v0, [Ljava/lang/String;

    invoke-static {p0, v1}, Ljava/nio/file/Paths;->get(Ljava/lang/String;[Ljava/lang/String;)Ljava/nio/file/Path;

    move-result-object p0

    invoke-virtual {v2}, Ljava/nio/ByteBuffer;->array()[B

    move-result-object v1

    new-array v0, v0, [Ljava/nio/file/OpenOption;

    invoke-static {p0, v1, v0}, Ljava/nio/file/Files;->write(Ljava/nio/file/Path;[B[Ljava/nio/file/OpenOption;)Ljava/nio/file/Path;

    return-void
.end method

.method public static blacklist stretch([SIID)[S
    .registers 32

    move-object/from16 v0, p0

    move/from16 v1, p1

    array-length v2, v0

    div-int/2addr v2, v1

    mul-int/lit8 v3, p2, 0x28

    div-int/lit16 v3, v3, 0x3e8

    const/16 v4, 0x40

    invoke-static {v4, v3}, Ljava/lang/Math;->max(II)I

    move-result v3

    and-int/lit8 v3, v3, -0x2

    div-int/lit8 v4, v3, 0x2

    mul-int/lit8 v5, p2, 0xc

    div-int/lit16 v5, v5, 0x3e8

    int-to-double v6, v4

    div-double v6, v6, p3

    int-to-double v8, v2

    mul-double v8, v8, p3

    double-to-int v8, v8

    mul-int/lit8 v9, v3, 0x2

    if-lt v2, v9, :cond_162

    if-ge v8, v9, :cond_27

    goto/16 :goto_162

    :cond_27
    new-array v9, v2, [F

    const/4 v11, 0x0

    :goto_2a
    if-ge v11, v2, :cond_41

    const/4 v12, 0x0

    const/4 v13, 0x0

    :goto_2e
    if-ge v12, v1, :cond_39

    mul-int v14, v11, v1

    add-int/2addr v14, v12

    aget-short v14, v0, v14

    add-int/2addr v13, v14

    add-int/lit8 v12, v12, 0x1

    goto :goto_2e

    :cond_39
    int-to-float v12, v13

    int-to-float v13, v1

    div-float/2addr v12, v13

    aput v12, v9, v11

    add-int/lit8 v11, v11, 0x1

    goto :goto_2a

    :cond_41
    new-array v11, v3, [F

    const/4 v12, 0x0

    :goto_44
    if-ge v12, v3, :cond_64

    int-to-double v13, v12

    const-wide/high16 v15, 0x3fe0000000000000L    # 0.5

    add-double/2addr v13, v15

    const-wide v17, 0x401921fb54442d18L    # 6.283185307179586

    mul-double v13, v13, v17

    move-object/from16 v17, v11

    int-to-double v10, v3

    div-double/2addr v13, v10

    invoke-static {v13, v14}, Ljava/lang/Math;->cos(D)D

    move-result-wide v10

    mul-double/2addr v10, v15

    sub-double v10, v15, v10

    double-to-float v10, v10

    aput v10, v17, v12

    add-int/lit8 v12, v12, 0x1

    move-object/from16 v11, v17

    goto :goto_44

    :cond_64
    move-object/from16 v17, v11

    add-int v10, v8, v3

    mul-int v11, v10, v1

    new-array v11, v11, [F

    const/4 v12, 0x0

    const/4 v13, 0x0

    :goto_6e
    int-to-long v14, v13

    move/from16 v16, v5

    move-wide/from16 v18, v6

    int-to-long v5, v4

    mul-long/2addr v14, v5

    int-to-long v5, v3

    add-long/2addr v14, v5

    add-int v5, v8, v4

    int-to-long v5, v5

    cmp-long v5, v14, v5

    if-gtz v5, :cond_13c

    int-to-double v5, v13

    mul-double v5, v5, v18

    invoke-static {v5, v6}, Ljava/lang/Math;->round(D)J

    move-result-wide v5

    long-to-int v5, v5

    if-lez v13, :cond_f9

    add-int/2addr v12, v4

    sub-int v6, v5, v16

    const/4 v7, 0x0

    invoke-static {v7, v6}, Ljava/lang/Math;->max(II)I

    move-result v6

    sub-int v7, v2, v3

    add-int v14, v5, v16

    invoke-static {v7, v14}, Ljava/lang/Math;->min(II)I

    move-result v14

    add-int v15, v12, v3

    if-gt v15, v2, :cond_ed

    if-le v14, v6, :cond_ed

    const-wide v20, -0x39d6c1a6c65f7316L    # -1.0E30

    :goto_a3
    if-gt v6, v14, :cond_e8

    const-wide/16 v22, 0x0

    const-wide v24, 0x3f50624dd2f1a9fcL    # 0.001

    const/4 v7, 0x0

    :goto_ad
    if-ge v7, v3, :cond_cd

    add-int v15, v6, v7

    aget v15, v9, v15

    add-int v26, v12, v7

    aget v26, v9, v26

    mul-float v0, v15, v26

    move/from16 v26, v4

    move/from16 p3, v5

    float-to-double v4, v0

    add-double v22, v22, v4

    mul-float/2addr v15, v15

    float-to-double v4, v15

    add-double v24, v24, v4

    add-int/lit8 v7, v7, 0x4

    move-object/from16 v0, p0

    move/from16 v5, p3

    move/from16 v4, v26

    goto :goto_ad

    :cond_cd
    move/from16 v26, v4

    move/from16 p3, v5

    invoke-static/range {v24 .. v25}, Ljava/lang/Math;->sqrt(D)D

    move-result-wide v4

    div-double v22, v22, v4

    cmpl-double v0, v22, v20

    if-lez v0, :cond_df

    move v5, v6

    move-wide/from16 v20, v22

    goto :goto_e1

    :cond_df
    move/from16 v5, p3

    :goto_e1
    add-int/lit8 v6, v6, 0x2

    move-object/from16 v0, p0

    move/from16 v4, v26

    goto :goto_a3

    :cond_e8
    move/from16 v26, v4

    move/from16 p3, v5

    goto :goto_fb

    :cond_ed
    move/from16 v26, v4

    invoke-static {v7, v5}, Ljava/lang/Math;->min(II)I

    move-result v0

    const/4 v7, 0x0

    invoke-static {v7, v0}, Ljava/lang/Math;->max(II)I

    move-result v5

    goto :goto_fc

    :cond_f9
    move/from16 v26, v4

    :goto_fb
    const/4 v7, 0x0

    :goto_fc
    sub-int v0, v2, v3

    invoke-static {v0, v5}, Ljava/lang/Math;->min(II)I

    move-result v0

    invoke-static {v7, v0}, Ljava/lang/Math;->max(II)I

    move-result v12

    mul-int v4, v13, v26

    move v0, v7

    :goto_109
    if-ge v0, v3, :cond_130

    add-int v5, v4, v0

    if-ge v5, v10, :cond_130

    move v6, v7

    :goto_110
    if-ge v6, v1, :cond_12c

    mul-int v14, v5, v1

    add-int/2addr v14, v6

    aget v15, v11, v14

    aget v20, v17, v0

    add-int v21, v12, v0

    mul-int v21, v21, v1

    add-int v21, v21, v6

    aget-short v7, p0, v21

    int-to-float v7, v7

    mul-float v20, v20, v7

    add-float v15, v15, v20

    aput v15, v11, v14

    add-int/lit8 v6, v6, 0x1

    const/4 v7, 0x0

    goto :goto_110

    :cond_12c
    add-int/lit8 v0, v0, 0x1

    const/4 v7, 0x0

    goto :goto_109

    :cond_130
    add-int/lit8 v13, v13, 0x1

    move-object/from16 v0, p0

    move/from16 v5, v16

    move-wide/from16 v6, v18

    move/from16 v4, v26

    goto/16 :goto_6e

    :cond_13c
    mul-int/2addr v8, v1

    new-array v0, v8, [S

    const/4 v10, 0x0

    :goto_140
    if-ge v10, v8, :cond_161

    aget v1, v11, v10

    const v2, 0x46fffe00    # 32767.0f

    cmpl-float v2, v1, v2

    if-lez v2, :cond_14e

    const/16 v1, 0x7fff

    goto :goto_15b

    :cond_14e
    const/high16 v2, -0x39000000    # -32768.0f

    cmpg-float v2, v1, v2

    if-gez v2, :cond_157

    const/16 v1, -0x8000

    goto :goto_15b

    :cond_157
    invoke-static {v1}, Ljava/lang/Math;->round(F)I

    move-result v1

    :goto_15b
    int-to-short v1, v1

    aput-short v1, v0, v10

    add-int/lit8 v10, v10, 0x1

    goto :goto_140

    :cond_161
    return-object v0

    :cond_162
    :goto_162
    mul-int v0, v8, v1

    new-array v0, v0, [S

    const/4 v7, 0x0

    :goto_167
    if-ge v7, v8, :cond_185

    const/4 v3, 0x0

    :goto_16a
    if-ge v3, v1, :cond_182

    mul-int v4, v7, v1

    add-int/2addr v4, v3

    add-int/lit8 v5, v2, -0x1

    int-to-double v9, v7

    div-double v9, v9, p3

    double-to-int v6, v9

    invoke-static {v5, v6}, Ljava/lang/Math;->min(II)I

    move-result v5

    mul-int/2addr v5, v1

    add-int/2addr v5, v3

    aget-short v5, p0, v5

    aput-short v5, v0, v4

    add-int/lit8 v3, v3, 0x1

    goto :goto_16a

    :cond_182
    add-int/lit8 v7, v7, 0x1

    goto :goto_167

    :cond_185
    return-object v0
.end method
