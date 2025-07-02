module Common.Combo;

import core.sys.windows.windows;
import core.stdc.wchar_ : wcslen, wcscpy, wcsncmp, wcscmp, wchar_t;
import core.stdc.stdio : FILE, _wfopen, fwprintf, fclose;
import core.stdc.time : time_t, time;
import core.stdc.stdlib : free;
import core.stdc.string : memcpy;
import Common.Xml;

extern(C):
    wchar_t* GetConfigPath(const(wchar_t)* fileName);
    char* LoadFile(const(wchar_t)* fileName, uint* size);

extern(C):
alias HWND = void*;
alias LPCWSTR = const(wchar_t)*;
alias BOOL = int;
alias LPARAM = size_t;

immutable wchar_t[] TC_APPD_FILENAME_HISTORY = "History.xml"w;

enum CB_ADDSTRING = 0x0143;
enum CB_DELETESTRING = 0x0144;
enum CB_GETCOUNT = 0x0146;
enum CB_GETCURSEL = 0x0147;
enum CB_GETLBTEXT = 0x0148;
enum CB_GETLBTEXTLEN = 0x0149;
enum CB_RESETCONTENT = 0x014B;
enum CB_SETCURSEL = 0x014E;
enum CB_GETITEMDATA = 0x0150;
enum CB_SETITEMDATA = 0x0151;
enum CB_FINDSTRINGEXACT = 0x0158;

void AddComboItem(HWND hComboBox, LPCWSTR lpszFileName, BOOL saveHistory)
{
    LPARAM nIndex;
    if (!saveHistory)
    {
        SendMessageW(hComboBox, CB_RESETCONTENT, 0, 0);
        SetWindowTextW(hComboBox, lpszFileName);
        return;
    }
    nIndex = SendMessageW(hComboBox, CB_FINDSTRINGEXACT, cast(WPARAM)-1, cast(LPARAM)lpszFileName);
    if (nIndex == CB_ERR && *lpszFileName)
    {
        auto lTime = time(null);
        nIndex = SendMessageW(hComboBox, CB_ADDSTRING, 0, cast(LPARAM)lpszFileName);
        if (nIndex != CB_ERR)
            SendMessageW(hComboBox, CB_SETITEMDATA, nIndex, cast(LPARAM)lTime);
    }
    if (nIndex != CB_ERR && *lpszFileName)
        SendMessageW(hComboBox, CB_SETCURSEL, nIndex, 0);
    if (*lpszFileName == 0)
        SendMessageW(hComboBox, CB_SETCURSEL, cast(WPARAM)-1, 0);
}

LPARAM MoveEditToCombo(HWND hComboBox, BOOL saveHistory)
{
    wchar_t[260] szTmp = void;
    if (!saveHistory)
    {
        GetWindowTextW(hComboBox, szTmp.ptr, szTmp.sizeof / wchar_t.sizeof);
        SendMessageW(hComboBox, CB_RESETCONTENT, 0, 0);
        SetWindowTextW(hComboBox, szTmp.ptr);
        return 0;
    }
    GetWindowTextW(hComboBox, szTmp.ptr, szTmp.sizeof / wchar_t.sizeof);
    if (wcslen(szTmp.ptr) > 0)
    {
        LPARAM nIndex = SendMessageW(hComboBox, CB_FINDSTRINGEXACT, cast(WPARAM)-1, cast(LPARAM)szTmp.ptr);
        if (nIndex == CB_ERR)
        {
            auto lTime = time(null);
            nIndex = SendMessageW(hComboBox, CB_ADDSTRING, 0, cast(LPARAM)szTmp.ptr);
            if (nIndex != CB_ERR)
                SendMessageW(hComboBox, CB_SETITEMDATA, nIndex, cast(LPARAM)lTime);
        }
        else
        {
            auto lTime = time(null);
            SendMessageW(hComboBox, CB_SETITEMDATA, nIndex, cast(LPARAM)lTime);
        }
        return nIndex;
    }
    return SendMessageW(hComboBox, CB_GETCURSEL, 0, 0);
}

int GetOrderComboIdx(HWND hComboBox, int* nIdxList, int nElems)
{
    int x = cast(int)SendMessageW(hComboBox, CB_GETCOUNT, 0, 0);
    if (x != CB_ERR)
    {
        int nHighIdx = CB_ERR;
        time_t lHighTime = -1;
        for (int i = 0; i < x; ++i)
        {
            time_t lTime = cast(time_t)SendMessageW(hComboBox, CB_GETITEMDATA, i, 0);
            if (lTime > lHighTime)
            {
                int n;
                for (n = 0; n < nElems; ++n)
                    if (nIdxList[n] == i)
                        break;
                if (n == nElems)
                {
                    lHighTime = lTime;
                    nHighIdx = i;
                }
            }
        }
        return nHighIdx;
    }
    return CB_ERR;
}

LPARAM UpdateComboOrder(HWND hComboBox)
{
    LPARAM nIndex = SendMessageW(hComboBox, CB_GETCURSEL, 0, 0);
    if (nIndex != CB_ERR)
    {
        auto lTime = time(null);
        nIndex = SendMessageW(hComboBox, CB_SETITEMDATA, nIndex, cast(LPARAM)lTime);
    }
    return nIndex;
}

void LoadCombo(HWND hComboBox, BOOL bEnabled, BOOL bOnlyCheckModified, BOOL* pbModified)
{
    uint size;
    auto history = LoadFile(GetConfigPath(TC_APPD_FILENAME_HISTORY.ptr), &size);
    char* xml = history;
    char[260] volume;
    int[20] nComboIdx = 0;
    int count = cast(int)SendMessageW(hComboBox, CB_GETCOUNT, 0, 0);
    if (xml is null)
    {
        if (bEnabled && pbModified)
            *pbModified = true;
        return;
    }
    if (!bEnabled && bOnlyCheckModified)
    {
        if (pbModified)
            *pbModified = true;
        free(history);
        return;
    }
    for (int i = 0; i < 20; ++i)
        nComboIdx[i] = GetOrderComboIdx(hComboBox, nComboIdx.ptr, i);
    int i = 0;
    while ((xml = XmlFindElement(xml, "volume".ptr)) !is null)
    {
        wchar_t[260] szTmp = void;
        wchar_t[260] wszVolume = void;
        if (i < count)
        {
            if (SendMessageW(hComboBox, CB_GETLBTEXTLEN, nComboIdx[i], 0) < szTmp.length)
                SendMessageW(hComboBox, CB_GETLBTEXT, nComboIdx[i], cast(LPARAM)szTmp.ptr);
        }
        XmlGetNodeText(xml, volume.ptr, volume.length);
        MultiByteToWideChar(CP_UTF8, 0, volume.ptr, -1, wszVolume.ptr, wszVolume.length);
        if (!bOnlyCheckModified)
            AddComboItem(hComboBox, wszVolume.ptr, TRUE);
        if (pbModified && wcscmp(wszVolume.ptr, szTmp.ptr))
            *pbModified = true;
        ++xml;
        ++i;
    }
    if (pbModified && (i != count))
        *pbModified = true;
    if (!bOnlyCheckModified)
        SendMessageW(hComboBox, CB_SETCURSEL, 0, 0);
    free(history);
}

void DumpCombo(HWND hComboBox, int bClear)
{
    if (bClear)
    {
        DeleteFileW(GetConfigPath(TC_APPD_FILENAME_HISTORY.ptr));
        return;
    }
    FILE* f = _wfopen(GetConfigPath(TC_APPD_FILENAME_HISTORY.ptr), "w,ccs=UTF-8"w.ptr);
    if (f is null) return;
    XmlWriteHeader(f);
    fwprintf(f, L"\n\t<history>");
    int[20] nComboIdx = 0;
    for (int i = 0; i < 20; ++i)
        nComboIdx[i] = GetOrderComboIdx(hComboBox, nComboIdx.ptr, i);
    for (int i = 0; i < 20; ++i)
    {
        wchar_t[260] szTmp = void;
        if (SendMessageW(hComboBox, CB_GETLBTEXTLEN, nComboIdx[i], 0) < szTmp.length)
            SendMessageW(hComboBox, CB_GETLBTEXT, nComboIdx[i], cast(LPARAM)szTmp.ptr);
        if (szTmp[0] != 0)
        {
            wchar_t[520] q = void;
            XmlQuoteTextW(szTmp.ptr, q.ptr, q.length);
            fwprintf(f, L"\n\t\t<volume>%s</volume>", q.ptr);
        }
    }
    fwprintf(f, L"\n\t</history>");
    XmlWriteFooter(f);
    fclose(f);
}

void ClearCombo(HWND hComboBox)
{
    for (int i = 0; i < 20; ++i)
        SendMessageW(hComboBox, CB_DELETESTRING, 0, 0);
}

int IsComboEmpty(HWND hComboBox)
{
    return cast(int)(SendMessageW(hComboBox, CB_GETCOUNT, 0, 0) < 1);
}
