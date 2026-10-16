// Neural "Save slow-mo clip", two ways:
//  - offline (default, persist.sys.k4.slowmo_save_film != 0): the section is decoded here and every source pair goes
//    to a k4neuralmpp render session (TX_K4_RENDER: v3 + FILM on the DSP, "config A"); the frames it returns are
//    encoded from byte buffers. Not real time (~25 s per source second at x4), see renderOffline().
//  - real time (the fallback): records the proven neural playback (SemMediaPlayer + AI FRC post generator -> MPP ->
//    k4neuralmpp) of one section. An off-screen SemMediaPlayer renders the section at the hold rate into a MediaCodec
//    encoder's input surface.
// Either way the encoded frames are written with a constant cadence.
// Source of K4SlowMoExport.smali (see K4SlowMo.java for how the smali is generated, but dex the save classes WITHOUT
// "--no-desugaring": the anonymous classes call private methods of this class and need d8's nest bridges, or the
// drain thread dies with IllegalAccessError).
package com.k4.media;

import android.media.MediaCodec;
import android.media.MediaCodecInfo;
import android.media.MediaExtractor;
import android.media.MediaFormat;
import android.media.MediaMuxer;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.SystemClock;
import android.util.Log;
import android.view.Surface;
import java.io.FileDescriptor;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.nio.ByteBuffer;

public final class K4SlowMoExport implements Runnable, InvocationHandler {
    private static final String TAG = "K4SlowMo";
    private static final String PLAYER = "com.samsung.android.media.SemMediaPlayer";

    public interface Listener {
        void onFinished(K4SlowMoExport e, boolean ok, String detail);
    }

    private final FileDescriptor mIn, mOut;
    private final long mInOffset, mInLength;
    private final int mStartMs, mEndMs, mScale;
    private final float mRate;
    // The player drops frames that are late for their real-time slot; the file does not care about real time, so the
    // playback runs slower than the clip rate (same frames, more time for each).
    public static float sPlaybackFactor = 0.5f;
    // Time-stretched audio track (pitch kept): off unless persist.sys.k4.slowmo_save_audio is not 0. With it off not a
    // single audio call is made and the file is the video-only one.
    public static final String AUDIO_PROPERTY = "persist.sys.k4.slowmo_save_audio";
    public static boolean sAudio = false;      // test override (main)
    // Offline render (k4neuralmpp TX_K4_RENDER): the caller picks the mode (K4SlowMoCapture: FILM_PROPERTY, default on)
    public static final String FILM_PROPERTY = "persist.sys.k4.slowmo_save_film";
    private final boolean mOffline;
    private Thread mWorker; private volatile float mWork; private volatile boolean mStop;      // offline: the render thread, its progress (0..1), stop request
    private String mOfflineNote = "";
    private String mHandsNote = "";      // offline: second crops / FILM quarters used
    private boolean mAudio;
    private float mPlayRate;
    private final Listener mListener;
    private HandlerThread mThread;
    private Handler mHandler;
    private Object mPlayer;
    private Class<?> mPlayerClass;
    private MediaCodec mEncoder;
    private MediaMuxer mMuxer;
    private Surface mSurface;
    private Thread mDrain;
    // audio of the section: decoded, time-stretched with the pitch kept (K4TimeStretch) and encoded before the video
    // starts; written next to the video frames by time stamp
    private MediaFormat mAudioFormat; private int mAudioTrack = -1, mAudioNext; private String mAudioNote = "no audio track (" + AUDIO_PROPERTY + " is 0)";
    private final java.util.ArrayList<ByteBuffer> mAudioData = new java.util.ArrayList<>(); private final java.util.ArrayList<long[]> mAudioInfo = new java.util.ArrayList<>();
    private int mTrack = -1, mWidth, mHeight, mRotation, mFps = 30, mWritten, mDropped, mGaps;
    private long mFrcCallUs = Long.MAX_VALUE, mFirstPtsUs = -1, mLastPtsUs = -1, mFrameUs = 33333, mT0;
    private volatile int mPositionMs;
    private int mExpected;
    // The player starts mPreRollMs before the section (its first frames after a start are not evenly spaced) and the
    // first mSkip frames are not written. mSkip is a multiple of the encoder's key frame distance.
    private int mPreRollMs, mSkip; private long mPhaseAt; private volatile long mLastFrameAt; private volatile boolean mPlaying;
    private volatile boolean mCancelled, mDone, mStopping, mStarted;
    private volatile String mError;
    // Gallery's process may hold the CPU awake (it has WAKE_LOCK): the offline render takes ~20 s per source second and
    // must not stall when the screen goes off. Held from start() to finish(), with a time limit as a safety net.
    private android.os.PowerManager.WakeLock mWakeLock;

    public K4SlowMoExport(FileDescriptor in, long inOffset, long inLength, FileDescriptor out, int startMs, int endMs, float rate, Listener l) {
        this(in, inOffset, inLength, out, startMs, endMs, rate, l, false);
    }
    public K4SlowMoExport(FileDescriptor in, long inOffset, long inLength, FileDescriptor out, int startMs, int endMs, float rate, Listener l, boolean offline) {
        mOffline = offline; mIn = in; mInOffset = inOffset; mInLength = inLength; mOut = out; mStartMs = startMs; mEndMs = endMs; mRate = rate;
        mScale = rate <= 0.3f ? 4 : 2; mListener = l; mPositionMs = startMs;
    }

    public boolean isOffline() { return mOffline; }

    /** 0..1 */
    public float getProgress() {
        if (mDone) return 1.0f;
        float p = mOffline ? mWork : Math.max((mPositionMs - mStartMs) / (float) Math.max(1, mEndMs - mStartMs), mExpected > 0 ? mWritten / (float) mExpected : 0);
        return p < 0 ? 0 : (p > 0.99f ? 0.99f : p);
    }

    public void cancel() { mCancelled = true; Handler h = mHandler; if (h != null) h.post(this); }

    /** Checks the source and starts the export on its own thread; throws when this source cannot be handled. */
    public void start() throws Exception {
        MediaExtractor ex = new MediaExtractor();
        try {
            ex.setDataSource(mIn, mInOffset, mInLength);
            MediaFormat vf = null;
            for (int i = 0; i < ex.getTrackCount(); i++) {
                MediaFormat f = ex.getTrackFormat(i); String mime = f.getString(MediaFormat.KEY_MIME);
                if (mime != null && mime.startsWith("video/")) { if (!K4SlowMo.isEightBitSdr(mime, f)) throw new IllegalStateException("not an 8-bit SDR video"); vf = f; break; }
            }
            if (vf == null) throw new IllegalStateException("no video track");
            if (!K4SlowMo.isNeuralEligible(vf)) throw new IllegalStateException("the neural engine does not take this video: " + vf.getNumber(MediaFormat.KEY_WIDTH, Integer.valueOf(0))
                    + "x" + vf.getNumber(MediaFormat.KEY_HEIGHT, Integer.valueOf(0)) + " at " + (vf.containsKey(MediaFormat.KEY_FRAME_RATE) ? vf.getNumber(MediaFormat.KEY_FRAME_RATE) + " fps" : "an unknown frame rate"));
            mWidth = vf.getInteger(MediaFormat.KEY_WIDTH); mHeight = vf.getInteger(MediaFormat.KEY_HEIGHT);
            mRotation = vf.containsKey(MediaFormat.KEY_ROTATION) ? vf.getInteger(MediaFormat.KEY_ROTATION) : 0;
            if (vf.containsKey(MediaFormat.KEY_FRAME_RATE)) mFps = Math.max(1, Math.round(vf.getNumber(MediaFormat.KEY_FRAME_RATE).floatValue()));
            if (mFps > 31 || Math.max(mWidth, mHeight) > 1920 || Math.min(mWidth, mHeight) > 1088 || mEndMs <= mStartMs) throw new IllegalStateException("unsupported source " + mWidth + "x" + mHeight + "@" + mFps);
            mFrameUs = 1000000L / mFps;
        } finally { ex.release(); }
        mPlayRate = mRate * sPlaybackFactor;
        mAudio = sAudio || audioProperty();
        mExpected = (int) ((long) (mEndMs - mStartMs) * mFps * mScale / 1000) + 1;
        mPreRollMs = mStartMs >= 500 && !mOffline ? 500 : 0;
        mSkip = (int) ((long) mPreRollMs * mFps * mScale / 1000) / mFps * mFps;      // whole key frame distances (1 s of encoder frames)
        mThread = new HandlerThread("K4SlowMoExport"); mThread.start();
        mHandler = new Handler(mThread.getLooper());
        mT0 = SystemClock.elapsedRealtime();
        acquireWakeLock();
        mHandler.post(this);
    }

    private void acquireWakeLock() {
        try {
            android.content.Context c = (android.content.Context) Class.forName("android.app.ActivityThread").getMethod("currentApplication").invoke(null);
            if (c == null) return;          // app_process tests
            android.os.PowerManager pm = c.getSystemService(android.os.PowerManager.class);
            android.os.PowerManager.WakeLock wl = pm.newWakeLock(android.os.PowerManager.PARTIAL_WAKE_LOCK, "K4SlowMo:save");
            wl.setReferenceCounted(false);
            // the longer of the two paths' own limits (run()), plus a minute
            long section = Math.max(0, mEndMs - mStartMs);
            wl.acquire(60000L + Math.max(30000L + section * 120, 20000L + (long) (section / Math.max(0.01f, mPlayRate) * 3)));
            mWakeLock = wl;
        } catch (Throwable t) {
            Log.w(TAG, "save: no wake lock (" + t + "), the export may stall while the screen is off");
        }
    }

    private void releaseWakeLock() {
        android.os.PowerManager.WakeLock wl = mWakeLock; mWakeLock = null;
        if (wl != null) try { wl.release(); } catch (Throwable t) { }
    }

    // everything below runs on mThread (player callbacks arrive there too)
    @Override
    public void run() {
        try {
            if (mDone) return;
            if (mCancelled) { finish(false, "cancelled"); return; }
            if (!mStarted) { mStarted = true; if (mOffline) beginOffline(); else begin(); mHandler.postDelayed(this, 5); return; }
            if (mError != null) { finish(false, mError); return; }
            if (mOffline) {     // the render thread does the work; here only the overall limit (2 min per source second)
                if (SystemClock.elapsedRealtime() - mT0 > 30000L + (long) (mEndMs - mStartMs) * 120) finish(false, "timeout");
                else mHandler.postDelayed(this, 50);
                return;
            }
            if (SystemClock.elapsedRealtime() - mT0 > 20000L + (long) ((mEndMs - mStartMs) / mPlayRate * 3)) { finish(false, "timeout"); return; }
            long now = SystemClock.elapsedRealtime();
            if (mPlaying) {
                int pos = (Integer) mPlayerClass.getMethod("getCurrentPosition").invoke(mPlayer);
                if (pos > mPositionMs && pos <= mEndMs) mPositionMs = pos;
                if (now - mPhaseAt > 15000L + (long) ((mEndMs - mStartMs + mPreRollMs) / mPlayRate * 2)) { finish(false, "player did not reach the end of the section"); return; }
                if (now - Math.max(mPhaseAt, mLastFrameAt) > 6000) { finish(false, "no frame from the player for 6 s"); return; }
            }
            mHandler.postDelayed(this, 5);
        } catch (Throwable t) {
            finish(false, "export failed: " + t);
        }
    }

    private void begin() throws Exception {
        MediaFormat f = MediaFormat.createVideoFormat(MediaFormat.MIMETYPE_VIDEO_AVC, mWidth, mHeight);
        f.setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface);
        // Wanted in the file: the stock export's 720p30 at 9.8 Mbit/s. The encoder's rate control goes by the real time
        // between the frames it is handed (they arrive mFps * mScale * mPlayRate times per second, i.e. 15 for 30 fps
        // x4 at 0.125x) while the file plays them at mFps, so the request is scaled by that ratio. Constant bitrate:
        // in the default mode the encoder spent a sixth of the request on slow motion (1.6 Mbit/s for 720p, originals
        // down to 88 % of their detail); with CBR the file comes out at the wanted rate.
        long wanted = Math.min(24000000L, (long) (mWidth * mHeight * mFps * 0.353));
        f.setInteger(MediaFormat.KEY_BIT_RATE, (int) Math.max(1000000L, Math.min(60000000L, (long) (wanted * mScale * mPlayRate))));
        f.setInteger(MediaFormat.KEY_BITRATE_MODE, MediaCodecInfo.EncoderCapabilities.BITRATE_MODE_CBR);
        f.setInteger(MediaFormat.KEY_FRAME_RATE, mFps);
        f.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 1);
        f.setInteger(MediaFormat.KEY_PROFILE, MediaCodecInfo.CodecProfileLevel.AVCProfileHigh);
        f.setInteger(MediaFormat.KEY_LEVEL, MediaCodecInfo.CodecProfileLevel.AVCLevel41);
        mEncoder = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_VIDEO_AVC);
        mEncoder.configure(f, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE);
        mSurface = mEncoder.createInputSurface();
        mEncoder.start();
        mMuxer = new MediaMuxer(mOut, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4);
        mMuxer.setOrientationHint(mRotation);
        if (mAudio) try { prepareAudio(); } catch (Throwable t) { mAudioFormat = null; mAudioData.clear(); mAudioInfo.clear(); mAudioNote = "audio left out: " + t; }
        mDrain = new Thread(new Runnable() { @Override public void run() { drain(); } }, "K4SlowMoExportDrain");
        mDrain.start();
        mPlayerClass = Class.forName(PLAYER);
        announceSave();
        mPlayer = mPlayerClass.getDeclaredConstructor().newInstance();
        listen("OnInitCompleteListener"); listen("OnErrorListener"); listen("OnPlaybackCompleteListener");
        mPlayerClass.getMethod("setSurface", Surface.class).invoke(mPlayer, mSurface);
        mPlayerClass.getMethod("init", FileDescriptor.class, long.class, long.class).invoke(mPlayer, mIn, mInOffset, mInLength);
    }

    private void listen(String name) throws Exception {
        Class<?> l = Class.forName(PLAYER + "$" + name);
        mPlayerClass.getMethod("set" + name, l).invoke(mPlayer, Proxy.newProxyInstance(l.getClassLoader(), new Class<?>[] { l }, this));
    }

    @Override
    public Object invoke(Object proxy, Method m, Object[] args) {
        String n = m.getName();
        try {
            if (n.equals("onInitComplete")) {
                try { mPlayerClass.getMethod("setVolume", float.class, float.class).invoke(mPlayer, 0.0f, 0.0f); } catch (Throwable t) { Log.w(TAG, "export: player not muted: " + t); }
                mPlayerClass.getMethod("seekTo", int.class).invoke(mPlayer, mStartMs - mPreRollMs);
                Method frc; Object[] a = { Integer.valueOf(mScale), Float.valueOf(mRate), Boolean.FALSE };
                try { frc = mPlayerClass.getMethod("k4NativeVideoFrc", int.class, float.class, boolean.class); }
                catch (NoSuchMethodException e) { frc = mPlayerClass.getDeclaredMethod("_setVideoFrc", int.class, float.class, boolean.class); frc.setAccessible(true); }
                frc.invoke(mPlayer, a);
                if (mPlayRate != mRate) {       // same frames, but more real time for each of them
                    android.media.PlaybackParams pp = (android.media.PlaybackParams) mPlayerClass.getMethod("getPlaybackParams").invoke(mPlayer);
                    pp.setSpeed(mPlayRate);
                    mPlayerClass.getMethod("setPlaybackParams", android.media.PlaybackParams.class).invoke(mPlayer, pp);
                }
                // Started only now, so the first renderer is the interpolating one: a frame of the plain decoder path on the
                // encoder surface (other buffer format) makes the encoder fail.
                mFrcCallUs = System.nanoTime() / 1000;
                mPlayerClass.getMethod("start").invoke(mPlayer);
                mPhaseAt = SystemClock.elapsedRealtime(); mPlaying = true;
            } else if (n.equals("onError")) {
                mError = "player error " + args[1] + " " + args[2];
                return Boolean.TRUE;
            } else if (n.equals("onPlaybackComplete")) {
                mPositionMs = mEndMs; mHandler.post(new Runnable() { @Override public void run() { finish(true, null); } });
            }
        } catch (Throwable t) {
            mError = "player call failed: " + (t.getCause() != null ? t.getCause() : t);
        }
        Class<?> r = m.getReturnType();
        return r == boolean.class ? (Object) Boolean.FALSE : null;
    }

    // encoder output -> file. Frames rendered before the interpolation was requested are not part of the clip; the
    // frames keep the cadence of the source frame rate whatever their arrival times were.
    private void drain() {
        MediaCodec.BufferInfo info = new MediaCodec.BufferInfo();
        try {
            for (;;) {
                int i = mEncoder.dequeueOutputBuffer(info, 20000);
                if (i == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) { mTrack = mMuxer.addTrack(mEncoder.getOutputFormat()); if (mAudioFormat != null) mAudioTrack = mMuxer.addTrack(mAudioFormat); mMuxer.start(); continue; }
                if (i < 0) { if (mDone) break; continue; }
                ByteBuffer b = mEncoder.getOutputBuffer(i);
                boolean config = (info.flags & MediaCodec.BUFFER_FLAG_CODEC_CONFIG) != 0, key = (info.flags & MediaCodec.BUFFER_FLAG_KEY_FRAME) != 0;
                if (!config && info.size > 0 && mTrack >= 0) {
                    mLastFrameAt = SystemClock.elapsedRealtime();
                    if (mWritten >= mExpected) { /* the section is complete, the player is being stopped */ }
                    else if (info.presentationTimeUs < mFrcCallUs || mDropped < mSkip || (mWritten == 0 && !key)) mDropped++;
                    else {
                        if (mLastPtsUs >= 0 && info.presentationTimeUs - mLastPtsUs > (long) (mFrameUs * mRate / mPlayRate * 1.6f)) mGaps++;     // a frame slot without a frame
                        if (mFirstPtsUs < 0) mFirstPtsUs = info.presentationTimeUs;
                        mLastPtsUs = info.presentationTimeUs;
                        info.presentationTimeUs = mWritten * mFrameUs;
                        mMuxer.writeSampleData(mTrack, b, info); mWritten++;
                        writeAudio(mWritten * mFrameUs);
                        // the section is complete when its frames are there (the player's position is not exact while it interpolates)
                        if (mWritten == mExpected && !mStopping) { mStopping = true; mPositionMs = mEndMs; mHandler.post(new Runnable() { @Override public void run() { finish(true, null); } }); }
                    }
                }
                boolean eos = (info.flags & MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0;
                mEncoder.releaseOutputBuffer(i, false);
                if (eos) break;
            }
            writeAudio(mWritten * mFrameUs);
        } catch (Throwable t) { if (mError == null && !mDone) { mError = "encoder: " + t; Log.w(TAG, "save: encoder/muxer thread", t); } }
    }

    // Tells the neural front that the FRC pipe this player is about to open records a clip: no real-time limit, so it
    // may use its slower, sharper picture mode (k4neuralmpp TX_K4_SAVE). Without it the pipe is treated as a live hold.
    private static void announceSave() {
        try {
            android.os.IBinder b = (android.os.IBinder) Class.forName("android.os.ServiceManager").getMethod("checkService", String.class)
                    .invoke(null, "vendor.samsung.hardware.media.mpp.ISehMppStore/k4front");
            if (b == null) return;
            android.os.Parcel data = android.os.Parcel.obtain(), reply = android.os.Parcel.obtain();
            try {
                data.writeInterfaceToken("vendor.samsung.hardware.media.mpp.ISehMppStore");     // the NDK binder class checks it
                b.transact(0x4B3402, data, reply, 0);
            } finally { data.recycle(); reply.recycle(); }
        } catch (Throwable t) { Log.w(TAG, "save: could not announce the recording to the neural front: " + t); }
    }

    private static boolean audioProperty() {
        try { return (Integer) Class.forName("android.os.SystemProperties").getMethod("getInt", String.class, int.class).invoke(null, AUDIO_PROPERTY, 0) != 0; }
        catch (Throwable t) { return false; }
    }

    // Audio samples go into the file from the drain thread only (the one that writes the video), in time-stamp order,
    // each batch right after the video frame that reaches its time; the muxer has both tracks before it is started.
    private void writeAudio(long untilUs) {
        if (mAudioTrack < 0) return;
        MediaCodec.BufferInfo info = new MediaCodec.BufferInfo();
        while (mAudioNext < mAudioData.size() && mAudioInfo.get(mAudioNext)[0] <= untilUs) {
            ByteBuffer b = mAudioData.get(mAudioNext); long[] m = mAudioInfo.get(mAudioNext);
            info.set(0, b.remaining(), m[0], (int) m[1]);
            mMuxer.writeSampleData(mAudioTrack, b, info); mAudioNext++;
        }
    }

    private void prepareAudio() throws Exception {
        MediaExtractor ex = new MediaExtractor(); MediaCodec dec = null, enc = null;
        try {
            ex.setDataSource(mIn, mInOffset, mInLength);
            MediaFormat af = null;
            for (int i = 0; i < ex.getTrackCount(); i++) {
                MediaFormat f = ex.getTrackFormat(i); String mime = f.getString(MediaFormat.KEY_MIME);
                if (mime != null && mime.startsWith("audio/")) { af = f; ex.selectTrack(i); break; }
            }
            if (af == null) { mAudioNote = "no audio track in the source"; return; }
            long startUs = mStartMs * 1000L, endUs = mEndMs * 1000L;
            ex.seekTo(startUs, MediaExtractor.SEEK_TO_PREVIOUS_SYNC);
            dec = MediaCodec.createDecoderByType(af.getString(MediaFormat.KEY_MIME));
            dec.configure(af, null, null, 0); dec.start();
            int rate = af.getInteger(MediaFormat.KEY_SAMPLE_RATE), ch = af.getInteger(MediaFormat.KEY_CHANNEL_COUNT);
            java.io.ByteArrayOutputStream pcm = new java.io.ByteArrayOutputStream();
            MediaCodec.BufferInfo info = new MediaCodec.BufferInfo(); boolean inEos = false, outEos = false; long t0 = SystemClock.elapsedRealtime();
            while (!outEos && SystemClock.elapsedRealtime() - t0 < 8000) {
                if (!inEos) {
                    int i = dec.dequeueInputBuffer(5000);
                    if (i >= 0) {
                        int n = ex.readSampleData(dec.getInputBuffer(i), 0); long ts = ex.getSampleTime();
                        if (n < 0 || ts > endUs + 100000) { dec.queueInputBuffer(i, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM); inEos = true; }
                        else { dec.queueInputBuffer(i, 0, n, ts, 0); ex.advance(); }
                    }
                }
                int o = dec.dequeueOutputBuffer(info, 5000);
                if (o == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) { MediaFormat of = dec.getOutputFormat(); rate = of.getInteger(MediaFormat.KEY_SAMPLE_RATE); ch = of.getInteger(MediaFormat.KEY_CHANNEL_COUNT);
                    if (of.containsKey(MediaFormat.KEY_PCM_ENCODING) && of.getInteger(MediaFormat.KEY_PCM_ENCODING) != android.media.AudioFormat.ENCODING_PCM_16BIT) throw new IllegalStateException("PCM is not 16 bit"); }
                else if (o >= 0) {
                    if (info.size > 0) {
                        // keep the part of this buffer that lies inside the section
                        long bufUs = info.presentationTimeUs; int frames = info.size / (2 * ch);
                        int from = (int) Math.max(0, (startUs - bufUs) * rate / 1000000), to = (int) Math.min(frames, (endUs - bufUs) * rate / 1000000);
                        if (to > from) { byte[] tmp = new byte[(to - from) * 2 * ch]; ByteBuffer ob = dec.getOutputBuffer(o); ob.position(info.offset + from * 2 * ch); ob.get(tmp); pcm.write(tmp, 0, tmp.length); }
                    }
                    outEos = (info.flags & MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0;
                    dec.releaseOutputBuffer(o, false);
                }
            }
            byte[] raw = pcm.toByteArray();
            if (ch < 1 || ch > 2 || raw.length < rate * ch / 5) { mAudioNote = "audio left out: " + raw.length + " bytes of PCM, " + ch + " channels"; return; }
            short[] in = new short[raw.length / 2];
            ByteBuffer.wrap(raw).order(java.nio.ByteOrder.LITTLE_ENDIAN).asShortBuffer().get(in);
            // as long as the video that will be written: mExpected frames (one more than section / rate)
            int inFrames = in.length / ch; long outFrames = mExpected * mFrameUs * rate / 1000000L, wanted = (long) (mEndMs - mStartMs) * rate / 1000;
            // ... unless the source has less audio than the section (ends early): then the nominal factor, and silence after it
            double factor = Math.abs(inFrames - wanted) <= wanted / 50 ? outFrames / (double) inFrames : 1.0 / mRate;
            short[] out = K4TimeStretch.stretch(in, ch, rate, factor);
            MediaFormat ef = MediaFormat.createAudioFormat(MediaFormat.MIMETYPE_AUDIO_AAC, rate, ch);
            ef.setInteger(MediaFormat.KEY_AAC_PROFILE, MediaCodecInfo.CodecProfileLevel.AACObjectLC);
            ef.setInteger(MediaFormat.KEY_BIT_RATE, 64000 * ch);
            ef.setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, 16384);
            enc = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_AUDIO_AAC);
            enc.configure(ef, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE); enc.start();
            int pos = 0, total = out.length; inEos = false; outEos = false; t0 = SystemClock.elapsedRealtime();
            while (!outEos && SystemClock.elapsedRealtime() - t0 < 15000) {
                if (!inEos) {
                    int i = enc.dequeueInputBuffer(5000);
                    if (i >= 0) {
                        ByteBuffer ib = enc.getInputBuffer(i); ib.clear();
                        int n = Math.min((total - pos), Math.min(ib.capacity() / 2, 1024 * ch * 4)) / ch * ch;
                        long ts = (long) (pos / ch) * 1000000L / rate;
                        ib.order(java.nio.ByteOrder.LITTLE_ENDIAN).asShortBuffer().put(out, pos, n); pos += n;
                        inEos = pos >= total;
                        enc.queueInputBuffer(i, 0, n * 2, ts, inEos ? MediaCodec.BUFFER_FLAG_END_OF_STREAM : 0);
                    }
                }
                int o = enc.dequeueOutputBuffer(info, 5000);
                if (o == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) mAudioFormat = enc.getOutputFormat();
                else if (o >= 0) {
                    if (info.size > 0 && (info.flags & MediaCodec.BUFFER_FLAG_CODEC_CONFIG) == 0) {
                        ByteBuffer ob = enc.getOutputBuffer(o); ob.position(info.offset); ob.limit(info.offset + info.size);
                        ByteBuffer copy = ByteBuffer.allocate(info.size); copy.put(ob); copy.flip();
                        mAudioData.add(copy); mAudioInfo.add(new long[] { info.presentationTimeUs, info.flags & MediaCodec.BUFFER_FLAG_KEY_FRAME });
                    }
                    outEos = (info.flags & MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0;
                    enc.releaseOutputBuffer(o, false);
                }
            }
            if (mAudioFormat == null || mAudioData.isEmpty()) { mAudioFormat = null; mAudioData.clear(); mAudioInfo.clear(); mAudioNote = "audio left out: encoder gave nothing"; }
            else mAudioNote = "audio " + rate + " Hz x" + ch + ", " + inFrames * 1000L / rate + " ms stretched to " + out.length / ch * 1000L / rate + " ms, " + mAudioData.size() + " AAC frames";
        } finally {
            try { ex.release(); } catch (Throwable t) { }
            try { if (dec != null) { dec.stop(); dec.release(); } } catch (Throwable t) { }
            try { if (enc != null) { enc.stop(); enc.release(); } } catch (Throwable t) { }
        }
    }


    // ---------------------------------------------------------------------------------------------------------------
    // Offline render (config A). Pass 1 decodes the section and asks the render session for every pair's crop score
    // and the repeated-frame measure; the pair list (repeat bridging as k4n.h k4n_seq_step) and the crop centres
    // (median of 5 then mean of 3 over the pairs, as quality/mid_ground.py) are fixed then; pass 2 decodes again and
    // renders pair by pair. Shared memory: SLOTS tight NV12 frames, 0..3 = source frames (index % 4), 4.. = output.
    private static final String RENDER = "com.k4.neural.IRender";
    private static final int TX_K4_RENDER = 0x4B3403, SLOTS = 12, OUT0 = 4;
    private static final float REPEAT_MAD = 0.15f;      // k4n.h K4N_REPEAT_MAD
    private static final int CROP = 256;                // k4n.h K4N_FILM_CS

    private void beginOffline() throws Exception {
        MediaFormat f = MediaFormat.createVideoFormat(MediaFormat.MIMETYPE_VIDEO_AVC, mWidth, mHeight);
        f.setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Flexible);
        // the same file as the real-time path (CBR, ~9.8 Mbit/s at 720p30); the frames are handed over at the file's own cadence
        f.setInteger(MediaFormat.KEY_BIT_RATE, (int) Math.max(1000000L, Math.min(24000000L, (long) (mWidth * mHeight * mFps * 0.353))));
        f.setInteger(MediaFormat.KEY_BITRATE_MODE, MediaCodecInfo.EncoderCapabilities.BITRATE_MODE_CBR);
        f.setInteger(MediaFormat.KEY_FRAME_RATE, mFps);
        f.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 1);
        f.setInteger(MediaFormat.KEY_PROFILE, MediaCodecInfo.CodecProfileLevel.AVCProfileHigh);
        f.setInteger(MediaFormat.KEY_LEVEL, MediaCodecInfo.CodecProfileLevel.AVCLevel41);
        mEncoder = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_VIDEO_AVC);
        mEncoder.configure(f, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE);
        mEncoder.start();
        mMuxer = new MediaMuxer(mOut, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4);
        mMuxer.setOrientationHint(mRotation);
        mFrcCallUs = 0;       // drain(): every frame counts (mExpected: the nominal count until pass 1 knows the real one)
        mDrain = new Thread(new Runnable() { @Override public void run() { drain(); } }, "K4SlowMoExportDrain");
        mDrain.start();
        mWorker = new Thread(new Runnable() { @Override public void run() { renderOffline(); } }, "K4SlowMoExportRender");
        mWorker.start();
    }

    private void renderOffline() {
        android.os.IBinder ses = null; android.os.SharedMemory shm = null;
        try {
            final int fsz = mWidth * mHeight * 3 / 2;
            shm = android.os.SharedMemory.create("k4render", fsz * SLOTS);
            final ByteBuffer mem = shm.mapReadWrite();
            ses = openSession(shm);
            long t0 = SystemClock.elapsedRealtime();
            // pass 1: pair scores, repeated frames
            final java.util.HashMap<Long, float[]> score = new java.util.HashMap<>();
            final java.util.ArrayList<Float> diff = new java.util.ArrayList<>();      // diff.get(i): frame i against frame i - 1
            final android.os.IBinder fs = ses;
            final int n = decodeSection(mem, fsz, new FrameSink() { @Override public void frame(int i) throws Exception {
                if (i == 0) { diff.add(1e9f); return; }
                float[] r = scorePair(fs, i - 1, i); score.put(key(i - 1, i), r); diff.add(r[3]);
                if (i >= 2 && diff.get(i - 1) < REPEAT_MAD) score.put(key(i - 2, i), scorePair(fs, i - 2, i));     // a bridge may be needed
                mWork = 0.1f * Math.min(1f, (float) i / Math.max(1, mFps * (mEndMs - mStartMs) / 1000));
            } });
            if (n < 2) throw new IllegalStateException("section has " + n + " frames");
            long t1 = SystemClock.elapsedRealtime();
            // the pair list: k4n_seq_step with dedup (persist.sys.k4.slowmo_dedup, default on) - an isolated repeated frame is bridged
            boolean dedup = intProperty("persist.sys.k4.slowmo_dedup", 1) != 0;
            final java.util.ArrayList<int[]> jobs = new java.util.ArrayList<>();     // {a, b, bridge}
            boolean pend = false; int run = 0;
            for (int j = 1; j < n; j++) {
                boolean rep = diff.get(j) < REPEAT_MAD, last = j == n - 1;
                if (pend) { pend = false;
                    if (rep) { run = 2; jobs.add(new int[] { j - 2, j - 1, 0 }); jobs.add(new int[] { j - 1, j, 0 }); }
                    else { run = 0; jobs.add(new int[] { j - 2, j, 1 }); }
                    continue; }
                if (dedup && rep && run == 0 && !last) { pend = true; continue; }
                run = rep ? run + 1 : 0; jobs.add(new int[] { j - 1, j, 0 });
            }
            // crop centres smoothed over the pairs (median of 5, then mean of 3), boxes clamped into the frame, even
            int m = jobs.size(); float[] cx = new float[m], cy = new float[m]; int expected = 1;
            for (int k = 0; k < m; k++) { float[] r = score.get(key(jobs.get(k)[0], jobs.get(k)[1])); cx[k] = r[1]; cy[k] = r[2]; expected += jobs.get(k)[2] != 0 ? 2 * mScale : mScale; }
            cx = mean3(median5(cx)); cy = mean3(median5(cy));
            final int[] x0 = new int[m], y0 = new int[m];
            for (int k = 0; k < m; k++) { x0[k] = (int) Math.min(Math.max(cx[k] - CROP / 2f, 0), mWidth - CROP) & ~1; y0[k] = (int) Math.min(Math.max(cy[k] - CROP / 2f, 0), mHeight - CROP) & ~1; }
            // hands (persist.sys.k4.slowmo_save_hands; quality/hands3.py + hands4_*.py, 9.3.40 phone test): 1 (default) = a second
            // FILM crop only where a second region moves like a busy main region (>= the section's 75th percentile and >= half the
            // first); 2 = also FILM at t = .25 / .75 inside the crop(s) for the fastest quarter of the pairs at x4 - measured on the
            // reference section: +46 % save time for frames that differ from config A by < 0.5 levels (v3 already agrees there),
            // so it is opt-in. The first crop is kept >= 48 px around the strongest motion in the daemon (k4n_render_score2).
            final int hands = intProperty("persist.sys.k4.slowmo_save_hands", 1);
            final boolean[] two = new boolean[m], quart = new boolean[m]; final int[] x1 = new int[m], y1 = new int[m];
            int twoN = 0, quartN = 0;
            if (hands > 0 && m > 0) {
                float[] s1 = new float[m]; for (int k = 0; k < m; k++) s1[k] = score.get(key(jobs.get(k)[0], jobs.get(k)[1]))[0];
                float[] srt = s1.clone(); java.util.Arrays.sort(srt); float p75 = srt[Math.min(m - 1, (3 * m) / 4)];
                for (int k = 0; k < m; k++) {
                    float[] r = score.get(key(jobs.get(k)[0], jobs.get(k)[1]));
                    two[k] = r.length > 6 && r[0] > 0 && r[4] >= 0.5f * r[0] && r[4] >= p75;
                    quart[k] = hands >= 2 && mScale == 4 && jobs.get(k)[2] == 0 && s1[k] >= p75 && s1[k] > 0;
                    if (two[k]) { twoN++; x1[k] = (int) Math.min(Math.max(r[5] - CROP / 2f, 0), mWidth - CROP) & ~1; y1[k] = (int) Math.min(Math.max(r[6] - CROP / 2f, 0), mHeight - CROP) & ~1; }
                    if (quart[k]) quartN++;
                }
            }
            mHandsNote = "hands " + hands + ": " + twoN + " second crops, " + quartN + " pairs with FILM quarters";
            mExpected = expected;
            // audio stretched to the real frame count (the muxer takes its format at the encoder's first output, after this)
            if (mAudio) try { prepareAudio(); } catch (Throwable t) { mAudioFormat = null; mAudioData.clear(); mAudioInfo.clear(); mAudioNote = "audio left out: " + t; }
            // pass 2: render and encode, in order: source frame a, the generated frames, ...; at the end the last source frame
            final double[] ms = new double[3]; final int[] next = { 0 }, films = { 0 };
            int n2 = decodeSection(mem, fsz, new FrameSink() { @Override public void frame(int i) throws Exception {
                while (next[0] < jobs.size() && jobs.get(next[0])[1] == i) {
                    int k = next[0]++; int[] jb = jobs.get(k); int steps = jb[2] != 0 ? 2 * mScale : mScale;
                    float[] ts = new float[steps - 1]; for (int q = 1; q < steps; q++) ts[q - 1] = (float) q / steps;
                    encodeFrame(mem, (jb[0] % 4) * fsz);
                    int rc = renderPair(fs, jb[0] % 4, jb[1] % 4, x0[k], y0[k], x1[k], y1[k], two[k], quart[k], ts, ms);
                    if (rc == -2) throw new IllegalStateException("FILM failed at frames " + jb[0] + "-" + jb[1]);
                    films[0]++;
                    for (int q = 0; q < ts.length; q++) encodeFrame(mem, (OUT0 + q) * fsz);
                    mWork = 0.1f + 0.9f * next[0] / jobs.size();
                }
                if (i == n - 1) encodeFrame(mem, (i % 4) * fsz);
            } });
            if (n2 != n || next[0] != jobs.size()) throw new IllegalStateException("pass 2 decoded " + next[0] + " of " + jobs.size() + " pairs, " + n2 + " of " + n + " frames");
            int i = dequeueInput(); mEncoder.queueInputBuffer(i, 0, 0, (long) mQueued * mFrameUs, MediaCodec.BUFFER_FLAG_END_OF_STREAM);
            mOfflineNote = n + " source frames, " + jobs.size() + " pairs (" + films[0] + " with FILM; " + mHandsNote + "), pass 1 " + (t1 - t0) + " ms, pass 2 " + (SystemClock.elapsedRealtime() - t1)
                    + " ms (v3 " + (int) ms[0] + ", FILM " + (int) ms[1] + ", warps " + (int) ms[2] + " ms)";
        } catch (Throwable t) {
            if (!mStop && mError == null) mError = "offline render: " + t;
        } finally {
            if (ses != null) try { call(ses, 3, req()).recycle(); } catch (Throwable t) { }
            if (shm != null) shm.close();
        }
    }

    private static long key(int a, int b) { return ((long) a << 32) | b; }
    private static float[] median5(float[] v) {        // np.median over v[i-2 .. i+2] (clipped at the ends)
        float[] o = new float[v.length];
        for (int i = 0; i < v.length; i++) { int a = Math.max(0, i - 2), b = Math.min(v.length, i + 3); float[] w = java.util.Arrays.copyOfRange(v, a, b); java.util.Arrays.sort(w);
            o[i] = w.length % 2 == 1 ? w[w.length / 2] : (w[w.length / 2 - 1] + w[w.length / 2]) / 2; }
        return o;
    }
    private static float[] mean3(float[] v) {
        float[] o = new float[v.length];
        for (int i = 0; i < v.length; i++) { int a = Math.max(0, i - 1), b = Math.min(v.length, i + 2); float s = 0; for (int k = a; k < b; k++) s += v[k]; o[i] = s / (b - a); }
        return o;
    }
    private static int intProperty(String name, int def) {
        try { return (Integer) Class.forName("android.os.SystemProperties").getMethod("getInt", String.class, int.class).invoke(null, name, def); } catch (Throwable t) { return def; }
    }

    // render session calls (k4neuralmpp ren_tx)
    private android.os.IBinder openSession(android.os.SharedMemory shm) throws Exception {
        android.os.IBinder b = (android.os.IBinder) Class.forName("android.os.ServiceManager").getMethod("checkService", String.class)
                .invoke(null, System.getenv("K4E_SERVICE") != null ? System.getenv("K4E_SERVICE") : "vendor.samsung.hardware.media.mpp.ISehMppStore/k4front");     // env: tests only
        if (b == null) throw new IllegalStateException("no neural service");
        android.os.Parcel t = android.os.Parcel.obtain(), data = android.os.Parcel.obtain(), reply = android.os.Parcel.obtain();
        try {
            shm.writeToParcel(t, 0); t.setDataPosition(0);
            android.os.ParcelFileDescriptor pfd = t.readFileDescriptor();       // the region's descriptor (public API)
            data.writeInterfaceToken("vendor.samsung.hardware.media.mpp.ISehMppStore");
            data.writeInt(1); data.writeInt(mWidth); data.writeInt(mHeight); data.writeInt(SLOTS);
            data.writeTypedObject(pfd, 0); pfd.close();
            if (!b.transact(TX_K4_RENDER, data, reply, 0)) throw new IllegalStateException("render session: transaction failed");
            reply.readException();
            android.os.IBinder s = reply.readStrongBinder();
            if (s == null) throw new IllegalStateException("render session: no session");
            return s;
        } finally { t.recycle(); data.recycle(); reply.recycle(); }
    }
    private static android.os.Parcel call(android.os.IBinder s, int code, android.os.Parcel data) throws Exception {
        android.os.Parcel reply = android.os.Parcel.obtain();
        try { if (!s.transact(code, data, reply, 0)) throw new IllegalStateException("render call " + code + " failed"); reply.readException(); return reply; }
        catch (Exception e) { reply.recycle(); throw e; }
        finally { data.recycle(); }
    }
    private static android.os.Parcel req() { android.os.Parcel d = android.os.Parcel.obtain(); d.writeInterfaceToken(RENDER); return d; }
    private static float[] scorePair(android.os.IBinder s, int a, int b) throws Exception {
        android.os.Parcel d = req(); d.writeInt(a % 4); d.writeInt(b % 4);
        android.os.Parcel r = call(s, 1, d);
        try { if (r.readInt() != 0) throw new IllegalStateException("v3 failed"); return new float[] { r.readFloat(), r.readFloat(), r.readFloat(), r.readFloat(), r.readFloat(), r.readFloat(), r.readFloat() }; }
        finally { r.recycle(); }
    }
    private static int renderPair(android.os.IBinder s, int a, int b, int x0, int y0, int x1, int y1, boolean film2, boolean quarters, float[] ts, double[] ms) throws Exception {
        android.os.Parcel d = req(); d.writeInt(a); d.writeInt(b); d.writeInt(1); d.writeInt(x0); d.writeInt(y0); d.writeInt(ts.length);
        for (float t : ts) d.writeFloat(t);
        d.writeInt(OUT0);
        d.writeInt(film2 ? 1 : 0); d.writeInt(x1); d.writeInt(y1); d.writeInt(quarters ? 1 : 0);     // hands save (k4neuralmpp RENDER optional tail)
        android.os.Parcel r = call(s, 2, d);
        try { int rc = r.readInt(); for (int i = 0; i < 3; i++) ms[i] += r.readDouble(); if (rc == -1) throw new IllegalStateException("v3 failed"); return rc; }
        finally { r.recycle(); }
    }

    // decoder: the section's frames (time stamps startMs..endMs) as tight NV12 into slot (index % 4); returns the count
    private interface FrameSink { void frame(int index) throws Exception; }
    private int decodeSection(ByteBuffer mem, int fsz, FrameSink sink) throws Exception {
        MediaExtractor ex = new MediaExtractor(); MediaCodec dec = null; int count = 0;
        try {
            ex.setDataSource(mIn, mInOffset, mInLength);
            MediaFormat vf = null;
            for (int i = 0; i < ex.getTrackCount(); i++) { MediaFormat f = ex.getTrackFormat(i); String mime = f.getString(MediaFormat.KEY_MIME); if (mime != null && mime.startsWith("video/")) { vf = f; ex.selectTrack(i); break; } }
            if (vf == null) throw new IllegalStateException("no video track");
            long startUs = mStartMs * 1000L - 500, endUs = mEndMs * 1000L + 500;
            ex.seekTo(mStartMs * 1000L, MediaExtractor.SEEK_TO_PREVIOUS_SYNC);
            dec = MediaCodec.createDecoderByType(vf.getString(MediaFormat.KEY_MIME));
            vf.setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Flexible);
            dec.configure(vf, null, null, 0); dec.start();
            MediaCodec.BufferInfo info = new MediaCodec.BufferInfo(); boolean inEos = false;
            for (;;) {
                if (mStop || mCancelled) throw new IllegalStateException("stopped");
                if (!inEos) {
                    int i = dec.dequeueInputBuffer(5000);
                    if (i >= 0) {
                        int sz = ex.readSampleData(dec.getInputBuffer(i), 0); long ts = ex.getSampleTime();
                        if (sz < 0 || ts > endUs + 1000000) { dec.queueInputBuffer(i, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM); inEos = true; }
                        else { dec.queueInputBuffer(i, 0, sz, ts, 0); ex.advance(); }
                    }
                }
                int o = dec.dequeueOutputBuffer(info, 5000);
                if (o < 0) continue;
                boolean eos = (info.flags & MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0;
                if (info.size > 0 && info.presentationTimeUs >= startUs && info.presentationTimeUs <= endUs) {
                    android.media.Image img = dec.getOutputImage(o);
                    toNv12(img, mem, (count % 4) * fsz); img.close();
                    sink.frame(count++);
                }
                dec.releaseOutputBuffer(o, false);
                if (eos || info.presentationTimeUs > endUs) break;
            }
        } finally {
            try { ex.release(); } catch (Throwable t) { }
            try { if (dec != null) { dec.stop(); dec.release(); } } catch (Throwable t) { }
        }
        return count;
    }
    private void toNv12(android.media.Image img, ByteBuffer mem, int off) {
        android.media.Image.Plane[] p = img.getPlanes(); int w = mWidth, h = mHeight; byte[] row = new byte[w];
        ByteBuffer y = p[0].getBuffer(); int ys = p[0].getRowStride();
        for (int r = 0; r < h; r++) { y.position(r * ys); y.get(row, 0, w); mem.position(off + r * w); mem.put(row, 0, w); }
        ByteBuffer u = p[1].getBuffer(), v = p[2].getBuffer(); int us = p[1].getRowStride(), up = p[1].getPixelStride(), vs = p[2].getRowStride(), vp = p[2].getPixelStride();
        int base = off + w * h;
        for (int r = 0; r < h / 2; r++) for (int c = 0; c < w / 2; c++) { mem.put(base + r * w + 2 * c, u.get(r * us + c * up)); mem.put(base + r * w + 2 * c + 1, v.get(r * vs + c * vp)); }
    }

    // encoder input: one tight NV12 frame from the shared region, at the file's cadence
    private int mQueued;
    private int dequeueInput() {
        for (;;) { if (mStop || mCancelled) throw new IllegalStateException("stopped"); int i = mEncoder.dequeueInputBuffer(10000); if (i >= 0) return i; }
    }
    private void encodeFrame(ByteBuffer mem, int off) {
        int i = dequeueInput(); android.media.Image img = mEncoder.getInputImage(i);
        if (img == null) throw new IllegalStateException("encoder gives no input image");
        android.media.Image.Plane[] p = img.getPlanes(); int w = mWidth, h = mHeight; byte[] row = new byte[w];
        ByteBuffer y = p[0].getBuffer(); int ys = p[0].getRowStride();
        for (int r = 0; r < h; r++) { mem.position(off + r * w); mem.get(row, 0, w); y.position(r * ys); y.put(row, 0, w); }
        ByteBuffer u = p[1].getBuffer(), v = p[2].getBuffer(); int us = p[1].getRowStride(), up = p[1].getPixelStride(), vs = p[2].getRowStride(), vp = p[2].getPixelStride();
        int base = off + w * h;
        for (int r = 0; r < h / 2; r++) for (int c = 0; c < w / 2; c++) { u.put(r * us + c * up, mem.get(base + r * w + 2 * c)); v.put(r * vs + c * vp, mem.get(base + r * w + 2 * c + 1)); }
        mEncoder.queueInputBuffer(i, 0, w * h * 3 / 2, (long) mQueued++ * mFrameUs, 0);
    }

    private void finish(boolean ok, String detail) {
        if (mDone) return;
        boolean stopOk = ok;
        try { if (mPlayer != null) mPlayerClass.getMethod("release").invoke(mPlayer); } catch (Throwable t) { }
        if (mWorker != null && Thread.currentThread() != mWorker) { if (!ok) mStop = true; try { mWorker.join(5000); } catch (InterruptedException e) { } }
        try { if (mEncoder != null) mEncoder.signalEndOfInputStream(); } catch (Throwable t) { }
        try { if (mDrain != null) mDrain.join(3000); } catch (InterruptedException e) { }
        mDone = true;
        try { if (mTrack >= 0) mMuxer.stop(); else stopOk = false; } catch (Throwable t) { stopOk = false; if (detail == null) detail = "muxer: " + t; }
        try { if (mMuxer != null) mMuxer.release(); } catch (Throwable t) { }
        try { if (mEncoder != null) { mEncoder.stop(); mEncoder.release(); } } catch (Throwable t) { }
        try { if (mSurface != null) mSurface.release(); } catch (Throwable t) { }
        int expected = mOffline ? mExpected : (int) ((long) (mEndMs - mStartMs) * mFps * mScale / 1000);
        if (stopOk && mWritten < expected / 2) { stopOk = false; detail = "only " + mWritten + " of " + expected + " frames"; }
        Log.i(TAG, "save: neural x" + mScale + " " + mWidth + "x" + mHeight + " " + mStartMs + ".." + mEndMs + " ms -> " + mWritten + " frames (expected " + expected + ", "
                + mDropped + " before the section (" + mSkip + " pre-roll), " + mGaps + " gaps, " + (mOffline ? "offline: " + mOfflineNote : "played at " + mPlayRate + "x") + "; " + mAudioNote + ") in " + (SystemClock.elapsedRealtime() - mT0) + " ms: " + (stopOk ? "ok" : "FAILED " + detail));
        mThread.quitSafely();
        releaseWakeLock();
        if (mListener != null) mListener.onFinished(this, stopOk, detail);
    }

    private static Object sKeep;

    // test: app_process /system/bin com.k4.media.K4SlowMoExport in.mp4 out.mp4 startMs endMs [rate] [cancel after ms]
    public static void main(String[] a) throws Exception {
        android.os.Looper.prepareMainLooper();
        java.io.FileInputStream in = new java.io.FileInputStream(a[0]); java.io.FileOutputStream out = new java.io.FileOutputStream(a[1]);     // write-only, like Gallery
        sKeep = new Object[] { in, out };         // the streams own the descriptors: keep them from being finalized
        final long t0 = SystemClock.elapsedRealtime();
        final K4SlowMoExport e = new K4SlowMoExport(in.getFD(), 0, 0x7ffffffffffffffL, out.getFD(), Integer.parseInt(a[2]), Integer.parseInt(a[3]), a.length > 4 ? Float.parseFloat(a[4]) : 0.25f,
                new Listener() { @Override public void onFinished(K4SlowMoExport x, boolean ok, String d) { System.out.println("K4E finished ok=" + ok + " " + d + " after " + (SystemClock.elapsedRealtime() - t0) + " ms"); System.exit(ok ? 0 : 1); } },
                System.getenv("K4E_OFFLINE") != null);      // K4E_OFFLINE=1: the offline render (needs a render-capable k4front)
        if (a.length > 6) sPlaybackFactor = Float.parseFloat(a[6]);
        if (a.length > 7) sAudio = a[7].equals("audio");
        e.start();
        if (a.length > 5 && Integer.parseInt(a[5]) > 0) new Handler(android.os.Looper.getMainLooper()).postDelayed(new Runnable() { @Override public void run() { System.out.println("K4E cancel"); e.cancel(); } }, Integer.parseInt(a[5]));
        new Thread(new Runnable() { @Override public void run() { try { for (;;) { Thread.sleep(1000); System.out.println("K4E progress " + e.getProgress()); } } catch (InterruptedException x) { } } }).start();
        android.os.Looper.loop();
    }
}
