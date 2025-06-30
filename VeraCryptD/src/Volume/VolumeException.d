module Volume.VolumeException;

class VolumeException : Exception
{
    this()
    {
        super("Volume exception");
    }

    this(string message)
    {
        super(message);
    }

    this(string message, string subject)
    {
        super(message ~ " " ~ subject);
    }
}

class HigherVersionRequired : VolumeException { this(string msg="") { super(msg); } }
class KeyfilePathEmpty : VolumeException { this(string msg="") { super(msg); } }
class MissingVolumeData : VolumeException { this(string msg="") { super(msg); } }
class MountedVolumeInUse : VolumeException { this(string msg="") { super(msg); } }
class UnsupportedSectorSize : VolumeException { this(string msg="") { super(msg); } }
class VolumeEncryptionNotCompleted : VolumeException { this(string msg="") { super(msg); } }
class VolumeHostInUse : VolumeException { this(string msg="") { super(msg); } }
class VolumeProtected : VolumeException { this(string msg="") { super(msg); } }
class VolumeReadOnly : VolumeException { this(string msg="") { super(msg); } }

// TODO: Implement serializer factory equivalents if needed.
