module Main.Forms.LegalNoticesDialog;

class LegalNoticesDialog : LegalNoticesDialogBase
{
    this(wxWindow parent)
    {
        super(parent);
        // Display legal notices text from resources
        LegalNoticesTextCtrl.changeValue(Resources.getLegalNotices());
        center();
    }
}
