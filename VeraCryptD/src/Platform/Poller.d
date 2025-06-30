module Platform.Poller;

import core.sys.posix.poll : pollfd, poll, POLLIN, nfds_t;
import std.exception : enforce;
import Platform.Exception;

class Poller
{
    private int[] fds;

    this(int fd1, int fd2=-1, int fd3=-1, int fd4=-1)
    {
        if (fd1 != -1) fds ~= fd1;
        if (fd2 != -1) fds ~= fd2;
        if (fd3 != -1) fds ~= fd3;
        if (fd4 != -1) fds ~= fd4;
    }

    int[] waitForData(int timeout=-1) const
    {
        pollfd[] pfds;
        pfds.length = fds.length;
        foreach(i, fd; fds)
        {
            pfds[i].fd = fd;
            pfds[i].events = POLLIN;
            pfds[i].revents = 0;
        }
        auto res = poll(pfds.ptr, cast(nfds_t)pfds.length, timeout);
        if (res == 0 && timeout != -1)
            throw new TimeOut("timeout");
        enforce(res >= 0, "poll failed");
        int[] ready;
        if (res > 0)
        {
            foreach(p; pfds)
                if ((p.revents & POLLIN) != 0)
                    ready ~= p.fd;
        }
        return ready;
    }
}
