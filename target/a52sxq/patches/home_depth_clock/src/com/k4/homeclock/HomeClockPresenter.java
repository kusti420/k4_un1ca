package com.k4.homeclock;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.ColorSpace;
import android.graphics.Rect;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.SystemClock;
import android.util.Log;

import com.samsung.android.wallpaper.live.unified.engines.layered.source.b;

import java.util.ArrayList;

/**
 * Replaces FlattenLayeredPresenter (h3.d) for the home instance. Like it, it lets the full LayeredPresenter (h3.f) load
 * every layer of the document (through the wallpaper's own source, i.e. WallpaperManager asset file descriptors),
 * flattens them into screen-sized bitmaps and releases the originals. The difference: the layers are split at the
 * cut-out subject node, giving
 *   [everything below the subject] -> clock -> [subject and everything above it (frame bottom, AI watermark)].
 * Memory: two screen-sized bitmaps instead of one.
 */
final class HomeClockPresenter extends h3.a {
    final Ticker ticker;
    volatile ClockNode clock;

    HomeClockPresenter(Context context, int which, b source) {
        super(context, which, source);
        ticker = new Ticker(this);
    }

    @Override
    public void a(b source, int w, int h, g0.a data) {
        long t0 = SystemClock.elapsedRealtime();
        h3.f inner = new h3.f(this.a, this.c, source);
        inner.e(w, h);
        g0.a in = inner.e;
        i3.k group = (i3.k) data.b;
        if (in == null) {
            Log.w(HomeDepthClock.TAG, "build: no presenter data");
            inner.d();
            return;
        }
        ArrayList<?> nodes = new ArrayList<Object>(inner.f.c);
        data.a = in.a;
        data.f = in.f;
        data.g = in.g;
        try {
            int split = in.d == null ? -1 : nodes.indexOf(in.d);
            Bitmap.Config config = in.g instanceof Bitmap.Config ? (Bitmap.Config) in.g : Bitmap.Config.ARGB_8888;
            ColorSpace cs = in.f instanceof ColorSpace ? (ColorSpace) in.f : null;
            Bitmap back = create(w, h, config, cs, false);
            Bitmap front = null;
            Canvas backCanvas = new Canvas(back);
            Canvas frontCanvas = null;
            for (int i = 0; i < nodes.size(); i++) {
                i3.j node = (i3.j) nodes.get(i);
                if (split >= 0 && i >= split) {
                    if (front == null) {
                        front = create(w, h, config, cs, true);
                        frontCanvas = new Canvas(front);
                    }
                    node.a(frontCanvas);
                } else {
                    node.a(backCanvas);
                }
            }
            float subjectTop = subjectTop(in.d instanceof i3.c ? (i3.c) in.d : null);

            Rect full = new Rect(0, 0, w, h);
            i3.c backNode = new i3.c(this.a, new i3.b(back, full, full, null), this.c);
            ClockNode clockNode = new ClockNode(this.a, w, h, subjectTop, back);
            data.c = backNode;
            group.c.add(backNode);
            group.c.add(clockNode);
            if (front != null) {
                group.c.add(new i3.c(this.a, new i3.b(front, full, full, null), this.c));
            }
            clock = clockNode;
            inner.d(); // recycles the source bitmaps, as FlattenLayeredPresenter does
            Log.i(HomeDepthClock.TAG, "build: " + w + "x" + h + ", layers=" + nodes.size() + ", subjectAt=" + split
                    + ", subjectTop=" + subjectTop + ", " + (SystemClock.elapsedRealtime() - t0) + " ms");
        } catch (Throwable t) {
            // keep the stock full layer stack (no clock) rather than a broken wallpaper
            Log.e(HomeDepthClock.TAG, "build failed, showing the layers without a clock", t);
            clock = null;
            group.c.clear();
            for (Object n : nodes) {
                group.c.add(n);
            }
            data.c = in.c;
            data.d = in.d;
            data.e = in.e;
        }
    }

    @Override
    public void d() {
        clock = null;
        this.f.b();
    }

    private static Bitmap create(int w, int h, Bitmap.Config config, ColorSpace cs, boolean alpha) {
        if (cs == null) {
            return Bitmap.createBitmap(w, h, config);
        }
        return Bitmap.createBitmap(w, h, config, alpha, cs);
    }

    /** Screen y of the first clearly opaque row of the cut-out subject, or -1. */
    private static float subjectTop(i3.c node) {
        if (node == null) {
            return -1;
        }
        Drawable d = node.c;
        if (!(d instanceof BitmapDrawable)) {
            return -1;
        }
        Bitmap bm = ((BitmapDrawable) d).getBitmap();
        Rect r = d.getBounds();
        if (bm == null || bm.isRecycled() || r.isEmpty() || bm.getConfig() == Bitmap.Config.HARDWARE) {
            return -1;
        }
        int bw = bm.getWidth();
        int bh = bm.getHeight();
        int[] row = new int[bw];
        int need = Math.max(3, bw / 100);
        for (int y = 0; y < bh; y += 2) {
            bm.getPixels(row, 0, bw, 0, y, bw, 1);
            int n = 0;
            for (int x = 0; x < bw; x += 2) {
                if ((row[x] >>> 24) > 160 && ++n >= need) {
                    return r.top + (float) y * r.height() / bh;
                }
            }
        }
        return -1;
    }
}
