module Crypto.rdrand;

extern(C):
    void MASM_RDRAND_GenerateBlock(ubyte* buf, size_t len);
    void MASM_RDSEED_GenerateBlock(ubyte* buf, size_t len);
    __gshared int g_hasRDRAND;
    __gshared int g_hasRDSEED;

private bool hasRDRAND() { return g_hasRDRAND != 0; }
private bool hasRDSEED() { return g_hasRDSEED != 0; }

int RDRAND_getBytes(ubyte* buf, size_t bufLen)
{
    if (buf is null || !hasRDRAND())
        return 0;
    if (bufLen)
        MASM_RDRAND_GenerateBlock(buf, bufLen);
    return 1;
}

int RDSEED_getBytes(ubyte* buf, size_t bufLen)
{
    if (buf is null || !hasRDSEED())
        return 0;
    if (bufLen)
        MASM_RDSEED_GenerateBlock(buf, bufLen);
    return 1;
}
