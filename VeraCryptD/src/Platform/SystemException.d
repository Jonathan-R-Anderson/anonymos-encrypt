module Platform.SystemException;

import Platform.Exception;
import Platform.Serializer;
import Platform.SerializerFactory;
import Platform.Stream;
import core.stdc.errno : errno;
import core.stdc.string : strerror;
import std.string : fromStringz;
import std.conv : to;

class SystemException : Exception
{
    long errorCode;

    this()
    {
        super("", "");
        errorCode = errno;
    }

    this(string message)
    {
        super(message);
        errorCode = errno;
    }

    this(string message, string subject)
    {
        super(message, subject);
        errorCode = errno;
    }

    this(string message, wstring subject)
    {
        super(message, to!string(subject));
        errorCode = errno;
    }

    this(string message, long code)
    {
        super(message);
        errorCode = code;
    }

    override void deserialize(Stream stream)
    {
        super.deserialize(stream);
        auto sr = new Serializer(stream);
        ulong ec;
        sr.deserialize("ErrorCode", ec);
        errorCode = ec;
    }

    override void serialize(Stream stream) const
    {
        super.serialize(stream);
        auto sr = new Serializer(stream);
        sr.serialize("ErrorCode", cast(ulong)errorCode);
    }

    long getErrorCode() const { return errorCode; }
    bool isError() const { return errorCode != 0; }
    string systemText() const { return fromStringz(strerror(cast(int)errorCode)); }
}

static this()
{
    SerializerFactory.add("SystemException", typeid(SystemException), { return new SystemException(); });
}
