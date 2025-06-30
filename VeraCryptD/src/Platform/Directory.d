module Platform.Directory;

import std.file : mkdir, dirEntries, SpanMode, DirEntry;
import std.path : dirSeparator, buildPath;
import std.algorithm : endsWith;

alias DirectoryPath = string;
alias FilePath = string;
alias FilePathList = string[];

class Directory
{
    static void create(string path)
    {
        mkdir(path);
    }

    static string appendSeparator(string path)
    {
        if (path.length && !path.endsWith(dirSeparator))
            return path ~ dirSeparator;
        return path;
    }

    static FilePathList getFilePaths(string path = ".", bool regularFilesOnly = true)
    {
        FilePathList files;
        foreach (DirEntry de; dirEntries(path, SpanMode.shallow))
        {
            if (regularFilesOnly && !de.isFile)
                continue;
            files ~= buildPath(path, de.name);
        }
        return files;
    }

private:
    this() {}
}
