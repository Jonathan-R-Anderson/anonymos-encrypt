module Main.Forms.KeyfilesDialog;

import Main.Forms.international; // for LangString

class KeyfilesDialog : KeyfilesDialogBase
{
    KeyfileList keyfiles;
    KeyfilesPanel mKeyfilesPanel;

    this(wxWindow parent, KeyfileList keyfiles)
    {
        super(parent);
        this.keyfiles = keyfiles;
        mKeyfilesPanel = new KeyfilesPanel(this, keyfiles);
        PanelSizer.add(mKeyfilesPanel, 1, wxALL | wxEXPAND);
        WarningStaticText.setLabel(LangString["IDT_KEYFILE_WARNING"]);
        WarningStaticText.wrap(Gui.getCharWidth(this) * 15);
        Layout();
        Fit();
        KeyfilesNoteStaticText.setLabel(LangString["KEYFILES_NOTE"]);
        KeyfilesNoteStaticText.wrap(UpperSizer.getSize().getWidth() - Gui.getCharWidth(this) * 2);
        Layout();
        Fit();
        Center();
    }

    KeyfileList getKeyfiles() const { return mKeyfilesPanel.getKeyfiles(); }

protected:
    void onCreateKeyfileButttonClick(wxCommandEvent event)
    {
        Gui.createKeyfile();
    }

    void onKeyfilesHyperlinkClick(wxHyperlinkEvent event)
    {
        Gui.openHomepageLink(this, "keyfiles");
    }
}
