module Main.Forms.VolumePasswordWizardPage;

class VolumePasswordWizardPage : VolumePasswordWizardPageBase
{
    bool confirmationMode;
    VolumePasswordPanel passwordPanel;

    this(wxPanel parent, VolumePassword password, KeyfileList keyfiles, bool enableConfirmation = true)
    {
        super(parent);
        confirmationMode = enableConfirmation;
        passwordPanel = new VolumePasswordPanel(this, null, password, keyfiles, false, true, true,
                                                enableConfirmation, !enableConfirmation, !enableConfirmation);
        passwordPanel.updateEvent.connect(&onPasswordPanelUpdate);
        PasswordPanelSizer.add(passwordPanel, 1, wxALL | wxEXPAND);
    }

    ~this()
    {
        passwordPanel.updateEvent.disconnect(this);
    }

    bool isValid()
    {
        if (confirmationMode && !passwordPanel.passwordsMatch())
            return false;
        try
        {
            auto kf = getKeyfiles();
            auto pwd = getPassword();
            return (pwd !is null && !pwd.isEmpty()) || (kf !is null && !kf.empty);
        }
        catch (PasswordException e)
        {
            return false;
        }
    }

    KeyfileList getKeyfiles() const { return passwordPanel.getKeyfiles(); }
    VolumePassword getPassword() const { return passwordPanel.getPassword(); }
    void enableUsePim() { passwordPanel.enableUsePim(); }
    bool isPimSelected() const { return passwordPanel.isUsePimChecked(); }
    void setPimSelected(bool selected) const { passwordPanel.setUsePimChecked(selected); }
    Pkcs5Kdf getPkcs5Kdf() const { return passwordPanel.getPkcs5Kdf(); }
    void setMaxStaticTextWidth(int width) { InfoStaticText.wrap(width); }
    void setPageText(string text) { InfoStaticText.setLabel(text); }

protected:
    void onPasswordPanelUpdate(EventArgs args) { PageUpdatedEvent.raise(); }
}
