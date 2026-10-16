.method public enhance([B[BIII)Z
    .locals 10

    # k4_remaster_dn: Denoise (DENOISE enhancer) for SM7325. Stock: AI_CLARITY_2X on the full picture (12 MP in ->
    # 6936x9248 float buffers, 88 GPU tiles x 1.5 s) then a 2x downscale; on the A52s that is >140 s and lmkd kills
    # the service at ~2 GB. Here: if w*h > cap, downscale by f = min(0.5, sqrt(cap / (w*h))) (INTER_AREA), run the
    # same clarity model as a true 2x (runClarityEnhancer scale 2, the VSWClarity2xEnhancer call), and resize the
    # result to w x h (INTER_CUBIC; a plain copy when f is exactly 0.5).
    # cap = persist.sys.k4.remaster_dn_kpx * 1000 pixels (default 4000 = 4.0 MP); 0 = stock full-size path,
    # negative = no AI denoise (output = input, HDR still runs).
    sget-object v0, Lcom/samsung/android/photoremaster/engine/enhancer/VSWClarity2xDownscaledTo1xEnhancer;->TAG:Ljava/lang/String;

    const-string v1, "enhance - E"

    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    invoke-static {}, Lcom/samsung/android/photoremaster/engine/nativeInterface/VSWEngineNativeInterface;->printLibraryVersion()V

    const v2, 0x3d0900

    const-string v1, "persist.sys.k4.remaster_dn_kpx"

    invoke-static {v1}, Landroid/os/SemSystemProperties;->get(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    :try_start_k4
    invoke-static {v1}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v1

    mul-int/lit16 v2, v1, 0x3e8
    :try_end_k4
    .catch Ljava/lang/RuntimeException; {:try_start_k4 .. :try_end_k4} :k4_cap_set

    :k4_cap_set
    if-eqz v2, :k4_stock

    if-gez v2, :k4_check_size

    # cap < 0: no AI denoise
    array-length v1, p1

    const/4 v3, 0x0

    invoke-static {p1, v3, p2, v3, v1}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    const-string v1, "k4: AI denoise skipped (persist.sys.k4.remaster_dn_kpx < 0)"

    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    const/4 v1, 0x1

    return v1

    :k4_check_size
    mul-int v3, p3, p4

    if-le v3, v2, :k4_stock

    # f = min(0.5, sqrt(cap / pixels)) in v4/v5
    int-to-double v4, v2

    int-to-double v6, v3

    div-double/2addr v4, v6

    invoke-static {v4, v5}, Ljava/lang/Math;->sqrt(D)D

    move-result-wide v4

    const-wide/high16 v6, 0x3fe0000000000000L    # 0.5

    invoke-static {v4, v5, v6, v7}, Ljava/lang/Math;->min(DD)D

    move-result-wide v4

    # v7 = even(w * f), v8 = even(h * f)
    int-to-double v0, p3

    mul-double/2addr v0, v4

    double-to-int v7, v0

    and-int/lit8 v7, v7, -0x2

    int-to-double v0, p4

    mul-double/2addr v0, v4

    double-to-int v8, v0

    and-int/lit8 v8, v8, -0x2

    const/16 v0, 0x40

    if-lt v7, v0, :k4_stock

    if-lt v8, v0, :k4_stock

    # v9 = small = new byte[w2 * h2 * 3]; resize3ch(in, small, w, h, w2, h2, INTER_AREA)
    mul-int v0, v7, v8

    mul-int/lit8 v0, v0, 0x3

    new-array v9, v0, [B

    move-object v0, p1

    move-object v1, v9

    move v2, p3

    move v3, p4

    move v4, v7

    move v5, v8

    const/4 v6, 0x3

    invoke-static/range {v0 .. v6}, Lcom/samsung/android/photoremaster/JNI;->resize3ch([B[BIIIII)V

    # v6 = big = new byte[(2 w2) * (2 h2) * 3]; v9 = runClarityEnhancer(small, big, w2, h2, 2)
    mul-int v0, v7, v8

    mul-int/lit8 v0, v0, 0xc

    new-array v6, v0, [B

    const/4 v0, 0x2

    invoke-static {v9, v6, v7, v8, v0}, Lcom/samsung/android/photoremaster/engine/nativeInterface/VSWEngineNativeInterface;->runClarityEnhancer([B[BIII)Z

    move-result v9

    if-eqz v9, :k4_split_done

    # resize3ch(big, out, 2 w2, 2 h2, w, h, INTER_CUBIC)
    move-object v0, v6

    move-object v1, p2

    shl-int/lit8 v2, v7, 0x1

    shl-int/lit8 v3, v8, 0x1

    move v4, p3

    move v5, p4

    const/4 v6, 0x2

    invoke-static/range {v0 .. v6}, Lcom/samsung/android/photoremaster/JNI;->resize3ch([B[BIIIII)V

    :k4_split_done
    sget-object v0, Lcom/samsung/android/photoremaster/engine/enhancer/VSWClarity2xDownscaledTo1xEnhancer;->TAG:Ljava/lang/String;

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "k4: denoise "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, p3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v2, "x"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, p4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v2, " via clarity 2x of "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v7}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v2, "x"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v8}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v2, ", result: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v9}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    return v9

    :k4_stock
    sget-object v0, Lcom/samsung/android/photoremaster/engine/enhancer/VSWClarity2xDownscaledTo1xEnhancer;->TAG:Ljava/lang/String;

    invoke-static {p1, p2, p3, p4}, Lcom/samsung/android/photoremaster/engine/nativeInterface/VSWEngineNativeInterface;->runClarity2xEnhancerDownscaledTo1x([B[BII)Z

    move-result v1

    const-string v2, "result : "

    const-string v3, "enhance - X"

    invoke-static {v2, v0, v0, v1, v3}, LE/l;->p(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ZLjava/lang/String;)V

    return v1
.end method
