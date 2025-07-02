module Common.Password;

enum MIN_PASSWORD = 1;
enum MAX_LEGACY_PASSWORD = 64;
enum MAX_PASSWORD = 128;
enum MAX_PIM = 7;
enum MAX_PIM_VALUE = 2147468;
enum MAX_BOOT_PIM = 5;
enum MAX_BOOT_PIM_VALUE = 65535;
enum PASSWORD_LEN_WARNING = 20;

struct Password
{
    uint Length;
    ubyte[MAX_PASSWORD + 1] Text;
    char[3] Pad;
}

struct PasswordLegacy
{
    uint Length;
    ubyte[MAX_LEGACY_PASSWORD + 1] Text;
    char[3] Pad;
}

