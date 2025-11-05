#!/usr/bin/stap

probe kernel.function("__schedule").call
{
    if (execname() == "python" || execname() == "python3") {
        printf("[%s] %s (PID:%d) context switch\n",
               ctime(gettimeofday_s()), execname(), pid());
    }
}

probe kernel.function("try_to_wake_up").call
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