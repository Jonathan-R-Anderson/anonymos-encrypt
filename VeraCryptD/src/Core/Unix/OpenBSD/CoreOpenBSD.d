module Core.Unix.OpenBSD.CoreOpenBSD;

// Original code derived from Unix/CoreOpenBSD.cpp
import Platform.Process;
import Platform.FilesystemPath;
import Platform.Thread;
import Core.HostDevice;
import Platform.Exception;
import std.conv : to;

class CoreOpenBSD
{
    this() {}
    ~this() {}

    string attachFileToLoopDevice(string filePath, bool readOnly) const
    {
        if (readOnly)
            throw new Exception("readOnly not supported");
        int freeVnd = -1;
        foreach(vnd; 0 .. 4)
        {
            auto devPath = "/dev/vnd" ~ vnd.to!string ~ "c";
            auto fsp = new FilesystemPath(devPath);
            if (fsp.isBlockDevice() || fsp.isCharacterDevice())
            {
                auto device = new HostDevice();
                device.path = devPath;
                try
                {
                    getDeviceSize(device.path);
                }
                catch(Exception)
                {
                    freeVnd = vnd;
                    break;
                }
            }
        }
        if (freeVnd == -1)
            throw new Exception("couldn't find free vnd");
        string freePath = "vnd" ~ freeVnd.to!string;
        string[] args = [freePath, filePath];
        Process.execute("/sbin/vnconfig", args);
        return "/dev/" ~ freePath ~ "c";
    }

    void detachLoopDevice(string devicePath) const
    {
        string[] args = ["-u", devicePath];
        for(int t=0;;t++)
        {
            try
            {
                Process.execute("/sbin/vnconfig", args);
                break;
            }
            catch(ExecutedProcessFailed e)
            {
                if (t > 5)
                    throw e;
                Thread.sleep(200);
            }
        }
    }

    HostDevice[] getHostDevices(bool pathListOnly) const
    {
        throw new Exception("not implemented");
    }

    MountedFilesystem[] getMountedFilesystems(string devicePath, string mountPoint) const
    {
        return MountedFilesystem[].init; // unimplemented simple placeholder
    }

    void mountFilesystem(string devicePath, string mountPoint, string filesystemType, bool readOnly, string systemMountOptions) const
    {
        auto type = filesystemType.length ? filesystemType : "msdos";
        string[] args = readOnly ? ["-r", "-t", type, devicePath, mountPoint] : ["-t", type, devicePath, mountPoint];
        try
        {
            Process.execute("/sbin/mount", args);
        }
        catch(ExecutedProcessFailed e)
        {
            if (filesystemType.length)
                throw e;
            Process.execute("/sbin/mount", ["-t", filesystemType, devicePath, mountPoint]);
        }
    }
}
