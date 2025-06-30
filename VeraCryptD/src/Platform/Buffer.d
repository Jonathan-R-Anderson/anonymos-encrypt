module Platform.Buffer;

import std.exception : enforce;
import core.stdc.stdlib : malloc, free;
import core.stdc.string : memcpy, memcmp, memset;

struct ConstBufferPtr
{
    const(ubyte)* ptr;
    size_t size;

    this()
    {
        ptr = null;
        size = 0;
    }

    this(const(ubyte)* p, size_t s)
    {
        ptr = p;
        size = s;
    }

    const(ubyte)* get() const { return ptr; }
    size_t length() const { return size; }
    bool isDataEqual(ConstBufferPtr other) const
    {
        if (size != other.size)
            return false;
        return memcmp(ptr, other.ptr, size) == 0;
    }

    ConstBufferPtr getRange(size_t offset, size_t len) const
    {
        enforce(offset + len <= size, "ParameterIncorrect");
        return ConstBufferPtr(ptr + offset, len);
    }
}

struct BufferPtr
{
    ubyte* ptr;
    size_t size;

    this()
    {
        ptr = null;
        size = 0;
    }

    this(ubyte* p, size_t s)
    {
        ptr = p;
        size = s;
    }

    ubyte* get() const { return ptr; }
    size_t length() const { return size; }

    void copyFrom(ConstBufferPtr other) const
    {
        enforce(other.size <= size, "ParameterTooLarge");
        memcpy(ptr, other.ptr, other.size);
    }

    BufferPtr getRange(size_t offset, size_t len) const
    {
        enforce(offset + len <= size, "ParameterIncorrect");
        return BufferPtr(ptr + offset, len);
    }

    void zero() const { memset(ptr, 0, size); }
    void erase() const { zero(); }

    operator ConstBufferPtr() const { return ConstBufferPtr(ptr, size); }
}

class Buffer
{
    protected ubyte* dataPtr = null;
    protected size_t dataSize = 0;
    protected size_t dataAlignment = 0;

    this() {}
    this(size_t size, size_t alignment = 0) { allocate(size, alignment); }
    this(ConstBufferPtr buf, size_t alignment = 0) { copyFrom(buf, alignment); }
    ~this() { if (dataPtr !is null) free(); }

    void allocate(size_t size, size_t alignment = 0)
    {
        enforce(size > 0, "ParameterIncorrect");
        if (dataPtr !is null)
        {
            if (dataSize == size && dataAlignment == alignment)
                return;
            free();
        }
        version(Windows)
        {
            import core.stdc.stdlib : _aligned_malloc;
            dataPtr = cast(ubyte*)_aligned_malloc(size, alignment > 0 ? alignment : size_t.sizeof);
        }
        else
        {
            if (alignment > 0)
            {
                void* p = null;
                import core.stdc.stdlib : posix_memalign;
                if (posix_memalign(&p, alignment, size) != 0)
                    p = null;
                dataPtr = cast(ubyte*)p;
            }
            else
                dataPtr = cast(ubyte*)malloc(size);
        }
        enforce(dataPtr !is null, "bad_alloc");
        dataSize = size;
        dataAlignment = alignment;
    }

    void copyFrom(ConstBufferPtr buf, size_t alignment = 0)
    {
        if (dataPtr is null || buf.size != 0 && dataAlignment != alignment)
        {
            if (dataPtr !is null)
                free();
            if (buf.size != 0)
                allocate(buf.size, alignment);
        }
        else if (buf.size > dataSize)
            throw new Exception("ParameterTooLarge");
        if (buf.size != 0)
            memcpy(dataPtr, buf.ptr, buf.size);
    }

    BufferPtr getRange(size_t offset, size_t len) const
    {
        enforce(offset + len <= dataSize, "ParameterIncorrect");
        return BufferPtr(dataPtr + offset, len);
    }

    void erase() { if (dataSize > 0) memset(dataPtr, 0, dataSize); }
    void free()
    {
        enforce(dataPtr !is null, "NotInitialized");
        version(Windows)
        {
            import core.stdc.stdlib : _aligned_free;
            if (dataAlignment > 0)
                _aligned_free(dataPtr);
            else
                free(dataPtr);
        }
        else
        {
            if (dataAlignment > 0)
                free(dataPtr); // posix_memalign memory freed by free
            else
                free(dataPtr);
        }
        dataPtr = null;
        dataSize = 0;
        dataAlignment = 0;
    }

    size_t size() const { return dataSize; }
    size_t alignment() const { return dataAlignment; }
    bool isAllocated() const { return dataSize != 0; }
    void zero() { if (dataSize > 0) memset(dataPtr, 0, dataSize); }

    ubyte* ptr() const { return dataPtr; }
}

class SecureBuffer : Buffer
{
    this() {}
    this(size_t size, size_t alignment = 0) { allocate(size, alignment); }
    this(ConstBufferPtr buf) { copyFrom(buf); }
    ~this() { if (dataPtr !is null && dataSize != 0) free(); }

    override void allocate(size_t size, size_t alignment = 0)
    {
        super.allocate(size, alignment);
    }

    override void free()
    {
        enforce(dataPtr !is null, "NotInitialized");
        erase();
        super.free();
    }
}
