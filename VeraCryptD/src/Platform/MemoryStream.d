module Platform.MemoryStream;

import std.exception : enforce;

class MemoryStream
{
    private ubyte[] data;
    private size_t readPosition = 0;

    this() {}

    this(const(ubyte)[] input)
    {
        data = input.idup;
    }

    ulong read(ubyte[] buffer)
    {
        enforce(data.length != 0, "ParameterIncorrect");
        size_t len = buffer.length;
        if (data.length - readPosition < len)
            len = data.length - readPosition;
        buffer[0 .. len] = data[readPosition .. readPosition + len];
        readPosition += len;
        return len;
    }

    void readCompleteBuffer(ubyte[] buffer)
    {
        auto n = read(buffer);
        enforce(n == buffer.length, "InsufficientData");
    }

    void write(const(ubyte)[] input)
    {
        data ~= input;
    }

    const(ubyte)[] getData() const { return data; }
}
