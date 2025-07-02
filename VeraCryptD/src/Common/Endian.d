module Common.Endian;

import core.stdc.string : memcpy;

// Helper functions implementing byte order conversions and
// portable read/write operations used throughout the code base.

ushort MirrorBytes16(ushort x)
{
    return (x << 8) | (x >> 8);
}

uint MirrorBytes32(uint x)
{
    uint n = cast(ubyte)x;
    n <<= 8; n |= cast(ubyte)(x >> 8);
    n <<= 8; n |= cast(ubyte)(x >> 16);
    return (n << 8) | cast(ubyte)(x >> 24);
}

ulong MirrorBytes64(ulong x)
{
    ulong n = cast(ubyte)x;
    n <<= 8; n |= cast(ubyte)(x >> 8);
    n <<= 8; n |= cast(ubyte)(x >> 16);
    n <<= 8; n |= cast(ubyte)(x >> 24);
    n <<= 8; n |= cast(ubyte)(x >> 32);
    n <<= 8; n |= cast(ubyte)(x >> 40);
    n <<= 8; n |= cast(ubyte)(x >> 48);
    return (n << 8) | cast(ubyte)(x >> 56);
}

version(BigEndian)
{
    ushort LE16(ushort x) { return MirrorBytes16(x); }
    uint   LE32(uint x)   { return MirrorBytes32(x); }
    ulong  LE64(ulong x)  { return MirrorBytes64(x); }
    ushort BE16(ushort x) { return x; }
    uint   BE32(uint x)   { return x; }
    ulong  BE64(ulong x)  { return x; }
}
else
{
    ushort LE16(ushort x) { return x; }
    uint   LE32(uint x)   { return x; }
    ulong  LE64(ulong x)  { return x; }
    ushort BE16(ushort x) { return MirrorBytes16(x); }
    uint   BE32(uint x)   { return MirrorBytes32(x); }
    ulong  BE64(ulong x)  { return MirrorBytes64(x); }
}

void mputInt64(ref ubyte* memPtr, ulong data)
{
    *memPtr++ = cast(ubyte)((data >> 56) & 0xFF);
    *memPtr++ = cast(ubyte)((data >> 48) & 0xFF);
    *memPtr++ = cast(ubyte)((data >> 40) & 0xFF);
    *memPtr++ = cast(ubyte)((data >> 32) & 0xFF);
    *memPtr++ = cast(ubyte)((data >> 24) & 0xFF);
    *memPtr++ = cast(ubyte)((data >> 16) & 0xFF);
    *memPtr++ = cast(ubyte)((data >> 8) & 0xFF);
    *memPtr++ = cast(ubyte)(data & 0xFF);
}

void mputLong(ref ubyte* memPtr, uint data)
{
    *memPtr++ = cast(ubyte)((data >> 24) & 0xFF);
    *memPtr++ = cast(ubyte)((data >> 16) & 0xFF);
    *memPtr++ = cast(ubyte)((data >> 8) & 0xFF);
    *memPtr++ = cast(ubyte)(data & 0xFF);
}

void mputWord(ref ubyte* memPtr, ushort data)
{
    *memPtr++ = cast(ubyte)((data >> 8) & 0xFF);
    *memPtr++ = cast(ubyte)(data & 0xFF);
}

void mputByte(ref ubyte* memPtr, ubyte data)
{
    *memPtr++ = data;
}

void mputBytes(ref ubyte* memPtr, const(ubyte)* data, size_t len)
{
    memcpy(memPtr, data, len);
    memPtr += len;
}

ulong mgetInt64(ref const(ubyte)* memPtr)
{
    ulong val = (cast(ulong)memPtr[0] << 56) |
                (cast(ulong)memPtr[1] << 48) |
                (cast(ulong)memPtr[2] << 40) |
                (cast(ulong)memPtr[3] << 32) |
                (cast(ulong)memPtr[4] << 24) |
                (cast(ulong)memPtr[5] << 16) |
                (cast(ulong)memPtr[6] << 8)  |
                (cast(ulong)memPtr[7]);
    memPtr += 8;
    return val;
}

uint mgetLong(ref const(ubyte)* memPtr)
{
    uint val = (cast(uint)memPtr[0] << 24) |
               (cast(uint)memPtr[1] << 16) |
               (cast(uint)memPtr[2] << 8)  |
               (cast<uint)memPtr[3]);
    memPtr += 4;
    return val;
}

ushort mgetWord(ref const(ubyte)* memPtr)
{
    ushort val = cast(ushort)(((cast(uint)memPtr[0] << 8) | memPtr[1]));
    memPtr += 2;
    return val;
}

ubyte mgetByte(ref const(ubyte)* memPtr)
{
    auto val = memPtr[0];
    memPtr += 1;
    return val;
}
