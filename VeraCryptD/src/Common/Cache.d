module Common.Cache;

public import Common.Password; // for Password struct if defined

enum CACHE_SIZE = 4;

struct CryptoInfo; // forward declaration

extern(C) shared int cacheEmpty;

private Password[CACHE_SIZE] CachedPasswords;
private int[CACHE_SIZE] CachedPim;
private int nPasswordIdx = 0;

extern(C) int ReadVolumeHeader(bool boot, ubyte* header, Password* password, int pkcs5, int pim, CryptoInfo** retInfo, void*);
extern(C) bool IsRamEncryptionEnabled();
extern(C) void VcProtectMemory(ulong encID, ubyte* buf1, size_t size1, ubyte* buf2, size_t size2);
extern(C) void burn(void* ptr, size_t size);

ulong VcGetPasswordEncryptionID(Password* p)
{
    return cast(ulong)p.Text.ptr + cast(ulong)p;
}

void VcProtectPassword(Password* p, ulong encID)
{
    VcProtectMemory(encID, p.Text.ptr, p.Text.sizeof, cast(ubyte*)&p.Length, Password.sizeof - p.Text.sizeof);
}

void VcUnprotectPassword(Password* p, ulong encID)
{
    VcProtectPassword(p, encID);
}

extern(C)
int ReadVolumeHeaderWCache(bool boot, bool cache, bool cachePim,
    ubyte* header, Password* password, int pkcs5, int pim,
    CryptoInfo** retInfo)
{
    int nReturnCode = ERR_PASSWORD_WRONG;
    int i, effectivePim;

    if (password.Length > 0)
    {
        nReturnCode = ReadVolumeHeader(boot, header, password, pkcs5, pim, retInfo, null);
        if (cache && (nReturnCode == 0 || nReturnCode == ERR_CIPHER_INIT_WEAK_KEY))
        {
            Password tmpPass;
            for (i = 0; i < CACHE_SIZE; ++i)
            {
                Password* current = &CachedPasswords[i];
                if (IsRamEncryptionEnabled())
                {
                    tmpPass = *current;
                    VcUnprotectPassword(&tmpPass, VcGetPasswordEncryptionID(current));
                    current = &tmpPass;
                }
                import core.stdc.string : memcmp;
                if (memcmp(current, password, Password.sizeof) == 0)
                    break;
            }
            if (IsRamEncryptionEnabled())
                burn(&tmpPass, Password.sizeof);
            if (i == CACHE_SIZE)
            {
                CachedPasswords[nPasswordIdx] = *password;
                if (IsRamEncryptionEnabled())
                    VcProtectPassword(&CachedPasswords[nPasswordIdx], VcGetPasswordEncryptionID(&CachedPasswords[nPasswordIdx]));
                CachedPim[nPasswordIdx] = cachePim && pim > 0 ? pim : 0;
                nPasswordIdx = (nPasswordIdx + 1) % CACHE_SIZE;
                cacheEmpty = 0;
            }
            else if (cachePim)
            {
                CachedPim[i] = pim > 0 ? pim : 0;
            }
        }
    }
    else if (!cacheEmpty)
    {
        Password tmpPass;
        for (i = 0; i < CACHE_SIZE; ++i)
        {
            Password* current = &CachedPasswords[i];
            if (IsRamEncryptionEnabled())
            {
                tmpPass = *current;
                VcUnprotectPassword(&tmpPass, VcGetPasswordEncryptionID(current));
                current = &tmpPass;
            }
            if (current.Length > 0 && current.Length <= (boot ? MAX_LEGACY_PASSWORD : MAX_PASSWORD))
            {
                effectivePim = pim == -1 ? CachedPim[i] : pim;
                nReturnCode = ReadVolumeHeader(boot, header, current, pkcs5, effectivePim, retInfo, null);
                if (nReturnCode != ERR_PASSWORD_WRONG)
                    break;
            }
        }
        if (IsRamEncryptionEnabled())
            burn(&tmpPass, Password.sizeof);
    }
    return nReturnCode;
}

extern(C)
void AddPasswordToCache(Password* password, int pim, bool cachePim)
{
    Password tmpPass;
    int i;
    for (i = 0; i < CACHE_SIZE; ++i)
    {
        Password* current = &CachedPasswords[i];
        if (IsRamEncryptionEnabled())
        {
            tmpPass = *current;
            VcUnprotectPassword(&tmpPass, VcGetPasswordEncryptionID(current));
            current = &tmpPass;
        }
        import core.stdc.string : memcmp;
        if (memcmp(current, password, Password.sizeof) == 0)
            break;
    }
    if (i == CACHE_SIZE)
    {
        CachedPasswords[nPasswordIdx] = *password;
        if (IsRamEncryptionEnabled())
            VcProtectPassword(&CachedPasswords[nPasswordIdx], VcGetPasswordEncryptionID(&CachedPasswords[nPasswordIdx]));
        CachedPim[nPasswordIdx] = cachePim && pim > 0 ? pim : 0;
        nPasswordIdx = (nPasswordIdx + 1) % CACHE_SIZE;
        cacheEmpty = 0;
    }
    else if (cachePim)
    {
        CachedPim[i] = pim > 0 ? pim : 0;
    }
    if (IsRamEncryptionEnabled())
        burn(&tmpPass, Password.sizeof);
}

extern(C)
void AddLegacyPasswordToCache(PasswordLegacy* password, int pim)
{
    Password input;
    input.Length = password.Length;
    import core.stdc.string : memcpy;
    memcpy(input.Text.ptr, password.Text.ptr, password.Length);
    AddPasswordToCache(&input, pim, true);
    burn(&input, Password.sizeof);
}

extern(C)
void WipeCache()
{
    burn(CachedPasswords.ptr, CachedPasswords.sizeof);
    burn(CachedPim.ptr, CachedPim.sizeof);
    nPasswordIdx = 0;
    cacheEmpty = 1;
}

enum ERR_PASSWORD_WRONG = 3;
enum ERR_CIPHER_INIT_WEAK_KEY = 18;
