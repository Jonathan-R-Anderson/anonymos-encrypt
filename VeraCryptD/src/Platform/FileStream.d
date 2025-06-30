module Platform.FileStream;

import Platform.Stream;
import Platform.File;
import std.exception : enforce;

class FileStream : Stream
{
    File dataFile;

    this(File file)
    {
        dataFile = file;
    }

    override ulong read(ubyte[] buffer)
    {
        return dataFile.read(buffer);
    }

    override void readCompleteBuffer(ubyte[] buffer)
    {
        dataFile.readCompleteBuffer(buffer);
    }

    override void write(const(ubyte)[] data)
    {
        dataFile.write(data);
    }
}
