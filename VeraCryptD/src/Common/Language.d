module Common.Language;

extern(C):
    bool LocalizationActive;
    int LocalizationSerialNo;
    wchar_t[1024] UnknownString;

struct Font
{
    wchar_t* FaceName;
    int Size;
}

extern(C):
    bool LanguageDlgProc(void* hwndDlg, uint msg, void* wParam, void* lParam);
    wchar_t* GetString(const char* stringId);
    Font* GetFont(char* fontType);
    bool LoadLanguageFile();
    bool LoadLanguageFromResource(int resourceid, bool setPreferred, bool forceSilent);
    char* GetPreferredLangId();
    void SetPreferredLangId(char* langId);
    char* GetActiveLangPackVersion();
