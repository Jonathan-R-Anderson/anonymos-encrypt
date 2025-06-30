module Platform.SyncEvent;

import core.sync.mutex; 
import core.sync.condition;

class SyncEvent
{
    private Mutex mtx = new Mutex();
    private Condition cond = new Condition(mtx);
    private bool signaled = false;

    this() {}

    void signal()
    {
        synchronized(mtx)
        {
            signaled = true;
            cond.notifyAll();
        }
    }

    void wait()
    {
        synchronized(mtx)
        {
            while(!signaled)
                cond.wait();
            signaled = false;
        }
    }
}
