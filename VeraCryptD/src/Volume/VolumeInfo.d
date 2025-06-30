module Volume.VolumeInfo;

import Volume.VolumePassword;

class VolumeInfo
{
    string mountPoint;
    string path;

    this() {}

    void set() {}
}

alias VolumeInfoList = VolumeInfo[];

bool firstVolumeMountedAfterSecond(VolumeInfo a, VolumeInfo b)
{
    return false;
}
