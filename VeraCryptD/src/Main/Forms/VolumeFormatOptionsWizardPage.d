module Main.Forms.VolumeFormatOptionsWizardPage;

class VolumeFormatOptionsWizardPage : VolumeFormatOptionsWizardPageBase
{
    this(wxPanel parent, ulong filesystemSize, uint sectorSize, bool enableQuickFormatButton, bool disableNoneFilesystem, bool disable32bitFilesystems)
    {
        super(parent);
        InfoStaticText.setLabel(LangString["QUICK_FORMAT_HELP"]);
        if (!disableNoneFilesystem)
            FilesystemTypeChoice.append(LangString["NONE"], cast(void*)VolumeCreationOptions.FilesystemType.None);
        if (!disable32bitFilesystems && filesystemSize <= TC_MAX_FAT_SECTOR_COUNT * sectorSize)
            FilesystemTypeChoice.append("FAT", cast(void*)VolumeCreationOptions.FilesystemType.FAT);
        version(TC_WINDOWS)
        {
            FilesystemTypeChoice.append("NTFS", cast(void*)VolumeCreationOptions.FilesystemType.NTFS);
            FilesystemTypeChoice.append("exFAT", cast(void*)VolumeCreationOptions.FilesystemType.exFAT);
        }
        else version(TC_LINUX)
        {
            FilesystemTypeChoice.append("Linux Ext2", cast(void*)VolumeCreationOptions.FilesystemType.Ext2);
            FilesystemTypeChoice.append("Linux Ext3", cast(void*)VolumeCreationOptions.FilesystemType.Ext3);
            if (VolumeCreationOptions.FilesystemType.isFsFormatterPresent(VolumeCreationOptions.FilesystemType.Ext4))
                FilesystemTypeChoice.append("Linux Ext4", cast(void*)VolumeCreationOptions.FilesystemType.Ext4);
            if (VolumeCreationOptions.FilesystemType.isFsFormatterPresent(VolumeCreationOptions.FilesystemType.NTFS))
                FilesystemTypeChoice.append("NTFS", cast(void*)VolumeCreationOptions.FilesystemType.NTFS);
            if (VolumeCreationOptions.FilesystemType.isFsFormatterPresent(VolumeCreationOptions.FilesystemType.exFAT))
                FilesystemTypeChoice.append("exFAT", cast(void*)VolumeCreationOptions.FilesystemType.exFAT);
            if (VolumeCreationOptions.FilesystemType.isFsFormatterPresent(VolumeCreationOptions.FilesystemType.Btrfs))
            {
                if (filesystemSize >= VC_MIN_SMALL_BTRFS_VOLUME_SIZE)
                    FilesystemTypeChoice.append("Btrfs", cast(void*)VolumeCreationOptions.FilesystemType.Btrfs);
            }
        }
        else version(TC_MACOSX)
        {
            FilesystemTypeChoice.append("Mac OS Extended", cast(void*)VolumeCreationOptions.FilesystemType.MacOsExt);
            FilesystemTypeChoice.append("exFAT", cast(void*)VolumeCreationOptions.FilesystemType.exFAT);
        }
        else version(TC_FREEBSD) {} // simplified

        if (!disable32bitFilesystems && filesystemSize <= TC_MAX_FAT_SECTOR_COUNT * sectorSize)
            setFilesystemType(VolumeCreationOptions.FilesystemType.FAT);
        else
            setFilesystemType(VolumeCreationOptions.FilesystemType.getPlatformNative());
        QuickFormatCheckBox.enable(enableQuickFormatButton);
    }

    VolumeCreationOptions.FilesystemType.Enum getFilesystemType() const
    {
        return cast(VolumeCreationOptions.FilesystemType.Enum)Gui.getSelectedData!void(FilesystemTypeChoice);
    }

protected:
    void onFilesystemTypeSelected(wxCommandEvent event) {}
    void onQuickFormatCheckBoxClick(wxCommandEvent event)
    {
        if (event.isChecked())
            QuickFormatCheckBox.setValue(Gui.askYesNo(LangString["WARN_QUICK_FORMAT"], false, true));
    }
}
