module Main.Forms.VolumeLocationWizardPage;

class VolumeLocationWizardPage : VolumeLocationWizardPageBase
{
    bool selectExisting;
    this(wxPanel parent, VolumeHostType.Enum hostType, bool selectExisting)
    {
        super(parent);
        this.selectExisting = selectExisting;
        final switch(hostType)
        {
            case VolumeHostType.Device:
                SelectFileButton.show(false);
                break;
            case VolumeHostType.File:
                SelectDeviceButton.show(false);
                break;
            default:
                break;
        }
        Gui.PreferencesUpdatedEvent.connect(EventConnector!(VolumeLocationWizardPage)(this, &onPreferencesUpdated));
        VolumeHistory.connectComboBox(VolumePathComboBox);
        NoHistoryCheckBox.setValue(!Gui.getPreferences().SaveHistory);
    }
    ~this()
    {
        Gui.PreferencesUpdatedEvent.disconnect(this);
        VolumeHistory.disconnectComboBox(VolumePathComboBox);
    }
    void onNoHistoryCheckBoxClick(wxCommandEvent event)
    {
        auto prefs = Gui.getPreferences();
        prefs.SaveHistory = !event.isChecked();
        Gui.setPreferences(prefs);
        if (event.isChecked())
        {
            try { VolumeHistory.clear(); }
            catch(Exception e){ Gui.showError(e); }
        }
    }
    void onPageChanging(bool forward)
    {
        if (forward)
        {
            auto path = getVolumePath();
            if (!path.isEmpty())
                VolumeHistory.add(path);
        }
    }
    void onPreferencesUpdated(EventArgs args)
    {
        NoHistoryCheckBox.setValue(!Gui.getPreferences().SaveHistory);
    }
    void onSelectFileButtonClick(wxCommandEvent event)
    {
        auto path = Gui.selectVolumeFile(this, !selectExisting);
        if (!path.isEmpty())
            setVolumePath(path);
    }
    void onSelectDeviceButtonClick(wxCommandEvent event)
    {
        auto path = Gui.selectDevice(this);
        if (!path.isEmpty())
            setVolumePath(path);
    }
    void setVolumePath(VolumePath path)
    {
        VolumePathComboBox.setValue(cast(string)path);
        PageUpdatedEvent.raise();
    }
}
