module Platform.SharedPtr;

import std.typecons : RefCounted;

struct SharedPtr(T)
{
    private RefCounted!T* rc;

    this()
    {
        rc = null;
    }

    this(T value)
    {
        rc = new RefCounted!T(value);
    }

    this(T* p)
    {
        if (p is null)
            rc = null;
        else
            rc = new RefCounted!T(*p);
    }

    // copy constructor
    this(ref SharedPtr rhs)
    {
        rc = rhs.rc;
    }

    ~this()
    {
        // RefCounted cleans itself when last reference destroyed
    }

    SharedPtr opAssign(ref SharedPtr rhs)
    {
        if (&rhs !is &this)
            rc = rhs.rc;
        return this;
    }

    bool opCast(TT : bool)() const
    {
        return rc !is null;
    }

    ref T opUnary(string op)() if (op == "*")
    {
        return (*rc).payload;
    }

    T* get() const
    {
        return rc is null ? null : &(*rc).payload;
    }

    void reset()
    {
        rc = null;
    }

    size_t useCount() const
    {
        return rc is null ? 0 : rc.refCount;
    }
}

SharedPtr!T makeShared(T, Args...)(Args args)
{
    auto obj = T(args);
    return SharedPtr!T(obj);
}
