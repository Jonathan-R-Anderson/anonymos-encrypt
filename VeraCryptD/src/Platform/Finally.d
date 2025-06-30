module Platform.Finally;

struct Finally {
    void delegate() action;
    this(void delegate() a) { action = a; }
    ~this() { if (action !is null) action(); }
}

Finally finallyDo(void delegate() a) {
    return Finally(a);
}

finallyDoArg(T)(T arg, void delegate(T) a) {
    return Finally({ a(arg); });
}

finallyDoArg2(T1,T2)(T1 arg1, T2 arg2, void delegate(T1,T2) a) {
    return Finally({ a(arg1, arg2); });
}
