module COMReg.COMReg;

import core.stdc.wchar_ : wcsrchr;

extern(C)
{
    void SelfExtractStartupInit();
    uint GetModuleFileNameW(void* hModule, wchar* lpFilename, uint nSize);
    void MakeSelfExtractingPackage(void* hwndDlg, wchar* destDir, bool bSkipX64);
}

extern(Windows)
int wWinMain(void* hInstance, void* hPrevInstance, wchar* lpCmdLine, int nCmdShow)
{
    wchar[260] setupFilesDir;
    if (lpCmdLine && lpCmdLine[0] == '/' && lpCmdLine[1] == 'p')
    {
        SelfExtractStartupInit();
        GetModuleFileNameW(null, setupFilesDir.ptr, setupFilesDir.length);
        auto s = wcsrchr(setupFilesDir.ptr, '\\');
        if (s)
            s[1] = 0;
        MakeSelfExtractingPackage(null, setupFilesDir.ptr, true);
    }
    return 0;
}
