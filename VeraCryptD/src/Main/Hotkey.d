module Main.Hotkey;

import std.file : readText, write, exists, remove;
import std.path : buildPath, dirName;
import std.conv : to;
import std.xml;
import Platform.FilesystemPath;

struct Hotkey
{
    int id;
    string name;
    string description;
    int virtualKeyCode = 0;
    int virtualKeyModifiers = 0;

    string getShortcutString() const
    {
        return name;
    }
}

alias HotkeyList = Hotkey[];

HotkeyList getAvailableHotkeys()
{
    return HotkeyList();
}

private string cfgPath()
{
    return buildPath(dirName(__FILE__), getFileName());
}

HotkeyList loadList()
{
    HotkeyList list;
    auto path = cfgPath();
    if (!exists(path))
        return list;
    auto xml = readText(path);
    auto doc = parseXML(xml);
    foreach (n; doc.childElements)
    {
        if (n.tag == "hotkey")
        {
            Hotkey h;
            h.name = n.attributes.get("name", "");
            h.virtualKeyCode = to!int(n.attributes.get("vkeycode", "0"));
            h.description = "hotkey";
            list ~= h;
        }
    }
    return list;
}

void saveList(const HotkeyList hotkeys)
{
    if (hotkeys.length == 0)
    {
        if (exists(cfgPath())) remove(cfgPath());
        return;
    }
    string data = "<hotkeys>\n";
    foreach(h; hotkeys)
    {
        data ~= "<hotkey name=\""~h.name~"\" vkeycode=\""~to!string(h.virtualKeyCode)~"\"></hotkey>\n";
    }
    data ~= "</hotkeys>\n";
    write(cfgPath(), data);
}

void registerList(HotkeyList hotkeys) {}
void unregisterList(HotkeyList hotkeys) {}

string getFileName() { return "Hotkeys.xml"; }
