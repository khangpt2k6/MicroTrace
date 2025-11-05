#!/usr/bin/stap

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

probe end
{
    printf("\n=== CPU Scheduling Summary ===\n");
    printf("Analysis complete. Check events above for scheduling patterns.\n");
}