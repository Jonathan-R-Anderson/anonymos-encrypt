module Main.Forms.SelectDirectoryWizardPage;

class SelectDirectoryWizardPage : SelectDirectoryWizardPageBase
{
    this(wxPanel parent)
    {
        super(parent);
    }

    DirectoryPath getDirectory() const
    {
        return DirectoryPath(DirectoryTextCtrl.getValue().wc_str());
    }

    bool isValid()
    {
        if (!DirectoryTextCtrl.isEmpty())
            return FilesystemPath(DirectoryTextCtrl.getValue().wc_str()).isDirectory();
        return false;
    }

    void setDirectory(DirectoryPath path)
    {
        DirectoryTextCtrl.setValue(cast(string)path);
    }

    void setMaxStaticTextWidth(int width) { InfoStaticText.wrap(width); }
    void setPageText(string text) { InfoStaticText.setLabel(text); }

protected:
    void onBrowseButtonClick(wxCommandEvent event)
    {
        auto dir = Gui.selectDirectory(this);
        if (!dir.isEmpty())
            DirectoryTextCtrl.setValue(cast(string)dir);
    }

    void onDirectoryTextChanged(wxCommandEvent event)
    {
        PageUpdatedEvent.raise();
    }
}
