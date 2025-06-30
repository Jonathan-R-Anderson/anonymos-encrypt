module Main.StringFormatter;

import std.string : replace;
import std.conv : to;
import std.exception : enforce;

class StringFormatterArg
{
    string value;
    bool empty = true;
    bool referenced = false;

    this(){}
    this(string v){ value = v; empty=false; }
    this(dchar c){ value = to!string(c); empty=false; }
    this(long n){ value = to!string(n); empty=false; }
    this(ulong n){ value = to!string(n); empty=false; }

    bool isEmpty() const { return empty; }
    bool wasReferenced() const { return referenced; }

    alias value this;
}

class StringFormatter
{
    wstring formatted;

    this(wstring fmt, StringFormatterArg a0=StringFormatterArg(), StringFormatterArg a1=StringFormatterArg(), StringFormatterArg a2=StringFormatterArg(), StringFormatterArg a3=StringFormatterArg(), StringFormatterArg a4=StringFormatterArg(), StringFormatterArg a5=StringFormatterArg(), StringFormatterArg a6=StringFormatterArg(), StringFormatterArg a7=StringFormatterArg(), StringFormatterArg a8=StringFormatterArg(), StringFormatterArg a9=StringFormatterArg())
    {
        auto args = [a0,a1,a2,a3,a4,a5,a6,a7,a8,a9];
        string text = to!string(fmt);
        text = replace(text, "%s", "{}");
        text = replace(text, "%d", "{}");
        text = replace(text, "%c", "{}");
        size_t idx=0;
        while(true)
        {
            auto p = text.indexOf("{}");
            if(p == -1) break;
            text = text[0..p] ~ "{" ~ to!string(idx++) ~ "}" ~ text[p+2..$];
        }

        bool numberExpected=false;
        bool endExpected=false;
        foreach(ch; text)
        {
            if(numberExpected)
            {
                endExpected=true;
                enforce(ch >= '0' && ch <= '9', "Format error");
                size_t pos = ch - '0';
                enforce(pos < args.length, "Format error");
                formatted ~= to!wstring(args[pos].value);
                args[pos].referenced = true;
                numberExpected=false;
            }
            else if(endExpected)
            {
                enforce(ch == '}', "Format error");
                endExpected=false;
            }
            else if(ch == '{')
            {
                numberExpected=true;
            }
            else if(ch == '}')
            {
                formatted ~= ch;
                endExpected=true;
            }
            else
                formatted ~= ch;
        }
    }

    alias formatted this;
}
