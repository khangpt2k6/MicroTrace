#!/usr/bin/stap
/*
 * cpu_usage.d - Monitor CPU usage and context switches
 * 
 * Usage:
 *   dtrace -s cpu_usage.d 2>/dev/null
 * 
 * Shows: Process scheduling, context switches, CPU time allocation
 */

probe scheduler.cpu_off
{
    if (execname() == "python" || execname() == "python3") {
        printf("[%s] %s (PID:%d) off CPU\n",
               ctime(gettimeofday_s()), execname(), pid());
    }
}

probe scheduler.cpu_on
{
    if (execname() == "python" || execname() == "python3") {
        printf("[%s] %s (PID:%d) on CPU\n",
               ctime(gettimeofday_s()), execname(), pid());
    }
}

probe scheduler.wakeup
{
    if (execname() == "python" || execname() == "python3") {
        printf("[%s] %s (PID:%d) woken up\n",
               ctime(gettimeofday_s()), execname(), pid());
    }
}

END
{
    printf("\n=== CPU Scheduling Summary ===\n");
    printf("Analysis complete. Check events above for scheduling patterns.\n");
}