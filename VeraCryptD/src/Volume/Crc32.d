module Volume.Crc32;

class Crc32
{
    private uint crcValue = 0xFFFF_FFFF;

    uint get() const { return crcValue ^ 0xFFFF_FFFF; }

    uint process(ubyte b)
    {
        crcValue = update(crcValue, b);
        return crcValue;
    }

    static uint processBuffer(const(ubyte)[] buf)
    {
        uint crc = 0xFFFF_FFFF;
        foreach (b; buf)
            crc = update(crc, b);
        return crc ^ 0xFFFF_FFFF;
    }

private:
    static uint update(uint crc, ubyte b)
    {
        crc ^= b;
        foreach(i; 0 .. 8)
        {
            if (crc & 1)
                crc = (crc >> 1) ^ 0xEDB88320u;
            else
                crc >>= 1;
        }
        return crc;
    }
}
