module Volume.VolumeInfo;

import Platform.Serializable;
import Platform.Serializer;
import Platform.SerializerFactory;
import Platform.Stream;
import Volume.VolumeSlot;

enum VolumeType { Unknown, Normal, Hidden }
enum VolumeProtection { None, ReadOnly, HiddenVolumeReadOnly }

class VolumeInfo : Serializable
{
    ulong serialInstanceNumber = 0;
    string auxMountPoint;
    uint encryptionAlgorithmBlockSize;
    uint encryptionAlgorithmKeySize;
    uint encryptionAlgorithmMinBlockSize;
    string encryptionAlgorithmName;
    string encryptionModeName;
    ulong headerCreationTime;
    bool hiddenVolumeProtectionTriggered;
    string loopDevice;
    uint minRequiredProgramVersion;
    string mountPoint;
    string path;
    uint pkcs5IterationCount;
    string pkcs5PrfName;
    uint programVersion;
    VolumeProtection protection = VolumeProtection.None;
    ulong serialInstanceCounter;
    ulong size;
    VolumeSlotNumber slotNumber;
    bool systemEncryption;
    ulong topWriteOffset;
    ulong totalDataRead;
    ulong totalDataWritten;
    VolumeType type = VolumeType.Unknown;
    string virtualDevice;
    ulong volumeCreationTime;
    int pim;
    bool masterKeyVulnerable;

    this() { serialInstanceNumber = ++serialInstanceCounter; }

    override void deserialize(Stream stream)
    {
        auto sr = new Serializer(stream);
        sr.deserialize("ProgramVersion", programVersion);
        sr.deserialize("AuxMountPoint", auxMountPoint);
        sr.deserialize("EncryptionAlgorithmBlockSize", encryptionAlgorithmBlockSize);
        sr.deserialize("EncryptionAlgorithmKeySize", encryptionAlgorithmKeySize);
        sr.deserialize("EncryptionAlgorithmMinBlockSize", encryptionAlgorithmMinBlockSize);
        sr.deserialize("EncryptionAlgorithmName", encryptionAlgorithmName);
        sr.deserialize("EncryptionModeName", encryptionModeName);
        sr.deserialize("HeaderCreationTime", headerCreationTime);
        sr.deserialize("HiddenVolumeProtectionTriggered", hiddenVolumeProtectionTriggered);
        sr.deserialize("LoopDevice", loopDevice);
        sr.deserialize("MinRequiredProgramVersion", minRequiredProgramVersion);
        sr.deserialize("MountPoint", mountPoint);
        sr.deserialize("Path", path);
        sr.deserialize("Pkcs5IterationCount", pkcs5IterationCount);
        sr.deserialize("Pkcs5PrfName", pkcs5PrfName);
        uint prot; sr.deserialize("Protection", prot); protection = cast(VolumeProtection)prot;
        sr.deserialize("SerialInstanceNumber", serialInstanceNumber);
        sr.deserialize("Size", size);
        sr.deserialize("SlotNumber", slotNumber);
        sr.deserialize("SystemEncryption", systemEncryption);
        sr.deserialize("TopWriteOffset", topWriteOffset);
        sr.deserialize("TotalDataRead", totalDataRead);
        sr.deserialize("TotalDataWritten", totalDataWritten);
        uint t; sr.deserialize("Type", t); type = cast(VolumeType)t;
        sr.deserialize("VirtualDevice", virtualDevice);
        sr.deserialize("VolumeCreationTime", volumeCreationTime);
        sr.deserialize("Pim", pim);
        sr.deserialize("MasterKeyVulnerable", masterKeyVulnerable);
    }

    override void serialize(Stream stream) const
    {
        auto sr = new Serializer(stream);
        Serializable.serializeHeader(sr, "VolumeInfo");
        sr.serialize("ProgramVersion", programVersion);
        sr.serialize("AuxMountPoint", auxMountPoint);
        sr.serialize("EncryptionAlgorithmBlockSize", encryptionAlgorithmBlockSize);
        sr.serialize("EncryptionAlgorithmKeySize", encryptionAlgorithmKeySize);
        sr.serialize("EncryptionAlgorithmMinBlockSize", encryptionAlgorithmMinBlockSize);
        sr.serialize("EncryptionAlgorithmName", encryptionAlgorithmName);
        sr.serialize("EncryptionModeName", encryptionModeName);
        sr.serialize("HeaderCreationTime", headerCreationTime);
        sr.serialize("HiddenVolumeProtectionTriggered", hiddenVolumeProtectionTriggered);
        sr.serialize("LoopDevice", loopDevice);
        sr.serialize("MinRequiredProgramVersion", minRequiredProgramVersion);
        sr.serialize("MountPoint", mountPoint);
        sr.serialize("Path", path);
        sr.serialize("Pkcs5IterationCount", pkcs5IterationCount);
        sr.serialize("Pkcs5PrfName", pkcs5PrfName);
        sr.serialize("Protection", cast(uint)protection);
        sr.serialize("SerialInstanceNumber", serialInstanceNumber);
        sr.serialize("Size", size);
        sr.serialize("SlotNumber", slotNumber);
        sr.serialize("SystemEncryption", systemEncryption);
        sr.serialize("TopWriteOffset", topWriteOffset);
        sr.serialize("TotalDataRead", totalDataRead);
        sr.serialize("TotalDataWritten", totalDataWritten);
        sr.serialize("Type", cast(uint)type);
        sr.serialize("VirtualDevice", virtualDevice);
        sr.serialize("VolumeCreationTime", volumeCreationTime);
        sr.serialize("Pim", pim);
        sr.serialize("MasterKeyVulnerable", masterKeyVulnerable);
    }
}

alias VolumeInfoList = VolumeInfo[];

bool firstVolumeMountedAfterSecond(VolumeInfo a, VolumeInfo b)
{
    return a.serialInstanceNumber > b.serialInstanceNumber;
}

static this()
{
    SerializerFactory.add("VolumeInfo", typeid(VolumeInfo), { return new VolumeInfo(); });
}
