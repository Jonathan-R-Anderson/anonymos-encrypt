module Core.CoreException;

import Platform.Exception;

class ElevationFailed : ExecutedProcessFailed
{
    this(string message="", string command="", long exitCode=0, string errorOutput="")
    {
        super(message, command, exitCode, errorOutput);
    }
}

class RootDeviceUnavailable : SystemException { this(string m="") { super(m); } }
class DriveLetterUnavailable : Exception { this(string m="") { super(m); } }
class DriverError : Exception { this(string m="") { super(m); } }
class EncryptedSystemRequired : Exception { this(string m="") { super(m); } }
class HigherFuseVersionRequired : Exception { this(string m="") { super(m); } }
class KernelCryptoServiceTestFailed : Exception { this(string m="") { super(m); } }
class LoopDeviceSetupFailed : Exception { this(string m="") { super(m); } }
class MountPointRequired : Exception { this(string m="") { super(m); } }
class MountPointUnavailable : Exception { this(string m="") { super(m); } }
class NoDriveLetterAvailable : Exception { this(string m="") { super(m); } }
class TemporaryDirectoryFailure : Exception { this(string m="") { super(m); } }
class UnsupportedSectorSizeHiddenVolumeProtection : Exception { this(string m="") { super(m); } }
class UnsupportedSectorSizeNoKernelCrypto : Exception { this(string m="") { super(m); } }
class VolumeAlreadyMounted : Exception { this(string m="") { super(m); } }
class VolumeSlotUnavailable : Exception { this(string m="") { super(m); } }
