package com.k4.homeclock;

import android.content.ContentResolver;
import android.content.Context;
import android.content.ContextWrapper;
import android.database.ContentObserver;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.provider.Settings;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

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
 *
 * Weather (the date line's icon and temperature, which also switch the date to its short form), the way the editor
 * (DressRoom) and the lock screen (SystemUI's KeyguardWeatherManager) do it: the plugin's own weather manager
 * (ClockProvider.getWeatherManager) is fed by the plugin's own data fetcher, which reads the Samsung Weather app's data
 * once per Plugin.onResume(true); its IWeatherManager.Listener delivers each result (main thread) and the clocks redraw
 * when it changed. When to fetch again: the Weather app sends its WEATHER_DATA_SYNC broadcast only to an allowlist of
 * packages (SystemUI, ...), but SystemUI's copy of this very weather manager then writes the new temperature to
 * Settings.System clock_weather_temperature / clock_weather_location_exist. A ContentObserver on those two is the
 * trigger, so there is no polling, no alarm and no wakeup of our own: a fetch happens only after the system's own
 * weather update changed what is shown.
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
    private final Context hostContext;
    private int refs;

    private static final String SETTING_TEMPERATURE = "clock_weather_temperature";
    private static final String SETTING_LOCATION = "clock_weather_location_exist";
    private static final long REFETCH_DELAY_MS = 1000;
    private static final long REGISTER_DELAY_MS = 400;
    private boolean weatherRegistered;
    private Object weatherManager;
    private Object weatherListener;
    private ContentObserver weatherObserver;
    private boolean weatherFailed;
    /** The latest WeatherInfo (AOD's class) the plugin's weather manager delivered, or null before the first one. */
    Object weatherInfo;
    /** What weatherInfo shows ("enabled|temperature|icon"), "" before the first delivery; part of the clocks' text(). */
    String weatherKey = "";
    private boolean weatherEnabled;
    private String weatherTemperature = "";
    private final Runnable refetch = new Runnable() {
        @Override
        public void run() {
            refetchWeather("settings changed");
        }
    };

    /**
     * The plugin context: AOD's resources and class loader, inflating AOD's layouts with AOD's classes. Shared
     * preferences come from the host's own data directory (prefixed): AOD's is not ours to open (the plugin's weather
     * code asks for one on every fetch; through AOD's package context that only logs a failed mkdir and stays empty).
     */
    static final class PluginContext extends ContextWrapper {
        private final ClassLoader loader;
        private final Context host;
        private LayoutInflater inflater;

        PluginContext(Context base, ClassLoader loader, Context host) {
            super(base);
            this.loader = loader;
            this.host = host;
        }

        @Override
        public android.content.SharedPreferences getSharedPreferences(String name, int mode) {
            return host.getSharedPreferences("aod_plugin_" + name, mode);
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
        Context app = host.getApplicationContext();
        hostContext = app != null ? app : host;
        plugin = new PluginContext(aod, loader, hostContext);
        Class<?> p = Class.forName(PROVIDER, true, loader);
        provider = p.getDeclaredConstructor().newInstance();
        p.getMethod("onCreate", Context.class, Context.class).invoke(provider, hostContext, plugin);
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

    /** ClockProvider.isSupportWeatherInfo(LOCK_SCREEN, clockType): the clock type has a weather slot on its date line. */
    boolean supportsWeather(int clockType) {
        try {
            Class<?> category = cls("com.samsung.android.clockpack.plugins.Category");
            Object lock = category.getField("LOCK_SCREEN").get(null);
            Object r = cls(CP + "ClockProvider").getMethod("isSupportWeatherInfo", category, int.class)
                    .invoke(provider, lock, clockType);
            return Boolean.TRUE.equals(r);
        } catch (Throwable t) {
            Log.w(HomeDepthClock.TAG, "AOD clock: isSupportWeatherInfo failed: " + t);
            return false;
        }
    }

    /** Links the plugin's weather manager once (a clock that shows weather is alive). Main thread. */
    void startWeather() {
        if (weatherManager != null || weatherFailed) {
            return;
        }
        try {
            Object wm = cls(CP + "ClockProvider").getMethod("getWeatherManager").invoke(provider);
            if (wm == null) {
                throw new IllegalStateException("no weather manager");
            }
            Class<?> listener = cls(CP + "IWeatherManager$Listener");
            Object l = Proxy.newProxyInstance(loader, new Class<?>[] {listener}, new InvocationHandler() {
                @Override
                public Object invoke(Object proxy, Method m, Object[] args) {
                    switch (m.getName()) {
                        case "onWeatherInfoUpdated":
                            final Object info = args != null && args.length > 0 ? args[0] : null;
                            if (Looper.myLooper() == Looper.getMainLooper()) {
                                onWeather(info);
                            } else {
                                main().post(new Runnable() {
                                    @Override
                                    public void run() {
                                        onWeather(info);
                                    }
                                });
                            }
                            return null;
                        case "equals":
                            return args != null && args.length == 1 && proxy == args[0];
                        case "hashCode":
                            return System.identityHashCode(proxy);
                        case "toString":
                            return "K4HomeClockWeatherListener";
                        default:
                            return null;
                    }
                }
            });
            // fetch first, listen a moment later: registering delivers what the manager has at that time and stores it
            // in Settings (as SystemUI's and the editor's copies do), which should be the fetched weather, not the empty
            // start value (a read takes some 30 ms)
            resume(false);
            resume(true);
            weatherManager = wm;
            weatherListener = l;
            main().postDelayed(new Runnable() {
                @Override
                public void run() {
                    if (weatherManager != wm || weatherListener != l) {
                        return; // stopped meanwhile
                    }
                    try {
                        cls(CP + "IWeatherManager").getMethod("registerListener", listener).invoke(wm, l);
                        weatherRegistered = true;
                    } catch (Throwable t) {
                        Throwable c = t instanceof java.lang.reflect.InvocationTargetException && t.getCause() != null ? t.getCause() : t;
                        Log.w(HomeDepthClock.TAG, "AOD clock weather: registerListener failed", c);
                        weatherFailed = true;
                        stopWeather();
                    }
                }
            }, REGISTER_DELAY_MS);
            ContentObserver o = new ContentObserver(main()) {
                @Override
                public void onChange(boolean selfChange) {
                    main().removeCallbacks(refetch);
                    main().postDelayed(refetch, REFETCH_DELAY_MS); // the two settings are written back to back
                }
            };
            ContentResolver cr = hostContext.getContentResolver();
            cr.registerContentObserver(Settings.System.getUriFor(SETTING_TEMPERATURE), false, o);
            cr.registerContentObserver(Settings.System.getUriFor(SETTING_LOCATION), false, o);
            weatherObserver = o;
            Log.i(HomeDepthClock.TAG, "AOD clock weather: listening to the plugin's weather manager");
        } catch (Throwable t) {
            Throwable c = t instanceof java.lang.reflect.InvocationTargetException && t.getCause() != null ? t.getCause() : t;
            Log.w(HomeDepthClock.TAG, "AOD clock weather unavailable, date line without weather", c);
            weatherFailed = true;
            stopWeather();
        }
    }

    /** The system's weather settings changed: fetch again unless they already say what we show (our own write). */
    private void refetchWeather(String why) {
        if (weatherManager == null || !weatherRegistered) {
            return;
        }
        ContentResolver cr = hostContext.getContentResolver();
        String t = Settings.System.getString(cr, SETTING_TEMPERATURE);
        int exists = Settings.System.getInt(cr, SETTING_LOCATION, 0);
        if (weatherInfo != null && (exists != 0) == weatherEnabled && (t == null ? "" : t).equals(weatherTemperature)) {
            return;
        }
        Log.i(HomeDepthClock.TAG, "AOD clock weather: " + why + " (" + t + ", location " + exists + "), fetching");
        try {
            resume(false);
            resume(true);
        } catch (Throwable e) {
            Log.w(HomeDepthClock.TAG, "AOD clock weather: fetch failed: " + e);
        }
    }

    /** Plugin.onResume: true starts the plugin's weather fetch (one read on its own background thread). */
    private void resume(boolean on) throws Exception {
        cls("com.samsung.android.clockpack.plugins.Plugin").getMethod("onResume", Boolean.class)
                .invoke(provider, Boolean.valueOf(on));
    }

    /** IWeatherManager.Listener.onWeatherInfoUpdated, main thread. */
    private void onWeather(Object info) {
        if (info == null || weatherManager == null) {
            return;
        }
        try {
            Class<?> wi = info.getClass();
            boolean enabled = Boolean.TRUE.equals(wi.getMethod("isEnabled").invoke(info));
            Object temp = wi.getMethod("getTemperature").invoke(info);
            Object icon = wi.getMethod("getWeatherIconDrawable").invoke(info);
            Object state = icon instanceof android.graphics.drawable.Drawable
                    ? ((android.graphics.drawable.Drawable) icon).getConstantState() : null;
            String key = enabled + "|" + temp + "|" + (icon == null ? "-" : icon.getClass().getSimpleName() + "@"
                    + Integer.toHexString(System.identityHashCode(state != null ? state : icon)));
            weatherInfo = info;
            weatherEnabled = enabled;
            weatherTemperature = temp == null ? "" : temp.toString();
            if (!key.equals(weatherKey)) {
                Log.i(HomeDepthClock.TAG, "AOD clock weather: " + info);
                weatherKey = key;
                HomeDepthClock.redrawStale("weather");
            }
        } catch (Throwable t) {
            Log.w(HomeDepthClock.TAG, "AOD clock weather: unreadable " + info + ": " + t);
        }
    }

    private void stopWeather() {
        main().removeCallbacks(refetch);
        ContentObserver o = weatherObserver;
        weatherObserver = null;
        if (o != null) {
            try {
                hostContext.getContentResolver().unregisterContentObserver(o);
            } catch (Throwable ignored) {
            }
        }
        Object wm = weatherManager;
        Object l = weatherListener;
        boolean registered = weatherRegistered;
        weatherManager = null;
        weatherListener = null;
        weatherRegistered = false;
        if (wm != null && l != null && registered) {
            try {
                cls(CP + "IWeatherManager").getMethod("unregisterListener", cls(CP + "IWeatherManager$Listener"))
                        .invoke(wm, l);
            } catch (Throwable t) {
                Log.w(HomeDepthClock.TAG, "AOD clock weather: unregisterListener: " + t);
            }
        }
    }

    private void destroy() {
        stopWeather();
        try {
            provider.getClass().getMethod("onDestroy").invoke(provider);
            Log.i(HomeDepthClock.TAG, "AOD clock plugin destroyed");
        } catch (Throwable t) {
            Log.w(HomeDepthClock.TAG, "AOD clock plugin onDestroy", t);
        }
    }
}
