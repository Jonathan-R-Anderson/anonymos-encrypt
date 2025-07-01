module SetupDLL.ComSetup;

extern(C):
alias wchar_t_ptr = const(wchar_t)*;

int RegisterComServers(wchar_t_ptr modulePath);
int UnregisterComServers(wchar_t_ptr modulePath);
