module Common.Registry;

import core.sys.windows.windows;
import core.sys.windows.winreg;
import core.stdc.wchar_ : wcslen, wcscpy;
import core.stdc.string : memcpy;

extern(C):
alias DWORD = uint;

bool ReadLocalMachineRegistryDword(wchar_t* subKey, wchar_t* name, uint* value)
{
    HKEY hkey = null;
    DWORD size = DWORD.sizeof;
    DWORD type;
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, subKey, 0, KEY_READ, &hkey) != ERROR_SUCCESS)
        return false;
    if (RegQueryValueExW(hkey, name, null, &type, cast(BYTE*)value, &size) != ERROR_SUCCESS)
    {
        RegCloseKey(hkey);
        return false;
    }
    RegCloseKey(hkey);
    return type == REG_DWORD;
}

bool ReadLocalMachineRegistryMultiString(wchar_t* subKey, wchar_t* name, wchar_t* value, uint* size)
{
    HKEY hkey = null;
    DWORD type;
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, subKey, 0, KEY_READ, &hkey) != ERROR_SUCCESS)
        return false;
    if (RegQueryValueExW(hkey, name, null, &type, cast(BYTE*)value, size) != ERROR_SUCCESS)
    {
        RegCloseKey(hkey);
        return false;
    }
    RegCloseKey(hkey);
    return type == REG_MULTI_SZ;
}

bool ReadLocalMachineRegistryString(const wchar_t* subKey, wchar_t* name, wchar_t* value, uint* size)
{
    HKEY hkey = null;
    DWORD type;
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, subKey, 0, KEY_READ, &hkey) != ERROR_SUCCESS)
        return false;
    if (RegQueryValueExW(hkey, name, null, &type, cast(BYTE*)value, size) != ERROR_SUCCESS)
    {
        RegCloseKey(hkey);
        return false;
    }
    RegCloseKey(hkey);
    return type == REG_SZ;
}

bool ReadLocalMachineRegistryStringNonReflected(const wchar_t* subKey, wchar_t* name, wchar_t* str, uint* size, bool bit32App)
{
    HKEY hkey = null;
    DWORD type;
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, subKey, 0, KEY_READ | (bit32App ? KEY_WOW64_32KEY : KEY_WOW64_64KEY), &hkey) != ERROR_SUCCESS)
        return false;
    if (RegQueryValueExW(hkey, name, null, &type, cast(BYTE*)str, size) != ERROR_SUCCESS)
    {
        RegCloseKey(hkey);
        return false;
    }
    RegCloseKey(hkey);
    return type == REG_SZ;
}

int ReadRegistryInt(wchar_t* subKey, wchar_t* name, int defaultValue)
{
    HKEY hkey = null;
    DWORD value;
    DWORD size = DWORD.sizeof;
    if (RegOpenKeyExW(HKEY_CURRENT_USER, subKey, 0, KEY_READ, &hkey) != ERROR_SUCCESS)
        return defaultValue;
    if (RegQueryValueExW(hkey, name, null, null, cast(LPBYTE)&value, &size) != ERROR_SUCCESS)
        value = defaultValue;
    RegCloseKey(hkey);
    return cast(int)value;
}

wchar_t* ReadRegistryString(wchar_t* subKey, wchar_t* name, wchar_t* defaultValue, wchar_t* str, int maxLen)
{
    HKEY hkey = null;
    wchar_t[MAX_PATH*4] value;
    DWORD size = value.sizeof;
    str[(maxLen / wchar_t.sizeof) - 1] = 0;
    wcscpy(str, defaultValue);
    memset(value.ptr, 0, value.sizeof);
    if (RegOpenKeyExW(HKEY_CURRENT_USER, subKey, 0, KEY_READ, &hkey) == ERROR_SUCCESS)
        if (RegQueryValueExW(hkey, name, 0, null, cast(LPBYTE)value.ptr, &size) == ERROR_SUCCESS)
            wcscpy(str, value.ptr);
    if (hkey) RegCloseKey(hkey);
    return str;
}

uint ReadRegistryBytes(wchar_t* path, wchar_t* name, char* value, int maxLen)
{
    HKEY hkey = null;
    DWORD size = cast(DWORD)maxLen;
    bool success = false;
    if (RegOpenKeyExW(HKEY_CURRENT_USER, path, 0, KEY_READ, &hkey) != ERROR_SUCCESS)
        return 0;
    success = (RegQueryValueExW(hkey, name, 0, null, cast(LPBYTE)value, &size) == ERROR_SUCCESS);
    RegCloseKey(hkey);
    return success ? size : 0;
}

void WriteRegistryInt(wchar_t* subKey, wchar_t* name, int value)
{
    HKEY hkey = null;
    DWORD disp;
    if (RegCreateKeyExW(HKEY_CURRENT_USER, subKey, 0, null, REG_OPTION_NON_VOLATILE, KEY_WRITE, null, &hkey, &disp) != ERROR_SUCCESS)
        return;
    RegSetValueExW(hkey, name, 0, REG_DWORD, cast(BYTE*)&value, DWORD.sizeof);
    RegCloseKey(hkey);
}

bool WriteLocalMachineRegistryDword(wchar_t* subKey, wchar_t* name, uint value)
{
    HKEY hkey = null;
    DWORD disp;
    LONG status;
    if ((status = RegCreateKeyExW(HKEY_LOCAL_MACHINE, subKey, 0, null, REG_OPTION_NON_VOLATILE, KEY_WRITE, null, &hkey, &disp)) != ERROR_SUCCESS)
    {
        SetLastError(status);
        return false;
    }
    if ((status = RegSetValueExW(hkey, name, 0, REG_DWORD, cast(BYTE*)&value, DWORD.sizeof)) != ERROR_SUCCESS)
    {
        RegCloseKey(hkey);
        SetLastError(status);
        return false;
    }
    RegCloseKey(hkey);
    return true;
}

bool WriteLocalMachineRegistryMultiString(wchar_t* subKey, wchar_t* name, wchar_t* multiString, uint size)
{
    HKEY hkey = null;
    DWORD disp;
    LONG status;
    if ((status = RegCreateKeyExW(HKEY_LOCAL_MACHINE, subKey, 0, null, REG_OPTION_NON_VOLATILE, KEY_WRITE, null, &hkey, &disp)) != ERROR_SUCCESS)
    {
        SetLastError(status);
        return false;
    }
    if ((status = RegSetValueExW(hkey, name, 0, REG_MULTI_SZ, cast(BYTE*)multiString, size)) != ERROR_SUCCESS)
    {
        RegCloseKey(hkey);
        SetLastError(status);
        return false;
    }
    RegCloseKey(hkey);
    return true;
}

bool WriteLocalMachineRegistryString(wchar_t* subKey, wchar_t* name, wchar_t* str, bool expandable)
{
    HKEY hkey = null;
    DWORD disp;
    LONG status;
    if ((status = RegCreateKeyExW(HKEY_LOCAL_MACHINE, subKey, 0, null, REG_OPTION_NON_VOLATILE, KEY_WRITE, null, &hkey, &disp)) != ERROR_SUCCESS)
    {
        SetLastError(status);
        return false;
    }
    if ((status = RegSetValueExW(hkey, name, 0, expandable ? REG_EXPAND_SZ : REG_SZ, cast(BYTE*)str, cast(DWORD)((wcslen(str) + 1) * wchar_t.sizeof))) != ERROR_SUCCESS)
    {
        RegCloseKey(hkey);
        SetLastError(status);
        return false;
    }
    RegCloseKey(hkey);
    return true;
}

void WriteRegistryString(wchar_t* subKey, wchar_t* name, wchar_t* str)
{
    HKEY hkey = null;
    DWORD disp;
    if (RegCreateKeyExW(HKEY_CURRENT_USER, subKey, 0, null, REG_OPTION_NON_VOLATILE, KEY_WRITE, null, &hkey, &disp) != ERROR_SUCCESS)
        return;
    RegSetValueExW(hkey, name, 0, REG_SZ, cast(BYTE*)str, cast(DWORD)((wcslen(str) + 1) * wchar_t.sizeof));
    RegCloseKey(hkey);
}

bool WriteRegistryBytes(wchar_t* path, wchar_t* name, char* str, uint size)
{
    HKEY hkey = null;
    DWORD disp;
    if (RegCreateKeyExW(HKEY_CURRENT_USER, path, 0, null, REG_OPTION_NON_VOLATILE, KEY_WRITE, null, &hkey, &disp) != ERROR_SUCCESS)
        return false;
    bool res = RegSetValueExW(hkey, name, 0, REG_BINARY, cast(BYTE*)str, size) == ERROR_SUCCESS;
    RegCloseKey(hkey);
    return res;
}

bool DeleteLocalMachineRegistryKey(wchar_t* parentKey, wchar_t* subKeyToDelete)
{
    LONG status;
    HKEY hkey = null;
    if ((status = RegOpenKeyExW(HKEY_LOCAL_MACHINE, parentKey, 0, KEY_WRITE, &hkey)) != ERROR_SUCCESS)
    {
        SetLastError(status);
        return false;
    }
    if ((status = RegDeleteKeyW(hkey, subKeyToDelete)) != ERROR_SUCCESS)
    {
        RegCloseKey(hkey);
        SetLastError(status);
        return false;
    }
    RegCloseKey(hkey);
    return true;
}

void DeleteRegistryValue(wchar_t* subKey, wchar_t* name)
{
    HKEY hkey = null;
    if (RegOpenKeyExW(HKEY_CURRENT_USER, subKey, 0, KEY_WRITE, &hkey) != ERROR_SUCCESS)
        return;
    RegDeleteValueW(hkey, name);
    RegCloseKey(hkey);
}

void GetStartupRegKeyName(wchar_t* regk, size_t cbRegk)
{
    swprintf(regk, cbRegk / wchar_t.sizeof, L"%s%s", L"Software\\Microsoft\\Windows\\Curren", L"tVersion\\Run");
}

void GetRestorePointRegKeyName(wchar_t* regk, size_t cbRegk)
{
    swprintf(regk, cbRegk / wchar_t.sizeof, L"%s%s%s%s", L"Software\\Microsoft\\Windows", L" NT\\Curren", L"tVersion\\Sy", L"stemRestore");
}
