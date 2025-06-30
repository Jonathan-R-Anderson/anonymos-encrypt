module Volume.EncryptionThreadPool;

import Volume.EncryptionMode;

class EncryptionThreadPool
{
    static void doWork(EncryptionMode mode, ubyte[] data, ulong startUnitNo, ulong unitCount, size_t sectorSize)
    {
        // simplified single-threaded work
        mode.encryptSectors(data, startUnitNo, unitCount, sectorSize);
    }
}
