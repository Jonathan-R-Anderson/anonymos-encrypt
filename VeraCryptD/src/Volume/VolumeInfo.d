module Volume.VolumeInfo;

import Volume.VolumePassword;

class VolumeInfo
{
    static ulong _counter = 0;

    ulong serialInstanceNumber;
    string mountPoint;
    string path;

    this()
    {
        serialInstanceNumber = ++_counter;
    }

    void set(string mountPoint, string path)
    {
        this.mountPoint = mountPoint;
        this.path = path;
    }
}

alias VolumeInfoList = VolumeInfo[];

bool firstVolumeMountedAfterSecond(VolumeInfo a, VolumeInfo b)
{
    return a.serialInstanceNumber > b.serialInstanceNumber;
}
