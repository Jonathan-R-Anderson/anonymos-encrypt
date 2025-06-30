module Main.LanguageStrings;

import std.regex : regex, matchAll;
import std.file : readText, exists;
import std.string : replace;
import std.conv : to;
import std.path : buildPath, dirName;

class LanguageStrings
{
    private string[string] _map;
    string preferredLang;

    this() {}

    string opIndex(string key) const
    {
        if (auto p = key in _map)
            return *p;
        if (key == "VeraCrypt")
            return "VeraCrypt";
        return "?" ~ key ~ "?";
    }

    bool exists(string key) const { return (key in _map) !is null; }

    string get(string key) const { return this[key]; }

    void init()
    {
        string xmlPath = buildPath(dirName(__FILE__), "../../../VeraCrypt/src/Common/Language.xml");
        string xmlContent = exists(xmlPath) ? readText(xmlPath) : "";
        auto re = regex(`<entry[^>]*key="([^"]+)"[^>]*>([^<]*)</entry>`, "g");
        foreach(m; matchAll(xmlContent, re))
        {
            string text = replace(m.captures[2], "\\n", "\n");
            _map[m.captures[1]] = text;
        }
        preferredLang = "en";
    }
}

__gshared LanguageStrings LangString;
