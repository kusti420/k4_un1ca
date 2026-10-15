// Source of K4SlowMo.smali (the build only uses the .smali; this file is its readable form).
// To regenerate after an edit: compile with "javac -g:source -XDstringConcat=inline" against android.jar plus stubs for
// SemMediaPlayer (getPlaybackParams, setPlaybackParams, k4NativeVideoFrc), android.app.ActivityThread
// (currentPackageName, currentApplication), android.os.SystemProperties (getInt) and android.os.ServiceManager
// (checkService), dex it with "d8 --release --min-api 34 --no-desugaring", disassemble with the baksmali inside
// apktool.jar (com.android.tools.smali.baksmali.Main d), then put "blacklist" in front of every field and method name
// and keep the comment block at the top of K4SlowMo.smali.
package com.k4.media;

import android.app.ActivityThread;
import android.app.Application;
import android.media.MediaExtractor;
import android.media.MediaFormat;
import android.media.PlaybackParams;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.os.Parcel;
import android.os.ServiceManager;
import android.os.SystemClock;
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
    private static final int SDR8 = 1, NEURAL = 2;
    private static final String STORE = "vendor.samsung.hardware.media.mpp.ISehMppStore";
    private static final String NEURAL_SERVICE = STORE + "/k4front";
    private static final int NEURAL_WARM_UP = 0x4B3401;
    private static final int NEURAL_STATUS = 0x4B3404;

    private static int sGallery;
    private static WeakReference<SemMediaPlayer> sSlowed;
    private static int sPath;
    private static final WeakHashMap<SemMediaPlayer, Integer> sSources = new WeakHashMap<>();
    private static IBinder sNeural;
    private static long sNeuralLookup;
    private static long sNeuralWarmUp;

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
        int source = 0;
        MediaExtractor extractor = null;
        try {
            extractor = new MediaExtractor();
            extractor.setDataSource(fd, offset, length);
            int n = extractor.getTrackCount();
            for (int i = 0; i < n; i++) {
                MediaFormat f = extractor.getTrackFormat(i);
                String mime = f.getString("mime");
                if (mime != null && mime.startsWith("video/")) {
                    if (isEightBitSdr(mime, f)) {
                        source = isNeuralEligible(f) ? SDR8 | NEURAL : SDR8;
                    }
                    break;
                }
            }
        } catch (Throwable t) {
            source = 0;
        }
        if (extractor != null) {
            try {
                extractor.release();
            } catch (Throwable t) {
            }
        }
        synchronized (sSources) {
            sSources.put(player, Integer.valueOf(source));
        }
        if ((source & NEURAL) != 0) {
            warmUpNeural();
        }
    }

    // What the neural engine takes, on top of 8-bit SDR. The one place to widen once more is proven. Mirrors the size
    // checks of the k4neuralmpp pipe's init() (at least 320x240, even sizes, up to 1920x1088 either way round) and asks
    // for a known frame rate of at most 30 fps (the real-time budget).
    public static boolean isNeuralEligible(MediaFormat f) {
        int w = f.getNumber("width", Integer.valueOf(0)).intValue();
        int h = f.getNumber("height", Integer.valueOf(0)).intValue();
        if (w < 320 || h < 240 || (w & 1) != 0 || (h & 1) != 0 || Math.max(w, h) > 1920 || Math.min(w, h) > 1088) {
            return false;
        }
        if (!f.containsKey("frame-rate")) {
            return false;
        }
        float fps = f.getNumber("frame-rate", Integer.valueOf(0)).floatValue();
        return fps > 0.0f && fps <= 30.5f;
    }

    private static boolean neuralEnabled() {
        return SystemProperties.getInt("persist.sys.k4.slowmo_neural", 1) != 0;
    }

    // The k4front MPP store (the neural engine's daemon). A hit is trusted for 10 s, a miss for 3 s, so a daemon that
    // (re)starts is picked up without asking the service manager on every call.
    private static IBinder neuralService() {
        long now = SystemClock.uptimeMillis();
        IBinder service;
        synchronized (sSources) {
            service = sNeural;
            long age = now - sNeuralLookup;
            if (sNeuralLookup != 0L && age >= 0L) {
                if (service == null) {
                    if (age < 3000L) {
                        return null;
                    }
                } else if (age < 10000L && service.isBinderAlive()) {
                    return service;
                }
            }
        }
        try {
            service = ServiceManager.checkService(NEURAL_SERVICE);
        } catch (Throwable t) {
            service = null;
        }
        synchronized (sSources) {
            sNeural = service;
            sNeuralLookup = now == 0L ? 1L : now;
        }
        return service;
    }

    // Asks the daemon to build its network in the background (it frees it again after two minutes without a pipe).
    // One-way, so it never waits for the daemon; nothing here may reach the player.
    private static void warmUpNeural() {
        try {
            if (!neuralEnabled()) {
                return;
            }
            long now = SystemClock.uptimeMillis();
            synchronized (sSources) {
                if (sNeuralWarmUp != 0L && now - sNeuralWarmUp >= 0L && now - sNeuralWarmUp < 5000L) {
                    return;
                }
            }
            IBinder service = neuralService();
            if (service == null) {
                return;
            }
            synchronized (sSources) {
                sNeuralWarmUp = now == 0L ? 1L : now;
            }
            Parcel data = Parcel.obtain();
            try {
                data.writeInterfaceToken(STORE);
                service.transact(NEURAL_WARM_UP, data, null, IBinder.FLAG_ONEWAY);
            } finally {
                data.recycle();
            }
        } catch (Throwable t) {
            synchronized (sSources) {
                sNeural = null;
                sNeuralLookup = 0L;
            }
        }
    }

    // The daemon's own view of its network (transaction 0x4B3404, answered without waiting for the engine): 1 ready,
    // 0 not built yet (worth a try: the pipe builds it), -1 not usable right now (the last build or inference failed,
    // or a build hangs). A daemon that does not know the call counts as 0, one that is gone as -1.
    public static int neuralEngineState(IBinder service) {
        Parcel data = Parcel.obtain();
        Parcel reply = Parcel.obtain();
        try {
            data.writeInterfaceToken(STORE);
            if (!service.transact(NEURAL_STATUS, data, reply, 0)) {
                return 0;
            }
            reply.readException();
            return reply.readInt();
        } catch (android.os.RemoteException e) {
            synchronized (sSources) {
                sNeural = null;
                sNeuralLookup = 0L;
            }
            return -1;
        } catch (Throwable t) {
            return 0;
        } finally {
            data.recycle();
            reply.recycle();
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
            Integer boxed;
            synchronized (sSources) {
                boxed = sSources.get(player);
            }
            int source = boxed == null ? 0 : boxed.intValue();
            String why;
            String noNeural;
            IBinder neural = null;
            if (!neuralEnabled()) {
                noNeural = "persist.sys.k4.slowmo_neural is off";
            } else if ((neural = neuralService()) == null) {
                noNeural = "no k4front service";
            } else if (boxed == null) {
                noNeural = "source was not examined";
            } else if ((source & NEURAL) == 0) {
                noNeural = "source not eligible";
            } else if (neuralEngineState(neural) < 0) {
                noNeural = "neural engine not usable (see the K4Neural log)";
            } else {
                noNeural = null;
            }
            if (noNeural == null) {
                try {
                    nativeFrc(player, 4, 0.25f, lowLatency);
                    sSlowed = new WeakReference<>(player);
                    sPath = FRC;
                    Log.i(TAG, "hold: neural x4, playing at 0.25x");
                    return;
                } catch (IllegalStateException e) {
                    throw e;
                } catch (RuntimeException e) {
                    why = "neural frame interpolation refused: " + e;
                }
            } else {
                int mode = SystemProperties.getInt("persist.sys.k4.slowmo_frc", 1);
                if (mode <= 0) {
                    why = "persist.sys.k4.slowmo_frc is off";
                } else if (boxed == null) {
                    why = "source was not examined";
                } else if ((source & SDR8) == 0) {
                    why = "not an 8-bit SDR video";
                } else {
                    int s = mode == 2 ? scale : 2;
                    float r = mode == 2 ? rate : 0.5f;
                    try {
                        nativeFrc(player, s, r, lowLatency);
                        sSlowed = new WeakReference<>(player);
                        sPath = FRC;
                        Log.i(TAG, "hold: frame interpolation x2, playing at " + r + "x (no neural: " + noNeural + ")");
                        return;
                    } catch (IllegalStateException e) {
                        throw e;
                    } catch (RuntimeException e) {
                        why = "frame interpolation refused: " + e;
                    }
                }
                why = why + "; no neural: " + noNeural;
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
