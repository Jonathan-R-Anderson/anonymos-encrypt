module Volume.EncryptionModeWolfCryptXTS;

import Volume.EncryptionMode;

class EncryptionModeWolfCryptXTS : EncryptionMode
{
    this() {}

    override void encryptSectors(ubyte[] data, ulong sectorIndex, ulong sectorCount, size_t sectorSize)
    {
        // use base class simple XOR implementation
        super.encryptSectors(data, sectorIndex, sectorCount, sectorSize);
    }

    override void decryptSectors(ubyte[] data, ulong sectorIndex, ulong sectorCount, size_t sectorSize)
    {
        super.decryptSectors(data, sectorIndex, sectorCount, sectorSize);
    }

    size_t getKeySize() const { return 32; }
}
