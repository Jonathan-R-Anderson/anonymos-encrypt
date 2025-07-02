module Main.Forms.NewSecurityTokenKeyfileDialog;

import Main.Forms.international;

class NewSecurityTokenKeyfileDialog : NewSecurityTokenKeyfileDialogBase
{
    this(wxWindow parent, wstring keyfileName)
    {
        super(parent);
        auto tokens = SecurityToken.getAvailableTokens();
        if (tokens.length == 0)
            throw_err(LangString["NO_TOKENS_FOUND"]);
        foreach(token; tokens)
        {
            auto tokenLabel = L"[" ~ to!wstring(token.SlotId) ~ L"] " ~ token.Label;
            SecurityTokenChoice.append(tokenLabel, cast(void*)token.SlotId);
        }
        SecurityTokenChoice.select(0);
        KeyfileNameTextCtrl.setValue(keyfileName);
        KeyfileNameTextCtrl.setMinSize(wxSize(Gui.getCharWidth(KeyfileNameTextCtrl) * 32, -1));
        Fit();
        Layout();
        Center();
    }

    wstring getKeyfileName() const { return KeyfileNameTextCtrl.getValue(); }
    CK_SLOT_ID getSelectedSlotId() const
    {
        return cast(CK_SLOT_ID) SecurityTokenChoice.getClientData(SecurityTokenChoice.getSelection());
    }

protected:
    void onKeyfileNameChanged(wxCommandEvent event)
    {
        OKButton.enable(!KeyfileNameTextCtrl.getValue().empty());
        event.skip();
    }
}
