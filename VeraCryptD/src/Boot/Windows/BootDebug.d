module Boot.Windows.BootDebug;

import Boot.Windows.BootConsoleIo;
import Boot.Windows.BootDefs;

version(TC_BOOT_TRACING_ENABLED)
{
    void initDebugPort()
    {
        asm {
            mov dx, TC_DEBUG_PORT;
            mov ah, 1;
            int 0x17;
            mov dx, TC_DEBUG_PORT;
            mov ah, 0xe2;
            int 0x17;
        }
    }

    void writeDebugPort(ubyte dataByte)
    {
        asm {
            mov al, dataByte;
            mov dx, TC_DEBUG_PORT;
            mov ah, 0;
            int 0x17;
        }
    }
}
else
{
    void initDebugPort() {}
    void writeDebugPort(ubyte dataByte) {}
}

version(TC_BOOT_DEBUG_ENABLED)
{
    extern(C) void PrintDebug(uint debugVal)
    {
        Print(debugVal);
        PrintEndl();
    }

    void printVal(const(char)* message, uint value, bool newLine=true, bool hex=false)
    {
        Print(message);
        Print(": ");
        if (hex)
            PrintHex(value);
        else
            Print(value);
        if (newLine)
            PrintEndl();
    }

    void printVal(const(char)* message, ulong value, bool newLine=true, bool hex=false)
    {
        Print(message);
        Print(": ");
        PrintHex(value);
        if (newLine)
            PrintEndl();
    }

    void printHexDump(ubyte* mem, size_t size, ushort* memSegment=null)
    {
        enum size_t width = 16;
        for (size_t pos = 0; pos < size; )
        {
            foreach(pass; 1 .. 3)
            {
                size_t i;
                for (i = 0; i < width && pos < size; ++i)
                {
                    ubyte dataByte;
                    if (memSegment)
                    {
                        asm {
                            push es;
                            mov si, memSegment;
                            mov es, [si];
                            mov si, mem;
                            add si, pos;
                            mov al, es:[si];
                            mov dataByte, al;
                            pop es;
                        }
                        ++pos;
                    }
                    else
                        dataByte = mem[pos++];
                    if (pass == 1)
                    {
                        PrintHex(dataByte);
                        PrintChar(' ');
                    }
                    else
                        PrintChar(IsPrintable(cast(char)dataByte) ? cast(char)dataByte : '.');
                }
                if (pass == 1)
                {
                    pos -= i;
                    PrintChar(' ');
                }
            }
            PrintEndl();
        }
    }

    void printHexDump(ushort memSegment, ushort memOffset, size_t size)
    {
        printHexDump(cast(ubyte*)memOffset, size, &memSegment);
    }
}
else
{
    void printHexDump(const(ubyte)[] mem, size_t size, ushort* memSegment=null) {}
    void printHexDump(ushort memSegment, ushort memOffset, size_t size) {}
    void printVal(const(char)* m, uint v, bool nl=true, bool hex=false) {}
    void printVal(const(char)* m, ulong v, bool nl=true, bool hex=false) {}
}

version(TC_BOOT_STACK_CHECKING_ENABLED)
{
    extern(C) __gshared char end[];

    static void PrintStackInfo()
    {
        ushort spReg;
        asm mov spReg, sp;
        Print("Stack: ");
        Print(TC_BOOT_LOADER_STACK_TOP - spReg);
        Print("/");
        Print(TC_BOOT_LOADER_STACK_TOP - cast(ushort) end);
    }

    void checkStack()
    {
        ushort spReg;
        asm mov spReg, sp;
        if (*cast(uint*)end != 0x12345678UL || spReg < cast(ushort)end)
        {
            asm cli;
            asm mov sp, TC_BOOT_LOADER_STACK_TOP;
            PrintError("Stack overflow");
            assert(0);
        }
    }

    void initStackChecker()
    {
        *cast(uint*)end = 0x12345678UL;
        PrintStackInfo();
        PrintEndl();
    }
}
else
{
    void checkStack() {}
    void initStackChecker() {}
}
