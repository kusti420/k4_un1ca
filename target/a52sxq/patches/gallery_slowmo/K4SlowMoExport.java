// Neural "Save slow-mo clip": records the proven neural playback (SemMediaPlayer + AI FRC post generator -> MPP ->
// k4neuralmpp) of one section into an H.264 file. An off-screen SemMediaPlayer renders the section at the hold rate into
// a MediaCodec encoder's input surface; the encoded frames are written with a constant cadence.
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
    public static boolean sAudio = false;      // time-stretched audio track: not proven yet, off
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
    private MediaFormat mAudioFormat; private int mAudioTrack = -1, mAudioNext; private String mAudioNote = "no audio track yet";
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

    public K4SlowMoExport(FileDescriptor in, long inOffset, long inLength, FileDescriptor out, int startMs, int endMs, float rate, Listener l) {
        mIn = in; mInOffset = inOffset; mInLength = inLength; mOut = out; mStartMs = startMs; mEndMs = endMs; mRate = rate;
        mScale = rate <= 0.3f ? 4 : 2; mListener = l; mPositionMs = startMs;
    }

    /** 0..1 */
    public float getProgress() {
        if (mDone) return 1.0f;
        float p = Math.max((mPositionMs - mStartMs) / (float) Math.max(1, mEndMs - mStartMs), mExpected > 0 ? mWritten / (float) mExpected : 0);
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
            mWidth = vf.getInteger(MediaFormat.KEY_WIDTH); mHeight = vf.getInteger(MediaFormat.KEY_HEIGHT);
            mRotation = vf.containsKey(MediaFormat.KEY_ROTATION) ? vf.getInteger(MediaFormat.KEY_ROTATION) : 0;
            if (vf.containsKey(MediaFormat.KEY_FRAME_RATE)) mFps = Math.max(1, Math.round(vf.getNumber(MediaFormat.KEY_FRAME_RATE).floatValue()));
            if (mFps > 31 || Math.max(mWidth, mHeight) > 1920 || Math.min(mWidth, mHeight) > 1088 || mEndMs <= mStartMs) throw new IllegalStateException("unsupported source " + mWidth + "x" + mHeight + "@" + mFps);
            mFrameUs = 1000000L / mFps;
        } finally { ex.release(); }
        mPlayRate = mRate * sPlaybackFactor;
        mExpected = (int) ((long) (mEndMs - mStartMs) * mFps * mScale / 1000) + 1;
        mPreRollMs = mStartMs >= 500 ? 500 : 0;
        mSkip = (int) ((long) mPreRollMs * mFps * mScale / 1000) / mFps * mFps;      // whole key frame distances (1 s of encoder frames)
        mThread = new HandlerThread("K4SlowMoExport"); mThread.start();
        mHandler = new Handler(mThread.getLooper());
        mT0 = SystemClock.elapsedRealtime();
        mHandler.post(this);
    }

    // everything below runs on mThread (player callbacks arrive there too)
    @Override
    public void run() {
        try {
            if (mDone) return;
            if (mCancelled) { finish(false, "cancelled"); return; }
            if (!mStarted) { mStarted = true; begin(); mHandler.postDelayed(this, 5); return; }
            if (mError != null) { finish(false, mError); return; }
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
        f.setInteger(MediaFormat.KEY_BIT_RATE, (int) Math.min(24000000L, (long) (mWidth * mHeight * mFps * 0.353)));   // stock export: 720p30 at 9.8 Mbit/s
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
        if (sAudio) try { prepareAudio(); } catch (Throwable t) { mAudioFormat = null; mAudioData.clear(); mAudioInfo.clear(); mAudioNote = "audio left out: " + t; }
        mDrain = new Thread(new Runnable() { @Override public void run() { drain(); } }, "K4SlowMoExportDrain");
        mDrain.start();
        mPlayerClass = Class.forName(PLAYER);
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
            short[] out = K4TimeStretch.stretch(in, ch, rate, 1.0 / mRate);
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
            else mAudioNote = "audio " + rate + " Hz x" + ch + " stretched " + (1.0f / mRate) + "x, " + mAudioData.size() + " AAC frames";
        } finally {
            try { ex.release(); } catch (Throwable t) { }
            try { if (dec != null) { dec.stop(); dec.release(); } } catch (Throwable t) { }
            try { if (enc != null) { enc.stop(); enc.release(); } } catch (Throwable t) { }
        }
    }

    private void finish(boolean ok, String detail) {
        if (mDone) return;
        boolean stopOk = ok;
        try { if (mPlayer != null) mPlayerClass.getMethod("release").invoke(mPlayer); } catch (Throwable t) { }
        try { if (mEncoder != null) mEncoder.signalEndOfInputStream(); } catch (Throwable t) { }
        try { if (mDrain != null) mDrain.join(3000); } catch (InterruptedException e) { }
        mDone = true;
        try { if (mTrack >= 0) mMuxer.stop(); else stopOk = false; } catch (Throwable t) { stopOk = false; if (detail == null) detail = "muxer: " + t; }
        try { if (mMuxer != null) mMuxer.release(); } catch (Throwable t) { }
        try { if (mEncoder != null) { mEncoder.stop(); mEncoder.release(); } } catch (Throwable t) { }
        try { if (mSurface != null) mSurface.release(); } catch (Throwable t) { }
        int expected = (int) ((long) (mEndMs - mStartMs) * mFps * mScale / 1000);
        if (stopOk && mWritten < expected / 2) { stopOk = false; detail = "only " + mWritten + " of " + expected + " frames"; }
        Log.i(TAG, "save: neural x" + mScale + " " + mWidth + "x" + mHeight + " " + mStartMs + ".." + mEndMs + " ms -> " + mWritten + " frames (expected " + expected + ", "
                + mDropped + " before the section (" + mSkip + " pre-roll), " + mGaps + " gaps, played at " + mPlayRate + "x; " + mAudioNote + ") in " + (SystemClock.elapsedRealtime() - mT0) + " ms: " + (stopOk ? "ok" : "FAILED " + detail));
        mThread.quitSafely();
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
                new Listener() { @Override public void onFinished(K4SlowMoExport x, boolean ok, String d) { System.out.println("K4E finished ok=" + ok + " " + d + " after " + (SystemClock.elapsedRealtime() - t0) + " ms"); System.exit(ok ? 0 : 1); } });
        if (a.length > 6) sPlaybackFactor = Float.parseFloat(a[6]);
        if (a.length > 7) sAudio = a[7].equals("audio");
        e.start();
        if (a.length > 5 && Integer.parseInt(a[5]) > 0) new Handler(android.os.Looper.getMainLooper()).postDelayed(new Runnable() { @Override public void run() { System.out.println("K4E cancel"); e.cancel(); } }, Integer.parseInt(a[5]));
        new Thread(new Runnable() { @Override public void run() { try { for (;;) { Thread.sleep(1000); System.out.println("K4E progress " + e.getProgress()); } } catch (InterruptedException x) { } } }).start();
        android.os.Looper.loop();
    }
}
