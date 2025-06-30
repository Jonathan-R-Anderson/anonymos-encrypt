module Volume.Pkcs5Kdf;

import Volume.VolumePassword;

class Pkcs5Kdf
{
    this() {}

    void deriveKey(ubyte[] key, const VolumePassword password, int pim, const(ubyte)[] salt)
    {
        // placeholder
    }

    string getName() const { return "PKCS5"; }
}

alias Pkcs5KdfList = Pkcs5Kdf[];
