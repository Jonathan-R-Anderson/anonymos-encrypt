module Main.VolumeHistory;

import std.file : readText, exists, write, remove;
import std.path : buildPath, dirName;
import std.regex : regex, matchAll;
import Platform.Mutex;

struct VolumeHistory
{
    private static string[] volumePaths;
    private static Mutex accessMutex = new Mutex();

    static void add(string path)
    {
        auto lock = ScopeLock(accessMutex);
        foreach(i, p; volumePaths)
        {
            if (p == path)
            {
                volumePaths = volumePaths[0 .. i] ~ volumePaths[i+1 .. $];
                break;
            }
        }
        volumePaths = [path] ~ volumePaths;
        if (volumePaths.length > MaxSize)
            volumePaths.length = MaxSize;
    }

    static void clear()
    {
        auto lock = ScopeLock(accessMutex);
        volumePaths.length = 0;
        save();
    }

    static string[] get()
    {
        auto lock = ScopeLock(accessMutex);
        return volumePaths.dup;
    }

    static void connectComboBox() {}
    static void disconnectComboBox() {}

    static void load()
    {
        auto lock = ScopeLock(accessMutex);
        string file = historyFilePath();
        if (!exists(file)) return;
        string xml = readText(file);
        auto re = regex(`<volume>([^<]+)</volume>`, "g");
        foreach(m; matchAll(xml, re))
            volumePaths ~= m.captures[1];
    }

    static void save()
    {
        auto lock = ScopeLock(accessMutex);
        string file = historyFilePath();
        if (volumePaths.length == 0)
        {
            if (exists(file)) remove(file);
            return;
        }
        string[] lines;
        lines ~= "<history>";
        foreach(p; volumePaths)
            lines ~= "<volume>"~p~"</volume>";
        lines ~= "</history>";
        write(file, lines.join("\n"));
    }

    private static string historyFilePath()
    {
        return buildPath(dirName(__FILE__), getFileName());
    }

    enum uint MaxSize = 10;
    static string getFileName() { return "History.xml"; }
}
