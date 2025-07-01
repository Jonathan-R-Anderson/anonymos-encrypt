module Crypto.Serpent;

extern(C):
void serpent_set_key(const(ubyte)* userKey, ubyte* ks);
void serpent_encrypt(const(ubyte)* inBlock, ubyte* outBlock, ubyte* ks);
void serpent_decrypt(const(ubyte)* inBlock, ubyte* outBlock, ubyte* ks);
