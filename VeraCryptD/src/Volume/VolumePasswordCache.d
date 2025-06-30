module Volume.VolumePasswordCache;

import Volume.VolumePassword;

alias CachedPasswordList = VolumePassword[];

class VolumePasswordCache
{
    static CachedPasswordList cachedPasswords;
    static size_t Capacity = 4;

    static CachedPasswordList getPasswords()
    {
        return cachedPasswords.dup;
    }

    static bool isEmpty()
    {
        return cachedPasswords.length == 0;
    }

    static void store(const VolumePassword pwd)
    {
        foreach(i, ref p; cachedPasswords)
        {
            if (p.size == pwd.size && p.passwordBuffer[0 .. p.size] == pwd.passwordBuffer[0 .. pwd.size])
            {
                cachedPasswords = cachedPasswords[0 .. i] ~ cachedPasswords[i+1 .. $];
                break;
            }
        }
        cachedPasswords = [pwd] ~ cachedPasswords;
        if (cachedPasswords.length > Capacity)
            cachedPasswords.length = Capacity;
    }

    static void clear()
    {
        cachedPasswords.length = 0;
    }
}
