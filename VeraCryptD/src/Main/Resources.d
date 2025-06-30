module Main.Resources;

import std.file : readText, exists;
import std.path : buildPath, dirName;
import Platform.FilesystemPath;

struct DummyBitmap {}
struct DummyIcon {}

string getLanguageXml(out string preferredLang)
{
    auto path = buildPath(dirName(__FILE__), "../../../VeraCrypt/src/Common/Language.xml");
    preferredLang = "en";
    if (exists(path))
        return readText(path);
    return "";
}

string getLegalNotices()
{
    auto path = buildPath(dirName(__FILE__), "../../../VeraCrypt/src/License.html");
    if (exists(path))
        return readText(path);
    return "";
}

DummyBitmap getDriveIconBitmap() { return DummyBitmap(); }
DummyBitmap getDriveIconMaskBitmap() { return DummyBitmap(); }
DummyBitmap getLogoBitmap() { return DummyBitmap(); }
DummyBitmap getTextualLogoBitmap() { return DummyBitmap(); }
DummyIcon getVeraCryptIcon() { return DummyIcon(); }
DummyBitmap getVolumeCreationWizardBitmap(int height=-1) { return DummyBitmap(); }
