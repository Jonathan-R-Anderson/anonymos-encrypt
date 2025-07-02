module Main.Forms.DeviceSelectionDialog;

class DeviceSelectionDialog : DeviceSelectionDialogBase
{
    HostDeviceList deviceList;
    HostDevice selectedDevice;
    this(wxWindow parent)
    {
        super(parent);
        wxBusyCursor busy;
        int[] cols;
        DeviceListCtrl.insertColumn(ColumnDevice, LangString["DEVICE"], wxLIST_FORMAT_LEFT, 1); cols ~= 447;
        version(TC_WINDOWS){ DeviceListCtrl.insertColumn(ColumnDrive, LangString["DRIVE"], wxLIST_FORMAT_LEFT,1); cols ~= 91; }
        DeviceListCtrl.insertColumn(ColumnSize, LangString["SIZE"], wxLIST_FORMAT_RIGHT, 1); cols ~= 153;
        version(TC_WINDOWS){ DeviceListCtrl.insertColumn(ColumnName, LangString["LABEL"], wxLIST_FORMAT_LEFT,1); cols ~= 307; }
        else{ DeviceListCtrl.insertColumn(ColumnMountPoint, LangString["MOUNT_POINT"], wxLIST_FORMAT_LEFT,1); cols ~= 396; }
        auto imageList = new wxImageList(16,12,true);
        imageList.add(Resources.getDriveIconBitmap(), Resources.getDriveIconMaskBitmap());
        DeviceListCtrl.assignImageList(imageList, wxIMAGE_LIST_SMALL);
        deviceList = Core.getHostDevices();
        foreach(ref device; deviceList)
        {
            string[] fields(DeviceListCtrl.getColumnCount());
            if (DeviceListCtrl.getItemCount() > 0)
                Gui.appendToListCtrl(DeviceListCtrl, fields);
            if (device.Size == 0)
            {
                bool hasNonEmpty=false;
                foreach(ref part; device.Partitions){ if(part.Size){ hasNonEmpty=true; break; } }
                if (!hasNonEmpty) continue;
            }
            version(TC_WINDOWS){ fields[ColumnDevice] = StringFormatter(L"{0} {1}:", LangString["HARDDISK"], device.SystemNumber); fields[ColumnDrive]=device.MountPoint; fields[ColumnName]=device.Name; }
            else{ fields[ColumnDevice]=cast(string)device.Path ~ ":"; fields[ColumnMountPoint]=device.MountPoint; }
            fields[ColumnSize] = device.Size ? Gui.sizeToString(device.Size) : "";
            Gui.appendToListCtrl(DeviceListCtrl, fields, 0, &device);
            foreach(ref partition; device.Partitions)
            {
                if (!partition.Size) continue;
                fields[ColumnDevice] = version(TC_WINDOWS) ? cast(string)partition.Path : "      " ~ cast(string)partition.Path;
                version(TC_WINDOWS){ fields[ColumnDrive]=partition.MountPoint; fields[ColumnName]=partition.Name; }
                else{ fields[ColumnMountPoint]=partition.MountPoint; }
                fields[ColumnSize] = Gui.sizeToString(partition.Size);
                Gui.appendToListCtrl(DeviceListCtrl, fields, -1, &partition);
            }
        }
        Gui.setListCtrlWidth(DeviceListCtrl, 73);
        Gui.setListCtrlHeight(DeviceListCtrl, 16);
        Gui.setListCtrlColumnWidths(DeviceListCtrl, cols);
        Fit();
        Layout();
        Center();
        OKButton.disable();
        OKButton.setDefault();
    }
    void onListItemActivated(wxListEvent event) { if (OKButton.isEnabled()) EndModal(wxID_OK); }
    void onListItemDeselected(wxListEvent event){ if (DeviceListCtrl.getSelectedItemCount() == 0) OKButton.disable(); }
    void onListItemSelected(wxListEvent event)
    {
        auto device = cast(HostDevice*)event.getItem().getData();
        if (device && device.Size)
        {
            selectedDevice = *device;
            OKButton.enable();
        }
        else OKButton.disable();
    }
}
