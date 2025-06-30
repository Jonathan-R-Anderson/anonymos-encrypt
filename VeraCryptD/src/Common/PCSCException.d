module Common.PCSCException;

class PCSCException : Exception
{
    private int errorCode;
    this(int code= -1, string msg="PCSC error")
    {
        super(msg);
        errorCode = code;
    }
    int getErrorCode() const { return errorCode; }
}

class CommandAPDUNotValid : Exception
{
    this(string srcPos = "", string err="")
    {
        super(srcPos ~ ":" ~ err);
    }
}

class ExtendedAPDUNotSupported : Exception { this(){super("EXTENDED_APDU_UNSUPPORTED");} }
class ScardLibraryInitializationFailed : Exception { this(){super("SCARD_MODULE_INIT_FAILED");} }
class EMVUnknownCardType : Exception { this(){super("EMV_UNKNOWN_CARD_TYPE");} }
class EMVSelectAIDFailed : Exception { this(){super("EMV_SELECT_AID_FAILED");} }
class EMVIccCertNotFound : Exception { this(){super("EMV_ICC_CERT_NOTFOUND");} }
class EMVIssuerCertNotFound : Exception { this(){super("EMV_ISSUER_CERT_NOTFOUND");} }
class EMVCPLCNotFound : Exception { this(){super("EMV_CPLC_NOTFOUND");} }
class EMVKeyfileDataNotFound : Exception { this(){super("EMV_KEYFILE_DATA_NOTFOUND");} }
class EMVPANNotFound : Exception { this(){super("EMV_PAN_NOTFOUND");} }
class InvalidEMVPath : Exception { this(){super("INVALID_EMV_PATH");} }
