#!/usr/bin/dtrace -s
/*
 * io_analysis.d - Monitor I/O operations and file access
 * 
 * Usage:
 *   dtrace -s io_analysis.d 2>/dev/null
 * 
 * Shows: File I/O patterns, read/write operations
 */

syscall:::entry
/(execname == "python" || execname == "python3") && 
 (probefunc == "read" || probefunc == "write" || probefunc == "open" || probefunc == "close")/
{
    printf("[%Y] %s (PID:%d) -> %s()\n",
           walltimestamp, execname, pid, probefunc);
}

syscall:::return
/(execname == "python" || execname == "python3") && 
 (probefunc == "read" || probefunc == "write")/
{
    printf("       Result: %d bytes\n", arg0);
    @io[execname, probefunc] = count();
}

END
{
    printf("\n=== I/O Operations Summary ===\n");
    printa(@io);
}