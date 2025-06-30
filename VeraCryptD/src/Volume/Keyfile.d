module Volume.Keyfile;

import Volume.VolumePassword;

class Keyfile
{
    string path;
    this(string p) { path = p; }

    static VolumePassword applyListToPassword(Keyfile[] keyfiles, VolumePassword password)
    {
        import std.stdio : File;
        import std.file : read;
        foreach(kf; keyfiles)
        {
            try
            {
                auto content = cast(ubyte[]) read(kf.path);
                size_t i = 0;
                foreach (ubyte b; cast(ubyte[])content)
                {
                    if (i < password.passwordBuffer.length)
                    {
                        password.passwordBuffer[i] ^= b;
                        ++i;
                    }
                    else
                        break;
                }
                if (i > password.passwordSize)
                    password.passwordSize = i;
            }
            catch (Exception)
            {
                // ignore errors reading keyfiles
            }
        }
        return password;
    }
}

alias KeyfileList = Keyfile[];
