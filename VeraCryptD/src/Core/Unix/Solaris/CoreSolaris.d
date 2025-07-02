module Core.Unix.Solaris.CoreSolaris;

import Platform.Process;
import Platform.Thread;
import Platform.FilesystemPath;
import Platform.Directory;
import Platform.File;
import Core.HostDevice;
import Platform.Exception;
import std.conv : to;
import std.string : strip;

class CoreSolaris
{
    this() {}
    ~this() {}

    string attachFileToLoopDevice(string filePath, bool readOnly) const
    {
        string[] args = ["-a", filePath];
        return Process.execute("/usr/sbin/lofiadm", args).strip();
    }

    void detachLoopDevice(string devicePath) const
    {
        string[] args = ["-d", devicePath];
        for(int t=0;;t++)
        {
            try
            {
                Process.execute("/usr/sbin/lofiadm", args);
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
        HostDevice[] devices;
        foreach(devPath; Directory.getFilePaths("/dev/rdsk", false))
        {
            string drivePath = devPath;
            if (drivePath.endsWith("p0"))
            {
                auto device = new HostDevice();
                device.path = drivePath;
                try { device.size = getDeviceSize(device.path); } catch(Exception) { device.size = 0; }
                if (device.size == 0) continue;
                device.mountPoint = getDeviceMountPoint(device.path);
                device.systemNumber = 0;
                devices ~= device;
                foreach(partNumber; 1 .. 33)
                {
                    string partPath = drivePath[0 .. $-1] ~ to!string(partNumber);
                    auto fp = new FilesystemPath(partPath);
                    if (fp.isBlockDevice() || fp.isCharacterDevice())
                    {
                        auto part = new HostDevice();
                        part.path = partPath;
                        try { part.size = getDeviceSize(part.path); } catch(Exception) { part.size = 0; }
                        if (part.size == 0) continue;
                        part.mountPoint = getDeviceMountPoint(part.path);
                        part.systemNumber = 0;
                        device.partitions ~= part;
                    }
                }
            }
        }
        return devices;
    }

    MountedFilesystem[] getMountedFilesystems(string devicePath, string mountPoint) const
    {
        return MountedFilesystem[].init; // not implemented
    }

    void mountFilesystem(string devicePath, string mountPoint, string filesystemType, bool readOnly, string systemMountOptions) const
    {
        auto type = filesystemType.length ? filesystemType : "pcfs";
        string[] args = readOnly ? ["-r", "-F", type, devicePath, mountPoint] : ["-F", type, devicePath, mountPoint];
        try
        {
            Process.execute("/sbin/mount", args);
        }
        catch(ExecutedProcessFailed e)
        {
            if (filesystemType.length)
                throw e;
            Process.execute("/sbin/mount", ["-F", filesystemType, devicePath, mountPoint]);
        }
    }
}
