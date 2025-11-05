#!/usr/bin/stap

global total_syscalls

probe kernel.function("__x64_sys_execve").call
{
    if (execname() == "python" || execname() == "python3") {
        printf("[%s] New process: %s (PID:%d, PPID:%d)\n",
               ctime(gettimeofday_s()), execname(), pid(), ppid());
    }
}

probe kernel.function("do_exit").call
{
    if (execname() == "python" || execname() == "python3") {
        printf("[%s] Process exited: %s (PID:%d)\n",
               ctime(gettimeofday_s()), execname(), pid());
    }
}

probe kernel.function("__x64_sys_*").call
{
    if (pid() != 0 && (execname() == "python" || execname() == "python3")) {
        total_syscalls[execname()]++
    }
}

probe end
{
    printf("\n=== Process Activity Summary ===\n");
    foreach (proc in total_syscalls) {
        printf("%s: %d system calls\n", proc, total_syscalls[proc]);
    }
}