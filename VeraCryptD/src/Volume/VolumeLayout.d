module Volume.VolumeLayout;

import Volume.EncryptionMode;
import Volume.EncryptionModeWolfCryptXTS;

class VolumeLayout
{
    ulong dataOffset;
    ulong dataSize;

    this(ulong offset = 0, ulong size = 0)
    {
        dataOffset = offset;
        dataSize = size;
    }

    ulong getDataOffset(ulong volumeHostSize) const { return dataOffset; }
    ulong getDataSize(ulong volumeHostSize) const { return dataSize; }
}

alias VolumeLayoutList = VolumeLayout[];
