module Volume.EncryptionMode;

import Volume.VolumePassword;

class EncryptionMode
{
    bool keySet;
    ulong sectorOffset;

    this()
    {
        keySet = false;
        sectorOffset = 0;
    }

    void decryptSectors(ubyte[] data, ulong sectorIndex, ulong sectorCount, size_t sectorSize)
    {
        // simple XOR-based decryption matching encryptSectors
        encryptSectors(data, sectorIndex, sectorCount, sectorSize);
    }

    void encryptSectors(ubyte[] data, ulong sectorIndex, ulong sectorCount, size_t sectorSize)
    {
        size_t pos = sectorIndex * sectorSize;
        for (ulong i = 0; i < sectorCount; ++i)
        {
            for (size_t j = 0; j < sectorSize; ++j)
            {
                data[pos + j] ^= cast(ubyte)((sectorOffset + pos + j) & 0xFF);
            }
            pos += sectorSize;
        }
    }
}

alias EncryptionModeList = EncryptionMode[];
