module Main.Xml;

import std.xml : parseXML, Tag, Element;
import std.file : readText, write;
import std.path : baseName;
import Platform.FilesystemPath;

struct XmlNode
{
    string name;
    string[string] attributes;
    string innerText;
    XmlNode[] innerNodes;
}
alias XmlNodeList = XmlNode[];

class XmlParser
{
    string xmlText;
    this(FilePath path)
    {
        xmlText = readText(path.toString());
    }

    XmlNodeList getNodes(string nodeName) const
    {
        XmlNodeList list;
        auto doc = parseXML(xmlText);
        foreach (n; doc.childElements)
        {
            if (n.tag == nodeName)
            {
                XmlNode node;
                node.name = n.tag;
                foreach (k, v; n.attributes)
                    node.attributes[k] = v;
                node.innerText = n.text;
                list ~= node;
            }
        }
        return list;
    }
}

class XmlWriter
{
    FilePath path;
    string data;
    this(FilePath p)
    {
        path = p;
        data ~= "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<VeraCrypt>\n";
    }

    void writeNode(XmlNode node)
    {
        data ~= "<" ~ node.name;
        foreach (k, v; node.attributes)
            data ~= " " ~ k ~ "=\"" ~ v ~ "\"";
        if (node.innerNodes.length == 0 && node.innerText.length == 0)
        {
            data ~= "/>\n";
            return;
        }
        data ~= ">";
        if (node.innerText.length)
            data ~= node.innerText;
        foreach (c; node.innerNodes)
            writeNode(c);
        data ~= "</" ~ node.name ~ ">\n";
    }

    void writeNodes(XmlNodeList nodes)
    {
        foreach(n; nodes) writeNode(n);
    }

    void close()
    {
        data ~= "</VeraCrypt>\n";
        write(path.toString(), data);
    }

    ~this()
    {
        try { close(); } catch(Exception) {}
    }
}
