module Platform.Event;

import core.sync.mutex;
import std.algorithm : remove; // for filtering
import std.array : array;

class EventArgs {}

alias EventHandler = void delegate(EventArgs);

class Event
{
    private EventHandler[] handlers;
    private Mutex m = new Mutex();

    void connect(EventHandler handler)
    {
        synchronized(m) {
            handlers ~= handler;
        }
    }

    void disconnect(EventHandler handler)
    {
        synchronized(m) {
            handlers = handlers.remove!(h => h.funcptr == handler.funcptr).array;
        }
    }

    void raise()
    {
        EventArgs args;
        raise(args);
    }

    void raise(EventArgs args)
    {
        EventHandler[] copy;
        synchronized(m) {
            copy = handlers.dup;
        }
        foreach(h; copy) {
            h(args);
        }
    }
}
