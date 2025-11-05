#!/usr/bin/dtrace -s
/*
 * cpu_usage.d - Monitor CPU usage and context switches
 * 
 * Usage:
 *   dtrace -s cpu_usage.d 2>/dev/null
 * 
 * Shows: Process scheduling, context switches, CPU time allocation
 */

sched:::off-cpu
/execname == "python" || execname == "python3"/
{
    printf("[%Y] %s (PID:%d) off CPU after %d nanoseconds\n",
           walltimestamp, execname, pid, (timestamp - self->start));
    self->start = 0;
}

sched:::on-cpu
/execname == "python" || execname == "python3"/
{
    printf("[%Y] %s (PID:%d) on CPU\n", walltimestamp, execname, pid);
    self->start = timestamp;
}

sched:::wakeup
/execname == "python" || execname == "python3"/
{
    printf("[%Y] %s (PID:%d) woken up\n", walltimestamp, execname, pid);
}

END
{
    printf("\n=== CPU Scheduling Summary ===\n");
    printf("Analysis complete. Check events above for scheduling patterns.\n");
}