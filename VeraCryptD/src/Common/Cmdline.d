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
