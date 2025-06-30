module Boot.Windows.BootDiskIo;

import Boot.Windows.BootConsoleIo;
import Boot.Windows.BootDefs;
import Boot.Windows.BootDebug;
import Boot.Windows.Bios;

enum uint TC_MAX_BIOS_DISK_IO_RETRIES = 5;

enum BiosResultEccCorrected = 0x11;

#pragma pack(push,1)
struct PartitionEntryMBR
{
    ubyte BootIndicator;
    ubyte StartHead;
    ubyte StartCylSector;
    ubyte StartCylinder;
    ubyte Type;
    ubyte EndHead;
    ubyte EndSector;
    ubyte EndCylinder;
    uint StartLBA;
    uint SectorCountLBA;
}

struct MBR
{
    ubyte[446] Code;
    PartitionEntryMBR[4] Partitions;
    ushort Signature;
}

struct BiosLbaPacket
{
    ubyte Size;
    ubyte Reserved;
    ushort SectorCount;
    uint Buffer;
    ulong Sector;
}
#pragma pack(pop)

struct ChsAddress
{
    ushort Cylinder;
    ubyte Head;
    ubyte Sector;
}

struct Partition
{
    ubyte Number;
    ubyte Drive;
    bool Active;
    ulong EndSector;
    bool Primary;
    ulong SectorCount;
    ulong StartSector;
    ubyte Type;
}

struct DriveGeometry
{
    ushort Cylinders;
    ubyte Heads;
    ubyte Sectors;
}

__gshared ubyte[TC_LB_SIZE] SectorBuffer;

version(TC_BOOT_DEBUG_ENABLED)
{
    static bool SectorBufferInUse = false;
    void AcquireSectorBuffer()
    {
        if (SectorBufferInUse)
            assert(0);
        SectorBufferInUse = true;
    }
    void ReleaseSectorBuffer()
    {
        SectorBufferInUse = false;
    }
}
else
{
    void AcquireSectorBuffer() {}
    void ReleaseSectorBuffer() {}
}

bool IsLbaSupported(ubyte drive)
{
    static ubyte CachedDrive = TC_INVALID_BIOS_DRIVE;
    static bool CachedStatus;
    ushort result = 0;
    if (CachedDrive == drive)
        return CachedStatus;
    asm {
        mov bx, 0x55aa;
        mov dl, drive;
        mov ah, 0x41;
        int 0x13;
        jc err;
        mov result, bx;
    err:
    }
    CachedDrive = drive;
    CachedStatus = (result == 0xaa55);
    return CachedStatus;
}

void Print(const ChsAddress* chs)
{
    Print(chs.Cylinder);
    PrintChar('/');
    Print(chs.Head);
    PrintChar('/');
    Print(chs.Sector);
}

void PrintSectorCountInMB(const ulong sectorCount)
{
    Print(sectorCount >> (TC_LB_SIZE_BIT_SHIFT_DIVISOR + 2));
    Print(" MiB");
}

void PrintDiskError(BiosResult error, bool write, ubyte drive, const ulong* sector, const ChsAddress* chs=null)
{
    PrintEndl();
    Print(write ? "Write" : "Read");
    Print(" error:");
    Print(cast<uint>error);
    Print(" Drive:");
    Print(drive ^ 0x80);
    if (sector)
    {
        Print(" Sector:");
        Print(*sector);
    }
    if (chs)
    {
        Print(" CHS:");
        Print(*chs);
    }
    PrintEndl();
    Beep();
}

BiosResult ReadWriteSectors(bool write, BiosLbaPacket* dapPacket, ubyte drive, const ulong sector, ushort sectorCount, bool silent)
{
    CheckStack();
    ubyte function = write ? 0x43 : 0x42;
    BiosResult result;
    ubyte tryCount = TC_MAX_BIOS_DISK_IO_RETRIES;
    do
    {
        result = BiosResult.Success;
        asm {
            mov bx, 0x55aa;
            mov dl, drive;
            mov si, dapPacket;
            mov ah, function;
            xor al, al;
            int 0x13;
            jnc ok;
            mov result, ah;
        ok:
        }
        if (result == BiosResultEccCorrected)
            result = BiosResult.Success;
    } while (result != BiosResult.Success && --tryCount != 0);
    if (!silent && result != BiosResult.Success)
        PrintDiskError(result, write, drive, &sector);
    return result;
}

BiosResult ReadWriteSectors(bool write, ushort bufferSegment, ushort bufferOffset, ubyte drive, const ulong sector, ushort sectorCount, bool silent)
{
    BiosLbaPacket dap;
    dap.Buffer = (cast(uint)bufferSegment << 16) | bufferOffset;
    dap.Sector = sector;
    dap.SectorCount = sectorCount;
    return ReadWriteSectors(write, &dap, drive, sector, sectorCount, silent);
}

BiosResult ReadWriteSectors(bool write, ubyte* buffer, ubyte drive, const ulong sector, ushort sectorCount, bool silent)
{
    BiosLbaPacket dap;
    dap.Buffer = cast(uint)buffer;
    dap.Sector = sector;
    dap.SectorCount = sectorCount;
    return ReadWriteSectors(write, &dap, drive, sector, sectorCount, silent);
}

BiosResult ReadSectors(ushort bufferSegment, ushort bufferOffset, ubyte drive, const ulong sector, ushort sectorCount, bool silent)
{
    return ReadWriteSectors(false, bufferSegment, bufferOffset, drive, sector, sectorCount, silent);
}

BiosResult ReadSectors(ubyte* buffer, ubyte drive, const ulong sector, ushort sectorCount, bool silent)
{
    BiosResult result;
    ushort codeSeg;
    asm mov codeSeg, cs;
    result = ReadSectors(BootStarted ? codeSeg : TC_BOOT_LOADER_ALT_SEGMENT, cast(ushort)buffer, drive, sector, sectorCount, silent);
    if (!BootStarted)
        CopyMemory(TC_BOOT_LOADER_ALT_SEGMENT, cast(ushort)buffer, buffer, sectorCount * TC_LB_SIZE);
    return result;
}

BiosResult WriteSectors(ubyte* buffer, ubyte drive, const ulong sector, ushort sectorCount, bool silent)
{
    return ReadWriteSectors(true, buffer, drive, sector, sectorCount, silent);
}

BiosResult GetDriveGeometry(ubyte drive, DriveGeometry* geometry, bool silent)
{
    CheckStack();
    ubyte maxCylinderLow;
    ubyte maxHead;
    ubyte maxSector;
    BiosResult result;
    asm {
        push es;
        mov dl, drive;
        mov ah, 0x08;
        int 0x13;
        mov result, ah;
        mov maxCylinderLow, ch;
        mov maxSector, cl;
        mov maxHead, dh;
        pop es;
    }
    if (result == BiosResult.Success)
    {
        geometry.Cylinders = (maxCylinderLow | (cast(ushort)(maxSector & 0xc0) << 2)) + 1;
        geometry.Heads = maxHead + 1;
        geometry.Sectors = maxSector & ~0xc0;
    }
    else if (!silent)
    {
        Print("Drive ");
        Print(drive ^ 0x80);
        Print(" not found: ");
        PrintErrorNoEndl("");
        Print(cast<uint>result);
        PrintEndl();
    }
    return result;
}

void ChsToLba(const DriveGeometry* geometry, const ChsAddress* chs, ulong* lba)
{
    lba.high = 0;
    lba.low = (cast(uint)(chs.Cylinder) * geometry.Heads + chs.Head) * geometry.Sectors + chs.Sector - 1;
}

void LbaToChs(const DriveGeometry* geometry, const ulong lba, ChsAddress* chs)
{
    chs.Sector = cast(ubyte)((lba.low % geometry.Sectors) + 1);
    uint ch = lba.low / geometry.Sectors;
    chs.Head = cast(ubyte)(ch % geometry.Heads);
    chs.Cylinder = cast(ushort)(ch / geometry.Heads);
}

BiosResult ReadWriteMBR(bool write, ubyte drive, bool silent=false)
{
    ulong mbrSector = 0;
    if (write)
        return WriteSectors(SectorBuffer.ptr, drive, mbrSector, 1, silent);
    return ReadSectors(SectorBuffer.ptr, drive, mbrSector, 1, silent);
}

