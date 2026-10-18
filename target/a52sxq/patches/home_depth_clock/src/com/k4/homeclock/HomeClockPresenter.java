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
 * The engine draws its dark mode dim (DarkModeNode) over this presenter's node group; the clock and the subject are drawn
 * after it by HomeDepthClock.PostDim (see {@link #drawAbove}), the group itself holds only the background.
 * Memory: two screen-sized bitmaps instead of one.
 */
final class HomeClockPresenter extends h3.a {
    HomeClockPresenter(Context context, int which, b source) {
        super(context, which, source);
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
            int split = clockSlot(nodes, in.d, in.e);
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
            DepthClock clockNode = HomeDepthClock.makeClock(this.a, w, h, subjectTop, back, null, null);
            HomeDepthClock.setClock(this, clockNode); // also releases it if the rest of the build fails
            data.c = backNode;
            group.c.add(backNode);
            // the clock and the subject are drawn after the engine's dark mode dim (see drawAbove); this node only
            // draws them in place when that post-dim node is missing
            this.clock = clockNode;
            this.frontNode = front != null ? new i3.c(this.a, new i3.b(front, full, full, null), this.c) : null;
            group.c.add(new InPlace(this.a));
            inner.d(); // recycles the source bitmaps, as FlattenLayeredPresenter does
            Log.i(HomeDepthClock.TAG, "build: " + w + "x" + h + ", layers=" + nodes.size() + ", subjectAt=" + split
                    + ", subjectTop=" + subjectTop + ", clock=" + clockNode.getClass().getSimpleName() + ", " + (SystemClock.elapsedRealtime() - t0) + " ms");
        } catch (Throwable t) {
            // keep the stock full layer stack (no clock) rather than a broken wallpaper
            Log.e(HomeDepthClock.TAG, "build failed, showing the layers without a clock", t);
            HomeDepthClock.setClock(this, null);
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
        HomeDepthClock.setClock(this, null);
        this.f.b();
        clock = null;
        frontNode = null;
    }

    private DepthClock clock;
    private i3.c frontNode;

    /**
     * The clock, then the cut-out subject in front of it. Samsung's "Dim wallpaper when Dark mode is on" is a node
     * (DarkModeNode, f3.a.j) that draws black at alpha a over the whole layer stack; drawn from after that node, the clock
     * stays as bright as the lock screen's and the editor's clock (they are never dimmed), and the subject gets the very
     * same dim through a colour filter (rgb x (1 - a), alpha kept) so it matches the dimmed background around it.
     * dim = 0: stock look.
     */
    void drawAbove(Canvas canvas, float dim) {
        DepthClock c = clock;
        if (c != null) {
            c.a(canvas);
        }
        i3.c f = frontNode;
        if (f == null || f.c == null) {
            return;
        }
        if (dim > 0f) {
            int k = Math.round(255f * (1f - dim));
            f.c.setColorFilter(new android.graphics.LightingColorFilter(0xff000000 | k << 16 | k << 8 | k, 0));
        }
        try {
            f.a(canvas);
        } finally {
            if (dim > 0f) {
                f.c.setColorFilter(null);
            }
        }
    }

    /** Group member: draws the clock and the subject in place (under the dim) only when no post-dim node is installed. */
    private final class InPlace extends i3.j {
        InPlace(Context context) {
            super(context, "K4ClockInPlace");
        }

        @Override
        public void a(Canvas canvas) {
            if (!HomeDepthClock.postDimInstalled(HomeClockPresenter.this)) {
                drawAbove(canvas, 0f);
            }
        }
    }

    private static Bitmap create(int w, int h, Bitmap.Config config, ColorSpace cs, boolean alpha) {
        if (cs == null) {
            return Bitmap.createBitmap(w, h, config);
        }
        return Bitmap.createBitmap(w, h, config, alpha, cs);
    }

    /**
     * Where the clock goes in the layer list (every layer from there on is drawn in front of it), or -1 (on top).
     * Plain layout [background, masked]: right below the subject. Frame layouts (Wallpaper & style Frame / Suggest:
     * LayeredPresenter adds the frame layers, FrameBitmapNode i3.h, to g0.a.e in document order frame_base,
     * frame_bottom): the subject pops out of the frame [background, frame_base, masked, frame_bottom] -> below the
     * subject, which then also covers it; the subject stays inside the frame [background, masked, frame_base,
     * frame_bottom] -> above the frame plate, which would otherwise hide the clock (only frame_bottom stays in front).
     * The editor (HomeClock.SubjectView) puts the same views in front of its clock.
     */
    static int clockSlot(java.util.List<?> nodes, Object subject, Object frames) {
        int at = subject == null ? -1 : nodes.indexOf(subject);
        if (at < 0 || !(frames instanceof java.util.List) || ((java.util.List<?>) frames).isEmpty()) {
            return at;
        }
        int base = nodes.indexOf(((java.util.List<?>) frames).get(0));
        if (base > at) {
            at = base + 1;
            Log.i(HomeDepthClock.TAG, "frame layout, subject inside the frame: clock above the frame plate (layer " + at + "/" + nodes.size() + ")");
            return at < nodes.size() ? at : -1;
        }
        if (base >= 0) {
            Log.i(HomeDepthClock.TAG, "frame layout, subject out of the frame: clock below the subject (layer " + at + "/" + nodes.size() + ")");
        }
        return at;
    }

    /** Screen y of the first clearly opaque row of the cut-out subject, or -1. */
    static float subjectTop(i3.c node) {
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
