module Common.Endian;

import core.stdc.string : memcpy;

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
