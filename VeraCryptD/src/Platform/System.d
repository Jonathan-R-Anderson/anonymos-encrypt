module Platform.System;

import core.stdc.stdlib : getenv;
import core.thread : Thread;
import std.string : toStringz, fromStringz;
import std.datetime : msecs, dur;

string getEnv(string name)
{
    auto p = getenv(name.toStringz);
    return p ? cast(string) p.fromStringz : "";
}

void sleepMs(int ms)
{
    Thread.sleep(dur!msecs(ms));
}
