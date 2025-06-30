module Platform.FilesystemPath;

import std.file : remove, stat, exists, FileException;
import std.conv : to;
import std.path : baseName;
import Platform.User;
import Platform.Exception;

struct FilesystemPathType
{
    enum Enum
    {
        Unknown,
        File,
        Directory,
        SymbolicLink,
        BlockDevice,
        CharacterDevice
    }
}

class FilesystemPath
{
    string path;

    this()
    {
    }

    this(string p)
    {
        path = p;
    }

    this(const(char)* p)
    {
        if (p) path = to!string(p); else path = "";
    }

    this(wstring p)
    {
        path = to!string(p);
    }

    override string toString() const
    {
        return path;
    }

    void delete() const
    {
        remove(path);
    }

    UserId getOwner() const
    {
        import core.sys.posix.sys.stat : stat as c_stat, stat_t;
        stat_t st;
        if (c_stat(path.toStringz, &st) != 0)
            throw new SystemException("stat failed", path);
        return UserId(st.st_uid);
    }

    FilesystemPathType.Enum getType() const
    {
        import core.sys.posix.sys.stat : stat as c_stat, stat_t, S_IFMT, S_IFREG, S_IFDIR, S_IFLNK, S_IFBLK, S_IFCHR;
        stat_t st;
        if (c_stat(path.toStringz, &st) != 0)
            throw new SystemException("stat failed", path);
        auto m = st.st_mode & S_IFMT;
        if (m == S_IFREG) return FilesystemPathType.Enum.File;
        if (m == S_IFDIR) return FilesystemPathType.Enum.Directory;
        if (m == S_IFLNK) return FilesystemPathType.Enum.SymbolicLink;
        if (m == S_IFBLK) return FilesystemPathType.Enum.BlockDevice;
        if (m == S_IFCHR) return FilesystemPathType.Enum.CharacterDevice;
        return FilesystemPathType.Enum.Unknown;
    }

    bool isBlockDevice() const { try { return getType()==FilesystemPathType.Enum.BlockDevice; } catch(Exception){ return false; } }
    bool isCharacterDevice() const { try { return getType()==FilesystemPathType.Enum.CharacterDevice; } catch(Exception){ return false; } }
    bool isDirectory() const { try { return getType()==FilesystemPathType.Enum.Directory; } catch(Exception){ return false; } }
    bool isFile() const { try { return getType()==FilesystemPathType.Enum.File; } catch(Exception){ return false; } }
    bool isDevice() const { return isBlockDevice() || isCharacterDevice(); }
    bool isEmpty() const { return path.length == 0; }

    FilesystemPath toBaseName() const
    {
        return FilesystemPath(baseName(path));
    }

    FilesystemPath toHostDriveOfPartition() const
    {
        import std.regex : matchFirst, regex;
        auto m = matchFirst(path, regex("^(.*?)(\\d+)$"));
        if (m.empty)
            throw new PartitionDeviceRequired("Partition device required");
        return FilesystemPath(m.captures[1]);
    }

    static immutable int MaxSize = 260;
}

alias DevicePath = FilesystemPath;
alias DirectoryPath = FilesystemPath;
alias FilePath = FilesystemPath;

alias DirectoryPathList = DirectoryPath[];
alias FilePathList = FilePath[];
