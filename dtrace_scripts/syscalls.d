#!/usr/bin/dtrace -s
/*
 * syscalls.d - Track system calls from both Flask and Noise Generator processes
 * 
 * Usage:
 *   dtrace -s syscalls.d 2>/dev/null | head -100
 * 
 * Shows: Syscall name, process name, execution time
 */

syscall:::entry
/execname == "python" || execname == "python3"/
{
    @calls[execname, probefunc] = count();
    @totaltime[execname, probefunc] = sum(arg0);
}

syscall:::return
/execname == "python" || execname == "python3"/
{
    self->time = timestamp - self->start[probefunc];
    @times[execname, probefunc] = avg(self->time);
}

END
{
    printf("\n=== System Calls Summary ===\n");
    printf("Process: Function Count\n");
    printa(@calls);
    
    printf("\n=== Average Execution Time (ns) ===\n");
    printa(@times);
}