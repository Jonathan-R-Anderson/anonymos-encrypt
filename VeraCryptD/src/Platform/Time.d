module Platform.Time;

import core.sys.posix.sys.time : timeval, gettimeofday;

/// Returns current time in hundreds of nanoseconds since 1601-01-01.
class Time
{
    static ulong getCurrent()
    {
        timeval tv;
        gettimeofday(&tv, null);
        enum ulong windowsEpoch = 134_774UL * 24UL * 3600UL; // days between 1601 and 1970
        return (cast(ulong)tv.tv_sec + windowsEpoch) * 1_000_000UL * 10UL;
    }
}
