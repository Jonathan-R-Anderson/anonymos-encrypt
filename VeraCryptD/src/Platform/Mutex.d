module Platform.Mutex;

import core.sync.mutex : Mutex as SysMutex;

class Mutex
{
    private SysMutex m;

    this()
    {
        m = new SysMutex();
    }

    ~this()
    {
    }

    SysMutex getSystemHandle() { return m; }
    void lock() { m.lock(); }
    void unlock() { m.unlock(); }
}

class ScopeLock
{
    private Mutex mtx;
    this(Mutex m)
    {
        mtx = m;
        mtx.lock();
    }
    ~this()
    {
        mtx.unlock();
    }
}
