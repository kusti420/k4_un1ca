package io.mesalabs.unica.settings.ui;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.content.res.Configuration;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.os.SemSystemProperties;
import android.provider.OpenableColumns;
import android.widget.Toast;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

import io.mesalabs.unica.utils.Utils;

/**
 * Settings > K4_UN1CA > UI > GPU driver > "Add driver…" (action ADD) and "Remove a driver…" (action REMOVE), started
 * from unica_ui_settings.xml. A translucent activity that only shows dialogs, so the picker result comes back here
 * and not to the settings page.
 * Add: system file picker -> the zip is copied to /data/k4gpu/incoming/.tmp-*, the driver files are extracted in the
 * vendor layout (GpuDriverPackage.plan), checked (GpuDriverPackage.check) and the directory becomes
 * incoming/u_&lt;version&gt;_&lt;id&gt; with info + ready; k4-gpu-driver installs it at the next boot.
 */
public class GpuDriverActivity extends Activity {
    static final String ACTION_ADD = "io.mesalabs.unica.action.GPU_DRIVER_ADD";
    static final String ACTION_REMOVE = "io.mesalabs.unica.action.GPU_DRIVER_REMOVE";
    private static final int REQUEST_PICK = 1;
    private static final String BASE = "/data/k4gpu";

    private GpuDriverModel mModel;
    private AlertDialog mDialog;
    private boolean mBusy;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mModel = new GpuDriverModel(new GpuDriverPreferenceController.SystemProps(), new File(BASE));
        if (savedInstanceState != null) return;
        if (!mModel.available()) {
            finish();
            return;
        }
        if (ACTION_REMOVE.equals(getIntent().getAction())) {
            showRemoveList();
            return;
        }
        Intent pick = Utils.getFilePickerOpenIntent(this,
                new String[] {"application/zip", "application/x-zip-compressed", "application/octet-stream"},
                new String[] {"zip"});
        try {
            startActivityForResult(pick, REQUEST_PICK);
        } catch (RuntimeException e) {
            Intent doc = new Intent(Intent.ACTION_OPEN_DOCUMENT).addCategory(Intent.CATEGORY_OPENABLE).setType("*/*");
            try {
                startActivityForResult(doc, REQUEST_PICK);
            } catch (RuntimeException e2) {
                finish();
            }
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode != REQUEST_PICK) return;
        Uri uri = data != null ? data.getData() : null;
        if (resultCode != RESULT_OK || uri == null) {
            finish();
            return;
        }
        mBusy = true;
        mDialog = builder().setMessage(str("k4_gpu_driver_add_checking")).setCancelable(false).create();
        mDialog.show();
        new Thread(() -> {
            String[] r = stage(uri);
            runOnUiThread(() -> showResult(r));
        }, "k4-gpu-driver-add").start();
    }

    @Override
    protected void onDestroy() {
        if (mDialog != null) mDialog.dismiss();
        super.onDestroy();
    }

    /** {slot, label} on success, {null, message} on failure. */
    private String[] stage(Uri uri) {
        File incoming = mModel.incoming();
        String[] old = incoming.list();
        if (old != null) for (String o : old) if (o.startsWith(".tmp-")) GpuDriverModel.deleteTree(new File(incoming, o));
        File tmp = new File(incoming, ".tmp-" + Long.toString(System.currentTimeMillis(), 36));
        try {
            if (!mkdir(tmp)) return fail("io", "");
            File zipCopy = new File(tmp, "src.zip");
            long size = copy(getContentResolver().openInputStream(uri), zipCopy, GpuDriverPackage.MAX_BYTES * 2);
            if (size < 0) return fail(GpuDriverPackage.ERR_TOO_LARGE, String.valueOf(GpuDriverPackage.MAX_BYTES >> 19));
            if (incoming.getUsableSpace() < size * 3) return fail("space", "");
            String name = displayName(uri);
            ZipFile zip;
            try {
                zip = new ZipFile(zipCopy);
            } catch (IOException e) {
                return fail("not_zip", "");
            }
            try {
                List<String> names = new ArrayList<>();
                Enumeration<? extends ZipEntry> en = zip.entries();
                while (en.hasMoreElements()) {
                    ZipEntry e = en.nextElement();
                    if (!e.isDirectory()) names.add(e.getName());
                }
                ZipEntry prop = zip.getEntry("module.prop");
                if (prop != null && prop.getSize() < 65536) {
                    try (InputStream in = zip.getInputStream(prop)) {
                        String id = GpuDriverPackage.moduleId(readAll(in, 65536));
                        if (id != null) name = id;
                    }
                }
                GpuDriverPackage.Plan plan = GpuDriverPackage.plan(names);
                if (plan.error != null) return fail(plan.error, plan.detail);
                long total = 0;
                for (Map.Entry<String, String> f : plan.files.entrySet()) {
                    File out = new File(tmp, f.getValue());
                    if (!mkdir(out.getParentFile())) return fail("io", "");
                    long n = copy(zip.getInputStream(zip.getEntry(f.getKey())), out, GpuDriverPackage.MAX_BYTES - total);
                    if (n < 0) return fail(GpuDriverPackage.ERR_TOO_LARGE, String.valueOf(GpuDriverPackage.MAX_BYTES >> 20));
                    total += n;
                }
            } finally {
                zip.close();
            }
            zipCopy.delete();
            GpuDriverPackage.Result res = GpuDriverPackage.check(tmp);
            if (res.error != null) return fail(res.error, res.detail);
            if (mModel.duplicateOf(res.version, name) != null) {
                return fail("duplicate", GpuDriverModel.addedLabel(res.version, name));
            }
            String slot = GpuDriverPackage.slotFor(res.version, Long.toString(System.currentTimeMillis() % 1679616L, 36));
            File dst = new File(incoming, slot);
            File info = new File(tmp, "info");
            try (OutputStream o = new FileOutputStream(info)) {
                o.write(("version=" + res.version + "\nname=" + name + "\n").getBytes(java.nio.charset.StandardCharsets.UTF_8));
            }
            chmod(info, 0660);
            if (dst.exists() || !tmp.renameTo(dst)) return fail("io", "");
            tmp = null;
            File ready = new File(dst, "ready");
            if (!GpuDriverModel.touch(ready)) {
                GpuDriverModel.deleteTree(dst);
                return fail("io", "");
            }
            chmod(ready, 0660);
            return new String[] {slot, GpuDriverModel.addedLabel(res.version, name)};
        } catch (IOException | RuntimeException e) {
            return fail("io", "");
        } finally {
            if (tmp != null) GpuDriverModel.deleteTree(tmp);
        }
    }

    private String[] fail(String code, String detail) {
        return new String[] {null, str("k4_gpu_driver_err_" + code, detail)};
    }

    private void showResult(String[] r) {
        mBusy = false;
        if (mDialog != null) mDialog.dismiss();
        if (isFinishing() || isDestroyed()) return;
        mModel.reload();
        if (r[0] == null) {
            mDialog = builder().setTitle(str("k4_gpu_driver_add_failed_title")).setMessage(r[1])
                    .setPositiveButton(str("k4_gpu_driver_failed_button"), null).create();
        } else {
            String slot = r[0];
            mDialog = builder().setTitle(str("k4_gpu_driver_add_done_title", r[1]))
                    .setMessage(str("k4_gpu_driver_add_done_msg", label(mModel.stockDriver())))
                    .setPositiveButton(str("k4_gpu_driver_add_use"), (d, w) -> {
                        if (!mModel.select(slot)) toast(lockedMessage());
                    })
                    .setNegativeButton(str("k4_gpu_driver_add_later"), null).create();
        }
        mDialog.setOnDismissListener(d -> finish());
        mDialog.show();
    }

    private void showRemoveList() {
        List<GpuDriverModel.Entry> list = new ArrayList<>();
        for (GpuDriverModel.Entry e : mModel.entries()) if (e.kind != GpuDriverModel.BUILTIN) list.add(e);
        if (list.isEmpty()) {
            finish();
            return;
        }
        CharSequence[] labels = new CharSequence[list.size()];
        for (int i = 0; i < labels.length; i++) labels[i] = list.get(i).label;
        mDialog = builder().setTitle(str("k4_gpu_driver_remove_title"))
                .setItems(labels, (d, which) -> {
                    mDialog.setOnDismissListener(null);
                    confirmRemove(list.get(which));
                })
                .setNegativeButton(str("k4_gpu_driver_cancel"), null).create();
        mDialog.setOnDismissListener(d -> finish());
        mDialog.show();
    }

    private void confirmRemove(GpuDriverModel.Entry e) {
        String root = mModel.root().isEmpty() ? str("k4_gpu_driver_root_unknown") : mModel.root();
        AlertDialog.Builder b = builder().setTitle(str("k4_gpu_driver_remove_title"));
        if (e.external) {
            b.setMessage(str("k4_gpu_driver_remove_external_msg", e.label, root, mModel.moduleOf(e.id)))
                    .setPositiveButton(str("k4_gpu_driver_failed_button"), null);
        } else if (e.kind == GpuDriverModel.MODULE) {
            b.setMessage(str("k4_gpu_driver_remove_module_msg", e.label, root, mModel.moduleOf(e.id)))
                    .setPositiveButton(str("k4_gpu_driver_remove_hide"), (d, w) -> doRemove(e))
                    .setNegativeButton(str("k4_gpu_driver_cancel"), null);
        } else {
            b.setMessage(str(e.kind == GpuDriverModel.STAGED ? "k4_gpu_driver_remove_staged_msg"
                            : "k4_gpu_driver_remove_added_msg", e.label))
                    .setPositiveButton(str("k4_gpu_driver_remove_delete"), (d, w) -> doRemove(e))
                    .setNegativeButton(str("k4_gpu_driver_cancel"), null);
        }
        mDialog = b.create();
        mDialog.setOnDismissListener(d -> finish());
        mDialog.show();
    }

    private void doRemove(GpuDriverModel.Entry e) {
        if (!mModel.remove(e.id)) toast(str("k4_gpu_driver_err_io", ""));
    }

    private String lockedMessage() {
        String ext = mModel.external();
        GpuDriverModel.Entry e = mModel.entry(ext);
        String root = mModel.root().isEmpty() ? str("k4_gpu_driver_root_unknown") : mModel.root();
        return str("k4_gpu_driver_locked", e != null ? e.label : ext, root, mModel.moduleOf(ext));
    }

    private String label(String id) {
        return GpuDriverPreferenceController.label(this, mModel, id);
    }

    private AlertDialog.Builder builder() {
        boolean night = (getResources().getConfiguration().uiMode & Configuration.UI_MODE_NIGHT_MASK)
                == Configuration.UI_MODE_NIGHT_YES;
        return new AlertDialog.Builder(this, night ? android.R.style.Theme_DeviceDefault_Dialog_Alert
                : android.R.style.Theme_DeviceDefault_Light_Dialog_Alert);
    }

    private void toast(String s) {
        Toast.makeText(this, s, Toast.LENGTH_LONG).show();
    }

    private String str(String name, Object... args) {
        return getString(Utils.getResourceId("string", name), args);
    }

    private String displayName(Uri uri) {
        String name = null;
        try (Cursor c = getContentResolver().query(uri, new String[] {OpenableColumns.DISPLAY_NAME}, null, null, null)) {
            if (c != null && c.moveToFirst()) name = c.getString(0);
        } catch (RuntimeException ignored) {
        }
        if (name == null) name = uri.getLastPathSegment();
        if (name == null) name = "zip";
        if (name.toLowerCase(java.util.Locale.ROOT).endsWith(".zip")) name = name.substring(0, name.length() - 4);
        return GpuDriverPackage.sanitize(name);
    }

    /**
     * The staged files are system:system; k4-gpu-driver runs as root with group system and without dac_override, so
     * it can read and delete them only through the group bits (an app's umask leaves 0700 / 0600).
     */
    private static boolean mkdir(File d) {
        if (d == null) return false;
        if (d.isDirectory()) return true;
        if (!mkdir(d.getParentFile()) || !d.mkdir() && !d.isDirectory()) return false;
        chmod(d, 0770);
        return true;
    }

    private static void chmod(File f, int mode) {
        try {
            android.system.Os.chmod(f.getPath(), mode);
        } catch (Exception ignored) {
        }
    }

    /** Copies at most max bytes; returns the size, or -1 if the input is larger. */
    private static long copy(InputStream in, File out, long max) throws IOException {
        if (in == null) throw new IOException("no input");
        long total = 0;
        try (InputStream i = in; OutputStream o = new FileOutputStream(out)) {
            byte[] buf = new byte[1 << 16];
            int n;
            while ((n = i.read(buf)) > 0) {
                total += n;
                if (total > max) return -1;
                o.write(buf, 0, n);
            }
        }
        chmod(out, 0660);
        return total;
    }

    private static byte[] readAll(InputStream in, int max) throws IOException {
        java.io.ByteArrayOutputStream b = new java.io.ByteArrayOutputStream();
        byte[] buf = new byte[4096];
        int n;
        while ((n = in.read(buf)) > 0 && b.size() < max) b.write(buf, 0, n);
        return b.toByteArray();
    }

    @Override
    public void onBackPressed() {
        if (!mBusy) super.onBackPressed();
    }
}
