#!/usr/bin/stap

global io

probe syscall.read.entry,
      syscall.write.entry,
      syscall.open.entry,
      syscall.close.entry,
      syscall.openat.entry
{
    if (execname() == "python" || execname() == "python3") {
        printf("[%s] %s (PID:%d) -> %s()\n",
               ctime(gettimeofday_s()), execname(), pid(), probefunc());
    }
}

probe syscall.read.return,
      syscall.write.return
{
    if (execname() == "python" || execname() == "python3") {
        printf("       Result: %d bytes\n", retval);
        io[execname(), probefunc()]++
    }
}

probe end
{
    printf("\n=== I/O Operations Summary ===\n");
    foreach ([proc, func] in io) {
        printf("%s -> %s: %d operations\n", proc, func, io[proc, func]);
    }
}