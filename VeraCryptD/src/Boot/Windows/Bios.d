module Boot.Windows.Bios;

enum uint TC_LB_SIZE_BIT_SHIFT_DIVISOR = 9;

enum uint TC_FIRST_BIOS_DRIVE = 0x80;
enum uint TC_LAST_BIOS_DRIVE = 0x8f;
enum uint TC_INVALID_BIOS_DRIVE = TC_FIRST_BIOS_DRIVE - 1;

enum BiosResult : ubyte
{
    Success = 0x00,
    InvalidFunction = 0x01,
    Timeout = 0x80
}
