module Main.UserInterfaceException;

class MissingArgumentException : Exception
{
    this(string msg="Missing argument"){ super(msg); }
}

class UnrecognizedCommandException : Exception
{
    this(string msg="Unrecognized command"){ super(msg); }
}
