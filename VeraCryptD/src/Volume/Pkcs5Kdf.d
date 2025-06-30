module Volume.Pkcs5Kdf;

import Volume.VolumePassword;

class Pkcs5Kdf
{
    this() {}

    void deriveKey(ubyte[] key, const VolumePassword password, int pim, const(ubyte)[] salt)
    {
        uint hash = 0xabcdef01;
        foreach (b; password.passwordBuffer[0 .. password.passwordSize])
            hash = (hash * 31) ^ b;
        foreach (b; salt)
            hash = (hash * 31) ^ b;

        uint iter = cast(uint)(pim > 0 ? pim : 1000);
        for (uint i = 0; i < iter; ++i)
            hash = (hash * 1103515245 + 12345) & 0xffffffff;

        for (size_t i = 0; i < key.length; ++i)
        {
            hash = (hash * 1103515245 + 12345) & 0xffffffff;
            key[i] = cast(ubyte)(hash & 0xff);
        }
    }

    string getName() const { return "PKCS5"; }
}

alias Pkcs5KdfList = Pkcs5Kdf[];
