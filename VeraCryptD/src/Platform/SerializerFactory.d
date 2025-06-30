module Platform.SerializerFactory;

import Platform.Serializable;
import std.exception : enforce;
import std.typeinfo;
import std.conv;

class SerializerFactory
{
    static struct MapEntry
    {
        string typeName;
        Serializable delegate() getNewPtr;
    }

    private __gshared MapEntry[string] nameToTypeMap;
    private __gshared string[string] typeToNameMap;
    private __gshared int useCount;

    static void initialize()
    {
        ++useCount;
    }

    static void deinitialize()
    {
        if(--useCount == 0)
        {
            nameToTypeMap = MapEntry[string].init;
            typeToNameMap = string[string].init;
        }
    }

    static string getName(TypeInfo ti)
    {
        auto key = ti.toString();
        enforce(key in typeToNameMap, "Type not registered");
        return typeToNameMap[key];
    }

    static Serializable getNewSerializable(string typeName)
    {
        enforce(typeName in nameToTypeMap, "Type not registered");
        return nameToTypeMap[typeName].getNewPtr();
    }

    static void add(string name, TypeInfo ti, Serializable delegate() getNew)
    {
        nameToTypeMap[name] = MapEntry(ti.toString(), getNew);
        typeToNameMap[ti.toString()] = name;
    }

    template registerClass(T)(string name)
    {
        static this()
        {
            SerializerFactory.add(name, typeid(T), { return new T(); });
        }
    }
}
