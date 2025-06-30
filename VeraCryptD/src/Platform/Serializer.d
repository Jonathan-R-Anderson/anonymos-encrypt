module Platform.Serializer;

import Platform.Stream;
import Platform.Buffer;
import Platform.Exception;
import Platform.Memory : Endian;
import std.exception : enforce;
import std.string;
import std.array;
import std.conv;

class Serializer
{
    private Stream dataStream;

    this(Stream stream)
    {
        dataStream = stream;
    }

    private T readBigEndian(T)()
    {
        ubyte[T.sizeof] buf;
        dataStream.readCompleteBuffer(buf[]);
        T val;
        import core.stdc.string : memcpy;
        memcpy(&val, buf.ptr, buf.length);
        static if (T.sizeof == 1)
            return val;
        else
            return Endian.big(val);
    }

    private void writeBigEndian(T)(T val)
    {
        static if (T.sizeof == 1)
        {
            dataStream.write((&val)[0 .. 1]);
        }
        else
        {
            T tmp = Endian.big(val);
            ubyte[T.sizeof] buf;
            import core.stdc.string : memcpy;
            memcpy(buf.ptr, &tmp, buf.length);
            dataStream.write(buf[]);
        }
    }

    private T deserializeRaw(T)()
    {
        auto size = readBigEndian!ulong();
        enforce(size == T.sizeof, "ParameterIncorrect");
        return readBigEndian!T();
    }

    private void serializeRaw(T)(T val)
    {
        writeBigEndian!ulong(cast(ulong)T.sizeof);
        writeBigEndian!T(val);
    }

    void deserialize(string name, ref bool data)
    {
        validateName(name);
        data = deserializeRaw!ubyte() == 1;
    }

    void deserialize(string name, ref ubyte data)
    {
        validateName(name);
        data = deserializeRaw!ubyte();
    }

    void deserialize(string name, ref int data)
    {
        validateName(name);
        data = cast(int) deserializeRaw!uint();
    }

    void deserialize(string name, ref long data)
    {
        validateName(name);
        data = cast(long) deserializeRaw!ulong();
    }

    void deserialize(string name, ref uint data)
    {
        validateName(name);
        data = deserializeRaw!uint();
    }

    void deserialize(string name, ref ulong data)
    {
        validateName(name);
        data = deserializeRaw!ulong();
    }

    void deserialize(string name, ref string data)
    {
        validateName(name);
        data = deserializeString();
    }

    void deserialize(string name, ref wstring data)
    {
        validateName(name);
        data = deserializeWString();
    }

    void deserialize(string name, BufferPtr data)
    {
        validateName(name);
        auto size = deserializeRaw!ulong();
        enforce(size == data.length, "ParameterIncorrect");
        ubyte[] buf = new ubyte[data.length];
        dataStream.readCompleteBuffer(buf);
        import core.stdc.string : memcpy;
        memcpy(data.ptr, buf.ptr, buf.length);
    }

    bool deserializeBool(string name)
    {
        bool v; deserialize(name, v); return v;
    }

    int deserializeInt32(string name)
    {
        validateName(name);
        return cast(int) deserializeRaw!uint();
    }

    long deserializeInt64(string name)
    {
        validateName(name);
        return cast(long) deserializeRaw!ulong();
    }

    uint deserializeUInt32(string name)
    {
        validateName(name);
        return deserializeRaw!uint();
    }

    ulong deserializeUInt64(string name)
    {
        validateName(name);
        return deserializeRaw!ulong();
    }

    string deserializeString()
    {
        auto size = deserializeRaw!ulong();
        ubyte[] buf = new ubyte[cast(size_t)size];
        dataStream.readCompleteBuffer(buf);
        if (buf.length == 0) return "";
        if (buf[$-1] == 0)
            buf = buf[0 .. $-1];
        return cast(string)buf.idup;
    }

    string deserializeString(string name)
    {
        validateName(name);
        return deserializeString();
    }

    wstring deserializeWString()
    {
        auto size = deserializeRaw!ulong();
        wchar[] buf = new wchar[cast(size_t)(size / wchar.sizeof)];
        ubyte[] raw = cast(ubyte[])buf;
        dataStream.readCompleteBuffer(raw[0 .. cast(size_t)size]);
        if (buf.length && buf[$-1] == 0)
            buf = buf[0 .. $-1];
        return buf.idup;
    }

    wstring deserializeWString(string name)
    {
        validateName(name);
        return deserializeWString();
    }

    void serialize(string name, bool data)
    {
        serializeString(name);
        serializeRaw!ubyte(data ? 1 : 0);
    }

    void serialize(string name, ubyte data)
    {
        serializeString(name);
        serializeRaw!ubyte(data);
    }

    void serialize(string name, int data)
    {
        serializeString(name);
        serializeRaw!uint(cast(uint)data);
    }

    void serialize(string name, long data)
    {
        serializeString(name);
        serializeRaw!ulong(cast(ulong)data);
    }

    void serialize(string name, uint data)
    {
        serializeString(name);
        serializeRaw!uint(data);
    }

    void serialize(string name, ulong data)
    {
        serializeString(name);
        serializeRaw!ulong(data);
    }

    void serialize(string name, const string data)
    {
        serializeString(name);
        serializeString(data);
    }

    void serialize(string name, const wstring data)
    {
        serializeString(name);
        serializeWString(data);
    }

    void serialize(string name, const wchar[] data)
    {
        serialize(name, cast(wstring)data);
    }

    void serialize(string name, const string[] list)
    {
        serializeString(name);
        auto count = cast(ulong)list.length;
        serializeRaw!ulong(count);
        foreach(item; list)
            serializeString(item);
    }

    void serialize(string name, const wstring[] list)
    {
        serializeString(name);
        auto count = cast(ulong)list.length;
        serializeRaw!ulong(count);
        foreach(item; list)
            serializeWString(item);
    }

    void serialize(string name, ConstBufferPtr data)
    {
        serializeString(name);
        serializeRaw!ulong(cast(ulong)data.length);
        dataStream.write(data.ptr[0 .. data.length]);
    }

    private void serializeString(string data)
    {
        serializeRaw!ulong(cast(ulong)(data.length + 1));
        dataStream.write((cast(ubyte[]) data) ~ 0);
    }

    private void serializeWString(wstring data)
    {
        auto bytes = (data.length + 1) * wchar.sizeof;
        serializeRaw!ulong(cast(ulong)bytes);
        ubyte[] raw = cast(ubyte[]) data;
        dataStream.write(raw);
        ubyte[ wchar.sizeof ] zero = 0;
        dataStream.write(zero[]);
    }

    private void validateName(string name)
    {
        auto dname = deserializeString();
        enforce(dname == name, "ParameterIncorrect");
    }
}
