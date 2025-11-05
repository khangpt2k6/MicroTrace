#!/usr/bin/stap
/*
 * syscalls.d - Track system calls from both Flask and Noise Generator processes
 * 
 * Usage:
 *   dtrace -s syscalls.d 2>/dev/null | head -100
 * 
 * Shows: Syscall name, process name, execution time
 */

probe syscall.*.entry
{
    if (execname() == "python" || execname() == "python3") {
        @calls[execname(), probefunc()] <<< 1;
    }
}

probe syscall.*.return
{
    if (execname() == "python" || execname() == "python3") {
        @times[execname(), probefunc()] <<< 1;
    }
}

probe end
{
    printf("\n=== System Calls Summary ===\n");
    foreach ([proc, func] in @calls) {
        printf("%s -> %s: %d\n", proc, func, @calls[proc, func]);
    }
    
    printf("\n=== System Call Frequency ===\n");
    foreach ([proc, func] in @times) {
        printf("%s -> %s: %d calls\n", proc, func, @times[proc, func]);
    }
}