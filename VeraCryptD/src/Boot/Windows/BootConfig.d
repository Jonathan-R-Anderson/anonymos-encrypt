module Boot.Windows.BootConfig;

import Boot.Windows.BootDiskIo;
import Boot.Windows.BootDefs;
import Boot.Windows.BootConsoleIo;
import Boot.Windows.BootStrings;
import Boot.Windows.BootDebug;

__gshared ubyte BootSectorFlags;
__gshared ubyte BootLoaderDrive;
__gshared ubyte BootDrive;
__gshared bool BootDriveGeometryValid = false;
__gshared bool PreventNormalSystemBoot = false;
__gshared bool PreventBootMenu = false;
__gshared char[TC_BOOT_SECTOR_USER_MESSAGE_MAX_LENGTH + 1] CustomUserMessage;
__gshared uint OuterVolumeBackupHeaderCrc;

__gshared bool BootStarted = false;

__gshared DriveGeometry BootDriveGeometry;
__gshared CRYPTO_INFO* BootCryptoInfo;
__gshared Partition EncryptedVirtualPartition;

__gshared Partition ActivePartition;
__gshared Partition PartitionFollowingActive;
__gshared bool ExtraBootPartitionPresent = false;
__gshared ulong PimValueOrHiddenVolumeStartUnitNo;
__gshared ulong HiddenVolumeStartSector;

version(TC_WINDOWS_BOOT_RESCUE_DISK_MODE) {}
else
{
    void ReadBootSectorUserConfiguration()
    {
        ubyte userConfig;

        AcquireSectorBuffer();

        if (ReadWriteMBR(false, BootLoaderDrive, true) != BiosResult.Success)
            goto ret;

        userConfig = SectorBuffer[TC_BOOT_SECTOR_USER_CONFIG_OFFSET];

        PreventBootMenu = (userConfig & TC_BOOT_USER_CFG_FLAG_DISABLE_ESC) != 0;

        memcpy(CustomUserMessage.ptr, SectorBuffer.ptr + TC_BOOT_SECTOR_USER_MESSAGE_OFFSET,
               TC_BOOT_SECTOR_USER_MESSAGE_MAX_LENGTH);
        CustomUserMessage[TC_BOOT_SECTOR_USER_MESSAGE_MAX_LENGTH] = 0;

        if ((userConfig & TC_BOOT_USER_CFG_FLAG_SILENT_MODE) != 0)
        {
            if (CustomUserMessage[0])
            {
                InitVideoMode();
                Print(CustomUserMessage.ptr);
            }

            DisableScreenOutput();
        }

        if ((userConfig & TC_BOOT_USER_CFG_FLAG_DISABLE_PIM) != 0)
        {
            PimValueOrHiddenVolumeStartUnitNo = 0;
            memcpy(&PimValueOrHiddenVolumeStartUnitNo, SectorBuffer.ptr + TC_BOOT_SECTOR_PIM_VALUE_OFFSET,
                   TC_BOOT_SECTOR_PIM_VALUE_SIZE);
        }
        else
            PimValueOrHiddenVolumeStartUnitNo = cast(ulong)-1;

        OuterVolumeBackupHeaderCrc = *cast(uint*)(SectorBuffer.ptr + TC_BOOT_SECTOR_OUTER_VOLUME_BAK_HEADER_CRC_OFFSET);

    ret:
        ReleaseSectorBuffer();
    }

    BiosResult UpdateBootSectorConfiguration(ubyte drive)
    {
        ulong mbrSector = 0;

        AcquireSectorBuffer();
        BiosResult result = ReadWriteSectors(false, TC_BOOT_LOADER_BUFFER_SEGMENT, 0, drive, mbrSector, 8, false);
        if (result != BiosResult.Success)
            goto ret;

        CopyMemory(TC_BOOT_LOADER_BUFFER_SEGMENT, 0, SectorBuffer.ptr, TC_LB_SIZE);
        SectorBuffer[TC_BOOT_SECTOR_CONFIG_OFFSET] = BootSectorFlags;
        CopyMemory(SectorBuffer.ptr, TC_BOOT_LOADER_BUFFER_SEGMENT,0, TC_LB_SIZE);

        result = ReadWriteSectors(true, TC_BOOT_LOADER_BUFFER_SEGMENT, 0, drive, mbrSector, 8, false);

    ret:
        ReleaseSectorBuffer();
        return result;
    }
}
