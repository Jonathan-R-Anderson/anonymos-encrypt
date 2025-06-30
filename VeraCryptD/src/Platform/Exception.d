module Platform.Exception;

class Exception : object.Exception
{
    string mSubject;

    this(string msg = "", string subject = "")
    {
        super(msg);
        mSubject = subject;
    }

    string getSubject() const { return mSubject; }
}

class ExecutedProcessFailed : Exception
{
    string command;
    long exitCode;
    string errorOutput;

    this(string message, string command, long exitCode, string errorOutput)
    {
        super(message);
        this.command = command;
        this.exitCode = exitCode;
        this.errorOutput = errorOutput;
    }

    string getCommand() const { return command; }
    long getExitCode() const { return exitCode; }
    string getErrorOutput() const { return errorOutput; }
}

class AlreadyInitialized : Exception { this(string m="") { super(m); } }
class AssertionFailed : Exception { this(string m="") { super(m); } }
class DeviceSectorSizeMismatch : Exception { this(string m="") { super(m); } }
class ExternalException : Exception { this(string m="") { super(m); } }
class InsufficientData : Exception { this(string m="") { super(m); } }
class NotApplicable : Exception { this(string m="") { super(m); } }
class NotImplemented : Exception { this(string m="") { super(m); } }
class NotInitialized : Exception { this(string m="") { super(m); } }
class ParameterIncorrect : Exception { this(string m="") { super(m); } }
class ParameterTooLarge : Exception { this(string m="") { super(m); } }
class PartitionDeviceRequired : Exception { this(string m="") { super(m); } }
class StringConversionFailed : Exception { this(string m="") { super(m); } }
class TerminalNotFound : Exception { this(string m="") { super(m); } }
class TestFailed : Exception { this(string m="") { super(m); } }
class TimeOut : Exception { this(string m="") { super(m); } }
class UnknownException : Exception { this(string m="") { super(m); } }
class UserAbort : Exception { this(string m="") { super(m); } }
class MountPointBlocked : Exception { this(string m="") { super(m); } }
class MountPointNotAllowed : Exception { this(string m="") { super(m); } }
