module Platform.Thread;

import core.thread : Thread, dur;
import Platform.Functor;
import std.exception : enforce;

alias ThreadSystemHandle = Thread;
alias ThreadProcPtr = void function(void*);

class ThreadWrapper
{
    private ThreadSystemHandle handle;

    void join() const
    {
        enforce(handle !is null, "Thread not started");
        handle.join();
    }

    void start(ThreadProcPtr proc, void* param=null)
    {
        enforce(handle is null, "Thread already started");
        handle = new Thread(() { proc(param); });
        handle.start();
    }

    void start(Functor functor)
    {
        start((void* p){ functor(); }, null);
    }

    static void sleep(uint milliSeconds)
    {
        Thread.sleep(dur!"msecs"(milliSeconds));
    }
}
