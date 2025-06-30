module Volume.Version;

enum VERSION_STRING = "1.26.26";
enum VERSION_NUM = 0x0126;

class Version
{
    static string String() { return VERSION_STRING; }
    static ushort Number() { return VERSION_NUM; }
}
