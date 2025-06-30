module Volume.Hash;

class Hash
{
    private uint _state = 0;

    this() {}

    void update(const(ubyte)[] data)
    {
        foreach (b; data)
        {
            _state = ((_state << 5) + _state) ^ b;
        }
    }

    void getDigest(ubyte[] out)
    {
        if (out.length >= 4)
        {
            out[0] = cast(ubyte)((_state >> 24) & 0xFF);
            out[1] = cast(ubyte)((_state >> 16) & 0xFF);
            out[2] = cast(ubyte)((_state >> 8) & 0xFF);
            out[3] = cast(ubyte)(_state & 0xFF);
        }
    }

    string getName() const { return "DummyHash"; }
}

alias HashList = Hash[];
