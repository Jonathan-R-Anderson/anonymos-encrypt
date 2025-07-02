module Common.Cmdline;

extern(C):
struct argument
{
    int Id;
    wchar[32] long_name;
    wchar[8] short_name;
    bool Internal;
}

struct argumentspec
{
    argument* args;
    int arg_cnt;
}

enum HAS_ARGUMENT = 1;
enum HAS_NO_ARGUMENT = !HAS_ARGUMENT;

extern(C) {
    alias ArgumentDlgProc = int function(void* hwndDlg, uint msg, void* wParam, void* lParam);
    int Win32CommandLine(out wchar** args);
    int GetArgSepPosOffset(wchar* argument);
    int GetArgumentID(argumentspec* as, wchar* argument);
    int GetArgumentValue(wchar** commandLineArgs, int* argIdx, int nArgs, wchar* value, int valueSize);
}

private import core.stdc.stdlib : malloc, free, wcsdup;
private import core.stdc.wchar_ : wcscpy, wcsncpy, wcslen, wcscmp;
private import core.sys.windows.windows;

extern(Windows)
int CommandHelpDlgProc(HWND hwndDlg, UINT msg, WPARAM wParam, LPARAM lParam)
{
    switch(msg)
    {
        case WM_INITDIALOG:
        {
            import core.stdc.wchar_ : wcsncpy_s;
            import core.stdc.string : memset;
            auto tmp = cast(wchar*)malloc(8192 * wchar.sizeof);
            wchar[MAX_PATH*2] tmp2;
            auto as = cast(argumentspec*)lParam;

            *tmp = 0;
            wcscpy(tmp, `VeraCrypt `w.ptr);
            // VERSION_STRING etc. left as-is for brevity
            wcscat(tmp, `\n\nCommand line options:\n\n`w.ptr);
            foreach(i; 0 .. as.arg_cnt)
            {
                if(!as.args[i].Internal)
                {
                    swprintf(tmp2.ptr, tmp2.length, `%s\t%s\n`, as.args[i].short_name.ptr, as.args[i].long_name.ptr);
                    wcscat(tmp, tmp2.ptr);
                }
            }
            SetWindowTextW(GetDlgItem(hwndDlg, IDC_COMMANDHELP_TEXT), tmp);
            free(tmp);
            return 1;
        }
        case WM_COMMAND:
            EndDialog(hwndDlg, IDOK); return 1;
        case WM_CLOSE:
            EndDialog(hwndDlg, 0); return 1;
    }
    return 0;
}

extern(C)
int Win32CommandLine(out wchar** args)
{
    int argumentCount;
    auto arguments = CommandLineToArgvW(GetCommandLineW(), &argumentCount);
    if(arguments is null)
        return 0;
    argumentCount--;
    if(argumentCount < 1)
    {
        LocalFree(arguments);
        return 0;
    }
    args = cast(wchar**)malloc(argumentCount * (wchar*).sizeof);
    foreach(i; 0 .. argumentCount)
    {
        auto arg = wcsdup(arguments[i+1]);
        args[i] = arg;
    }
    LocalFree(arguments);
    return argumentCount;
}

extern(C)
int GetArgSepPosOffset(wchar* argument)
{
    return argument[0] == '/' ? 1 : 0;
}

extern(C)
int GetArgumentID(argumentspec* as, wchar* argument)
{
    foreach(i; 0 .. as.arg_cnt)
    {
        if(wcscmp(as.args[i].long_name.ptr, argument) == 0)
            return as.args[i].Id;
    }
    foreach(i; 0 .. as.arg_cnt)
    {
        if(as.args[i].short_name[0] == 0) continue;
        if(wcscmp(as.args[i].short_name.ptr, argument) == 0)
            return as.args[i].Id;
    }
    return -1;
}

extern(C)
int GetArgumentValue(wchar** commandLineArgs, int* argIdx, int nArgs, wchar* value, int valueSize)
{
    value[0] = 0;
    if(*argIdx + 1 < nArgs)
    {
        int x = GetArgSepPosOffset(commandLineArgs[*argIdx + 1]);
        if(x == 0)
        {
            wcsncpy(value, commandLineArgs[*argIdx + 1], valueSize);
            value[valueSize-1] = 0;
            ++(*argIdx);
            return HAS_ARGUMENT;
        }
    }
    return HAS_NO_ARGUMENT;
}
