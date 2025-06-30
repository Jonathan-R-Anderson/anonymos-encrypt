module Boot.Windows.BootDebug;

import std.stdio : writefln;

void initDebugPort() {}
void initStackChecker() {}
void writeDebugPort(ubyte dataByte) {}
void printHexDump(const(ubyte)[] mem, size_t size, ushort* memSegment = null) {
    foreach(i; 0 .. size) writefln("%02X", mem[i]);
}
void printHexDump(ushort memSegment, ushort memOffset, size_t size) {}
void printVal(string message, uint value, bool newLine=true, bool hex=false) {
    if(hex) writefln("%s %X", message, value); else writefln("%s %d", message, value);
}
void printVal(string message, ulong value, bool newLine=true, bool hex=false) {
    if(hex) writefln("%s %X", message, value); else writefln("%s %d", message, value);
}
