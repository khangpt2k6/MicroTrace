#!/usr/bin/dtrace -s
/*
 * process_info.d - Track process activity and resource usage
 * 
 * Usage:
 *   dtrace -s process_info.d 2>/dev/null
 * 
 * Shows: Process lifecycle, thread activity, resource statistics
 */

proc:::exec-success
/execname == "python" || execname == "python3"/
{
    printf("[%Y] New process: %s (PID:%d, PPID:%d)\n",
           walltimestamp, execname, pid, ppid);
}

proc:::exit
/execname == "python" || execname == "python3"/
{
    printf("[%Y] Process exited: %s (PID:%d, exit code:%d)\n",
           walltimestamp, execname, pid, arg0);
}

thread:::create
/execname == "python" || execname == "python3"/
{
    printf("[%Y] New thread created in %s (PID:%d, TID:%d)\n",
           walltimestamp, execname, pid, tid);
}

syscall:::entry
/pid != 0 && (execname == "python" || execname == "python3")/
{
    self->in_syscall = 1;
}

syscall:::return
/self->in_syscall && (execname == "python" || execname == "python3")/
{
    @total_syscalls[execname] = count();
    self->in_syscall = 0;
}

END
{
    printf("\n=== Process Activity Summary ===\n");
    printa(@total_syscalls);
}