module Common.ResponseAPDU;

import core.stdc.string : memcpy;
import std.conv : to;

struct ResponseAPDU
{
    ubyte[] data;
    ushort sw;

    void clear()
    {
        data.length = 0;
        sw = 0;
    }

    this()
    {
        clear();
    }

    this(const ubyte[] d, ushort s)
    {
        data = d.dup;
        sw = s;
    }

    uint getNr() const { return cast(uint)data.length; }
    ubyte[] getData() const { return data.dup; }
    ubyte getSW1() const { return cast(ubyte)((sw >> 8) & 0xFF); }
    ubyte getSW2() const { return cast(ubyte)(sw & 0xFF); }
    ushort getSW() const { return sw; }

    ubyte[] getBytes() const
    {
        auto apdu = data.dup;
        apdu ~= getSW1();
        apdu ~= getSW2();
        return apdu;
    }

    void setSW(ushort s) { sw = s; }

    void setBytes(const ubyte[] bytes)
    {
        clear();
        if(bytes.length >= 2)
        {
            data = bytes[0 .. $-2].dup;
            sw = cast(ushort)((bytes[$-2] << 8) | bytes[$-1]);
        }
    }

    void appendData(const ubyte[] d)
    {
        data ~= d;
    }

    void appendData(const(ubyte)* d, size_t len)
    {
        if (d && len > 0)
        {
            data ~= d[0 .. len];
        }
    }
}
