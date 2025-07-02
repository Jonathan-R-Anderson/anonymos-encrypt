module Common.Keyfiles;

import core.stdc.wchar_ : wchar_t;

struct KeyFile
{
    wchar_t[260] FileName; // MAX_PATH + 1
    KeyFile* Next;
}

struct KeyFilesDlgParam
{
    wchar_t[260] VolumeFileName;
    bool EnableKeyFiles;
    KeyFile* FirstKeyFile;
}

extern(C):
    KeyFile* KeyFileAdd(KeyFile* firstKeyFile, KeyFile* keyFile);
    void KeyFileRemoveAll(KeyFile** firstKeyFile);
    KeyFile* KeyFileClone(KeyFile* keyFile);
    void KeyFileCloneAll(KeyFile* firstKeyFile, KeyFile** outputKeyFile);
    bool KeyFilesApply(void* hwndDlg, void* password, KeyFile* firstKeyFile, const(wchar_t)* volumeFileName);
    bool KeyfilesDlgProc(void* hwndDlg, uint msg, void* wParam, void* lParam);
    bool KeyfilesPopupMenu(void* hwndDlg, void* popupPosition, KeyFilesDlgParam* dialogParam);

    __gshared bool HiddenFilesPresentInKeyfilePath;
