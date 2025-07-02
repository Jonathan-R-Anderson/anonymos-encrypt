module Main.Forms.VolumePropertiesDialog;

class VolumePropertiesDialog : VolumePropertiesDialogBase
{
    this(wxWindow parent, const VolumeInfo volumeInfo)
    {
        super(parent);
        int[] colPermilles;
        PropertiesListCtrl.insertColumn(0, LangString["PROPERTY"], wxLIST_FORMAT_LEFT, 208);
        colPermilles ~= 500;
        PropertiesListCtrl.insertColumn(1, LangString["VALUE"], wxLIST_FORMAT_LEFT, 192);
        colPermilles ~= 500;
        Gui.setListCtrlWidth(PropertiesListCtrl, 70, false);
        Gui.setListCtrlHeight(PropertiesListCtrl, 17);
        Gui.setListCtrlColumnWidths(PropertiesListCtrl, colPermilles, false);
        appendToList("LOCATION", cast(wstring)volumeInfo.Path);
        appendToList("SIZE", Gui.sizeToString(volumeInfo.Size));
        appendToList("TYPE", Gui.volumeTypeToString(volumeInfo.Type, volumeInfo.Protection));
        appendToList("READ_ONLY", LangString[volumeInfo.Protection==VolumeProtection.ReadOnly ? "UISTR_YES" : "UISTR_NO"]);
        wxString protection;
        if (volumeInfo.Type == VolumeType.Hidden)
            protection = LangString["NOT_APPLICABLE_OR_NOT_AVAILABLE"];
        else if (volumeInfo.HiddenVolumeProtectionTriggered)
            protection = LangString["HID_VOL_DAMAGE_PREVENTED"];
        else
            protection = LangString[volumeInfo.Protection == VolumeProtection.HiddenVolumeReadOnly ? "UISTR_YES" : "UISTR_NO"];
        appendToList("HIDDEN_VOL_PROTECTION", protection);
        appendToList("ENCRYPTION_ALGORITHM", volumeInfo.EncryptionAlgorithmName);
        appendToList("KEY_SIZE", StringFormatter(L"{0} {1}", volumeInfo.EncryptionAlgorithmKeySize * 8, LangString["BITS"]));
        if (volumeInfo.EncryptionModeName == L"XTS")
            appendToList("SECONDARY_KEY_SIZE_XTS", StringFormatter(L"{0} {1}", volumeInfo.EncryptionAlgorithmKeySize * 8, LangString["BITS"]));
        auto blockSize = to!wstring(volumeInfo.EncryptionAlgorithmBlockSize * 8);
        if (volumeInfo.EncryptionAlgorithmBlockSize != volumeInfo.EncryptionAlgorithmMinBlockSize)
            blockSize ~= L"/" ~ to!wstring(volumeInfo.EncryptionAlgorithmMinBlockSize * 8);
        appendToList("BLOCK_SIZE", blockSize ~ L" " ~ LangString["BITS"]);
        appendToList("MODE_OF_OPERATION", volumeInfo.EncryptionModeName);
        if (volumeInfo.Pim <= 0)
            appendToList("PKCS5_PRF", volumeInfo.Pkcs5PrfName);
        else
            appendToList("PKCS5_PRF", StringFormatter(L"{0} (Dynamic)", volumeInfo.Pkcs5PrfName));
        appendToList("VOLUME_FORMAT_VERSION", StringConverter.toWide(volumeInfo.MinRequiredProgramVersion < 0x10b ? "1" : "2"));
        appendToList("BACKUP_HEADER", LangString[volumeInfo.MinRequiredProgramVersion >= 0x10b ? "UISTR_YES" : "UISTR_NO"]);
        appendToList("TOTAL_DATA_READ", Gui.sizeToString(volumeInfo.TotalDataRead));
        appendToList("TOTAL_DATA_WRITTEN", Gui.sizeToString(volumeInfo.TotalDataWritten));
        Layout();
        Fit();
        Center();
        OKButton.setDefault();
    }

    private void appendToList(string name, wxString value)
    {
        string[] fields; fields.length = PropertiesListCtrl.getColumnCount();
        fields[0] = LangString[name];
        fields[1] = value;
        Gui.appendToListCtrl(PropertiesListCtrl, fields);
    }
}
