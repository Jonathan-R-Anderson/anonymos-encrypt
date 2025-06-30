module Boot.Windows.BootEncryptedIo;

import Boot.Windows.BootDiskIo;
import Boot.Windows.BootConfig;
import Boot.Windows.BootDefs;
import Boot.Windows.BootDebug;

BiosResult ReadEncryptedSectors(ushort destSegment, ushort destOffset, ubyte drive, ulong sector, ushort sectorCount)
{
    BiosResult result;
    bool decrypt = true;

    if (BootCryptoInfo.hiddenVolume)
    {
        if (ReadWritePartiallyCoversEncryptedArea(sector, sectorCount))
            return BiosResult.InvalidFunction;
        if (sector >= EncryptedVirtualPartition.StartSector && sector <= EncryptedVirtualPartition.EndSector)
        {
            sector -= EncryptedVirtualPartition.StartSector;
            sector += HiddenVolumeStartSector;
        }
        else
            decrypt = false;
    }

    result = ReadSectors(destSegment, destOffset, drive, sector, sectorCount);
    if (result != BiosResult.Success || !decrypt)
        return result;

    if (BootCryptoInfo.hiddenVolume)
    {
        sector -= HiddenVolumeStartSector;
        sector += PimValueOrHiddenVolumeStartUnitNo;
    }

    if (drive == EncryptedVirtualPartition.Drive)
    {
        while (sectorCount-- > 0)
        {
            if (BootCryptoInfo.hiddenVolume || (sector >= EncryptedVirtualPartition.StartSector && sector <= EncryptedVirtualPartition.EndSector))
            {
                AcquireSectorBuffer();
                CopyMemory(destSegment, destOffset, SectorBuffer.ptr, TC_LB_SIZE);
                DecryptDataUnits(SectorBuffer.ptr, &sector, 1, BootCryptoInfo);
                CopyMemory(SectorBuffer.ptr, destSegment, destOffset, TC_LB_SIZE);
                ReleaseSectorBuffer();
            }
            ++sector;
            destOffset += TC_LB_SIZE;
        }
    }
    return result;
}

BiosResult WriteEncryptedSectors(ushort sourceSegment, ushort sourceOffset, ubyte drive, ulong sector, ushort sectorCount)
{
    BiosResult result = BiosResult.Success;
    AcquireSectorBuffer();
    ulong dataUnitNo = sector;
    ulong writeOffset = 0;

    if (BootCryptoInfo.hiddenVolume)
    {
        if (ReadWritePartiallyCoversEncryptedArea(sector, sectorCount))
            return BiosResult.InvalidFunction;
        writeOffset = HiddenVolumeStartSector;
        writeOffset -= EncryptedVirtualPartition.StartSector;
        dataUnitNo -= EncryptedVirtualPartition.StartSector;
        dataUnitNo += PimValueOrHiddenVolumeStartUnitNo;
    }

    while (sectorCount-- > 0)
    {
        CopyMemory(sourceSegment, sourceOffset, SectorBuffer.ptr, TC_LB_SIZE);
        if (drive == EncryptedVirtualPartition.Drive && sector >= EncryptedVirtualPartition.StartSector && sector <= EncryptedVirtualPartition.EndSector)
        {
            EncryptDataUnits(SectorBuffer.ptr, &dataUnitNo, 1, BootCryptoInfo);
        }
        result = ReadWriteSectors(true, SectorBuffer.ptr, drive, sector + writeOffset, 1, true);
        if (BiosResult.Timeout == result)
        {
            if (BiosResult.Success == ReadWriteSectors(false, TC_BOOT_LOADER_BUFFER_SEGMENT, 0, drive, sector + writeOffset, 8, false))
            {
                CopyMemory(SectorBuffer.ptr, TC_BOOT_LOADER_BUFFER_SEGMENT,0, TC_LB_SIZE);
                result = ReadWriteSectors(true, TC_BOOT_LOADER_BUFFER_SEGMENT, 0, drive, sector + writeOffset, 8, true);
            }
        }
        if (result != BiosResult.Success)
        {
            ulong tmp = sector + writeOffset;
            PrintDiskError(result, true, drive, &tmp);
            break;
        }
        ++sector;
        ++dataUnitNo;
        sourceOffset += TC_LB_SIZE;
    }
    ReleaseSectorBuffer();
    return result;
}

static bool ReadWritePartiallyCoversEncryptedArea(const ulong sector, ushort sectorCount)
{
    ulong readWriteEnd = sector + --sectorCount;
    return ((sector < EncryptedVirtualPartition.StartSector && readWriteEnd >= EncryptedVirtualPartition.StartSector) ||
            (sector >= EncryptedVirtualPartition.StartSector && readWriteEnd > EncryptedVirtualPartition.EndSector));
}
