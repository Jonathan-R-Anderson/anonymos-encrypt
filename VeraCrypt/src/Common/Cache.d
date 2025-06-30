module Common.Cache;

import core.stdc.string : memcpy, memcmp;
import core.stdc.stdint : uint32_t, uint64_t;
import core.stdc.stddef : size_t;

extern(C):

alias BOOL = int;

enum TRUE = 1;
enum FALSE = 0;

enum ERR_PASSWORD_WRONG = 3;
enum ERR_CIPHER_INIT_WEAK_KEY = 18;

enum MAX_PASSWORD = 128;
enum MAX_LEGACY_PASSWORD = 64;
enum CACHE_SIZE = 4;

struct Password {
    uint32_t Length;
    ubyte[MAX_PASSWORD + 1] Text;
    char[3] Pad;
}

struct PasswordLegacy {
    uint32_t Length;
    ubyte[MAX_LEGACY_PASSWORD + 1] Text;
    char[3] Pad;
}

struct CRYPTO_INFO; // opaque
alias PCRYPTO_INFO = CRYPTO_INFO*;

__gshared Password[CACHE_SIZE] CachedPasswords;
__gshared int[CACHE_SIZE] CachedPim;
__gshared int cacheEmpty = 1;
__gshared int nPasswordIdx = 0;

// External C functions
BOOL IsRamEncryptionEnabled();
void burn(void* mem, size_t size);
int ReadVolumeHeader(BOOL bBoot, ubyte* header, Password* password, int pkcs5_prf, int pim, PCRYPTO_INFO* retInfo, void* reserved);
void VcProtectMemory(uint64_t encID, ubyte* data1, size_t size1, ubyte* data2, size_t size2);

uint64_t VcGetPasswordEncryptionID(Password* pPassword)
{
    return cast(uint64_t) pPassword.Text.ptr + cast(uint64_t) pPassword;
}

void VcProtectPassword(Password* pPassword, uint64_t encID)
{
    VcProtectMemory(encID, pPassword.Text.ptr, pPassword.Text.sizeof, cast(ubyte*)&pPassword.Length, Password.sizeof - pPassword.Text.sizeof);
}

void VcUnprotectPassword(Password* pPassword, uint64_t encID)
{
    VcProtectPassword(pPassword, encID);
}

int ReadVolumeHeaderWCache(BOOL bBoot, BOOL bCache, BOOL bCachePim, ubyte* header, Password* password, int pkcs5_prf, int pim, PCRYPTO_INFO* retInfo)
{
    int nReturnCode = ERR_PASSWORD_WRONG;
    int i;
    int effectivePim;

    if (password.Length > 0)
    {
        nReturnCode = ReadVolumeHeader(bBoot, header, password, pkcs5_prf, pim, retInfo, null);

        if (bCache && (nReturnCode == 0 || nReturnCode == ERR_CIPHER_INIT_WEAK_KEY))
        {
            Password tmpPass;
            for (i = 0; i < CACHE_SIZE; i++)
            {
                Password* pCurrentPassword = &CachedPasswords[i];
                if (IsRamEncryptionEnabled())
                {
                    memcpy(&tmpPass, pCurrentPassword, Password.sizeof);
                    VcUnprotectPassword(&tmpPass, VcGetPasswordEncryptionID(pCurrentPassword));
                    pCurrentPassword = &tmpPass;
                }
                if (memcmp(pCurrentPassword, password, Password.sizeof) == 0)
                    break;
            }

            if (IsRamEncryptionEnabled())
                burn(&tmpPass, Password.sizeof);

            if (i == CACHE_SIZE)
            {
                CachedPasswords[nPasswordIdx] = *password;
                if (IsRamEncryptionEnabled())
                    VcProtectPassword(&CachedPasswords[nPasswordIdx], VcGetPasswordEncryptionID(&CachedPasswords[nPasswordIdx]));
                if (bCachePim && (pim > 0))
                    CachedPim[nPasswordIdx] = pim;
                else
                    CachedPim[nPasswordIdx] = 0;
                nPasswordIdx = (nPasswordIdx + 1) % CACHE_SIZE;
                cacheEmpty = 0;
            }
            else if (bCachePim)
            {
                CachedPim[i] = pim > 0 ? pim : 0;
            }
        }
    }
    else if (!cacheEmpty)
    {
        Password tmpPass;
        for (i = 0; i < CACHE_SIZE; i++)
        {
            Password* pCurrentPassword = &CachedPasswords[i];
            if (IsRamEncryptionEnabled())
            {
                memcpy(&tmpPass, pCurrentPassword, Password.sizeof);
                VcUnprotectPassword(&tmpPass, VcGetPasswordEncryptionID(pCurrentPassword));
                pCurrentPassword = &tmpPass;
            }

            if (pCurrentPassword.Length > 0 && pCurrentPassword.Length <= cast(uint)((bBoot ? MAX_LEGACY_PASSWORD : MAX_PASSWORD)))
            {
                if (pim == -1)
                    effectivePim = CachedPim[i];
                else
                    effectivePim = pim;
                nReturnCode = ReadVolumeHeader(bBoot, header, pCurrentPassword, pkcs5_prf, effectivePim, retInfo, null);

                if (nReturnCode != ERR_PASSWORD_WRONG)
                    break;
            }
        }
        if (IsRamEncryptionEnabled())
            burn(&tmpPass, Password.sizeof);
    }
    return nReturnCode;
}

void AddPasswordToCache(Password* password, int pim, BOOL bCachePim)
{
    Password tmpPass;
    int i;
    for (i = 0; i < CACHE_SIZE; i++)
    {
        Password* pCurrentPassword = &CachedPasswords[i];
        if (IsRamEncryptionEnabled())
        {
            memcpy(&tmpPass, pCurrentPassword, Password.sizeof);
            VcUnprotectPassword(&tmpPass, VcGetPasswordEncryptionID(pCurrentPassword));
            pCurrentPassword = &tmpPass;
        }

        if (memcmp(pCurrentPassword, password, Password.sizeof) == 0)
            break;
    }

    if (i == CACHE_SIZE)
    {
        CachedPasswords[nPasswordIdx] = *password;
        if (IsRamEncryptionEnabled())
            VcProtectPassword(&CachedPasswords[nPasswordIdx], VcGetPasswordEncryptionID(&CachedPasswords[nPasswordIdx]));
        if (bCachePim && (pim > 0))
            CachedPim[nPasswordIdx] = pim;
        else
            CachedPim[nPasswordIdx] = 0;
        nPasswordIdx = (nPasswordIdx + 1) % CACHE_SIZE;
        cacheEmpty = 0;
    }
    else if (bCachePim)
    {
        CachedPim[i] = pim > 0 ? pim : 0;
    }

    if (IsRamEncryptionEnabled())
        burn(&tmpPass, Password.sizeof);
}

void AddLegacyPasswordToCache(PasswordLegacy* password, int pim)
{
    Password inputPass;
    inputPass.Length = password.Length;
    memcpy(inputPass.Text.ptr, password.Text.ptr, password.Length);
    AddPasswordToCache(&inputPass, pim, TRUE);
    burn(&inputPass, Password.sizeof);
}

void WipeCache()
{
    burn(CachedPasswords.ptr, CachedPasswords.sizeof);
    burn(CachedPim.ptr, CachedPim.sizeof);
    nPasswordIdx = 0;
    cacheEmpty = 1;
}

