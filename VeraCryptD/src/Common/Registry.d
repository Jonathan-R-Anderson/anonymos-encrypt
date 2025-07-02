module Common.Registry;

extern(C):
    bool ReadLocalMachineRegistryDword(wchar_t* subKey, wchar_t* name, uint* value);
    bool ReadLocalMachineRegistryMultiString(wchar_t* subKey, wchar_t* name, wchar_t* value, uint* size);
    bool ReadLocalMachineRegistryString(const wchar_t* subKey, wchar_t* name, wchar_t* value, uint* size);
    bool ReadLocalMachineRegistryStringNonReflected(const wchar_t* subKey, wchar_t* name, wchar_t* str, uint* size, bool bit32App);
    int ReadRegistryInt(wchar_t* subKey, wchar_t* name, int defaultValue);
    wchar_t* ReadRegistryString(wchar_t* subKey, wchar_t* name, wchar_t* defaultValue, wchar_t* str, int maxLen);
    uint ReadRegistryBytes(wchar_t* path, wchar_t* name, char* value, int maxLen);
    void WriteRegistryInt(wchar_t* subKey, wchar_t* name, int value);
    bool WriteLocalMachineRegistryDword(wchar_t* subKey, wchar_t* name, uint value);
    bool WriteLocalMachineRegistryMultiString(wchar_t* subKey, wchar_t* name, wchar_t* multiString, uint size);
    bool WriteLocalMachineRegistryString(wchar_t* subKey, wchar_t* name, wchar_t* str, bool expandable);
    void WriteRegistryString(wchar_t* subKey, wchar_t* name, wchar_t* str);
    bool WriteRegistryBytes(wchar_t* path, wchar_t* name, char* str, uint size);
    bool DeleteLocalMachineRegistryKey(wchar_t* parentKey, wchar_t* subKeyToDelete);
    void DeleteRegistryValue(wchar_t* subKey, wchar_t* name);
    void GetStartupRegKeyName(wchar_t* regk, size_t cbRegk);
    void GetRestorePointRegKeyName(wchar_t* regk, size_t cbRegk);
