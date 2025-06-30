module Main.FatalErrorHandler;

import std.stdio : stderr, writeln;
import core.runtime : Runtime;

class FatalErrorHandler
{
    static void function(Throwable) oldHandler;

    static void register()
    {
        oldHandler = Runtime.traceHandler;
        Runtime.traceHandler = &onTerminate;
    }

    static void deregister()
    {
        Runtime.traceHandler = oldHandler;
    }

    static uint getAppChecksum()
    {
        return 0;
    }

    static string getCallStack(int depth)
    {
        return "";
    }

    static void onTerminate(Throwable t)
    {
        stderr.writeln("Fatal error: ", t.msg);
        if (oldHandler !is null)
            oldHandler(t);
    }
}
