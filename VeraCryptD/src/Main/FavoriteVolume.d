module Main.FavoriteVolume;

import std.file : readText, exists, remove, write;
import std.regex : regex, matchAll;
import std.path : buildPath, dirName;
import std.string : replace;
import std.conv : to;
import Platform.Directory; // for DirectoryPath alias
import Volume.VolumeSlot; // for VolumeSlotNumber

enum VolumeProtection { None, ReadOnly, HiddenVolumeReadOnly }

struct MountOptions
{
    string mountPoint;
    string path;
    VolumeProtection protection = VolumeProtection.None;
    VolumeSlotNumber slotNumber;
    bool partitionInSystemEncryptionScope = false;
    bool noFilesystem = false;
}

struct FavoriteVolume
{
    string mountPoint;
    string path;
    bool readOnly = false;
    VolumeSlotNumber slotNumber = 0;
    bool system = false;

    static FavoriteVolume[] loadList()
    {
        string file = buildPath(dirName(__FILE__), getFileName());
        if (!exists(file)) return null;
        string xml = readText(file);
        FavoriteVolume[] list;
        auto re = regex(`<volume[^>]*mountpoint="([^"]*)"[^>]*slotnumber="([^"]*)"[^>]*readonly="([^"]*)"[^>]*system="([^"]*)">([^<]*)</volume>`, "g");
        foreach(m; matchAll(xml, re))
        {
            FavoriteVolume v;
            v.mountPoint = m.captures[1];
            v.slotNumber = to!uint(m.captures[2]);
            v.readOnly = m.captures[3] != "0";
            v.system = m.captures[4] != "0";
            v.path = m.captures[5];
            list ~= v;
        }
        return list;
    }

    static void saveList(const FavoriteVolume[] favs)
    {
        string file = buildPath(dirName(__FILE__), getFileName());
        if (favs.length == 0)
        {
            if (exists(file)) remove(file);
            return;
        }
        string[] lines;
        lines ~= "<favorites>";
        foreach(v; favs)
        {
            lines ~= "<volume mountpoint=\""~v.mountPoint~"\" slotnumber=\""~to!string(v.slotNumber)~"\" readonly=\""~(v.readOnly?"1":"0")~"\" system=\""~(v.system?"1":"0")~"\">"~v.path~"</volume>";
        }
        lines ~= "</favorites>";
        write(file, lines.join("\n"));
    }

    void toMountOptions(ref MountOptions opt) const
    {
        opt.mountPoint = mountPoint;
        opt.path = path;
        opt.slotNumber = slotNumber;
        opt.partitionInSystemEncryptionScope = system;
        opt.protection = readOnly ? VolumeProtection.ReadOnly : VolumeProtection.None;
        if (mountPoint.length == 0)
            opt.noFilesystem = true;
    }

    static string getFileName() { return "Favorite Volumes.xml"; }
}

alias FavoriteVolumeList = FavoriteVolume[];
