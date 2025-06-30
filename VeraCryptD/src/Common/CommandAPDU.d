module Common.CommandAPDU;

import std.array;
import std.conv : to;
import std.format : format;

string vformat(string fmt, ...)
{
    import std.format : vformat; // use built-in
    return vformat(fmt, _arguments, _argptr);
}

class CommandAPDU
{
    ubyte[] m_apdu;
    uint m_nc = 0;
    uint m_ne = 0;
    uint m_dataOffset = 0;
    bool m_isExtendedAPDU = false;
    string m_parsingErrorStr;
    bool m_parsedSuccessfully = false;

    this()
    {
    }

    private void parse()
    {
        uint l1 = 0;
        uint l2 = 0;
        uint l3 = 0;
        size_t leOfs = 0;
        m_parsingErrorStr = "";
        m_parsedSuccessfully = false;

        if (m_apdu.length < 4)
        {
            m_parsingErrorStr = format("APDU must be at least 4 bytes long - Length = %s", m_apdu.length);
            goto failure;
        }

        if (m_apdu.length == 4)
            goto success;

        l1 = m_apdu[4];
        if (m_apdu.length == 5)
        {
            m_ne = (l1 == 0) ? 256 : l1;
            goto success;
        }
        if (l1 != 0)
        {
            if (m_apdu.length == 4 + 1 + l1)
            {
                m_nc = l1;
                m_dataOffset = 5;
                goto success;
            }
            else if (m_apdu.length == 4 + 2 + l1)
            {
                m_nc = l1;
                m_dataOffset = 5;
                l2 = m_apdu[$-1];
                m_ne = (l2 == 0) ? 256 : l2;
                goto success;
            }
            else
            {
                m_parsingErrorStr = format("Invalid APDU : b1 = %u, expected length to be %u or %u, got %s", l1, 4 + 1 + l1, 4 + 2 + l1, m_apdu.length);
                goto failure;
            }
        }

        if (m_apdu.length < 7)
        {
            m_parsingErrorStr = format("Invalid APDU : b1 = %u, expected length to be >= 7 , got %s", l1, m_apdu.length);
            goto failure;
        }

        l2 = (m_apdu[5] << 8) | m_apdu[6];
        if (m_apdu.length == 7)
        {
            m_ne = (l2 == 0) ? 65536 : l2;
            m_isExtendedAPDU = true;
            goto success;
        }
        if (l2 == 0)
        {
            m_parsingErrorStr = format("Invalid APDU: b1 = %u, b2||b3 = %u, length = %s", l1, l2, m_apdu.length);
            goto failure;
        }
        if (m_apdu.length == 4 + 3 + l2)
        {
            m_nc = l2;
            m_dataOffset = 7;
            m_isExtendedAPDU = true;
            goto success;
        }
        if (m_apdu.length == 4 + 5 + l2)
        {
            m_nc = l2;
            m_dataOffset = 7;
            leOfs = m_apdu.length - 2;
            l3 = (m_apdu[leOfs] << 8) | m_apdu[leOfs + 1];
            m_ne = (l3 == 0) ? 65536 : l3;
            m_isExtendedAPDU = true;
            goto success;
        }
        else
        {
            m_parsingErrorStr = format("Invalid APDU : b1 = %u, b2||b3 = %u, expected length to be %u or %u, got %s", l1, l2, 4 + 3 + l2, 4 + 5 + l2, m_apdu.length);
            goto failure;
        }

    success:
        m_parsedSuccessfully = true;
        return;

    failure:
        clear();
    }

    private void init(ubyte cla, ubyte ins, ubyte p1, ubyte p2, const(ubyte)* data, uint dataOffset, uint dataLength, uint ne)
    {
        m_nc = 0;
        m_ne = 0;
        m_dataOffset = 0;
        m_isExtendedAPDU = false;
        m_parsingErrorStr = "";
        m_parsedSuccessfully = false;

        if (dataLength > 65535)
        {
            m_parsingErrorStr = format("dataLength is too large (>65535) - dataLength = %u", dataLength);
            clear();
            return;
        }
        if (ne > 65536)
        {
            m_parsingErrorStr = format("ne is too large (> 65536) - ne = %u", ne);
            clear();
            return;
        }

        m_ne = ne;
        m_nc = dataLength;

        if (dataLength == 0)
        {
            if (m_ne == 0)
            {
                m_apdu.length = 4;
                setHeader(cla, ins, p1, p2);
            }
            else
            {
                if (ne <= 256)
                {
                    ubyte len = (m_ne != 256) ? cast(ubyte)m_ne : 0;
                    m_apdu.length = 5;
                    setHeader(cla, ins, p1, p2);
                    m_apdu[4] = len;
                }
                else
                {
                    ubyte l1; ubyte l2b;
                    if (m_ne == 65536)
                    { l1 = 0; l2b = 0; }
                    else
                    { l1 = cast(ubyte)(m_ne >> 8); l2b = cast(ubyte)m_ne; }
                    m_apdu.length = 7;
                    setHeader(cla, ins, p1, p2);
                    m_apdu[5] = l1;
                    m_apdu[6] = l2b;
                    m_isExtendedAPDU = true;
                }
            }
        }
        else
        {
            if (m_ne == 0)
            {
                if (dataLength <= 255)
                {
                    m_apdu.length = 4 + 1 + dataLength;
                    setHeader(cla, ins, p1, p2);
                    m_apdu[4] = cast(ubyte)dataLength;
                    m_dataOffset = 5;
                    m_apdu[5 .. 5 + dataLength] = data[dataOffset .. dataOffset + dataLength];
                }
                else
                {
                    m_apdu.length = 4 + 3 + dataLength;
                    setHeader(cla, ins, p1, p2);
                    m_apdu[4] = 0;
                    m_apdu[5] = cast(ubyte)(dataLength >> 8);
                    m_apdu[6] = cast(ubyte)dataLength;
                    m_dataOffset = 7;
                    m_apdu[7 .. 7 + dataLength] = data[dataOffset .. dataOffset + dataLength];
                    m_isExtendedAPDU = true;
                }
            }
            else
            {
                if ((dataLength <= 255) && (m_ne <= 256))
                {
                    m_apdu.length = 4 + 2 + dataLength;
                    setHeader(cla, ins, p1, p2);
                    m_apdu[4] = cast(ubyte)dataLength;
                    m_dataOffset = 5;
                    m_apdu[5 .. 5 + dataLength] = data[dataOffset .. dataOffset + dataLength];
                    m_apdu[$-1] = (m_ne != 256) ? cast(ubyte)m_ne : 0;
                }
                else
                {
                    m_apdu.length = 4 + 5 + dataLength;
                    setHeader(cla, ins, p1, p2);
                    m_apdu[4] = 0;
                    m_apdu[5] = cast(ubyte)(dataLength >> 8);
                    m_apdu[6] = cast(ubyte)dataLength;
                    m_dataOffset = 7;
                    m_apdu[7 .. 7 + dataLength] = data[dataOffset .. dataOffset + dataLength];
                    if (ne != 65536)
                    {
                        size_t leOfs = m_apdu.length - 2;
                        m_apdu[leOfs] = cast(ubyte)(m_ne >> 8);
                        m_apdu[leOfs + 1] = cast(ubyte)m_ne;
                    }
                    m_isExtendedAPDU = true;
                }
            }
        }

        m_parsedSuccessfully = true;
    }

    private void setHeader(ubyte cla, ubyte ins, ubyte p1, ubyte p2)
    {
        m_apdu[0] = cla;
        m_apdu[1] = ins;
        m_apdu[2] = p1;
        m_apdu[3] = p2;
    }

    void clear()
    {
        m_apdu.length = 0;
        m_nc = m_ne = 0;
        m_dataOffset = 0;
    }

    this(ubyte cla, ubyte ins, ubyte p1, ubyte p2, const(ubyte)* data, uint dataOffset, uint dataLength, uint ne)
    {
        init(cla, ins, p1, p2, data, dataOffset, dataLength, ne);
    }
    this(ubyte cla, ubyte ins, ubyte p1, ubyte p2)
    {
        init(cla, ins, p1, p2, null, 0, 0, 0);
    }
    this(ubyte cla, ubyte ins, ubyte p1, ubyte p2, uint ne)
    {
        init(cla, ins, p1, p2, null, 0, 0, ne);
    }
    this(ubyte cla, ubyte ins, ubyte p1, ubyte p2, const(ubyte)[] data)
    {
        init(cla, ins, p1, p2, data.ptr, 0, cast(uint)data.length, 0);
    }
    this(ubyte cla, ubyte ins, ubyte p1, ubyte p2, const(ubyte)* data, uint dataOffset, uint dataLength)
    {
        init(cla, ins, p1, p2, data, dataOffset, dataLength, 0);
    }
    this(ubyte cla, ubyte ins, ubyte p1, ubyte p2, const(ubyte)[] data, uint ne)
    {
        init(cla, ins, p1, p2, data.ptr, 0, cast(uint)data.length, ne);
    }
    this(const(ubyte)[] apdu)
    {
        m_apdu = apdu.dup;
        parse();
    }

    ubyte getCLA() { return m_apdu[0]; }
    ubyte getINS() { return m_apdu[1]; }
    ubyte getP1() { return m_apdu[2]; }
    ubyte getP2() { return m_apdu[3]; }
    uint getNc() { return m_nc; }
    ubyte[] getData() { return (m_nc>0) ? m_apdu[m_dataOffset .. m_dataOffset + m_nc].dup : new ubyte[](0); }
    uint getNe() { return m_ne; }
    ubyte[] getAPDU() { return m_apdu.dup; }
    bool isExtended() { return m_isExtendedAPDU; }
    bool isValid() { return m_parsedSuccessfully; }
    string getErrorStr() { return m_parsingErrorStr; }
}
