module Common.Progress;

import core.sys.windows.windows;
import core.stdc.wchar_ : wcslen, wcscpy, wcsncpy;
import core.stdc.string : memset;

extern(C) wchar_t* GetString(const(char)* id);
extern(C) void GetSizeString(ulong size, wchar_t* str, size_t cbStr);
extern(C) void GetSpeedString(ulong speed, wchar_t* str, size_t cbStr);
extern(C) {
    __gshared HWND hCurPage;
    __gshared int nPbar;
    __gshared volatile int bVolTransformThreadCancel;
}

enum BYTES_PER_MB = 1048576UL;
enum BYTES_PER_GB = 1073741824UL;
enum BYTES_PER_TB = 1099511627776UL;
enum BYTES_PER_PB = 1125899906842624UL;

private DWORD prevTime;
private DWORD startTime;
private long TotalSize;
private long resumedPointBytesDone;
private bool bProgressBarReverse;
private bool bRWThroughput;
private bool bShowStatus;
private bool bPercentMode;

private wchar* seconds;
private wchar* minutes;
private wchar* hours;
private wchar* days;

extern(C)
void InitProgressBar(long totalBytes, long bytesDone, bool bReverse, bool bIOThroughput, bool bDisplayStatus, bool bShowPercent)
{
    auto hCurProgressBar = GetDlgItem(hCurPage, nPbar);
    SendMessageW(hCurProgressBar, PBM_SETRANGE32, 0, 10000);
    SendMessageW(hCurProgressBar, PBM_SETSTEP, 1, 0);

    bProgressBarReverse = bReverse;
    bRWThroughput = bIOThroughput;
    bShowStatus = bDisplayStatus;
    bPercentMode = bShowPercent;

    seconds = GetString("SECONDS");
    minutes = GetString("MINUTES");
    hours = GetString("HOURS");
    days = GetString("DAYS");

    prevTime = startTime = GetTickCount();
    TotalSize = totalBytes;
    resumedPointBytesDone = bytesDone;
}

extern(C)
bool UpdateProgressBar(long byteOffset)
{
    return UpdateProgressBarProc(byteOffset);
}

extern(C)
bool UpdateProgressBarProc(long byteOffset)
{
    wchar[100] text;
    wchar[100] speed;
    auto hCurProgressBar = GetDlgItem(hCurPage, nPbar);
    DWORD time = GetTickCount();
    int elapsed = (time - startTime) / 1000;

    ulong bytesDone = bProgressBarReverse ? cast(ulong)(TotalSize - byteOffset) : cast(ulong)byteOffset;
    ulong bytesPerSec = bProgressBarReverse ? cast(ulong)((resumedPointBytesDone - byteOffset) / (elapsed + 1)) : cast(ulong)((bytesDone - resumedPointBytesDone) / (elapsed + 1));

    if (bPercentMode)
    {
        double perc = 100.0 * (bProgressBarReverse ? cast(double)(TotalSize - byteOffset) : cast(double)byteOffset) / (TotalSize == 0 ? 0.0001 : cast(double)TotalSize);
        if (perc > 99.999999999)
            wcscpy(text.ptr, GetString("PROCESSED_PORTION_100_PERCENT"));
        else
            swprintf(text.ptr, text.length, GetString("PROCESSED_PORTION_X_PERCENT"), perc);
        wcscat(text.ptr, " "w.ptr);
    }
    else
    {
        GetSizeString(bytesDone, text.ptr, text.sizeof);
        if (bytesDone < BYTES_PER_MB * 1000000UL)
            swprintf(text.ptr, text.length, L"%I64d %s ", bytesDone / BYTES_PER_MB, GetString("MB"));
        else if (bytesDone < BYTES_PER_GB * 1000000UL)
            swprintf(text.ptr, text.length, L"%I64d %s ", bytesDone / BYTES_PER_GB, GetString("GB"));
        else if (bytesDone < BYTES_PER_TB * 1000000UL)
            swprintf(text.ptr, text.length, L"%I64d %s ", bytesDone / BYTES_PER_TB, GetString("TB"));
        else
            swprintf(text.ptr, text.length, L"%I64d %s ", bytesDone / BYTES_PER_PB, GetString("PB"));
    }

    SetWindowTextW(GetDlgItem(hCurPage, IDC_BYTESWRITTEN), text.ptr);

    if (!bShowStatus)
    {
        GetSpeedString(bRWThroughput ? bytesPerSec*2 : bytesPerSec, speed.ptr, speed.sizeof);
        wcscat(speed.ptr, " "w.ptr);
        SetWindowTextW(GetDlgItem(hCurPage, IDC_WRITESPEED), speed.ptr);
    }

    if (byteOffset < TotalSize)
    {
        long sec = cast(long)((bProgressBarReverse ? byteOffset : (TotalSize - byteOffset)) / (bytesPerSec == 0 ? 1 : bytesPerSec));
        if (bytesPerSec == 0 || sec > 60*60*24*999)
            wcscpy(text.ptr, GetString("NOT_APPLICABLE_OR_NOT_AVAILABLE"));
        else if (sec >= 60*60*24*2)
            swprintf(text.ptr, text.length, L"%I64d %s ", sec / (60*24*60), days);
        else if (sec >= 120*60)
            swprintf(text.ptr, text.length, L"%I64d %s ", sec / (60*60), hours);
        else if (sec >= 120)
            swprintf(text.ptr, text.length, L"%I64d %s ", sec / 60, minutes);
        else
            swprintf(text.ptr, text.length, L"%I64d %s ", sec, seconds);
        SetWindowTextW(GetDlgItem(hCurPage, IDC_TIMEREMAIN), text.ptr);
    }

    prevTime = time;
    SendMessageW(hCurProgressBar, PBM_SETPOS, cast(WPARAM)(10000.0 * (bProgressBarReverse ? (TotalSize - byteOffset) : byteOffset) / (TotalSize == 0 ? 1 : TotalSize)), 0);

    return bVolTransformThreadCancel != 0;
}

