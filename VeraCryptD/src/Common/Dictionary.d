module Common.Dictionary;

import core.stdc.stdlib : malloc;
import core.stdc.string : memcpy;

enum DATA_POOL_CAPACITY = 1000000;

private __gshared void*[string] stringKeyMap;
private __gshared void*[int] intKeyMap;

private __gshared ubyte[] dataPool;
private __gshared size_t dataPoolSize;

void AddDictionaryEntry(char* key, int intKey, void* value)
{
    import std.string : fromStringz;
    if (key !is null)
        stringKeyMap[fromStringz(key)] = value;
    if (intKey != 0)
        intKeyMap[intKey] = value;
}

void* GetDictionaryValue(const char* key)
{
    import std.string : fromStringz;
    auto k = fromStringz(key);
    if (auto p = k in stringKeyMap)
        return *p;
    return null;
}

void* GetDictionaryValueByInt(int intKey)
{
    if (auto p = intKey in intKeyMap)
        return *p;
    return null;
}

void* AddPoolData(void* data, size_t dataSize)
{
    import core.stdc.string : memcpy;
    if (dataPool.length == 0)
        dataPool = new ubyte[](DATA_POOL_CAPACITY);
    if (dataPoolSize + dataSize > DATA_POOL_CAPACITY)
        return null;
    memcpy(dataPool.ptr + dataPoolSize, data, dataSize);
    auto ret = cast(void*)(dataPool.ptr + dataPoolSize);
    dataSize = (dataSize + 3) & ~cast(size_t)3;
    dataPoolSize += dataSize;
    return ret;
}

void ClearDictionaryPool()
{
    dataPoolSize = 0;
    stringKeyMap = null;
    intKeyMap = null;
}
