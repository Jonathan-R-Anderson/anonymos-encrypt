module Platform.SharedVal;

import core.sync.mutex : Mutex;

struct SharedVal(T)
{
    private T value = T.init;
    private Mutex m;

    this() {}
    this(T v) { value = v; }

    T get() {
        synchronized(m) return value;
    }

    void set(T v) {
        synchronized(m) value = v;
    }

    T increment() {
        synchronized(m) {
            ++value;
            return value;
        }
    }

    T decrement() {
        synchronized(m) {
            --value;
            return value;
        }
    }
}
