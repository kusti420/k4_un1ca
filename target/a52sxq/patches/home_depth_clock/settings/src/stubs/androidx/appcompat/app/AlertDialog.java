package androidx.appcompat.app;
public class AlertDialog extends android.app.Dialog {
    public AlertDialog() { super(null); }
    // R8 made the setters of this SecSettings' copy return void
    public static class Builder {
        public Builder(android.content.Context c) { }
        public final void setTitle(int id) { throw new RuntimeException(); }
        public final void setSingleChoiceItems(CharSequence[] items, int checked, android.content.DialogInterface.OnClickListener l) { throw new RuntimeException(); }
        public final void setNegativeButton(int id, android.content.DialogInterface.OnClickListener l) { throw new RuntimeException(); }
        public AlertDialog create() { throw new RuntimeException(); }
    }
}
