#!/usr/bin/bpftrace

tracepoint:raw_syscalls:sys_enter
/comm == "python" || comm == "python3"/
{
    @calls[comm, args->id] = count();
}

tracepoint:raw_syscalls:sys_exit
/comm == "python" || comm == "python3"/
{
    @times[comm, args->id] = count();
}

END
{
    printf("\n=== System Calls Summary ===\n");
    print(@calls);
    
    printf("\n=== System Call Frequency ===\n");
    print(@times);
}
