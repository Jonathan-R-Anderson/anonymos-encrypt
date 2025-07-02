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

extern(C):
    int GetWipePassCount(WipeAlgorithmId algorithm);
    bool WipeBuffer(WipeAlgorithmId algorithm, ubyte[TC_WIPE_RAND_CHAR_COUNT] randChars, int pass, ubyte* buffer, size_t size);
