// Source of K4SlowMo.smali (the build only uses the .smali; this file is its readable form).
// To regenerate after an edit: compile with "javac -g:none -XDstringConcat=inline" against android.jar plus stubs for
// SemMediaPlayer (getPlaybackParams, setPlaybackParams, k4NativeVideoFrc), android.app.ActivityThread
// (currentPackageName, currentApplication) and android.os.SystemProperties (getInt), dex it with
// "d8 --release --min-api 34 --no-desugaring", disassemble with the baksmali inside apktool.jar
// (com.android.tools.smali.baksmali.Main d), then put "blacklist" in front of every field and method name and keep
// the comment block at the top of K4SlowMo.smali.
package com.k4.media;

import android.app.ActivityThread;
import android.app.Application;
import android.media.MediaExtractor;
import android.media.MediaFormat;
import android.media.PlaybackParams;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemProperties;
import android.util.Log;
import com.samsung.android.media.SemMediaPlayer;
import java.io.FileDescriptor;
import java.lang.ref.WeakReference;
import java.lang.reflect.Field;
import java.util.WeakHashMap;

public final class K4SlowMo implements Runnable {
    private static final String TAG = "K4SlowMo";
    private static final int PLAIN = 1, FRC = 2;

    private static int sGallery;
    private static WeakReference<SemMediaPlayer> sSlowed;
    private static int sPath;
    private static final WeakHashMap<SemMediaPlayer, Boolean> sSources = new WeakHashMap<>();

    private K4SlowMo() {
    }

    public static boolean featureBoolean(String key) {
        if ("SEC_FLOATING_FEATURE_CAMERA_SUPPORT_AIFRC".equals(key)) {
            return isGallery();
        }
        return false;
    }

    public static String featureString(String key) {
        if ("SEC_FLOATING_FEATURE_CAMERA_CONFIG_AIFRC_SPEC".equals(key) && isGallery()) {
            return "480,480,3840,2160,23,61,HDR,MP_PLAYBACK_OFF";
        }
        return null;
    }

    public static boolean hideMotionPhotoViewModes(ClassLoader loader) {
        try {
            Class<?> mode = Class.forName("com.samsung.android.gallery.module.motionphoto.MotionPhotoViewMode", true, loader);
            Field enabled = mode.getDeclaredField("mEnabled");
            enabled.setAccessible(true);
            enabled.setBoolean(mode.getField("BOOMERANG").get(null), false);
            enabled.setBoolean(mode.getField("SLOW_MO").get(null), false);
            return true;
        } catch (Throwable t) {
            Log.w(TAG, "Motion photo Boomerang/Slow-mo view modes were not turned off", t);
            return false;
        }
    }

    private static boolean isGallery() {
        int g = sGallery;
        if (g == 0) {
            String pkg = ActivityThread.currentPackageName();
            if (pkg == null) {
                return false;
            }
            if ("com.sec.android.gallery3d".equals(pkg)) {
                scheduleGalleryFixups();
                g = 1;
            } else {
                g = 2;
            }
            sGallery = g;
        }
        return g == 1;
    }

    private static void scheduleGalleryFixups() {
        try {
            new Handler(Looper.getMainLooper()).post(new K4SlowMo());
        } catch (Throwable t) {
        }
    }

    @Override
    public void run() {
        Application app = ActivityThread.currentApplication();
        if (app != null) {
            hideMotionPhotoViewModes(app.getClassLoader());
        }
    }

    public static void sourceOpened(SemMediaPlayer player, FileDescriptor fd, long offset, long length) {
        if (!isGallery()) {
            return;
        }
        boolean ok = false;
        MediaExtractor extractor = null;
        try {
            extractor = new MediaExtractor();
            extractor.setDataSource(fd, offset, length);
            int n = extractor.getTrackCount();
            for (int i = 0; i < n; i++) {
                MediaFormat f = extractor.getTrackFormat(i);
                String mime = f.getString("mime");
                if (mime != null && mime.startsWith("video/")) {
                    ok = isEightBitSdr(mime, f);
                    break;
                }
            }
        } catch (Throwable t) {
            ok = false;
        }
        if (extractor != null) {
            try {
                extractor.release();
            } catch (Throwable t) {
            }
        }
        synchronized (sSources) {
            sSources.put(player, Boolean.valueOf(ok));
        }
    }

    public static boolean isEightBitSdr(String mime, MediaFormat f) {
        int transfer = f.getInteger("color-transfer", 0);
        if (transfer == 6 || transfer == 7 || f.getInteger("color-standard", 0) == 6) {
            return false;
        }
        int profile = f.getInteger("profile", -1);
        if ("video/avc".equals(mime)) {
            return profile != 0x10 && profile != 0x20 && profile != 0x40;
        }
        if ("video/hevc".equals(mime) || "video/x-vnd.on2.vp9".equals(mime) || "video/av01".equals(mime)) {
            return profile == 1;
        }
        return false;
    }

    private static void nativeFrc(SemMediaPlayer player, int scale, float rate, boolean lowLatency) {
        player.k4NativeVideoFrc(scale, rate, lowLatency);
    }

    private static void setSpeed(SemMediaPlayer player, float speed) {
        PlaybackParams params = player.getPlaybackParams();
        params.setSpeed(speed);
        player.setPlaybackParams(params);
    }

    public static void setVideoFrc(SemMediaPlayer player, int scale, float rate, boolean lowLatency) {
        if (scale >= 2) {
            if (!(rate > 0.0f)) {
                return;
            }
            String why;
            int mode = SystemProperties.getInt("persist.sys.k4.slowmo_frc", 1);
            if (mode <= 0) {
                why = "persist.sys.k4.slowmo_frc is off";
            } else {
                Boolean ok;
                synchronized (sSources) {
                    ok = sSources.get(player);
                }
                if (ok == null) {
                    why = "source was not examined";
                } else if (!ok.booleanValue()) {
                    why = "not an 8-bit SDR video";
                } else {
                    int s = mode == 2 ? scale : 2;
                    float r = mode == 2 ? rate : 0.5f;
                    try {
                        nativeFrc(player, s, r, lowLatency);
                        sSlowed = new WeakReference<>(player);
                        sPath = FRC;
                        Log.i(TAG, "hold: frame interpolation x2, playing at " + r + "x");
                        return;
                    } catch (IllegalStateException e) {
                        throw e;
                    } catch (RuntimeException e) {
                        why = "frame interpolation refused: " + e;
                    }
                }
            }
            sSlowed = new WeakReference<>(player);
            sPath = PLAIN;
            setSpeed(player, rate);
            Log.i(TAG, "hold: plain " + rate + "x (" + why + ")");
            return;
        }
        WeakReference<SemMediaPlayer> slowed = sSlowed;
        if (slowed == null || slowed.get() != player) {
            return;
        }
        sSlowed = null;
        if (sPath == FRC) {
            try {
                nativeFrc(player, scale, 1.0f, lowLatency);
                Log.i(TAG, "release: frame interpolation off");
                return;
            } catch (IllegalStateException e) {
                throw e;
            } catch (RuntimeException e) {
                Log.w(TAG, "release: frame interpolation did not switch off, setting 1x", e);
            }
        }
        setSpeed(player, 1.0f);
    }
}
