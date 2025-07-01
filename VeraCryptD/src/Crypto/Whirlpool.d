module Crypto.Whirlpool;

struct WHIRLPOOL_CTX
{
    ulong countLo;
    ulong countHi;
    align(16) ulong[8] data;
    align(16) ulong[8] state;
}

extern(C):
void WHIRLPOOL_add(const(ubyte)* source, uint sourceBytes, WHIRLPOOL_CTX* ctx);
void WHIRLPOOL_finalize(WHIRLPOOL_CTX* ctx, ubyte* result);
void WHIRLPOOL_init(WHIRLPOOL_CTX* ctx);
