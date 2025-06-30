module Volume.Hash;

class Hash
{
    this() {}

    void update(const(ubyte)[] data) {}
    void getDigest(ubyte[] out) {}
    string getName() const { return "HASH"; }
}

alias HashList = Hash[];
