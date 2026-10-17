package com.k4.homeclock;

import android.content.Context;
import android.content.ContextWrapper;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;

/**
 * Samsung's AOD clock plugin, loaded into the wallpaper process the way the clockpack host library (ClockManager, as
 * used by DressRoom and SystemUI) loads it: AODService's code through a package context, a plugin ContextWrapper whose
 * class loader / layout inflater are AOD's, and com.samsung.android.uniform.plugins.UfClockProvider created in-process
 * with onCreate(hostAppContext, pluginContext). getClockView(clockType, 2 = Category.LOCK_SCREEN) then inflates the very
 * clock view the lock screen uses. Only public clockpack API names are used (reflection), never AOD's obfuscated
 * internals. UfClockProvider lets SYSTEM apps in (ApplicationInfo.FLAG_SYSTEM), so no extra grant is needed for it.
 *
 * One provider per process, shared by every clock that is alive (acquire/release); the last release destroys it a few
 * seconds later, so an engine rebuild (old presenter released, new one built) reuses it instead of reloading.
 * Main looper only.
 */
final class AodHost {
    static final String AOD = "com.samsung.android.app.aodservice";
    private static final String PROVIDER = "com.samsung.android.uniform.plugins.UfClockProvider";
    static final String CP = "com.samsung.android.clockpack.plugins.clock.";
    private static final int CATEGORY_LOCK_SCREEN = 2;
    private static final long DESTROY_DELAY_MS = 5000;

    private static AodHost sHost;
    private static Handler sMain;
    private static final Runnable DESTROY = new Runnable() {
        @Override
        public void run() {
            AodHost h = sHost;
            if (h != null && h.refs == 0) {
                sHost = null;
                h.destroy();
            }
        }
    };

    final Context aod;
    final ClassLoader loader;
    private final Context plugin;
    private final Object provider;
    private final String sourceDir;
    private int refs;

    /** The plugin context: AOD's resources and class loader, inflating AOD's layouts with AOD's classes. */
    static final class PluginContext extends ContextWrapper {
        private final ClassLoader loader;
        private LayoutInflater inflater;

        PluginContext(Context base, ClassLoader loader) {
            super(base);
            this.loader = loader;
        }

        @Override
        public Context getApplicationContext() {
            return getBaseContext();
        }

        @Override
        public ClassLoader getClassLoader() {
            return loader;
        }

        @Override
        public Object getSystemService(String name) {
            if (Context.LAYOUT_INFLATER_SERVICE.equals(name)) {
                if (inflater == null) {
                    inflater = LayoutInflater.from(getBaseContext()).cloneInContext(this);
                }
                return inflater;
            }
            return getBaseContext().getSystemService(name);
        }
    }

    private AodHost(Context host) throws Exception {
        long t0 = SystemClock.elapsedRealtime();
        aod = host.createPackageContext(AOD, Context.CONTEXT_INCLUDE_CODE | Context.CONTEXT_IGNORE_SECURITY);
        loader = aod.getClassLoader();
        sourceDir = aod.getApplicationInfo().sourceDir;
        plugin = new PluginContext(aod, loader);
        Class<?> p = Class.forName(PROVIDER, true, loader);
        provider = p.getDeclaredConstructor().newInstance();
        Context app = host.getApplicationContext();
        p.getMethod("onCreate", Context.class, Context.class).invoke(provider, app != null ? app : host, plugin);
        Log.i(HomeDepthClock.TAG, "AOD clock plugin loaded from " + sourceDir + " ("
                + aod.getPackageManager().getPackageInfo(AOD, 0).versionName + "), "
                + (SystemClock.elapsedRealtime() - t0) + " ms");
    }

    static AodHost acquire(Context host) throws Exception {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            throw new IllegalStateException("AOD clock: not on the main thread");
        }
        main().removeCallbacks(DESTROY);
        AodHost h = sHost;
        if (h != null && !h.current(host)) {
            Log.i(HomeDepthClock.TAG, "AOD clock plugin: AODService was updated, reloading");
            sHost = null;
            if (h.refs == 0) {
                h.destroy();
            } // else: the clocks holding it release it later; it is no longer shared
            h = null;
        }
        if (h == null) {
            h = new AodHost(host);
            sHost = h;
        }
        h.refs++;
        return h;
    }

    private static synchronized Handler main() {
        if (sMain == null) {
            sMain = new Handler(Looper.getMainLooper());
        }
        return sMain;
    }

    void release() {
        if (refs > 0) {
            refs--;
        }
        if (refs == 0) {
            if (sHost == this) {
                main().removeCallbacks(DESTROY);
                main().postDelayed(DESTROY, DESTROY_DELAY_MS);
            } else {
                destroy();
            }
        }
    }

    private boolean current(Context host) {
        try {
            return sourceDir.equals(host.getPackageManager().getApplicationInfo(AOD, 0).sourceDir);
        } catch (Throwable t) {
            return false;
        }
    }

    /** A new lock-screen clock view of this type (AOD's ClockView, a FrameLayout), or an exception. */
    View clockView(int clockType) throws Exception {
        Object v = provider.getClass().getMethod("getClockView", int.class, int.class)
                .invoke(provider, clockType, CATEGORY_LOCK_SCREEN);
        if (!(v instanceof View)) {
            throw new IllegalStateException("AOD clock: no view for clockType " + clockType);
        }
        return (View) v;
    }

    Class<?> cls(String name) throws ClassNotFoundException {
        return Class.forName(name, false, loader);
    }

    private void destroy() {
        try {
            provider.getClass().getMethod("onDestroy").invoke(provider);
            Log.i(HomeDepthClock.TAG, "AOD clock plugin destroyed");
        } catch (Throwable t) {
            Log.w(HomeDepthClock.TAG, "AOD clock plugin onDestroy", t);
        }
    }
}
