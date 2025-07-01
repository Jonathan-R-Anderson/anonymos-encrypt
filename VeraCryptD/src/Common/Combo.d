module Common.Combo;

extern(C):
alias HWND = void*;
alias LPCWSTR = const(wchar_t)*;
alias BOOL = int;
alias LPARAM = size_t;

void AddComboItem(HWND hComboBox, LPCWSTR lpszFileName, BOOL saveHistory);
LPARAM MoveEditToCombo(HWND hComboBox, BOOL saveHistory);
int GetOrderComboIdx(HWND hComboBox, int* nIdxList, int nElems);
LPARAM UpdateComboOrder(HWND hComboBox);
void LoadCombo(HWND hComboBox, BOOL bEnabled, BOOL bOnlyCheckModified, BOOL* pbModified);
void DumpCombo(HWND hComboBox, int bClear);
void ClearCombo(HWND hComboBox);
int IsComboEmpty(HWND hComboBox);
