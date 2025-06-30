module Platform.StringConverter;

import std.string : toLower, toUpper, strip, split, join, format;
import std.conv : to;
import std.algorithm : map;
import std.array : array;
import std.uni : byCodePoint;

class StringConverter
{
    static void erase(ref string str)
    {
        str = str.map!(c => ' ').array;
    }

    static void erase(ref wstring str)
    {
        str = str.map!(c => ' ').array;
    }

    static wstring fromNumber(long n) { return to!wstring(n); }
    static wstring fromNumber(ulong n) { return to!wstring(n); }
    static wstring fromNumber(int n) { return to!wstring(n); }
    static wstring fromNumber(uint n) { return to!wstring(n); }
    static wstring fromNumber(double n) { return to!wstring(n); }

    static string quoteSpaces(wstring s)
    {
        if (s.indexOf(' ') == -1)
            return to!string(s);
        return "'" ~ to!string(s).replace("'", "''") ~ "'";
    }

    static string[] splitString(string s, string seps=" \t\r\n", bool returnEmpty=false)
    {
        import std.array : empty;
        if (!returnEmpty)
            return s.split(seps).filter!(a => a.length).array;
        else
            return s.split(seps).array;
    }

    static string stripTrailingNumber(string s)
    {
        import std.regex : ctRegex, replace;
        return s.replace(ctRegex!"[0-9]+$", "");
    }

    static string toSingle(wstring wstr, bool noThrow=false)
    {
        try { return to!string(wstr); }
        catch(Exception e) { if (noThrow) return ""; throw e; }
    }

    static void toSingle(wstring wstr, out string s, bool noThrow=false)
    {
        s = toSingle(wstr, noThrow);
    }

    static wstring toWide(string s, bool noThrow=false)
    {
        try { return to!wstring(s); }
        catch(Exception e){ if(noThrow) return w""; throw e; }
    }

    static void toWideBuffer(wstring s, wchar* buffer, size_t size)
    {
        auto w = to!wstring(s);
        auto len = w.length < size-1 ? w.length : size-1;
        buffer[0 .. len] = w[0 .. len];
        buffer[len] = 0;
    }

    static uint toUInt32(string s) { return to!uint(s); }
    static uint toUInt32(wstring s) { return to!uint(s); }
    static int toInt32(string s) { return to!int(s); }
    static int toInt32(wstring s) { return to!int(s); }
    static ulong toUInt64(string s) { return to!ulong(s); }
    static ulong toUInt64(wstring s) { return to!ulong(s); }
    static long toInt64(string s) { return to!long(s); }
    static long toInt64(wstring s) { return to!long(s); }

    static string trim(string s) { return strip(s); }
}
