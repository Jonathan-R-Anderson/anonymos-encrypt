module Crypto.CamelliaSmall;

enum CAMELLIA_KS = 34 * 8 * 2;

extern(C):
void camellia_set_key(const(ubyte)* userKey, ubyte* ks);
void camellia_encrypt(const(ubyte)* inBlock, ubyte* outBlock, ubyte* ks);
void camellia_decrypt(const(ubyte)* inBlock, ubyte* outBlock, ubyte* ks);
