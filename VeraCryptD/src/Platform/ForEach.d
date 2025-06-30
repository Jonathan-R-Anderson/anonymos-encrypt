module Platform.ForEach;

struct ForEach
{
    static auto getContainerForward(T)(T container)
    {
        return container;
    }

    static auto getContainerReverse(T)(T container)
    {
        import std.range : retro;
        return retro(container);
    }
}
