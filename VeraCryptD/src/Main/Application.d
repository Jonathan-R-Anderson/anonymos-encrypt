module Main.Application;

import std.file : thisExePath, exists, mkdir;
import std.path : buildPath, dirName;
import Platform.FilesystemPath;

enum UserInterfaceTypeEnum { Unknown, Graphic, Text }

class DummyInterface {}

class Application
{
    static int exitCode = 0;
    static DummyInterface _ui;
    static UserInterfaceTypeEnum uiType = UserInterfaceTypeEnum.Unknown;

    static DummyInterface createConsoleApp()
    {
        _ui = new DummyInterface();
        uiType = UserInterfaceTypeEnum.Text;
        return _ui;
    }

    static DummyInterface createGuiApp()
    {
        _ui = new DummyInterface();
        uiType = UserInterfaceTypeEnum.Graphic;
        return _ui;
    }

    static FilePath getConfigFilePath(string name, bool createDir=false)
    {
        auto dir = buildPath(dirName(thisExePath()), "config");
        if (createDir && !exists(dir))
            mkdir(dir);
        return FilePath(buildPath(dir, name));
    }

    static DirectoryPath getExecutableDirectory()
    {
        return DirectoryPath(dirName(thisExePath()));
    }

    static FilePath getExecutablePath()
    {
        return FilePath(thisExePath());
    }

    static void initialize(UserInterfaceTypeEnum type)
    {
        uiType = type;
    }

    static string getName()
    {
        return "VeraCrypt";
    }

    static int getExitCode() { return exitCode; }
    static void setExitCode(int c) { exitCode = c; }
    static DummyInterface getUserInterface() { return _ui; }
    static UserInterfaceTypeEnum getUserInterfaceType() { return uiType; }
}
