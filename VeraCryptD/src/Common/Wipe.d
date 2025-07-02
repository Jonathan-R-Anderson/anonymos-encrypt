module Common.Wipe;

enum WipeAlgorithmId
{
    TC_WIPE_NONE = 0,
    TC_WIPE_1_RAND = 100,
    TC_WIPE_3_DOD_5220 = 300,
    TC_WIPE_7_DOD_5220 = 700,
    TC_WIPE_35_GUTMANN = 3500,
    TC_WIPE_256 = 25600
}

enum TC_WIPE_RAND_CHAR_COUNT = 3;

private bool wipe3Dod5220(int pass, ubyte* buffer, size_t size)
{
    ubyte wipeChar;
    switch (pass)
    {
        case 1: wipeChar = 0; break;
        case 2: wipeChar = 0xFF; break;
        default: return false;
    }
    import core.stdc.string : memset;
    memset(buffer, wipeChar, size);
    return true;
}

private bool wipe7Dod5220(int pass, ubyte[TC_WIPE_RAND_CHAR_COUNT] randChars, ubyte* buffer, size_t size)
{
    ubyte wipeChar;
    switch (pass)
    {
        case 1: wipeChar = randChars[0]; break;
        case 2: wipeChar = cast(ubyte)~randChars[0]; break;
        case 4: wipeChar = randChars[1]; break;
        case 5: wipeChar = randChars[2]; break;
        case 6: wipeChar = cast(ubyte)~randChars[2]; break;
        default: return false;
    }
    import core.stdc.string : memset;
    memset(buffer, wipeChar, size);
    return true;
}

private bool wipe35Gutmann(int pass, ubyte* buffer, size_t size)
{
    ubyte[3] wipePat3 = [0x92, 0x49, 0x24];
    int wipePat3Pos;

    switch (pass)
    {
        case 5: memset(buffer, 0x55, size); break;
        case 6: memset(buffer, 0xAA, size); break;
        case 7: case 26: case 29: wipePat3Pos = 0; goto wipe3;
        case 8: case 27: case 30: wipePat3Pos = 1; goto wipe3;
        case 9: case 28: case 31: wipePat3Pos = 2; goto wipe3;
wipe3:
            if (pass >= 29)
            {
                wipePat3[0] = cast(ubyte)~wipePat3[0];
                wipePat3[1] = cast(ubyte)~wipePat3[1];
                wipePat3[2] = cast(ubyte)~wipePat3[2];
            }
            foreach (i; 0 .. size)
                buffer[i] = wipePat3[(wipePat3Pos + i) % 3];
            break;
        default:
            if (pass >= 10 && pass <= 25)
                memset(buffer, cast(ubyte)((pass - 10) * 0x11), size);
            else
                return false;
    }
    return true;
}

extern(C):
int GetWipePassCount(WipeAlgorithmId algorithm)
{
    final switch (algorithm)
    {
        case WipeAlgorithmId.TC_WIPE_1_RAND: return 1;
        case WipeAlgorithmId.TC_WIPE_3_DOD_5220: return 3;
        case WipeAlgorithmId.TC_WIPE_7_DOD_5220: return 7;
        case WipeAlgorithmId.TC_WIPE_35_GUTMANN: return 35;
        case WipeAlgorithmId.TC_WIPE_256: return 256;
        default: return -1;
    }
}

extern(C):
bool WipeBuffer(WipeAlgorithmId algorithm, ubyte[TC_WIPE_RAND_CHAR_COUNT] randChars, int pass, ubyte* buffer, size_t size)
{
    switch (algorithm)
    {
        case WipeAlgorithmId.TC_WIPE_1_RAND:
        case WipeAlgorithmId.TC_WIPE_256:
            return false; // caller fills random data
        case WipeAlgorithmId.TC_WIPE_3_DOD_5220:
            return wipe3Dod5220(pass, buffer, size);
        case WipeAlgorithmId.TC_WIPE_7_DOD_5220:
            return wipe7Dod5220(pass, randChars, buffer, size);
        case WipeAlgorithmId.TC_WIPE_35_GUTMANN:
            return wipe35Gutmann(pass, buffer, size);
    }
    return false;
}
