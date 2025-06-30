module Core.HostDevice;

import Platform.Serializable;
import Platform.Serializer;
import Platform.SerializerFactory;
import Platform.Stream;

class HostDevice : Serializable
{
    string mountPoint;
    string name;
    string path;
    bool removable = false;
    ulong size = 0;
    uint systemNumber = 0;
    HostDevice[] partitions;

    this() {}

    override void deserialize(Stream stream)
    {
        auto sr = new Serializer(stream);
        sr.deserialize("MountPoint", mountPoint);
        sr.deserialize("Name", name);
        sr.deserialize("Path", path);
        bool rem; sr.deserialize("Removable", rem); removable = rem;
        ulong s; sr.deserialize("Size", s); size = s;
        sr.deserialize("SystemNumber", systemNumber);
        Serializable.deserializeList!(HostDevice)(stream, partitions);
    }

    override void serialize(Stream stream) const
    {
        auto sr = new Serializer(stream);
        Serializable.serializeHeader(sr, "HostDevice");
        sr.serialize("MountPoint", mountPoint);
        sr.serialize("Name", name);
        sr.serialize("Path", path);
        sr.serialize("Removable", removable);
        sr.serialize("Size", size);
        sr.serialize("SystemNumber", systemNumber);
        Serializable.serializeList!(HostDevice)(stream, partitions);
    }
}

static this()
{
    SerializerFactory.add("HostDevice", typeid(HostDevice), { return new HostDevice(); });
}
