#!/usr/bin/dtrace -s
/*
 * io_analysis.d - Monitor I/O operations and file access
 * 
 * Usage:
 *   dtrace -s io_analysis.d 2>/dev/null
 * 
 * Shows: File I/O patterns, read/write operations
 */

tracepoint:syscalls:sys_enter_read,
tracepoint:syscalls:sys_enter_write,
tracepoint:syscalls:sys_enter_open,
tracepoint:syscalls:sys_enter_close,
tracepoint:syscalls:sys_enter_openat
/execname == "python" || execname == "python3"/
{
    printf("[%Y] %s (PID:%d) -> %s()\n",
           walltimestamp, execname, pid, probefunc);
}

tracepoint:syscalls:sys_exit_read,
tracepoint:syscalls:sys_exit_write
/execname == "python" || execname == "python3"/
{
    printf("       Result: %d bytes\n", arg1);
    @io[execname, probefunc] = count();
}

END
{
    printf("\n=== I/O Operations Summary ===\n");
    printa(@io);
}