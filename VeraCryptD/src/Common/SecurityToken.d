module Common.SecurityToken;

import Common.Token;

class SecurityTokenInfo : TokenInfo
{
    uint flags = 0;
    string labelUtf8;
}

class SecurityTokenKeyfile : TokenKeyfile
{
    this(){ super(new TokenInfo()); }
    this(TokenKeyfilePath path){ super(new TokenInfo()); }
}

class SecurityToken
{
    static bool initialized;
    static void initLibrary(string path){ initialized = true; }
    static bool isInitialized(){ return initialized; }
}
