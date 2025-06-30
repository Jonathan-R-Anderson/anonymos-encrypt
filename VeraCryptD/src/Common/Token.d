module Common.Token;

struct TokenKeyfilePath
{
    string path;
    this(string p){ path = p; }
    override string toString() const { return path; }
}

class TokenInfo
{
    ulong slotId = 0;
    string label;
    bool isEditable() const { return true; }
}

class TokenKeyfile
{
    TokenInfo token;
    string id;
    this(TokenInfo t){ token = t; }
    TokenKeyfilePath toPath() const { return TokenKeyfilePath(id); }
    void getKeyfileData(ref ubyte[] out){ }
}

class Token
{
    static TokenKeyfile[] getAvailableKeyfiles(bool emv=false){ TokenKeyfile[] t; return t; }
    static bool isKeyfilePathValid(string path, bool emv=false){ return path.length>0; }
}
