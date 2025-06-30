module Platform.Memory;

import core.stdc.stdlib : malloc, free, posix_memalign;
import core.stdc.string : memcpy, memset, memcmp;
import std.exception : enforce;

class Memory
{
    static void* allocate(size_t size)
    {
        enforce(size > 0, "ParameterIncorrect");
        auto p = malloc(size);
        enforce(p !is null, "bad_alloc");
        return p;
    }

    static void* allocateAligned(size_t size, size_t alignment)
    {
        enforce(size > 0, "ParameterIncorrect");
        void* p = null;
        if (alignment > 0)
        {
            if (posix_memalign(&p, alignment, size) != 0)
                p = null;
        }
        else
        {
            p = malloc(size);
        }
        enforce(p !is null, "bad_alloc");
        return p;
    }

    static int compare(const void* m1, size_t size1, const void* m2, size_t size2)
    {
        if (size1 > size2)
            return 1;
        else if (size1 < size2)
            return -1;
        return memcmp(m1, m2, size1);
    }

    static void copy(void* dst, const void* src, size_t size)
    {
        enforce(dst !is null && src !is null);
        memcpy(dst, src, size);
    }

    static void zero(void* mem, size_t size)
    {
        memset(mem, 0, size);
        auto p = cast(volatile ubyte*) mem;
        for(size_t i = 0; i < size; ++i)
            p[i] = 0;
    }

    static void freeMemory(void* mem)
    {
        enforce(mem !is null);
        free(mem);
    }

    static void freeAligned(void* mem)
    {
        enforce(mem !is null);
        free(mem); // posix_memalign memory freed with free
    }
}

class Endian
{
    static ubyte big(in ubyte x) { return x; }
    static ushort big(in ushort x)
    {
        version(BigEndian)
            return x;
        else
            return ((x & 0xff) << 8) | (x >> 8);
    }
    static uint big(in uint x)
    {
        version(BigEndian)
            return x;
        else
            return ((x & 0xff) << 24) | ((x & 0xff00) << 8) |
                   ((x & 0xff0000) >> 8) | (x >> 24);
    }
    static ulong big(in ulong x)
    {
        version(BigEndian)
            return x;
        else
        {
            ulong n = 0;
            foreach(i; 0 .. 8)
            {
                n <<= 8;
                n |= (x >> (i*8)) & 0xff;
            }
            return n;
        }
    }

    static ubyte little(in ubyte x) { return x; }
    static ushort little(in ushort x)
    {
        version(LittleEndian)
            return x;
        else
            return big(x);
    }
    static uint little(in uint x)
    {
        version(LittleEndian)
            return x;
        else
            return big(x);
    }
    static ulong little(in ulong x)
    {
        version(LittleEndian)
            return x;
        else
            return big(x);
    }
}
