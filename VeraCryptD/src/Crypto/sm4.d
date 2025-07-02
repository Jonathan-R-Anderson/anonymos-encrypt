module Crypto.sm4;

extern(C):
struct sm4_kds
{
    align(16) uint[32] m_rEnckeys;
    align(16) uint[32] m_rDeckeys;
}

enum SM4_KS = sm4_kds.sizeof;

void sm4_set_key(const(ubyte)* key, sm4_kds* kds);
void sm4_encrypt_block(ubyte* out, const(ubyte)* in, sm4_kds* kds);
void sm4_encrypt_blocks(ubyte* out, const(ubyte)* in, size_t blocks, sm4_kds* kds);
void sm4_decrypt_block(ubyte* out, const(ubyte)* in, sm4_kds* kds);
void sm4_decrypt_blocks(ubyte* out, const(ubyte)* in, size_t blocks, sm4_kds* kds);
