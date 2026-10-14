package com.k4.settingsintelligence;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.util.Log;
import com.android.settings.intelligence.search.SearchFeatureProvider;
import com.android.settings.intelligence.search.indexing.DatabaseIndexingManager;
import com.android.settings.intelligence.search.indexing.IndexDatabaseHelper;
import java.util.List;

/**
 * Settings search: answer typed queries from the already-built index while the per-open refresh runs.
 *
 * Stock: every time search opens with an empty query, SearchFragment starts an "essential" re-index
 * (DatabaseIndexingManager.IndexingTask -> performIndexing) and handleQueryText() drops every typed query until
 * that task finishes ("onQueryTextChanged: indexing is progressing"); results only appear on the requery in
 * onEssentialIndexingFinished. On the A52s that refresh takes ~3 s (it also competes with the parallel ~5 s
 * non-indexable pass in the Settings process).
 *
 * Here: when the refresh is NOT a full index (isFullIndex() false = same build fingerprint, same locale, no provider
 * package change, essential indexing finished before), the existing database is complete and queries run at once.
 * The stock requery after the refresh is untouched, so the final result list is exactly what stock shows.
 * The only table the non-full refresh empties and refills (sec_dynamic_prefs_index, dropped at the start of
 * performIndexing) is now emptied inside the same write transaction that refills it, so a query running during the
 * refresh sees either the old or the new dynamic rows, never none (the DB is WAL). Full indexes are unchanged.
 */
public final class K4SearchSpeed {
    private static final String TAG = "K4SearchSpeed";
    private static final String DYNAMIC_TABLE = "sec_dynamic_prefs_index";

    /** true while the running/last refresh is a non-full one over a complete, same-locale index. */
    private static volatile boolean sIndexUsable;

    /** set on the performIndexing thread when the dynamic-table clear was deferred into updateDatabase. */
    private static final ThreadLocal<Boolean> sDynamicClearPending = new ThreadLocal<>();

    private K4SearchSpeed() {}

    /** DatabaseIndexingManager.rebuildIndexingDataIfNeeded(isFullIndex, locale), first instruction. */
    public static void onIndexingStart(DatabaseIndexingManager m, boolean isFullIndex) {
        sDynamicClearPending.set(Boolean.FALSE);
        boolean usable = false;
        if (!isFullIndex) {
            try {
                usable = IndexDatabaseHelper.isIndexingFinished(m.mContext, "essential_indexing_finished");
            } catch (RuntimeException e) {
                Log.w(TAG, "isIndexingFinished failed: " + e);
            }
        }
        sIndexUsable = usable;
        Log.i(TAG, "refresh start: fullIndex=" + isFullIndex + " queryExistingIndex=" + usable);
    }

    /** replaces rebuildIndexingDataIfNeeded's call to rebuildDynamicIndexDatabase(). */
    public static void rebuildDynamic(DatabaseIndexingManager m) {
        if (sIndexUsable) {
            sDynamicClearPending.set(Boolean.TRUE); // cleared in insertDynamic, inside the refill transaction
        } else {
            m.rebuildDynamicIndexDatabase(); // stock
        }
    }

    /** replaces updateDatabase's insertIndexData(db, dynamicList, "sec_dynamic_prefs_index") (inside its transaction). */
    public static void insertDynamic(DatabaseIndexingManager m, SQLiteDatabase db, List list, String table) {
        if (Boolean.TRUE.equals(sDynamicClearPending.get()) && DYNAMIC_TABLE.equals(table)) {
            sDynamicClearPending.set(Boolean.FALSE);
            try {
                db.execSQL("DELETE FROM " + DYNAMIC_TABLE);
            } catch (SQLiteException e) {
                Log.w(TAG, "in-transaction clear failed (" + e + "), recreating the table");
                IndexDatabaseHelper.getInstance(m.mContext).reconstructDynamicIndexDb(db);
            }
        }
        m.insertIndexData(db, list, table);
    }

    /** replaces SearchFragment.handleQueryText's provider.isIndexingComplete(activity) gate. */
    public static boolean isIndexingComplete(SearchFeatureProvider provider, Context context) {
        if (provider.isIndexingComplete(context)) {
            return true;
        }
        if (!sIndexUsable || context == null) {
            return false;
        }
        try {
            DatabaseIndexingManager m = provider.getIndexingManager(context);
            if (m == null || m.isLocaleChanged()) {
                return false;
            }
        } catch (RuntimeException e) {
            return false;
        }
        Log.d(TAG, "refresh running: querying the existing index");
        return true;
    }
}
