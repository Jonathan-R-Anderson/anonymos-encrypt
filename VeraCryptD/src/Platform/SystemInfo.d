module Platform.SystemInfo;

import Platform.Exception;
import std.string : split;
import core.sys.posix.unistd : uname, utsname;

class SystemInfo
{
    static string getPlatformName()
    {
        version(linux) return "Linux";
        version(OSX) return "Mac OS X";
        version(FreeBSD) return "FreeBSD";
        version(OpenBSD) return "OpenBSD";
        version(Solaris) return "Solaris";
        else static assert(0, "GetPlatformName undefined");
    }

    static int[] getVersion()
    {
        utsname u;
        if (uname(&u) != 0)
            throw new Exception("uname failed");
        auto parts = split(cast(string)u.release, '.');
        int[] ver;
        foreach(p; parts)
        {
            if (p.length == 0) break;
            string num = p.split("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")[0];
            if (num.length==0) break;
            ver ~= to!int(num);
        }
        return ver;
    }

    static bool isVersionAtLeast(int v1, int v2, int v3=0)
    {
        auto ver = getVersion();
        enforce(ver.length >= 2, "ParameterIncorrect");
        if (ver.length < 3) ver.length = 3;
        return (ver[0] * 10000000 + ver[1] * 10000 + ver[2]) >=
               (v1 * 10000000 + v2 * 10000 + v3);
    }

    protected this(){}
}
