module Platform.User;

struct UserId
{
    ulong systemId = 0;
    this(ulong id = 0) { systemId = id; }
}
