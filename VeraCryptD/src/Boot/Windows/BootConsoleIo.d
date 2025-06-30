module Boot.Windows.BootConsoleIo;

import Boot.Windows.BootDebug;
import Boot.Windows.BootStrings;
import Boot.Windows.BootDefs;

enum uint TC_DEBUG_PORT = 0;

enum uint TC_BIOS_KEY_ESC = 1;
enum uint TC_BIOS_KEY_BACKSPACE = 14;
enum uint TC_BIOS_KEY_ENTER = 28;
enum uint TC_BIOS_KEY_F1 = 0x3b;
enum uint TC_BIOS_KEY_F2 = 0x3c;
enum uint TC_BIOS_KEY_F3 = 0x3d;
enum uint TC_BIOS_KEY_F4 = 0x3e;
enum uint TC_BIOS_KEY_F5 = 0x3f;
enum uint TC_BIOS_KEY_F6 = 0x40;
enum uint TC_BIOS_KEY_F7 = 0x41;
enum uint TC_BIOS_KEY_F8 = 0x42;
enum uint TC_BIOS_KEY_F9 = 0x43;
enum uint TC_BIOS_KEY_F10 = 0x44;

enum uint TC_BIOS_SHIFTMASK_CAPSLOCK      = (1 << 6);
enum uint TC_BIOS_SHIFTMASK_LSHIFT        = (1 << 1);
enum uint TC_BIOS_SHIFTMASK_RSHIFT        = (1 << 0);

enum uint TC_BIOS_CHAR_BACKSPACE          = 8;

enum uint TC_BIOS_MAX_CHARS_PER_LINE      = 80;

void Beep()
{
    PrintChar(7);
}

static int ScreenOutputDisabled = 0;

version(TC_TRACE_INT13) {}
version(TC_WINDOWS_BOOT_RESCUE_DISK_MODE) {}

void DisableScreenOutput()
{
    ++ScreenOutputDisabled;
}

void EnableScreenOutput()
{
    --ScreenOutputDisabled;
}

void PrintChar(char c)
{
    version(TC_BOOT_TRACING_ENABLED)
        WriteDebugPort(cast(ubyte)c);

    if (ScreenOutputDisabled)
        return;

    asm {
        mov bx, 7;
        mov al, c;
        mov ah, 0xe;
        int 0x10;
    }
}

void PrintCharAtCursor(char c)
{
    if (ScreenOutputDisabled)
        return;
    asm {
        mov bx, 7;
        mov al, c;
        mov cx, 1;
        mov ah, 0xa;
        int 0x10;
    }
}

void Print(const(char)* str)
{
    char c;
    size_t i = 0;
    while ((c = str[i++]))
        PrintChar(c);
}

void Print(uint number)
{
    char[12] str;
    int pos = 0;
    uint n = number;
    while (n >= 10)
    {
        str[pos++] = cast(char)(n % 10) + '0';
        n /= 10;
    }
    str[pos] = cast(char)(n % 10) + '0';
    while (pos >= 0)
        PrintChar(str[pos--]);
}

void Print(const(ulong) number)
{
    if (number >> 32 == 0)
        Print(cast(uint)number);
    else
        PrintHex(number);
}

void PrintHex(ubyte b)
{
    PrintChar(((b >> 4) >= 0xA ? 'A' - 0xA : '0') + (b >> 4));
    PrintChar(((b & 0xF) >= 0xA ? 'A' - 0xA : '0') + (b & 0xF));
}

void PrintHex(ushort data)
{
    PrintHex(cast(ubyte)(data >> 8));
    PrintHex(cast(ubyte)data);
}

void PrintHex(uint data)
{
    PrintHex(cast(ushort)(data >> 16));
    PrintHex(cast(ushort)data);
}

void PrintHex(const(ulong) data)
{
    PrintHex(cast(uint)(data >> 32));
    PrintHex(cast(uint)data);
}

void PrintRepeatedChar(char c, int n)
{
    while (n-- > 0)
        PrintChar(c);
}

void PrintEndl()
{
    Print("\r\n");
}

void PrintEndl(int cnt)
{
    while (cnt-- > 0)
        PrintEndl();
}

void InitVideoMode()
{
    if (ScreenOutputDisabled)
        return;
    asm {
        mov ax, 3;
        int 0x10;
        mov ax, 0x500;
        int 0x10;
    }
}

void ClearScreen()
{
    if (ScreenOutputDisabled)
        return;
    asm {
        mov bh, 7;
        xor cx, cx;
        mov dx, 0x184f;
        mov ax, 0x600;
        int 0x10;
        xor bh, bh;
        xor dx, dx;
        mov ah, 2;
        int 0x10;
    }
}

void PrintBackspace()
{
    PrintChar(TC_BIOS_CHAR_BACKSPACE);
    PrintCharAtCursor(' ');
}

void PrintError(const(char)* message)
{
    Print(TC_BOOT_STR_ERROR.ptr);
    Print(message);
    PrintEndl();
    Beep();
}

void PrintErrorNoEndl(const(char)* message)
{
    Print(TC_BOOT_STR_ERROR.ptr);
    Print(message);
    Beep();
}

ubyte GetShiftFlags()
{
    ubyte flags;
    asm {
        mov ah, 2;
        int 0x16;
        mov flags, al;
    }
    return flags;
}

ubyte GetKeyboardChar()
{
    return GetKeyboardChar(null);
}

ubyte GetKeyboardChar(ubyte* scanCode)
{
    while (!IsKeyboardCharAvailable())
    {
        asm { hlt; }
    }
    ubyte asciiCode;
    ubyte scan;
    asm {
        mov ah, 0;
        int 0x16;
        mov asciiCode, al;
        mov scan, ah;
    }
    if (scanCode)
        *scanCode = scan;
    return asciiCode;
}

bool IsKeyboardCharAvailable()
{
    bool available = false;
    asm {
        mov ah, 1;
        int 0x16;
        jz not_avail;
        mov available, 1;
    not_avail:
    }
    return available;
}

bool EscKeyPressed()
{
    if (IsKeyboardCharAvailable())
    {
        ubyte keyScanCode;
        GetKeyboardChar(&keyScanCode);
        return keyScanCode == TC_BIOS_KEY_ESC;
    }
    return false;
}

void ClearBiosKeystrokeBuffer()
{
    asm {
        push es;
        xor ax, ax;
        mov es, ax;
        mov di, 0x41e;
        mov cx, 32;
        cld;
        rep stosb;
        mov ax, 0x001e;
        mov es:[0x41a], ax;
        mov es:[0x41c], ax;
        pop es;
    }
}

bool IsPrintable(char c)
{
    return c >= ' ' && c <= '~';
}

bool IsDigit(char c)
{
    return c >= '0' && c <= '9';
}

int GetString(char* buffer, size_t bufferSize)
{
    ubyte c;
    ubyte scanCode;
    size_t pos = 0;
    while (pos < bufferSize)
    {
        c = GetKeyboardChar(&scanCode);
        if (scanCode == TC_BIOS_KEY_ENTER)
            break;
        if (scanCode == TC_BIOS_KEY_ESC)
            return 0;
        buffer[pos++] = c;
        PrintChar(IsPrintable(c) ? c : ' ');
    }
    return cast(int)pos;
}
