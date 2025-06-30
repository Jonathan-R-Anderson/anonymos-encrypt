module Platform.File;

import std.stdio : File, write;
import std.exception : enforce;
import std.file : exists;
import Platform.Buffer;
import Platform.Exception;

class FileEx : Exception { this(string m=""){ super(m); } }

enum FileOpenMode { CreateReadWrite, CreateWrite, OpenRead, OpenWrite, OpenReadWrite }
enum FileShareMode { ShareNone, ShareRead, ShareReadWrite, ShareReadWriteIgnoreLock }
enum FileOpenFlags { FlagsNone = 0, PreserveTimestamps = 1, DisableWriteCaching = 2 }

class File
{
    private File f;
    private string path;
    private bool fileIsOpen = false;

    this(){}

    void open(string p, FileOpenMode mode=FileOpenMode.OpenRead)
    {
        if (fileIsOpen)
            close();
        path = p;
        string modeStr;
        final switch(mode)
        {
            case FileOpenMode.CreateReadWrite: modeStr="w+"; break;
            case FileOpenMode.CreateWrite: modeStr="w"; break;
            case FileOpenMode.OpenRead: modeStr="r"; break;
            case FileOpenMode.OpenWrite: modeStr="r+"; break;
            case FileOpenMode.OpenReadWrite: modeStr="r+"; break;
        }
        f = File(path, modeStr);
        fileIsOpen = true;
    }

    void close()
    {
        if (fileIsOpen)
        {
            f.close();
            fileIsOpen = false;
        }
    }

    bool isOpen() const { return fileIsOpen; }
    string getPath() const { return path; }

    ulong read(ubyte[] buffer)
    {
        enforce(fileIsOpen, "NotInitialized");
        return f.rawRead(buffer.ptr, buffer.length);
    }

    void readCompleteBuffer(ubyte[] buffer)
    {
        auto n = read(buffer);
        enforce(n == buffer.length, "InsufficientData");
    }

    ulong readAt(ubyte[] buffer, ulong pos)
    {
        enforce(fileIsOpen, "NotInitialized");
        f.seek(cast(long)pos, SeekPos.set);
        return read(buffer);
    }

    void seekAt(ulong pos)
    {
        enforce(fileIsOpen, "NotInitialized");
        f.seek(cast(long)pos, SeekPos.set);
    }

    void seekEnd(long offset)
    {
        enforce(fileIsOpen, "NotInitialized");
        f.seek(offset, SeekPos.end);
    }

    void write(const(ubyte)[] data)
    {
        enforce(fileIsOpen, "NotInitialized");
        f.rawWrite(data.ptr, data.length);
    }

    ulong length() const
    {
        enforce(fileIsOpen, "NotInitialized");
        auto pos = f.tell();
        f.seek(0, SeekPos.end);
        auto len = f.tell();
        f.seek(pos, SeekPos.set);
        return cast(ulong)len;
    }

    ~this()
    {
        if (fileIsOpen)
            close();
    }

    static void copy(string src, string dst)
    {
        auto s = File(src, "rb");
        auto d = File(dst, "wb");
        ubyte[8192] buf;
        size_t len;
        while ((len = s.rawRead(buf.ptr, buf.length)) > 0)
        {
            d.rawWrite(buf.ptr, len);
        }
        s.close();
        d.close();
    }

    void remove()
    {
        if (fileIsOpen)
            close();
        import std.file : remove;
        if (exists(path))
            remove(path);
    }
}
