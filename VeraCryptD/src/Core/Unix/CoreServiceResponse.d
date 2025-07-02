module Core.Unix.CoreServiceResponse;

import Platform.Serializable;
import Platform.Serializer;
import Platform.SerializerFactory;
import Platform.Stream;
import Core.HostDevice;
import Volume.VolumeInfo;

class CoreServiceResponse : Serializable
{
    override void deserialize(Stream stream) {}
    override void serialize(Stream stream) const
    {
        auto sr = new Serializer(stream);
        Serializable.serializeHeader(sr, "CoreServiceResponse");
    }
}

class CheckFilesystemResponse : CoreServiceResponse
{
    override void deserialize(Stream stream) {}
    override void serialize(Stream stream) const
    {
        auto sr = new Serializer(stream);
        Serializable.serializeHeader(sr, "CheckFilesystemResponse");
    }
}

class DismountFilesystemResponse : CoreServiceResponse
{
    override void deserialize(Stream stream) {}
    override void serialize(Stream stream) const
    {
        auto sr = new Serializer(stream);
        Serializable.serializeHeader(sr, "DismountFilesystemResponse");
    }
}

class DismountVolumeResponse : CoreServiceResponse
{
    VolumeInfo dismountedVolumeInfo;

    override void deserialize(Stream stream)
    {
        dismountedVolumeInfo = cast(VolumeInfo)Serializable.deserializeNew!VolumeInfo(stream);
    }

    override void serialize(Stream stream) const
    {
        auto sr = new Serializer(stream);
        Serializable.serializeHeader(sr, "DismountVolumeResponse");
        dismountedVolumeInfo.serialize(stream);
    }
}

class GetDeviceSectorSizeResponse : CoreServiceResponse
{
    uint size;

    override void deserialize(Stream stream)
    {
        auto sr = new Serializer(stream);
        sr.deserialize("Size", size);
    }

    override void serialize(Stream stream) const
    {
        auto sr = new Serializer(stream);
        Serializable.serializeHeader(sr, "GetDeviceSectorSizeResponse");
        sr.serialize("Size", size);
    }
}

class GetDeviceSizeResponse : CoreServiceResponse
{
    ulong size;

    override void deserialize(Stream stream)
    {
        auto sr = new Serializer(stream);
        sr.deserialize("Size", size);
    }

    override void serialize(Stream stream) const
    {
        auto sr = new Serializer(stream);
        Serializable.serializeHeader(sr, "GetDeviceSizeResponse");
        sr.serialize("Size", size);
    }
}

class GetHostDevicesResponse : CoreServiceResponse
{
    HostDevice[] hostDevices;

    override void deserialize(Stream stream)
    {
        Serializable.deserializeList!(HostDevice)(stream, hostDevices);
    }

    override void serialize(Stream stream) const
    {
        auto sr = new Serializer(stream);
        Serializable.serializeHeader(sr, "GetHostDevicesResponse");
        Serializable.serializeList!(HostDevice)(stream, hostDevices);
    }
}

class MountVolumeResponse : CoreServiceResponse
{
    VolumeInfo mountedVolumeInfo;

    override void deserialize(Stream stream)
    {
        mountedVolumeInfo = Serializable.deserializeNew!VolumeInfo(stream);
    }

    override void serialize(Stream stream) const
    {
        auto sr = new Serializer(stream);
        Serializable.serializeHeader(sr, "MountVolumeResponse");
        mountedVolumeInfo.serialize(stream);
    }
}

class SetFileOwnerResponse : CoreServiceResponse
{
    override void deserialize(Stream stream) {}
    override void serialize(Stream stream) const
    {
        auto sr = new Serializer(stream);
        Serializable.serializeHeader(sr, "SetFileOwnerResponse");
    }
}

static this()
{
    SerializerFactory.add("CheckFilesystemResponse", typeid(CheckFilesystemResponse), { return new CheckFilesystemResponse(); });
    SerializerFactory.add("DismountFilesystemResponse", typeid(DismountFilesystemResponse), { return new DismountFilesystemResponse(); });
    SerializerFactory.add("DismountVolumeResponse", typeid(DismountVolumeResponse), { return new DismountVolumeResponse(); });
    SerializerFactory.add("GetDeviceSectorSizeResponse", typeid(GetDeviceSectorSizeResponse), { return new GetDeviceSectorSizeResponse(); });
    SerializerFactory.add("GetDeviceSizeResponse", typeid(GetDeviceSizeResponse), { return new GetDeviceSizeResponse(); });
    SerializerFactory.add("GetHostDevicesResponse", typeid(GetHostDevicesResponse), { return new GetHostDevicesResponse(); });
    SerializerFactory.add("MountVolumeResponse", typeid(MountVolumeResponse), { return new MountVolumeResponse(); });
    SerializerFactory.add("SetFileOwnerResponse", typeid(SetFileOwnerResponse), { return new SetFileOwnerResponse(); });
}
