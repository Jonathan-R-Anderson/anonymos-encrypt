module Common.IccDataExtractor;

/// Simple utility to extract raw certificate data from EMV card buffers.
ubyte[] extractCertificate(const(ubyte)[] data)
{
    if (data.length <= 4)
        return null;
    auto len = data[1];
    if (len + 2 <= data.length)
        return data[2 .. 2 + len].idup;
    return null;
}
