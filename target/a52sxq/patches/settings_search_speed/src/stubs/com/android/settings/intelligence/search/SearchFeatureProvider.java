package com.android.settings.intelligence.search;
// compile-only stub of SecSettingsIntelligence's interface (not packaged)
public interface SearchFeatureProvider {
    com.android.settings.intelligence.search.indexing.DatabaseIndexingManager getIndexingManager(android.content.Context c);
    boolean isIndexingComplete(android.content.Context c);
}
