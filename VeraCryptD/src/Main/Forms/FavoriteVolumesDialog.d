module Main.Forms.FavoriteVolumesDialog;

class FavoriteVolumesDialog : FavoriteVolumesDialogBase
{
    FavoriteVolumeList favorites;
    this(wxWindow parent, FavoriteVolumeList favorites, size_t newItemCount)
    {
        super(parent);
        this.favorites = favorites;
        int[] cols;
        FavoritesListCtrl.insertColumn(ColumnVolumePath, LangString["VOLUME"], wxLIST_FORMAT_LEFT, 1); cols ~= 500;
        FavoritesListCtrl.insertColumn(ColumnMountPoint, LangString["MOUNT_POINT"], wxLIST_FORMAT_LEFT, 1); cols ~= 500;
        FavoritesListCtrl.setMinSize(wxSize(400, -1));
        Gui.setListCtrlHeight(FavoritesListCtrl, 15);
        Gui.setListCtrlColumnWidths(FavoritesListCtrl, cols);
        Layout();
        Fit();
        Center();
        auto fields = new wstring[FavoritesListCtrl.getColumnCount()];
        size_t itemCount = 0;
        foreach(favorite; favorites)
        {
            fields[ColumnVolumePath] = favorite.Path;
            fields[ColumnMountPoint] = favorite.MountPoint;
            Gui.appendToListCtrl(FavoritesListCtrl, fields, -1, favorite.ptr);
            if (++itemCount > favorites.length - newItemCount)
            {
                FavoritesListCtrl.setItemState(itemCount - 1, wxLIST_STATE_SELECTED, wxLIST_STATE_SELECTED);
                FavoritesListCtrl.ensureVisible(itemCount - 1);
            }
        }
        updateButtons();
        FavoritesListCtrl.setFocus();
    }
    void onMoveDownButtonClick(wxCommandEvent event)
    {
        foreach_reverse(long itemIndex; Gui.getListCtrlSelectedItems(FavoritesListCtrl))
        {
            if (itemIndex >= FavoritesListCtrl.getItemCount() - 1) break;
            Gui.moveListCtrlItem(FavoritesListCtrl, itemIndex, itemIndex + 1);
        }
        updateButtons();
    }
    void onMoveUpButtonClick(wxCommandEvent event)
    {
        foreach(long itemIndex; Gui.getListCtrlSelectedItems(FavoritesListCtrl))
        {
            if (itemIndex == 0) break;
            Gui.moveListCtrlItem(FavoritesListCtrl, itemIndex, itemIndex - 1);
        }
        updateButtons();
    }
    void onOKButtonClick(wxCommandEvent event)
    {
        FavoriteVolumeList newFav;
        for(long i=0;i<FavoritesListCtrl.getItemCount();i++)
            newFav ~= FavoriteVolume(*cast(FavoriteVolume*)FavoritesListCtrl.getItemData(i));
        favorites = newFav;
        EndModal(wxID_OK);
    }
    void onRemoveAllButtonClick(wxCommandEvent event)
    {
        FavoritesListCtrl.deleteAllItems();
        updateButtons();
    }
    void onRemoveButtonClick(wxCommandEvent event)
    {
        long offset=0;
        foreach(item; Gui.getListCtrlSelectedItems(FavoritesListCtrl))
            FavoritesListCtrl.deleteItem(item - offset++);
    }
    void updateButtons()
    {
        bool selected = FavoritesListCtrl.getSelectedItemCount() > 0;
        MoveDownButton.enable(selected);
        MoveUpButton.enable(selected);
        RemoveAllButton.enable(FavoritesListCtrl.getItemCount() > 0);
        RemoveButton.enable(selected);
    }
}
