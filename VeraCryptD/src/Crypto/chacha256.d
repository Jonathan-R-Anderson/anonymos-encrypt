module Crypto.chacha256;

extern(C):
struct ChaCha256Ctx
{
    align(16) uint[16] block_;
    align(16) uint[16] input_;
    size_t pos;
    int internalRounds;
}

void ChaCha256Init(ChaCha256Ctx* ctx, const(ubyte)* key, const(ubyte)* iv, int rounds);
void ChaCha256Encrypt(ChaCha256Ctx* ctx, const(ubyte)* in, size_t len, ubyte* out);
alias ChaCha256Decrypt = ChaCha256Encrypt;
