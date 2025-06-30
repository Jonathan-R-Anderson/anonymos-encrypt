module Volume.EncryptionModeWolfCryptXTS;

import Volume.EncryptionMode;

class EncryptionModeWolfCryptXTS : EncryptionMode
{
    this() {}

    override void encryptSectors(ubyte[] data, ulong sectorIndex, ulong sectorCount, size_t sectorSize)
    {
        // stub for XTS encryption
    }

    override void decryptSectors(ubyte[] data, ulong sectorIndex, ulong sectorCount, size_t sectorSize)
    {
        // stub for XTS decryption
    }

    size_t getKeySize() const { return 0; }
}
