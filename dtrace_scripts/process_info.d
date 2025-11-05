#!/usr/bin/stap
/*
 * process_info.d - Track process activity and resource usage
 * 
 * Usage:
 *   dtrace -s process_info.d 2>/dev/null
 * 
 * Shows: Process lifecycle, thread activity, resource statistics
 */

probe process.create
{
    if (execname() == "python" || execname() == "python3") {
        printf("[%s] New process: %s (PID:%d, PPID:%d)\n",
               ctime(gettimeofday_s()), execname(), pid(), ppid());
    }
}

probe process.exit
{
    if (execname() == "python" || execname() == "python3") {
        printf("[%s] Process exited: %s (PID:%d)\n",
               ctime(gettimeofday_s()), execname(), pid());
    }
}

probe syscall.*.entry
{
    if (pid() != 0 && (execname() == "python" || execname() == "python3")) {
        @total_syscalls[execname()] <<< 1;
    }
}

probe end
{
    printf("\n=== Process Activity Summary ===\n");
    foreach (proc in @total_syscalls) {
        printf("%s: %d system calls\n", proc, @total_syscalls[proc]);
    }
}