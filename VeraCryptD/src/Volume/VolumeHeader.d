module Volume.VolumeHeader;

import Volume.EncryptionMode;
import Volume.VolumePassword;
import Volume.Pkcs5Kdf;
import Volume.VolumeException;
import Platform.Buffer;

alias VolumeTime = ulong;

enum VolumeType { Unknown, Normal, Hidden }

struct VolumeHeaderCreationOptions
{
    ConstBufferPtr dataKey;
    VolumePassword password;
    shared(Pkcs5Kdf) kdf;
    ConstBufferPtr salt;
    uint sectorSize;
    ulong volumeDataSize;
    ulong volumeDataStart;
    VolumeType type;
}

class VolumeHeader
{
    uint headerSize;
    ulong encryptedAreaStart;
    ulong encryptedAreaLength;
    ulong volumeDataSize;
    ulong hiddenVolumeDataSize;
    VolumeType volType = VolumeType.Unknown;
    uint sectorSize = 512;

    this(uint size)
    {
        headerSize = size;
    }

    void create(BufferPtr buffer, VolumeHeaderCreationOptions opt)
    {
        buffer.zero();
        volType = opt.type;
        volumeDataSize = opt.volumeDataSize;
        encryptedAreaStart = opt.volumeDataStart;
        encryptedAreaLength = opt.volumeDataSize;
        sectorSize = opt.sectorSize;
    }

    bool decrypt(ConstBufferPtr data, VolumePassword pwd, int pim,
                 shared(Pkcs5Kdf) kdf)
    {
        // Simplified: just check magic
        if (data.size < 4) return false;
        if (data[0] != 'V' || data[1] != 'E' || data[2] != 'R' || data[3] != 'A')
            return false;
        return true;
    }

    void encryptNew(BufferPtr buffer, ConstBufferPtr salt, ConstBufferPtr key,
                    shared(Pkcs5Kdf) newKdf)
    {
        buffer.zero();
        buffer[0] = 'V';
        buffer[1] = 'E';
        buffer[2] = 'R';
        buffer[3] = 'A';
    }
}
