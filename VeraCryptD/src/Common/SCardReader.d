module Common.SCardReader;

import Common.SCardLoader;
import std.array;

class SCardReader
{
    this(string name, SCardLoader loader){}
    bool isCardPresent(){ return false; }
}
