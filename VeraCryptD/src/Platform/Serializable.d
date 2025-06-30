module Platform.Serializable;

import Platform.SerializerFactory;
import Platform.Serializer;
import Platform.Stream;
import Platform.Exception;
import std.exception : enforce;
import std.typeinfo;
import std.array;
import std.conv;

abstract class Serializable
{
    this(){}

    abstract void deserialize(Stream stream);
    abstract void serialize(Stream stream) const;

    static string deserializeHeader(Stream stream)
    {
        auto sr = new Serializer(stream);
        return sr.deserializeString("SerializableName");
    }

    static Serializable deserializeNew(Stream stream)
    {
        auto name = deserializeHeader(stream);
        auto obj = SerializerFactory.getNewSerializable(name);
        obj.deserialize(stream);
        return obj;
    }

    static T deserializeNew(T)(Stream stream) if (is(T : Serializable))
    {
        auto base = deserializeNew(stream);
        auto c = cast(T) base;
        enforce(c !is null, "Type mismatch");
        return c;
    }

    static void deserializeList(T)(Stream stream, ref T[] list) if (is(T : Serializable))
    {
        auto header = deserializeHeader(stream);
        auto expected = "list<" ~ SerializerFactory.getName(typeid(T)) ~ ">";
        enforce(header == expected, "ParameterIncorrect");
        auto sr = new Serializer(stream);
        auto count = sr.deserializeUInt64("ListSize");
        list.length = 0;
        foreach(i; 0 .. cast(size_t)count)
        {
            list ~= deserializeNew!T(stream);
        }
    }

    static void serializeList(T)(Stream stream, const T[] list) if (is(T : Serializable))
    {
        auto sr = new Serializer(stream);
        auto name = "list<" ~ SerializerFactory.getName(typeid(T)) ~ ">";
        serializeHeader(sr, name);
        sr.serialize("ListSize", cast(ulong)list.length);
        foreach(item; list)
            item.serialize(stream);
    }

    static void serializeHeader(Serializer sr, string name)
    {
        sr.serialize("SerializableName", name);
    }
}
