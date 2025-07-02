module Common.Cache;

public import Common.Password; // for Password struct if defined

enum CACHE_SIZE = 4;

extern(C):
    shared int cacheEmpty;

    void AddPasswordToCache(Password* password, int pim, bool cachePim);
    void AddLegacyPasswordToCache(PasswordLegacy* password, int pim);
    int ReadVolumeHeaderWCache(bool boot, bool cache, bool cachePim,
        ubyte* header, Password* password, int pkcs5, int pim,
        CryptoInfo** retInfo);
    void WipeCache();
