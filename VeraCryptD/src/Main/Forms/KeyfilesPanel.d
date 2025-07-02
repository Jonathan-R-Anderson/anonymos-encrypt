module Main.Forms.KeyfilesPanel;

class KeyfilesPanel : KeyfilesPanelBase
{
    this(wxWindow parent, KeyfileList keyfiles)
    {
        super(parent);
        KeyfilesListCtrl.insertColumn(0, LangString["KEYFILE"], wxLIST_FORMAT_LEFT, 1);
        Gui.setListCtrlHeight(KeyfilesListCtrl, 10);
        Layout();
        Fit();
        if (keyfiles !is null)
        {
            foreach(k; keyfiles)
            {
                string[] fields; fields ~= FilesystemPath(k);
                Gui.appendToListCtrl(KeyfilesListCtrl, fields);
            }
        }
        auto drop = new FileDropTarget(this);
        setDropTarget(drop);
        KeyfilesListCtrl.setDropTarget(new FileDropTarget(this));
        foreach(c; getChildren()) c.setDropTarget(new FileDropTarget(this));
        updateButtons();
    }

    void addKeyfile(Keyfile keyfile)
    {
        string[] fields; fields ~= FilesystemPath(keyfile);
        Gui.appendToListCtrl(KeyfilesListCtrl, fields);
        updateButtons();
    }

    KeyfileList getKeyfiles() const
    {
        KeyfileList keyfiles;
        for(long i=0;i<KeyfilesListCtrl.getItemCount();i++)
            keyfiles ~= Keyfile(KeyfilesListCtrl.getItemText(i));
        return keyfiles;
    }

    void onAddDirectoryButtonClick(wxCommandEvent event)
    {
        auto dir = Gui.selectDirectory(this, LangString["SELECT_KEYFILE_PATH"]);
        if (!dir.isEmpty())
        {
            string[] fields; fields ~= dir;
            Gui.appendToListCtrl(KeyfilesListCtrl, fields);
            updateButtons();
        }
    }

    void onAddFilesButtonClick(wxCommandEvent event)
    {
        auto files = Gui.selectFiles(this, LangString["SELECT_KEYFILES"], false, true);
        foreach(f; files)
        {
            string[] fields; fields ~= f;
            Gui.appendToListCtrl(KeyfilesListCtrl, fields);
        }
        updateButtons();
    }

    void onAddSecurityTokenSignatureButtonClick(wxCommandEvent event)
    {
        try
        {
            auto dialog = new SecurityTokenKeyfilesDialog(this);
            if (dialog.showModal() == wxID_OK)
            {
                foreach(path; dialog.getSelectedSecurityTokenKeyfilePaths())
                {
                    string[] fields; fields ~= path;
                    Gui.appendToListCtrl(KeyfilesListCtrl, fields);
                }
                updateButtons();
            }
        }
        catch(Exception e)
        {
            Gui.showError(e);
        }
    }

    void onListSizeChanged(wxSizeEvent event)
    {
        int[] cols; cols ~= 1000;
        Gui.setListCtrlColumnWidths(KeyfilesListCtrl, cols);
        event.skip();
    }

    void onRemoveAllButtonClick(wxCommandEvent event)
    {
        KeyfilesListCtrl.deleteAllItems();
        updateButtons();
    }

    void onRemoveButtonClick(wxCommandEvent event)
    {
        long offset = 0;
        foreach(item; Gui.getListCtrlSelectedItems(KeyfilesListCtrl))
            KeyfilesListCtrl.deleteItem(item - offset++);
        updateButtons();
    }

    void updateButtons()
    {
        RemoveAllButton.enable(KeyfilesListCtrl.getItemCount() > 0);
        RemoveButton.enable(KeyfilesListCtrl.getSelectedItemCount() > 0);
    }

    private class FileDropTarget : wxFileDropTarget
    {
        KeyfilesPanel panel;
        this(KeyfilesPanel p){ panel = p; }
        override wxDragResult onDragOver(int x, int y, wxDragResult def){ return wxDragLink; }
        override bool onDropFiles(int x, int y, const wxArrayString &files)
        {
            foreach(f; files)
                panel.addKeyfile(Keyfile(wstring(f)));
            return true;
        }
    }
}
