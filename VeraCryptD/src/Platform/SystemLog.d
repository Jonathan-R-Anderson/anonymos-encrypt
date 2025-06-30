module Platform.SystemLog;

import core.sys.posix.syslog; // for openlog, syslog, closelog
import std.string : toStringz;

class SystemLog
{
    static void writeDebug(string message)
    {
        openlog("veracrypt".toStringz, LOG_PID, LOG_USER);
        syslog(LOG_DEBUG, "%s", message.toStringz);
        closelog();
    }

    static void writeError(string message)
    {
        openlog("veracrypt".toStringz, LOG_PID, LOG_USER);
        syslog(LOG_ERR, "%s", message.toStringz);
        closelog();
    }

    static void writeException(Exception ex)
    {
        writeError("exception: " ~ ex.msg);
    }
}
