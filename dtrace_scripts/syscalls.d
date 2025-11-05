#!/usr/bin/stap

global calls, times

probe kernel.function("__x64_sys_*").call
{
    if (execname() == "python" || execname() == "python3") {
        calls[execname(), probefunc()]++
    }
}

probe kernel.function("__x64_sys_*").return
{
    if (execname() == "python" || execname() == "python3") {
        times[execname(), probefunc()]++
    }
}

probe end
{
    printf("\n=== System Calls Summary ===\n");
    foreach ([proc, func] in calls) {
        printf("%s -> %s: %d\n", proc, func, calls[proc, func]);
    }
    
    printf("\n=== System Call Frequency ===\n");
    foreach ([proc, func] in times) {
        printf("%s -> %s: %d calls\n", proc, func, times[proc, func]);
    }
}