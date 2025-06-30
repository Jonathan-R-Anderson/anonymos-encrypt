module Platform.Stream;

abstract class Stream
{
    abstract ulong read(ubyte[] buffer);
    abstract void readCompleteBuffer(ubyte[] buffer);
    abstract void write(const(ubyte)[] data);
}
