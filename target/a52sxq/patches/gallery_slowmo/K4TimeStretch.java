// Time-stretch of 16-bit PCM with the pitch kept (WSOLA: overlap-add of windowed frames whose positions are nudged to
// where the waveform continues best). Used for the audio of the neural slow-mo clip. Pure Java, no Android classes.
// Source of K4TimeStretch.smali (see K4SlowMo.java for how the smali is generated).
package com.k4.media;

public final class K4TimeStretch {
    private K4TimeStretch() {
    }

    /**
     * @param in       interleaved samples
     * @param channels 1 or 2
     * @param rate     sample rate in Hz
     * @param factor   output duration / input duration (4 for 0.25x)
     */
    public static short[] stretch(short[] in, int channels, int rate, double factor) {
        int n = in.length / channels;
        int win = Math.max(64, rate * 40 / 1000) & ~1, hs = win / 2, tol = rate * 12 / 1000;
        double ha = hs / factor;
        int outFrames = (int) (n * factor);
        if (n < win * 2 || outFrames < win * 2) { short[] o = new short[outFrames * channels]; for (int i = 0; i < outFrames; i++) for (int c = 0; c < channels; c++) o[i * channels + c] = in[Math.min(n - 1, (int) (i / factor)) * channels + c]; return o; }
        float[] mono = new float[n];
        for (int i = 0; i < n; i++) { int s = 0; for (int c = 0; c < channels; c++) s += in[i * channels + c]; mono[i] = s / (float) channels; }
        float[] w = new float[win];
        for (int i = 0; i < win; i++) w[i] = (float) (0.5 - 0.5 * Math.cos(2 * Math.PI * (i + 0.5) / win));
        float[] acc = new float[(outFrames + win) * channels];
        int prev = 0;                        // start of the previous frame in the input
        for (int k = 0; (long) k * hs + win <= outFrames + hs; k++) {
            int ideal = (int) Math.round(k * ha), pos = ideal;
            if (k > 0) {
                // the waveform that would follow the previous frame naturally starts at prev + hs: find it near `ideal`
                int target = prev + hs, lo = Math.max(0, ideal - tol), hi = Math.min(n - win, ideal + tol);
                if (target + win <= n && hi > lo) {
                    double best = -1e30;
                    for (int cand = lo; cand <= hi; cand += 2) {
                        double c = 0, e = 1e-3;
                        for (int i = 0; i < win; i += 4) { float a = mono[cand + i]; c += a * mono[target + i]; e += a * a; }
                        c /= Math.sqrt(e);
                        if (c > best) { best = c; pos = cand; }
                    }
                } else pos = Math.max(0, Math.min(n - win, ideal));
            }
            pos = Math.max(0, Math.min(n - win, pos));
            int o = k * hs;
            for (int i = 0; i < win && o + i < outFrames + win; i++) for (int c = 0; c < channels; c++) acc[(o + i) * channels + c] += w[i] * in[(pos + i) * channels + c];
            prev = pos;
        }
        short[] out = new short[outFrames * channels];
        for (int i = 0; i < out.length; i++) { float v = acc[i]; out[i] = (short) (v > 32767 ? 32767 : (v < -32768 ? -32768 : Math.round(v))); }
        return out;
    }

    // PC test: java com.k4.media.K4TimeStretch in.s16le channels rate factor out.s16le
    public static void main(String[] a) throws Exception {
        byte[] b = java.nio.file.Files.readAllBytes(java.nio.file.Paths.get(a[0]));
        short[] in = new short[b.length / 2];
        java.nio.ByteBuffer.wrap(b).order(java.nio.ByteOrder.LITTLE_ENDIAN).asShortBuffer().get(in);
        long t0 = System.nanoTime();
        short[] out = stretch(in, Integer.parseInt(a[1]), Integer.parseInt(a[2]), Double.parseDouble(a[3]));
        System.out.println("stretched " + in.length + " -> " + out.length + " samples in " + (System.nanoTime() - t0) / 1000000 + " ms");
        java.nio.ByteBuffer o = java.nio.ByteBuffer.allocate(out.length * 2).order(java.nio.ByteOrder.LITTLE_ENDIAN);
        o.asShortBuffer().put(out);
        java.nio.file.Files.write(java.nio.file.Paths.get(a[4]), o.array());
    }
}
