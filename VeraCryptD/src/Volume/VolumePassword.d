module Volume.VolumePassword;

class VolumePassword
{
    ubyte[] passwordBuffer;
    size_t passwordSize;

    static immutable size_t MaxLegacySize = 64;
    static immutable size_t MaxSize = 128;
    static immutable size_t WarningSizeThreshold = 12;

    this()
    {
        passwordBuffer.length = MaxSize;
        passwordSize = 0;
    }

    void set(const ubyte[] pwd)
    {
        if (pwd.length > MaxSize)
            throw new Exception("Password too long");
        passwordBuffer[0 .. pwd.length] = pwd;
        passwordSize = pwd.length;
    }

    bool empty() const { return passwordSize == 0; }
    size_t size() const { return passwordSize; }
}

class PasswordException : Exception
{
    this(string msg="") { super(msg); }
}

class PasswordIncorrect : PasswordException { this(string msg="") { super(msg); } }
class PasswordEmpty : PasswordException { this(string msg="") { super(msg); } }
class PasswordTooLong : PasswordException { this(string msg="") { super(msg); } }
