module Main.Forms.AboutDialog;

class AboutDialog : AboutDialogBase
{
    this(wxWindow parent)
    {
        super(parent);
        // In C++ this configured various labels and logos which we omit.
    }

    void onWebsiteHyperlinkClick(wxHyperlinkEvent event)
    {
        Gui.openHomepageLink(this, "main");
    }
}
