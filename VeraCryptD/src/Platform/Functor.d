module Platform.Functor;

interface Functor
{
    void opCall();
}

interface GetStringFunctor
{
    void opCall(ref string str);
}
