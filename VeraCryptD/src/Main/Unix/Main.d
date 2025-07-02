module Main.Unix.Main;

enum TC_CORE_SERVICE_CMDLINE_OPTION = "--core-service";

extern(C) int wxEntry(int argc, char** argv);

import Core.Unix.CoreService;
import Volume.EncryptionThreadPool;
import Main.Application;
import Main.Main;
import std.stdio;
import std.exception;
import std.env;

extern(C) int main(int argc, char** argv)
{
    try
    {
        string sysPathStr = "/usr/sbin:/sbin:/usr/bin:/bin";
        auto currentPath = environment.get("PATH", "");
        if (currentPath.length)
            sysPathStr ~= ":" ~ currentPath;
        environment["PATH"] = sysPathStr;

        if (argc > 1 && (argv[1] == TC_CORE_SERVICE_CMDLINE_OPTION))
        {
            try {
                CoreService.processElevatedRequests();
                return 0;
            } catch(Exception e) {
                writeln(e.msg);
            }
            return 1;
        }

        CoreService.start();
        scope(exit) CoreService.stop();

        EncryptionThreadPool.start();
        scope(exit) EncryptionThreadPool.stop();

        bool forceTextUI = false;
        version(TC_NO_GUI) forceTextUI = true;
        if (!environment.get("DISPLAY", "") && !environment.get("WAYLAND_DISPLAY", ""))
            forceTextUI = true;

        if (forceTextUI || (argc > 1 && (argv[1] == "-t" || argv[1] == "--text")))
            Application.initialize(UserInterfaceType.Text);
        else
            Application.initialize(UserInterfaceType.Graphic);

        Application.setExitCode(1);

        if (wxEntry(argc, argv) == 0)
            Application.setExitCode(0);
    }
    catch (Exception e)
    {
        writeln(e.msg);
    }
    return Application.getExitCode();
}
