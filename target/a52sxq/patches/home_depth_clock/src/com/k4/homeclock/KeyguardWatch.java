package com.k4.homeclock;

import android.app.KeyguardManager;
import android.content.Context;
import android.util.Log;

/**
 * Keyguard state for the shared home+lock instance: its single surface is the lock screen, AOD and home wallpaper at
 * once, so its clock is drawn only while the keyguard is gone (and the display is ON, see ClockNode). Installed once
 * per process, only when such a clock exists (needs SUBSCRIBE_TO_KEYGUARD_LOCKED_STATE, which SpriteWallpaper holds).
 * On a change every visible engine with a clock redraws if its clock is now stale (shown <-> hidden).
 */
final class KeyguardWatch {
    static volatile boolean locked = true; // until known: never risk a clock on the lock screen
    private static boolean installed;

    private KeyguardWatch() {}

    static synchronized void ensure(Context context) {
        if (installed) {
            return;
        }
        KeyguardManager km = context.getSystemService(KeyguardManager.class);
        if (km == null) {
            return;
        }
        locked = km.isKeyguardLocked();
        km.addKeyguardLockedStateListener(context.getApplicationContext().getMainExecutor(),
                new KeyguardManager.KeyguardLockedStateListener() {
                    @Override
                    public void onKeyguardLockedStateChanged(boolean isLocked) {
                        locked = isLocked;
                        for (EngineState st : HomeDepthClock.states()) {
                            st.redrawIfStale(isLocked ? "keyguard shown" : "keyguard gone", true);
                        }
                    }
                });
        installed = true;
        Log.i(HomeDepthClock.TAG, "keyguard watch installed, locked=" + locked);
    }
}
