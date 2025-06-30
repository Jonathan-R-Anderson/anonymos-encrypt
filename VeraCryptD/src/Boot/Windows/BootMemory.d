module Boot.Windows.BootMemory;

import Boot.Windows.BootDefs;
import Boot.Windows.Bios;
import Boot.Windows.BootDebug;

#pragma pack(push,1)
struct BiosMemoryMapEntry
{
    ulong BaseAddress;
    ulong Length;
    uint Type;
}
#pragma pack(pop)

static uint MemoryMapContValue;

static bool GetMemoryMapEntry(ref BiosMemoryMapEntry entry)
{
    enum uint function = 0x0000E820;
    enum uint magic = 0x534D4150;
    enum uint bufferSize = BiosMemoryMapEntry.sizeof;
    bool carry = false;
    uint resultMagic;
    uint resultSize;
    asm {
        push es;
        lea di, function;
        mov eax, [di];
        lea di, MemoryMapContValue;
        mov ebx, [di];
        lea di, bufferSize;
        mov ecx, [di];
        lea di, magic;
        mov edx, [di];
        lea di, MemoryMapContValue;
        mov edi, [di];
        push TC_BOOT_LOADER_ALT_SEGMENT;
        pop es;
        mov di, 0;
        int 0x15;
        jnc no_carry;
        mov carry, 1;
    no_carry:
        lea di, resultMagic;
        mov [di], eax;
        lea di, MemoryMapContValue;
        mov [di], ebx;
        lea di, resultSize;
        mov [di], ecx;
        pop es;
    }
    CopyMemory(TC_BOOT_LOADER_ALT_SEGMENT, 0, &entry, BiosMemoryMapEntry.sizeof);
    if (carry)
        MemoryMapContValue = 0;
    return resultMagic == magic && resultSize == bufferSize;
}

bool GetFirstBiosMemoryMapEntry(ref BiosMemoryMapEntry entry)
{
    MemoryMapContValue = 0;
    return GetMemoryMapEntry(entry);
}

bool GetNextBiosMemoryMapEntry(ref BiosMemoryMapEntry entry)
{
    if (MemoryMapContValue == 0)
        return false;
    return GetMemoryMapEntry(entry);
}
