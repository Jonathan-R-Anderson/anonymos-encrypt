module Common.SCardManager;

import std.stdio;
import std.array;

class SCardManager
{
    this(){}
    ~this(){}
    static string[] getReaders(){ return []; }
    static Object getReader(size_t idx){ return null; }
}
