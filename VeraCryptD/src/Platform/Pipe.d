module Platform.Pipe;

import core.sys.posix.unistd : pipe, close;
import std.exception : enforce;

class Pipe
{
    private int readFD = -1;
    private int writeFD = -1;

    this()
    {
        int[2] fds;
        enforce(pipe(fds.ptr) == 0, "pipe failed");
        readFD = fds[0];
        writeFD = fds[1];
    }

    ~this()
    {
        try { close(); } catch(Exception) {}
    }

    void close()
    {
        if (readFD != -1) { close(readFD); readFD = -1; }
        if (writeFD != -1) { close(writeFD); writeFD = -1; }
    }

    int getReadFD()
    {
        enforce(readFD != -1, "pipe closed");
        if (writeFD != -1) { close(writeFD); writeFD = -1; }
        return readFD;
    }

    int getWriteFD()
    {
        enforce(writeFD != -1, "pipe closed");
        if (readFD != -1) { close(readFD); readFD = -1; }
        return writeFD;
    }

    int peekReadFD() const { return readFD; }
    int peekWriteFD() const { return writeFD; }
}
