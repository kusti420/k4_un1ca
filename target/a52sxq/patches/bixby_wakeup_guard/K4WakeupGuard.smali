.class public final Lcom/k4/soundtrigger/K4WakeupGuard;
.super Ljava/lang/Object;
.source "K4WakeupGuard.java"

# Called first in SoundTriggerModule$Session.loadPhraseModel (patches/bixby_wakeup_guard). Refuses Samsung voice
# wake-up models (vendor UUID a1757552-af10-11e7-985a-a3754010baa2 = the "Samsung uuid" entry of the A52s
# sound_trigger_platform_info.xml, app_type 5): loading the S26 Ultra Bixby Wakeup model makes the A52s ADSP firmware
# fault in its LPI voice module (err_qdi.c audio_process LPro00dyn) and the SoC resets; the app reloads the model about
# a minute after every boot, so one enrolment ends in a boot loop. persist.sys.k4.samsung_wakeup=1 lets it through.

.method public static check(Landroid/media/soundtrigger/PhraseSoundModel;)V
    .registers 4

    if-eqz p0, :cond_ok
    iget-object v0, p0, Landroid/media/soundtrigger/PhraseSoundModel;->common:Landroid/media/soundtrigger/SoundModel;
    if-eqz v0, :cond_ok
    iget-object v0, v0, Landroid/media/soundtrigger/SoundModel;->vendorUuid:Ljava/lang/String;
    const-string v1, "a1757552-af10-11e7-985a-a3754010baa2"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z
    move-result v0
    if-eqz v0, :cond_ok
    const-string v0, "persist.sys.k4.samsung_wakeup"
    const/4 v1, 0x0
    invoke-static {v0, v1}, Landroid/os/SystemProperties;->getInt(Ljava/lang/String;I)I
    move-result v0
    if-nez v0, :cond_ok
    const-string v0, "K4WakeupGuard"
    const-string v1, "refusing a Samsung voice wake-up model: the A52s ADSP firmware crashes on it (SoC reset)"
    invoke-static {v0, v1}, Landroid/util/Slog;->w(Ljava/lang/String;Ljava/lang/String;)I
    new-instance v0, Lcom/android/server/soundtrigger_middleware/RecoverableException;
    const/4 v1, 0x2
    const-string v2, "Samsung voice wake-up is not supported on this device"
    invoke-direct {v0, v1, v2}, Lcom/android/server/soundtrigger_middleware/RecoverableException;-><init>(ILjava/lang/String;)V
    throw v0

    :cond_ok
    return-void
.end method
