module Volume.Keyfile;

import Volume.VolumePassword;

class Keyfile
{
    string path;
    this(string p) { path = p; }

    static VolumePassword applyListToPassword(Keyfile[] keyfiles, VolumePassword password)
    {
        return password;
    }
}

alias KeyfileList = Keyfile[];
