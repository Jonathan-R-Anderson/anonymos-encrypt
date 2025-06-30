module Common.EMVToken;

import Common.Token;
import Common.EMVCard;

class EMVTokenInfo : TokenInfo
{
    override bool isEditable() const { return false; }
}

class EMVTokenKeyfile : TokenKeyfile
{
    this(){ super(new TokenInfo()); }
    this(TokenKeyfilePath path){ super(new TokenInfo()); }
}

class EMVToken
{
    static EMVCard[ulong] emvCards;
    static bool isKeyfilePathValid(string path){ return path.startsWith("emv://"); }
    static EMVTokenKeyfile[] getAvailableKeyfiles(){ EMVTokenKeyfile[] r; return r; }
}
