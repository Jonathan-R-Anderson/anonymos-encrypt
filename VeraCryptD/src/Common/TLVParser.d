module Common.TLVParser;

import std.conv : to;
import core.stdc.string : memcpy;
import std.exception : enforce;

struct TLVNode
{
    ushort tag;
    ushort length;
    ubyte[] value;
    ubyte tagSize;
    ubyte lengthSize;
    ushort moreFlag;
    ushort subFlag;
    TLVNode[] subs;

    this()
    {
        tag = 0; length = 0; tagSize = 0; lengthSize = 0; moreFlag = 0; subFlag = 0;
    }
}

class TLVException : Exception
{
    this(string msg){ super(msg); }
}

class TLVParser
{
    static TLVNode TLV_CreateNode()
    {
        return TLVNode();
    }

    static ushort CheckBit(ubyte value, int bit)
    {
        immutable ubyte[8] bitvalue = [0x01,0x02,0x04,0x08,0x10,0x20,0x40,0x80];
        if (bit >=1 && bit <=8)
            return (value & bitvalue[bit-1]) ? 1 : 0;
        throw new TLVException("function parameter incorrect! bit="~to!string(bit));
    }

    static TLVNode TLV_Parse_One(ubyte[] buf)
    {
        size_t index = 0;
        ubyte tag1 = 0, tag2 = 0, tagsize = 1;
        ubyte len = 0, lensize = 1;
        TLVNode node = TLV_CreateNode();

        tag1 = buf[index++];
        if ((tag1 & 0x1f) == 0x1f)
        {
            tagsize++;
            tag2 = buf[index++];
        }
        if (tagsize == 1)
            node.tag = tag1;
        else
            node.tag = (cast(ushort)tag1 << 8) + tag2;
        node.tagSize = tagsize;

        node.subFlag = CheckBit(tag1,6);

        len = buf[index++];
        if ((len & 0x80) == 0)
        {
            node.length = len;
        }
        else
        {
            lensize = len & 0x7f;
            ushort tmp = 0;
            foreach(i; 0 .. lensize)
                tmp += cast(ushort)buf[index++] << (i*8);
            lensize++;
            node.length = tmp;
        }
        node.lengthSize = lensize;
        node.value.length = node.length;
        memcpy(node.value.ptr, buf.ptr + index, node.length);
        index += node.length;

        if (index < buf.length)
            node.moreFlag = 1;
        else if (index == buf.length)
            node.moreFlag = 0;
        else
            throw new TLVException("Parse Error! index="~to!string(index)~" size="~to!string(buf.length));

        return node;
    }

    static int TLV_Parse_SubNodes(ref TLVNode parent)
    {
        ushort sublen = 0;
        foreach(ref s; parent.subs)
            sublen += cast(ushort)(s.tagSize + s.length + s.lengthSize);

        if (sublen < parent.value.length)
        {
            auto subnode = TLV_Parse_One(parent.value[sublen .. parent.value.length]);
            parent.subs ~= subnode;
            return subnode.moreFlag;
        }
        else
            return 0;
    }

    static void TLV_Parse_Sub(ref TLVNode parent)
    {
        if (parent.subFlag != 0)
        {
            while (TLV_Parse_SubNodes(parent) != 0) {}
            foreach(ref s; parent.subs)
                if (s.subFlag != 0)
                    TLV_Parse_Sub(s);
        }
    }

    static TLVNode TLV_Parse(ubyte[] buf)
    {
        TLVNode node = TLV_Parse_One(buf);
        TLV_Parse_Sub(node);
        return node;
    }

    static TLVNode* TLV_Find(ref TLVNode node, ushort tag)
    {
        if (node.tag == tag)
            return &node;
        foreach(ref sub; node.subs)
        {
            auto tmp = TLV_Find(sub, tag);
            if (tmp !is null)
                return tmp;
        }
        return null;
    }
}
