package com.k4.soundtrigger;

import android.hardware.soundtrigger.ConversionUtil;
import android.media.soundtrigger.PhraseSoundModel;
import android.media.soundtrigger.SoundModel;
import android.os.ParcelFileDescriptor;
import android.os.SystemProperties;
import android.util.Slog;

import com.android.server.soundtrigger_middleware.RecoverableException;

import java.io.File;
import java.io.FileInputStream;
import java.security.MessageDigest;

/**
 * Called first in SoundTriggerModule$Session.loadPhraseModel (patches/bixby_wakeup_guard).
 *
 * Samsung voice wake-up (vendor UUID a1757552-af10-11e7-985a-a3754010baa2, the "Samsung uuid" entry of the A52s
 * sound_trigger_platform_info.xml) sends a keyword model straight from the Bixby Wakeup app's assets
 * (kwdModel/<mode>/<locale>/<keyword>_<mode>_<locale>.bin) to the ADSP. The S26 Ultra app's models are a newer
 * revision: the A52s ADSP firmware faults in its LPI voice module on them (err_qdi.c audio_process LPro00dyn) and the
 * SoC resets; the app reloads the model about a minute after every boot, so one enrolment used to end in a boot loop.
 *
 * /system/etc/k4wakeup/<bitrate>/<ll_cc>/ holds the A52s stock app's DSP network + grammar files (see a52sModel). The model being loaded is
 * identified by finding the asset with the same bytes in the installed Bixby Wakeup app (the Galaxy Store update or
 * the system copy) and swapped for the A52s model of the same name; anything without an A52s counterpart is refused,
 * so the ADSP only ever sees models its firmware shipped with.
 * persist.sys.k4.samsung_wakeup: unset/0/3 = A52s model swap (default; 9.3.36 test: loads, recognition starts, no
 * ADSP fault), 2 = refuse every Samsung model (kill switch), 1 = pass models through unchanged (debugging only: resets the SoC).
 */
public final class K4WakeupGuard {
    private static final String TAG = "K4WakeupGuard";
    private static final String SAMSUNG_UUID = "a1757552-af10-11e7-985a-a3754010baa2";
    private static final String MODEL_DIR = "/system/etc/k4wakeup/";
    private static final String APP = "com.samsung.android.bixby.wakeup";
    private static final String ASSETS = "assets/kwdModel/";
    private static final java.util.HashMap<String, String> sNames = new java.util.HashMap<>();

    private K4WakeupGuard() {}

    public static void check(PhraseSoundModel model) {
        if (model == null || model.common == null) return;
        SoundModel common = model.common;
        if (!SAMSUNG_UUID.equalsIgnoreCase(common.vendorUuid)) return;
        int mode = SystemProperties.getInt("persist.sys.k4.samsung_wakeup", 0);
        if (mode == 1) {
            Slog.w(TAG, "passing a Samsung voice wake-up model through unchanged (persist.sys.k4.samsung_wakeup=1)");
            return;
        }
        if (mode == 2) {
            Slog.w(TAG, "refusing every Samsung voice wake-up model (persist.sys.k4.samsung_wakeup=2)");
            throw new RecoverableException(2 /* Status.UNSUPPORTED */, "Samsung voice wake-up is turned off");
        }
        String hash = null, name = null;
        byte[] replacement = null;
        try {
            byte[] data = ConversionUtil.sharedMemoryToByteArray(common.data.dup(), common.dataSize);
            hash = sha256(data);
            name = modelName(hash, data.length);
            if (name != null) replacement = a52sModel(name);
        } catch (Throwable t) {
            Slog.e(TAG, "cannot read the Samsung voice wake-up model", t);
        }
        if (replacement == null) {
            Slog.w(TAG, "refusing Samsung voice wake-up model " + (name != null ? name : hash) + " (" + common.dataSize
                    + " bytes): no A52s counterpart, the ADSP firmware may crash on it");
            throw new RecoverableException(2 /* Status.UNSUPPORTED */,
                    "This Samsung voice wake-up model is not supported on this device");
        }
        ParcelFileDescriptor old = common.data;
        common.data = ConversionUtil.byteArrayToSharedMemory(replacement, "K4WakeupModel");
        common.dataSize = replacement.length;
        try {
            if (old != null) old.close();
        } catch (Throwable ignored) {
        }
        Slog.i(TAG, "Samsung voice wake-up model " + name + " -> A52s model (" + replacement.length + " bytes)");
    }

    /**
     * The A52s stock app's DSP model for the same keyword and language: on firmware type 1 (A52s) it sends
     * [int netSize][wakeupmodel/<bitrate>/<ll_cc>/hibixby_dsp_net_<ll_cc>.bin][int gramSize][..._grammar_...bin]
     * (native byte order, DspEnrollmentUtil); the S26 Ultra app sends a single kwdModel/<mode>/<llCC>/<kw>_<mode>_<llCC>.bin.
     * Only "Hi Bixby" exists for the A52s DSP.
     */
    private static byte[] a52sModel(String name) throws Exception {
        String[] parts = name.split("/");
        if (parts.length != 3 || !parts[2].startsWith("hibixby_") || parts[1].length() != 4) return null;
        String loc = parts[1].substring(0, 2).toLowerCase(java.util.Locale.US) + "_"
                + parts[1].substring(2).toLowerCase(java.util.Locale.US);
        String bits = SystemProperties.get("persist.sys.k4.wakeup_dsp_bits", "32bit");
        File net = new File(MODEL_DIR + bits + "/" + loc + "/hibixby_dsp_net_" + loc + ".bin");
        File gram = new File(MODEL_DIR + bits + "/" + loc + "/hibixby_dsp_grammar_" + loc + ".bin");
        if (!net.isFile() || !gram.isFile()) return null;
        byte[] n = readFile(net), g = readFile(gram);
        java.nio.ByteBuffer b = java.nio.ByteBuffer.allocate(8 + n.length + g.length).order(java.nio.ByteOrder.nativeOrder());
        b.putInt(n.length).put(n).putInt(g.length).put(g);
        return b.array();
    }

    /** Path under kwdModel/ of the installed app's asset with these bytes, or null. */
    private static synchronized String modelName(String hash, int size) throws Exception {
        if (sNames.containsKey(hash)) return sNames.get(hash);
        String found = null;
        for (File apk : appApks()) {
            try (java.util.zip.ZipFile z = new java.util.zip.ZipFile(apk)) {
                java.util.Enumeration<? extends java.util.zip.ZipEntry> en = z.entries();
                while (found == null && en.hasMoreElements()) {
                    java.util.zip.ZipEntry e = en.nextElement();
                    String n = e.getName();
                    if (!n.startsWith(ASSETS) || !n.endsWith(".bin") || e.getSize() != size) continue;
                    try (java.io.InputStream in = z.getInputStream(e)) {
                        if (hash.equals(sha256(in.readAllBytes()))) found = n.substring(ASSETS.length());
                    }
                }
            } catch (Throwable t) {
                Slog.w(TAG, "cannot read " + apk + ": " + t);
            }
            if (found != null) break;
        }
        sNames.put(hash, found);
        return found;
    }

    /** The Galaxy Store copy (/data/app/<x>/<pkg>-<y>/base.apk) first, then the system copy. */
    private static java.util.List<File> appApks() {
        java.util.ArrayList<File> l = new java.util.ArrayList<>();
        File[] outer = new File("/data/app").listFiles();
        if (outer != null) {
            for (File o : outer) {
                File[] inner = o.listFiles();
                if (inner == null) continue;
                for (File i : inner) {
                    if (i.getName().startsWith(APP + "-")) l.add(new File(i, "base.apk"));
                }
            }
        }
        l.add(new File("/system/app/BixbyWakeup/BixbyWakeup.apk"));
        return l;
    }

    private static byte[] readFile(File f) throws Exception {
        byte[] b = new byte[(int) f.length()];
        try (FileInputStream in = new FileInputStream(f)) {
            int off = 0;
            while (off < b.length) {
                int n = in.read(b, off, b.length - off);
                if (n < 0) throw new java.io.EOFException(f.getPath());
                off += n;
            }
        }
        return b;
    }

    private static String sha256(byte[] data) throws Exception {
        byte[] d = MessageDigest.getInstance("SHA-256").digest(data);
        StringBuilder sb = new StringBuilder(64);
        for (byte x : d) sb.append(Character.forDigit((x >> 4) & 15, 16)).append(Character.forDigit(x & 15, 16));
        return sb.toString();
    }
}
