module Setup.Dir;

import std.file : mkdirRecurse, exists;
import std.string : fromWstringz;
import std.conv : to;
import core.stdc.wchar_ : wcslen;

extern(C):
int mkfulldir(wchar_t* path, int bCheckonly)
{
    auto s = fromWstringz(path);
    if (bCheckonly!=0)
        return exists(s) ? 0 : -1;
    mkdirRecurse(s);
    return exists(s) ? 0 : -1;
}

int mkfulldir_internal(wchar_t* path)
{
    return mkfulldir(path, 0);
}
