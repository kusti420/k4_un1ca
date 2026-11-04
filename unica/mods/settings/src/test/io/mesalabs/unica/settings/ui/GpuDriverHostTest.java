package io.mesalabs.unica.settings.ui;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Host test (src/test/run.sh) of GpuDriverModel and GpuDriverPackage. */
public final class GpuDriverHostTest {
    private static int passed;
    private static int failed;
    private static String section = "";

    static final class MapProps implements GpuDriverModel.Props {
        final Map<String, String> m = new HashMap<>();

        @Override
        public String get(String key) {
            String v = m.get(key);
            return v == null ? "" : v;
        }

        @Override
        public void set(String key, String value) {
            m.put(key, value);
        }
    }

    public static void main(String[] args) throws Exception {
        plans();
        checks();
        versions();
        names();
        model();
        System.out.println(passed + " passed, " + failed + " failed");
        if (failed > 0) System.exit(1);
    }

    static void eq(String what, Object got, Object want) {
        if (want == null ? got == null : want.equals(got)) {
            passed++;
        } else {
            failed++;
            System.out.println("FAIL [" + section + "] " + what + ": expected <" + want + ">, got <" + got + ">");
        }
    }

    static void plans() {
        section = "plan: KernelSU / Magisk module";
        GpuDriverPackage.Plan p = GpuDriverPackage.plan(Arrays.asList(
                "META-INF/com/google/android/update-binary", "module.prop", "customize.sh",
                "system/vendor/lib64/egl/libGLESv2_adreno.so", "system/vendor/lib64/egl/libEGL_adreno.so",
                "system/vendor/lib64/egl/libGLESv1_CM_adreno.so", "system/vendor/lib64/hw/vulkan.adreno.so",
                "system/vendor/lib64/libgsl.so", "system/vendor/lib64/libadreno_app_profiles.so",
                "system/vendor/lib64/libllvm-glnext.so", "system/vendor/lib64/sub/x.so", "system/vendor/lib64/README",
                "system/vendor/lib/egl/libGLESv2_adreno.so", "system/vendor/lib/libgsl.so",
                "system/vendor/firmware/a660_sqe.fw", "system/vendor/firmware/a650_sqe.fw",
                "system/vendor/etc/permissions/android.hardware.vulkan.version-1_3.xml"));
        eq("error", p.error, null);
        eq("GLES", p.files.get("system/vendor/lib64/egl/libGLESv2_adreno.so"), "lib64/egl/libGLESv2_adreno.so");
        eq("vulkan", p.files.get("system/vendor/lib64/hw/vulkan.adreno.so"), "lib64/hw/vulkan.adreno.so");
        eq("gsl", p.files.get("system/vendor/lib64/libgsl.so"), "lib64/libgsl.so");
        eq("sqe", p.files.get("system/vendor/firmware/a660_sqe.fw"), "firmware/a660_sqe.fw");
        eq("no subdirectories", p.files.containsKey("system/vendor/lib64/sub/x.so"), false);
        eq("no 32-bit", p.files.containsKey("system/vendor/lib/libgsl.so"), false);
        eq("no other GPU's microcode", p.files.containsKey("system/vendor/firmware/a650_sqe.fw"), false);
        eq("count", p.files.size(), 8);

        section = "plan: an unrelated vendor library in the layout is rejected (M2)";
        p = GpuDriverPackage.plan(Arrays.asList("system/vendor/lib64/egl/libGLESv2_adreno.so",
                "system/vendor/lib64/libsec-ril.so"));
        eq("error", p.error, GpuDriverPackage.ERR_UNEXPECTED);
        eq("detail", p.detail, "libsec-ril.so");
        eq("nothing staged", p.files.size(), 0);
        p = GpuDriverPackage.plan(Arrays.asList("system/vendor/lib64/egl/libGLESv2_adreno.so",
                "system/vendor/lib64/hw/gralloc.default.so"));
        eq("unexpected hw file", p.error, GpuDriverPackage.ERR_UNEXPECTED);
        p = GpuDriverPackage.plan(Arrays.asList("Adreno/libGLESv2_adreno.so", "Adreno/libmali.so"));
        eq("unexpected flat lib", p.error, GpuDriverPackage.ERR_UNEXPECTED);

        section = "plan: vendor/ at the root, microcode elsewhere";
        p = GpuDriverPackage.plan(Arrays.asList("drv/vendor/lib64/egl/libGLESv2_adreno.so", "drv/vendor/lib64/libgsl.so",
                "drv/firmware_extra/a660_sqe.fw", "other/system/vendor/firmware/a660_sqe.fw"));
        eq("GLES", p.files.get("drv/vendor/lib64/egl/libGLESv2_adreno.so"), "lib64/egl/libGLESv2_adreno.so");
        eq("prefers vendor/firmware", p.files.get("other/system/vendor/firmware/a660_sqe.fw"), "firmware/a660_sqe.fw");

        section = "plan: two copies, the shorter prefix wins";
        p = GpuDriverPackage.plan(Arrays.asList("backup/system/vendor/lib64/egl/libGLESv2_adreno.so",
                "system/vendor/lib64/egl/libGLESv2_adreno.so"));
        eq("shorter", p.files.containsKey("system/vendor/lib64/egl/libGLESv2_adreno.so"), true);
        eq("not the backup", p.files.containsKey("backup/system/vendor/lib64/egl/libGLESv2_adreno.so"), false);

        section = "plan: flat set";
        p = GpuDriverPackage.plan(Arrays.asList("Adreno/libGLESv2_adreno.so", "Adreno/libEGL_adreno.so",
                "Adreno/libGLESv1_CM_adreno.so", "Adreno/eglSubDriverAndroid.so", "Adreno/libq3dtools_esx.so",
                "Adreno/libVkLayer_ADRENO_qprofiler.so", "Adreno/vulkan.adreno.so", "Adreno/libgsl.so",
                "Adreno/libadreno_app_profiles.so", "Adreno/a660_sqe.fw", "Adreno/readme.txt", "Adreno/x/libfoo.so"));
        eq("error", p.error, null);
        eq("egl", p.files.get("Adreno/libEGL_adreno.so"), "lib64/egl/libEGL_adreno.so");
        eq("subdriver", p.files.get("Adreno/eglSubDriverAndroid.so"), "lib64/egl/eglSubDriverAndroid.so");
        eq("q3dtools", p.files.get("Adreno/libq3dtools_esx.so"), "lib64/egl/libq3dtools_esx.so");
        eq("layer", p.files.get("Adreno/libVkLayer_ADRENO_qprofiler.so"), "lib64/egl/libVkLayer_ADRENO_qprofiler.so");
        eq("vulkan", p.files.get("Adreno/vulkan.adreno.so"), "lib64/hw/vulkan.adreno.so");
        eq("other", p.files.get("Adreno/libadreno_app_profiles.so"), "lib64/libadreno_app_profiles.so");
        eq("sqe", p.files.get("Adreno/a660_sqe.fw"), "firmware/a660_sqe.fw");
        eq("not deeper", p.files.containsKey("Adreno/x/libfoo.so"), false);
        eq("not text", p.files.containsKey("Adreno/readme.txt"), false);

        section = "plan: flat at the zip root";
        p = GpuDriverPackage.plan(Arrays.asList("libGLESv2_adreno.so", "vulkan.adreno.so"));
        eq("root", p.files.get("libGLESv2_adreno.so"), "lib64/egl/libGLESv2_adreno.so");

        section = "plan: 32-bit only";
        p = GpuDriverPackage.plan(Arrays.asList("system/vendor/lib/egl/libGLESv2_adreno.so", "system/vendor/lib/libgsl.so"));
        eq("error", p.error, GpuDriverPackage.ERR_32BIT);

        section = "plan: not a driver";
        p = GpuDriverPackage.plan(Arrays.asList("module.prop", "system/bin/foo"));
        eq("error", p.error, GpuDriverPackage.ERR_NO_DRIVER);
        p = GpuDriverPackage.plan(Arrays.asList("xlibGLESv2_adreno.so"));
        eq("no partial name match", p.error, GpuDriverPackage.ERR_NO_DRIVER);
        p = GpuDriverPackage.plan(Arrays.asList("foo/xlib64/egl/libGLESv2_adreno.so"));
        eq("no partial dir match (flat fallback)", p.files.get("foo/xlib64/egl/libGLESv2_adreno.so"), "lib64/egl/libGLESv2_adreno.so");
    }

    static File tmp;

    static void lib(File f, String version, boolean arm64) throws IOException {
        f.getParentFile().mkdirs();
        try (FileOutputStream o = new FileOutputStream(f)) {
            o.write(new byte[] {0x7f, 'E', 'L', 'F', (byte) (arm64 ? 2 : 1), 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0,
                    (byte) (arm64 ? 183 : 40), 0});
            if (version != null) o.write(("junk V@1.2 V@12345.6 Qualcomm " + version + " (GIT@abc)\n").getBytes(StandardCharsets.US_ASCII));
        }
    }

    static File set(String name, String version) throws IOException {
        File d = new File(tmp, name);
        for (String f : GpuDriverPackage.REQUIRED) lib(new File(d, f), f.endsWith("libGLESv2_adreno.so") ? version : null, true);
        new File(d, "firmware").mkdirs();
        Files.write(new File(d, "firmware/a660_sqe.fw").toPath(), new byte[] {1, 2, 3});
        return d;
    }

    static void checks() throws IOException {
        tmp = Files.createTempDirectory("k4gpu").toFile();
        section = "check: complete set";
        GpuDriverPackage.Result r = GpuDriverPackage.check(set("a", "V@0849.0"));
        eq("error", r.error, null);
        eq("version", r.version, "V@0849.0");

        section = "check: missing";
        File d = set("b", "V@0849.0");
        new File(d, "lib64/libgsl.so").delete();
        new File(d, "lib64/hw/vulkan.adreno.so").delete();
        r = GpuDriverPackage.check(d);
        eq("error", r.error, GpuDriverPackage.ERR_MISSING);
        eq("detail", r.detail, "vulkan.adreno.so, libgsl.so");

        section = "check: 32-bit library";
        d = set("c", "V@0849.0");
        lib(new File(d, "lib64/libllvm-glnext.so"), null, false);
        r = GpuDriverPackage.check(d);
        eq("error", r.error, GpuDriverPackage.ERR_NOT_ARM64);
        eq("detail", r.detail, "libllvm-glnext.so");

        section = "check: not an ELF file";
        d = set("d", "V@0849.0");
        Files.write(new File(d, "lib64/egl/libEGL_adreno.so").toPath(), "#!/bin/sh".getBytes(StandardCharsets.US_ASCII));
        r = GpuDriverPackage.check(d);
        eq("error", r.error, GpuDriverPackage.ERR_NOT_ARM64);

        section = "check: no version";
        d = set("e", null);
        r = GpuDriverPackage.check(d);
        eq("error", r.error, GpuDriverPackage.ERR_NO_VERSION);

        section = "check: microcode optional";
        d = set("f", "V@0744.0");
        new File(d, "firmware/a660_sqe.fw").delete();
        eq("ok without sqe", GpuDriverPackage.check(d).error, null);
    }

    static void versions() throws IOException {
        section = "version strings";
        eq("plain", GpuDriverPackage.findVersion(b("x V@0530.0 (GIT@cac6e6f805")), "V@0530.0");
        eq("three parts", GpuDriverPackage.findVersion(b("V@0530.55.1 (GIT")), "V@0530.55.1");
        eq("trailing dot", GpuDriverPackage.findVersion(b("V@0849.0. x")), "V@0849.0");
        eq("3 digits", GpuDriverPackage.findVersion(b("V@744.0 x")), "V@744.0");
        eq("skips bad ones", GpuDriverPackage.findVersion(b("V@1.2 V@12345.6 V@0863.1 (")), "V@0863.1");
        eq("none", GpuDriverPackage.findVersion(b("V@ V@0x")), null);
        eq("touching the end: next block", GpuDriverPackage.findVersion(b("V@0530.5")), null);
        // across the 64 KiB read blocks
        File f = new File(tmp, "big.so");
        byte[] big = new byte[(1 << 16) + 100];
        byte[] v = b("V@0863.1 (GIT");
        System.arraycopy(v, 0, big, (1 << 16) - 5, v.length);
        Files.write(f.toPath(), big);
        eq("across blocks", GpuDriverPackage.version(f), "V@0863.1");
        byte[] big2 = new byte[(1 << 16) + 100];
        byte[] v2 = b("V@0530.55.1 (GIT");
        System.arraycopy(v2, 0, big2, (1 << 16) - 8, v2.length);
        Files.write(f.toPath(), big2);
        eq("third part across blocks", GpuDriverPackage.version(f), "V@0530.55.1");
    }

    static void names() {
        section = "names";
        eq("module.prop id", GpuDriverPackage.moduleId(b("name=Foo\nid=adreno_gpu_driver\r\nversion=1\n")), "adreno_gpu_driver");
        eq("no id", GpuDriverPackage.moduleId(b("name=Foo\n")), null);
        eq("sanitize", GpuDriverPackage.sanitize("v@0849 (MKSU)/../x"), "v_0849__MKSU__.._x");
        eq("sanitize length", GpuDriverPackage.sanitize("abcdefghijklmnopqrstuvwxyz0123").length(), 24);
        eq("sanitize empty", GpuDriverPackage.sanitize(""), "zip");
        eq("slot", GpuDriverPackage.slotFor("V@0530.55.1", "k3"), "u_0530_55_1_k3");
        eq("slot is a slot", GpuDriverModel.isSlot(GpuDriverPackage.slotFor("V@0849.0", "zz")), true);
        eq("not a slot", GpuDriverModel.isSlot("849"), false);
        eq("not a slot 2", GpuDriverModel.isSlot("m_../x"), false);
        eq("module id", GpuDriverModel.moduleId("m_adreno_x"), "adreno_x");
        eq("module id without the slot hash", GpuDriverModel.moduleId("m_k4test_adreno849_0249090c"), "k4test_adreno849");
        eq("an id that merely ends in _ is kept", GpuDriverModel.moduleId("m_drv_v2"), "drv_v2");
        eq("'+' is a slot character", GpuDriverModel.isSlot("m_drv+gl_0249090c"), true);
    }

    static void write(File f, String s) throws IOException {
        f.getParentFile().mkdirs();
        Files.write(f.toPath(), s.getBytes(StandardCharsets.UTF_8));
    }

    static List<String> ids(GpuDriverModel m) {
        StringBuilder b = new StringBuilder();
        for (GpuDriverModel.Entry e : m.entries()) b.append(b.length() > 0 ? " " : "").append(e.id);
        return Arrays.asList(b.toString().split(" "));
    }

    static void model() throws IOException {
        File base = new File(tmp, "data_k4gpu");
        new File(base, "incoming").mkdirs();
        MapProps p = new MapProps();
        GpuDriverModel m = new GpuDriverModel(p, base);

        section = "model: no selector";
        eq("unavailable", m.available(), false);
        p.set(GpuDriverModel.PROP_DRIVERS, "530");
        eq("one driver is no choice", m.available(), false);

        section = "model: built-ins only";
        p.set(GpuDriverModel.PROP_DRIVERS, "530 530_55 849 863");
        m.reload();
        eq("available", m.available(), true);
        eq("entries", ids(m), Arrays.asList("530", "530_55", "849", "863"));
        eq("stock", m.stockDriver(), "530");
        eq("no default prop: the stock is the default", m.defaultDriver(), "530");
        eq("selected default", m.selected(), "530");
        eq("active default", m.active(), "530");
        eq("no user entries", m.hasUserEntries(), false);
        eq("select", m.select("849"), true);
        eq("selected", p.get(GpuDriverModel.PROP_SELECTED), "849");
        eq("trial", p.get(GpuDriverModel.PROP_TRIAL), "pending");
        eq("select active", m.select("530"), true);
        eq("trial ok for the active one", p.get(GpuDriverModel.PROP_TRIAL), "ok");
        eq("unknown refused", m.select("999"), false);
        p.set(GpuDriverModel.PROP_ACTIVE, "849");
        eq("select stock while 849 is active", m.select("530"), true);
        eq("the stock driver is never on trial", p.get(GpuDriverModel.PROP_TRIAL), "ok");
        eq("a built-in other than stock is", m.select("863") && "pending".equals(p.get(GpuDriverModel.PROP_TRIAL)), true);
        p.set(GpuDriverModel.PROP_ACTIVE, "");

        section = "model: the default (ro.k4.gpu_default = 849, the stock 530 stays the fallback)";
        p.set(GpuDriverModel.PROP_DEFAULT, "849");
        p.set(GpuDriverModel.PROP_SELECTED, "");
        m.reload();
        eq("default", m.defaultDriver(), "849");
        eq("stock unchanged", m.stockDriver(), "530");
        eq("no selection shows the stock (k4-gpu-driver stores the default at boot, Settings never sees it unset)", m.selected(), "530");
        eq("no active prop shows the stock", m.active(), "530");
        eq("select the default from stock", m.select("849"), true);
        eq("the default is on trial like any set", p.get(GpuDriverModel.PROP_TRIAL), "pending");
        eq("select stock", m.select("530"), true);
        eq("stock never on trial", p.get(GpuDriverModel.PROP_TRIAL), "ok");
        p.set(GpuDriverModel.PROP_DEFAULT, "999");
        m.reload();
        eq("unknown default: the stock", m.defaultDriver(), "530");
        p.set(GpuDriverModel.PROP_DEFAULT, "530_55");
        m.reload();
        eq("another built-in as the default", m.defaultDriver(), "530_55");
        p.set(GpuDriverModel.PROP_DEFAULT, "849");
        m.reload();

        section = "model: user drivers listed only after the boot scan";
        write(new File(base, "drivers"), "m_adreno_x\tmodule\t-\tV@0744.0 (module adreno_x)\n"
                + "u_0849_0_k3\tadded\t-\tV@0849.0 (added: mine)\n"
                + "bad line\n"
                + "849\tmodule\t-\tshadowing a built-in\n");
        m.reload();
        eq("not yet", ids(m).size(), 4);
        p.set(GpuDriverModel.PROP_SCAN, "1");
        m.reload();
        eq("entries", ids(m), Arrays.asList("530", "530_55", "849", "863", "m_adreno_x", "u_0849_0_k3"));
        eq("module label", m.entry("m_adreno_x").label, "V@0744.0 (module adreno_x)");
        eq("kind", m.entry("u_0849_0_k3").kind, GpuDriverModel.ADDED);
        eq("user entries", m.hasUserEntries(), true);

        section = "model: staged driver";
        File st = new File(base, "incoming/u_0863_1_zz");
        write(new File(st, "info"), "version=V@0863.1\nname=other\n");
        m.reload();
        eq("not ready yet", m.isKnown("u_0863_1_zz"), false);
        GpuDriverModel.touch(new File(st, "ready"));
        m.reload();
        eq("staged listed", m.entry("u_0863_1_zz").kind, GpuDriverModel.STAGED);
        eq("staged label", m.entry("u_0863_1_zz").label, "V@0863.1 (added: other)");
        eq("duplicate of staged", m.duplicateOf("V@0863.1", "other").id, "u_0863_1_zz");
        eq("duplicate of added", m.duplicateOf("V@0849.0", "mine").id, "u_0849_0_k3");
        eq("other name is no duplicate", m.duplicateOf("V@0849.0", "theirs"), null);
        eq("module is no duplicate", m.duplicateOf("V@0744.0", "adreno_x"), null);
        eq("select staged", m.select("u_0863_1_zz"), true);
        eq("pending", p.get(GpuDriverModel.PROP_TRIAL), "pending");

        section = "model: remove a staged driver (deleted now)";
        p.set(GpuDriverModel.PROP_PREV, "849");
        eq("remove", m.remove("u_0863_1_zz"), true);
        eq("deleted", st.exists(), false);
        eq("selection back to prev", p.get(GpuDriverModel.PROP_SELECTED), "849");

        section = "model: remove an added driver (at the next boot)";
        p.set(GpuDriverModel.PROP_ACTIVE, "u_0849_0_k3");
        p.set(GpuDriverModel.PROP_SELECTED, "u_0849_0_k3");
        p.set(GpuDriverModel.PROP_PREV, "u_0849_0_k3");
        m.reload();
        eq("active user", m.active(), "u_0849_0_k3");
        eq("remove", m.remove("u_0849_0_k3"), true);
        eq("request", new File(base, "incoming/u_0849_0_k3.remove").exists(), true);
        eq("hidden now", m.isKnown("u_0849_0_k3"), false);
        eq("prev is itself: the default", p.get(GpuDriverModel.PROP_SELECTED), "849");
        eq("the default gets a trial (it is not the stock driver)", p.get(GpuDriverModel.PROP_TRIAL), "pending");
        eq("restart still needed (selected != active)", m.selected().equals(m.active()), false);

        section = "model: hide a module's driver";
        eq("hide", m.remove("m_adreno_x"), true);
        eq("request", new File(base, "incoming/m_adreno_x.hide").exists(), true);
        eq("hidden now", m.isKnown("m_adreno_x"), false);

        section = "model: the module id and label of a driver being hidden (polish 1)";
        write(new File(base, "drivers"), "m_k4test_adreno849_0249090c\tmodule\t-\tV@0849.0 (module k4test_adreno849)\tk4test_adreno849\n");
        new File(base, "incoming/m_adreno_x.hide").delete();
        p.set(GpuDriverModel.PROP_ACTIVE, "m_k4test_adreno849_0249090c");
        m.reload();
        eq("module id from the list", m.moduleOf("m_k4test_adreno849_0249090c"), "k4test_adreno849");
        eq("entry carries it", m.entry("m_k4test_adreno849_0249090c").module, "k4test_adreno849");
        GpuDriverModel.touch(new File(base, "incoming/m_k4test_adreno849_0249090c.hide"));
        m.reload();
        eq("hidden from the list", m.isKnown("m_k4test_adreno849_0249090c"), false);
        eq("but its label is still known while it is active", m.anyEntry("m_k4test_adreno849_0249090c").label,
                "V@0849.0 (module k4test_adreno849)");
        eq("and its module id", m.moduleOf("m_k4test_adreno849_0249090c"), "k4test_adreno849");
        eq("a slot not in the list falls back to the slot name minus the hash", m.moduleOf("m_other_drv_1234abcd"), "other_drv");
        new File(base, "incoming/m_k4test_adreno849_0249090c.hide").delete();
        write(new File(base, "drivers"), "m_adreno_x\tmodule\t-\tV@0744.0 (module adreno_x)\n");
        p.set(GpuDriverModel.PROP_ACTIVE, "");
        m.reload();
        eq("old 4-field lists still parse", m.entry("m_adreno_x").label, "V@0744.0 (module adreno_x)");
        eq("built-ins cannot be removed", m.remove("849"), false);

        section = "model: module mounted by the root manager";
        new File(base, "incoming/m_adreno_x.hide").delete();
        write(new File(base, "drivers"), "m_meta\tmodule\texternal\tV@0762.0 (module meta)\n");
        p.set(GpuDriverModel.PROP_EXTERNAL, "m_meta");
        p.set(GpuDriverModel.PROP_ACTIVE, "m_meta");
        p.set(GpuDriverModel.PROP_SELECTED, "m_meta");
        p.set(GpuDriverModel.PROP_TRIAL, "ok");
        m.reload();
        eq("external", m.external(), "m_meta");
        eq("active", m.active(), "m_meta");
        eq("others refused", m.select("849"), false);
        eq("unchanged", p.get(GpuDriverModel.PROP_SELECTED), "m_meta");
        eq("itself fine", m.select("m_meta"), true);
        eq("trial ok", p.get(GpuDriverModel.PROP_TRIAL), "ok");
        eq("cannot be removed here", m.remove("m_meta"), false);
        eq("a stale hide marker does not hide it", new File(base, "incoming/m_meta.hide").createNewFile() && m.isKnown("m_meta"), true);

        section = "model: failed / missing";
        p.set(GpuDriverModel.PROP_EXTERNAL, "");
        p.set(GpuDriverModel.PROP_FAILED, "m_gone");
        m.reload();
        eq("failed slot kept for the banner", m.failed(), "m_gone");
        p.set(GpuDriverModel.PROP_FAILED, "garbage!");
        eq("garbage dropped", m.failed(), "");
        p.set(GpuDriverModel.PROP_FAILED, "863");
        eq("built-in", m.failed(), "863");
        p.set(GpuDriverModel.PROP_SELECTED, "u_unknown");
        m.reload();
        eq("unknown selection shows the default", m.selected(), "530");
        p.set(GpuDriverModel.PROP_ROOT, "none");
        eq("no root", m.root(), "");
        p.set(GpuDriverModel.PROP_ROOT, "KernelSU");
        eq("root", m.root(), "KernelSU");
    }

    static byte[] b(String s) {
        return s.getBytes(StandardCharsets.US_ASCII);
    }
}
