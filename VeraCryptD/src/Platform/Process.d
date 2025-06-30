module Platform.Process;

import std.process : pipeProcess, Redirect; // spawn process and capture output
import std.array : appender;
import std.string : join;
import std.exception : enforce;
import Platform.Buffer;
import Platform.Exception;

struct ProcessExecFunctor
{
    void opCall(int argc, char** argv) {}
}

class Process
{
    static bool isExecutable(string path)
    {
        import std.file : stat;
        import core.sys.posix.sys.stat : S_IXUSR, S_IXGRP, S_IXOTH;
        auto s = stat(path);
        return s.isFile && (s.mode & (S_IXUSR|S_IXGRP|S_IXOTH));
    }

    static string findSystemBinary(const char* name, string errorMsg)
    {
        if (name is null)
        {
            errorMsg = "Invalid input";
            return "";
        }
        string n = name.idup;
        if (n.length && n[0] == '/')
        {
            if (isExecutable(n))
                return n;
        }
        else
        {
            string[] dirs = ["/usr/local/sbin","/usr/local/bin","/usr/sbin","/usr/bin","/sbin","/bin"];
            foreach(dir; dirs)
            {
                auto p = dir ~ "/" ~ n;
                if (isExecutable(p))
                    return p;
            }
        }
        errorMsg = n ~ " not found in system directories";
        return "";
    }

    static string execute(string procName, string[] arguments, int timeOut=-1, ProcessExecFunctor execFunctor=null, const(Buffer)* inputData=null)
    {
        auto cmd = [procName] ~ arguments;
        auto p = pipeProcess(cmd, Redirect.all);
        if (inputData !is null)
        {
            import std.stdio : write;
            write(p.stdin, cast(const(ubyte)[])inputData.ptr[0 .. inputData.length]);
            p.stdin.close();
        }
        auto output = p.stdout.readAll();
        auto err = p.stderr.readAll();
        auto result = p.wait();
        if (result != 0)
            throw new ExecutedProcessFailed("Process failed", procName, result, cast(string)err);
        return cast(string)output;
    }

    static bool isRunningUnderAppImage(string executablePath)
    {
        import std.env;
        auto appimage = environment.get("APPIMAGE", "");
        auto appdir = environment.get("APPDIR", "");
        if (!appimage.length || !appdir.length)
            return false;
        if (executablePath.startsWith(appdir) && appdir.startsWith("/tmp/.mount_"))
            return true;
        return false;
    }
}
