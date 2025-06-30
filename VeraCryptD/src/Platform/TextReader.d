module Platform.TextReader;

import std.stdio : File, readln;
import std.string : strip;

class TextReader
{
    private File file;

    this(string path)
    {
        file = File(path, "rb");
    }

    this(File f)
    {
        file = f;
    }

    bool readLine(out string output)
    {
        if (file.eof)
            return false;
        output = file.readln();
        output = strip(output, "\r\n");
        return true;
    }
}
