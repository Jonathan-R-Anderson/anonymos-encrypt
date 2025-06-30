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
        // stub
    }

    void encryptSectors(ubyte[] data, ulong sectorIndex, ulong sectorCount, size_t sectorSize)
    {
        // stub
    }
}

alias EncryptionModeList = EncryptionMode[];
