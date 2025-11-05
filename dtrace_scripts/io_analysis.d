#!/usr/bin/stap

global io

probe kernel.function("__x64_sys_read").call,
      kernel.function("__x64_sys_write").call,
      kernel.function("__x64_sys_open").call,
      kernel.function("__x64_sys_close").call,
      kernel.function("__x64_sys_openat").call
{
    if (execname() == "python" || execname() == "python3") {
        printf("[%s] %s (PID:%d) -> %s()\n",
               ctime(gettimeofday_s()), execname(), pid(), probefunc());
    }
}

probe kernel.function("__x64_sys_read").return,
      kernel.function("__x64_sys_write").return
{
    if (execname() == "python" || execname() == "python3") {
        printf("       Result: %ld bytes\n", $return);
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