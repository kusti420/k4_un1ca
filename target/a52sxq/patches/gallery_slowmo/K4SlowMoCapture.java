// Glue between SemMediaCapture (Gallery's "Save slow-mo clip") and K4SlowMoExport. SemMediaCapture calls the static
// methods below from its own methods (hooks added by customize.sh); state is kept here per SemMediaCapture instance.
// Only the instant slow-mo clip of Gallery (one dynamic viewing section over the whole requested range, neural service
// present, eligible source) is taken; everything else, and any failure, goes down the stock VEKit path.
// Source of K4SlowMoCapture.smali (see K4SlowMo.java for how the smali is generated).
package com.k4.media;

import android.os.Handler;
import android.system.Os;
import android.system.OsConstants;
import android.util.Log;
import java.io.FileDescriptor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.List;
import java.util.WeakHashMap;

public final class K4SlowMoCapture implements K4SlowMoExport.Listener, Runnable {
    private static final String TAG = "K4SlowMo";
    private static final String SERVICE = "vendor.samsung.hardware.media.mpp.ISehMppStore/k4front";
    private static final int PARAM_CAPTURE_TYPE = 1012, TYPE_INSTANT_SLOW_MO_CLIP = 89, MSG_RECORDING_COMPLETED = 7;
    private static final WeakHashMap<Object, K4SlowMoCapture> sStates = new WeakHashMap<>();

    private Object mCapture;                 // the SemMediaCapture while our export runs
    private FileDescriptor mIn, mOut;
    private long mInOffset, mInLength;
    private int mStart = -1, mEnd = -1, mDvCount, mDvStart, mDvEnd, mType = -1;
    private float mDvRate;
    private K4SlowMoExport mExport;
    private boolean mOurs, mFinished, mCancelled;

    private static boolean sTest;        // set by main() only

    private K4SlowMoCapture() {
    }

    private static K4SlowMoCapture of(Object capture, boolean create) {
        synchronized (sStates) {
            K4SlowMoCapture s = sStates.get(capture);
            if (s == null && create) { s = new K4SlowMoCapture(); sStates.put(capture, s); }
            return s;
        }
    }

    public static void source(Object capture, FileDescriptor fd, long offset, long length) {
        try { K4SlowMoCapture s = of(capture, true); s.mIn = fd; s.mInOffset = offset; s.mInLength = length; } catch (Throwable t) { }
    }

    public static void source(Object capture, FileDescriptor fd) {
        source(capture, fd, 0L, 0x7ffffffffffffffL);
    }

    public static void output(Object capture, FileDescriptor fd) {
        try { of(capture, true).mOut = fd; } catch (Throwable t) { }
    }

    public static void parameter(Object capture, int key, int value) {
        try { if (key == PARAM_CAPTURE_TYPE) of(capture, true).mType = value; } catch (Throwable t) { }
    }

    public static void startEnd(Object capture, int start, int end) {
        try { K4SlowMoCapture s = of(capture, true); s.mStart = start; s.mEnd = end; } catch (Throwable t) { }
    }

    public static void dynamicViewing(Object capture, List<?> configs) {
        try {
            K4SlowMoCapture s = of(capture, true);
            s.mDvCount = configs == null ? 0 : configs.size();
            if (s.mDvCount == 1) {
                Object c = configs.get(0); Class<?> k = c.getClass();
                s.mDvStart = (Integer) k.getMethod("getStartTime").invoke(c); s.mDvEnd = (Integer) k.getMethod("getEndTime").invoke(c);
                s.mDvRate = (Float) k.getMethod("getSpeedRate").invoke(c);
            }
        } catch (Throwable t) { try { of(capture, true).mDvCount = -1; } catch (Throwable u) { } }
    }

    /** true = our export has started and SemMediaCapture must not start VEKit. */
    public static boolean startCapture(Object capture) {
        K4SlowMoCapture s = null;
        try {
            s = of(capture, false);
            if (s == null) return false;
            if (s.mOurs && !s.mFinished) return true;         // already running
            s.mOurs = false; s.mExport = null;
            String why = s.refusal();
            if (why != null) { if (s.mDvCount > 0) Log.i(TAG, "save: stock path (" + why + ")"); return false; }
            s.mCapture = capture; s.mFinished = false; s.mCancelled = false;
            s.mExport = new K4SlowMoExport(s.mIn, s.mInOffset, s.mInLength, s.mOut, s.mDvStart, s.mDvEnd, s.mDvRate, s);
            s.mExport.start();
            s.mOurs = true;
            Log.i(TAG, "save: neural export of " + s.mDvStart + ".." + s.mDvEnd + " ms at " + s.mDvRate + "x started (no audio track yet)");
            return true;
        } catch (Throwable t) {
            Log.i(TAG, "save: stock path (neural export did not start: " + t + ")");
            if (s != null) { s.mOurs = false; s.mExport = null; s.mCapture = null; }
            return false;
        }
    }

    private String refusal() throws Exception {
        if (!sTest && !K4SlowMo.featureBoolean("SEC_FLOATING_FEATURE_CAMERA_SUPPORT_AIFRC")) return "not Gallery";
        if (intProp("persist.sys.k4.slowmo_neural", 1) == 0) return "persist.sys.k4.slowmo_neural is off";
        if (mDvCount != 1) return mDvCount + " dynamic viewing sections";
        if (mType != TYPE_INSTANT_SLOW_MO_CLIP) return "capture type " + mType;
        if (mIn == null || mOut == null) return "no file descriptors";
        if (mDvEnd <= mDvStart || mDvStart != mStart || mDvEnd != mEnd) return "section " + mDvStart + ".." + mDvEnd + " of " + mStart + ".." + mEnd;
        if (!(mDvRate == 0.25f || mDvRate == 0.5f)) return "rate " + mDvRate;
        Object b = Class.forName("android.os.ServiceManager").getMethod("checkService", String.class).invoke(null, SERVICE);
        if (b == null) return "no neural service";
        return null;
    }

    private static int intProp(String name, int def) throws Exception {
        return (Integer) Class.forName("android.os.SystemProperties").getMethod("getInt", String.class, int.class).invoke(null, name, def);
    }

    /** true while SemMediaCapture has to ask us, not VEKit, for the progress */
    public static boolean ours(Object capture) {
        try { K4SlowMoCapture s = of(capture, false); return s != null && s.mOurs; } catch (Throwable t) { return false; }
    }

    /** -1 = not ours (ask VEKit) */
    public static float progress(Object capture) {
        try {
            K4SlowMoCapture s = of(capture, false);
            if (s == null || !s.mOurs) return -1.0f;
            K4SlowMoExport e = s.mExport;
            return s.mFinished || e == null ? 1.0f : e.getProgress();
        } catch (Throwable t) { return -1.0f; }
    }

    /** true = it was our export (now cancelled or already finished); VEKit has nothing to stop. */
    public static boolean stopCapture(Object capture) {
        try {
            K4SlowMoCapture s = of(capture, false);
            if (s == null || !s.mOurs) return false;
            K4SlowMoExport e = s.mExport;
            if (!s.mFinished && e != null) { s.mCancelled = true; e.cancel(); }
            return true;
        } catch (Throwable t) { return false; }
    }

    public static void release(Object capture) {
        try {
            stopCapture(capture);
            synchronized (sStates) { sStates.remove(capture); }
        } catch (Throwable t) { }
    }

    @Override
    public void onFinished(K4SlowMoExport e, boolean ok, String detail) {
        Object capture = mCapture;
        try {
            if (ok) { mFinished = true; Handler h = handler(capture); if (h != null) h.sendMessage(h.obtainMessage(MSG_RECORDING_COMPLETED)); return; }
            clearOutput();
            if (mCancelled) { mFinished = true; return; }
            // our path failed: hand the capture to VEKit on SemMediaCapture's own thread, with an empty output file
            Log.w(TAG, "save: neural export failed (" + detail + "), falling back to the stock path");
            mOurs = false; mExport = null;
            Handler h = handler(capture);
            if (h != null) h.post(this); else run();
        } catch (Throwable t) {
            Log.w(TAG, "save: " + t);
        }
    }

    @Override
    public void run() {         // fallback: what SemMediaCapture.startCapture() would have done
        try {
            Object capture = mCapture; mCapture = null;
            Field f = capture.getClass().getDeclaredField("mWrapper"); f.setAccessible(true);
            Object w = f.get(capture);
            Method m = w.getClass().getMethod("startCapture");
            m.invoke(w);
        } catch (Throwable t) {
            Log.w(TAG, "save: stock path did not start: " + t);
        }
    }

    private void clearOutput() {
        try { Os.ftruncate(mOut, 0); Os.lseek(mOut, 0, OsConstants.SEEK_SET); } catch (Throwable t) { Log.w(TAG, "save: output not cleared: " + t); }
    }

    private static Handler handler(Object capture) throws Exception {
        Field f = capture.getClass().getDeclaredField("mEventHandler"); f.setAccessible(true);
        return (Handler) f.get(capture);
    }

    // test of the glue without Gallery/VEKit:
    // app_process /system/bin com.k4.media.K4SlowMoCapture in.mp4 out.mp4 startMs endMs [cancelAfterMs | "fail"]
    // ("fail" = a section the player cannot reach, to see the hand-over to the stock path)
    static final class FakeWrapper { public void startCapture() { System.out.println("K4G stock wrapper.startCapture() called on " + Thread.currentThread().getName()); } }
    static final class FakeCapture {
        Handler mEventHandler; Object mWrapper = new FakeWrapper();
    }
    public static void main(String[] a) throws Exception {
        android.os.Looper.prepareMainLooper();
        sTest = true;
        final FakeCapture c = new FakeCapture(); final long t0 = android.os.SystemClock.elapsedRealtime();
        final java.io.FileOutputStream out = new java.io.FileOutputStream(a[1]);
        c.mEventHandler = new Handler(android.os.Looper.getMainLooper()) {
            @Override public void handleMessage(android.os.Message m) {
                try { System.out.println("K4G message " + m.what + " after " + (android.os.SystemClock.elapsedRealtime() - t0) + " ms on " + Thread.currentThread().getName() + ", progress " + progress(c) + ", output " + out.getChannel().size() + " bytes"); } catch (Exception e) { }
                K4SlowMoCapture.stopCapture(c); K4SlowMoCapture.release(c); System.exit(0);
            }
        };
        int s = Integer.parseInt(a[2]), e = Integer.parseInt(a[3]); boolean fail = a.length > 4 && a[4].equals("fail");
        java.io.FileInputStream in = new java.io.FileInputStream(a[0]);
        source(c, in.getFD()); output(c, out.getFD()); parameter(c, 1011, 2); parameter(c, PARAM_CAPTURE_TYPE, TYPE_INSTANT_SLOW_MO_CLIP); startEnd(c, s, e);
        Class<?> dv = Class.forName("com.samsung.android.media.mediacapture.SemMediaCapture$DynamicViewingConfiguration");
        Object smc = Class.forName("com.samsung.android.media.mediacapture.SemMediaCapture").getDeclaredConstructor().newInstance();
        java.util.ArrayList<Object> l = new java.util.ArrayList<>(); l.add(dv.getDeclaredConstructors()[0].newInstance(smc, s, e, 0.25f));
        dynamicViewing(c, l);
        if (fail) out.close();       // the muxer cannot write -> our export fails after it has started
        System.out.println("K4G startCapture -> " + startCapture(c) + ", ours " + ours(c));
        if (a.length > 4 && !fail) c.mEventHandler.postDelayed(new Runnable() { @Override public void run() { try { System.out.println("K4G stopCapture -> " + stopCapture(c) + ", progress " + progress(c)); Thread.sleep(1500); System.out.println("K4G after cancel: output " + out.getChannel().size() + " bytes, ours " + ours(c)); } catch (Exception x) { } System.exit(0); } }, Integer.parseInt(a[4]));
        new Thread(new Runnable() { @Override public void run() { try { for (;;) { Thread.sleep(2000); System.out.println("K4G progress " + progress(c) + " ours " + ours(c)); } } catch (InterruptedException x) { } } }).start();
        c.mEventHandler.postDelayed(new Runnable() { @Override public void run() { System.out.println("K4G TIMEOUT"); System.exit(3); } }, 60000);
        android.os.Looper.loop();
    }
}
