#!/usr/bin/bpftrace

// Enhanced DTrace script for cloud/server computing research
// Traces background processes, system calls, I/O, and resource usage

// Track process lifecycle for key server processes
tracepoint:sched:sched_process_fork
{
    @process_starts[comm] = count();
    printf("[%s] Process fork: %s (PID:%d <- PPID:%d)\n",
           strftime("%H:%M:%S", nsecs / 1e9), comm, child_pid, pid);
}

tracepoint:sched:sched_process_exit
{
    @process_exits[comm] = count();
    printf("[%s] Process exit: %s (PID:%d)\n",
           strftime("%H:%M:%S", nsecs / 1e9), comm, pid);
}

// System call tracing with categorization
tracepoint:raw_syscalls:sys_enter
/pid != 0/
{
    @syscalls_total[comm] = count();
    @syscalls_by_type[args->id] = count();

    // Categorize system calls for research analysis
    if (args->id >= 0 && args->id <= 10) {
        @syscalls_category["process"] = count();
    } else if (args->id >= 11 && args->id <= 50) {
        @syscalls_category["file"] = count();
    } else if (args->id >= 51 && args->id <= 100) {
        @syscalls_category["network"] = count();
    } else {
        @syscalls_category["other"] = count();
    }
}

// CPU scheduling events
tracepoint:sched:sched_switch
{
    @cpu_switches[comm] = count();
}

// Memory allocation tracing
tracepoint:kmem:mm_page_alloc
{
    @memory_pages_alloc = count();
}

tracepoint:kmem:mm_page_free
{
    @memory_pages_free = count();
}

// Enhanced Disk I/O tracing
tracepoint:block:block_rq_issue
{
    @disk_io_requests[comm] = count();
    @disk_io_bytes[comm] = sum(args->bytes);

    // Separate read/write operations
    if (args->rwbs == "R" || args->rwbs == "RA") {
        @disk_reads[comm] = count();
        @disk_read_bytes[comm] = sum(args->bytes);
    } else {
        @disk_writes[comm] = count();
        @disk_write_bytes[comm] = sum(args->bytes);
    }

    // I/O size distribution
    if (args->bytes <= 4096) {
        @disk_io_sizes["small"] = count();
    } else if (args->bytes <= 65536) {
        @disk_io_sizes["medium"] = count();
    } else {
        @disk_io_sizes["large"] = count();
    }

    // Per-device statistics
    @disk_io_per_device[args->dev] = count();
    @disk_bytes_per_device[args->dev] = sum(args->bytes);

    // Track I/O start time for latency measurement
    @io_start_time[args->dev, args->sector] = nsecs;
}

tracepoint:block:block_rq_complete
{
    // Measure I/O latency
    $start_time = @io_start_time[args->dev, args->sector];
    if ($start_time) {
        $latency = nsecs - $start_time;
        @disk_io_latency[comm] = avg($latency);
        @disk_io_latency_dist[comm] = hist($latency / 1000000); // Convert to milliseconds

        delete(@io_start_time[args->dev, args->sector]);
    }
}

// Enhanced Network I/O tracing
tracepoint:net:net_dev_xmit
{
    @network_packets_out = count();
    @network_bytes_out = sum(args->len);

    // Packet size distribution
    if (args->len <= 64) {
        @network_packet_sizes_out["tiny"] = count();
    } else if (args->len <= 512) {
        @network_packet_sizes_out["small"] = count();
    } else if (args->len <= 1500) {
        @network_packet_sizes_out["medium"] = count();
    } else {
        @network_packet_sizes_out["large"] = count();
    }

    // Per-interface statistics
    @network_out_per_interface[args->name] = count();
    @network_bytes_out_per_interface[args->name] = sum(args->len);
}

tracepoint:net:netif_receive_skb
{
    @network_packets_in = count();
    @network_bytes_in = sum(args->len);

    // Packet size distribution
    if (args->len <= 64) {
        @network_packet_sizes_in["tiny"] = count();
    } else if (args->len <= 512) {
        @network_packet_sizes_in["small"] = count();
    } else if (args->len <= 1500) {
        @network_packet_sizes_in["medium"] = count();
    } else {
        @network_packet_sizes_in["large"] = count();
    }

    // Per-interface statistics
    @network_in_per_interface[args->name] = count();
    @network_bytes_in_per_interface[args->name] = sum(args->len);
}

// TCP/UDP protocol tracing
tracepoint:tcp:tcp_retransmit_skb
{
    @tcp_retransmits[comm] = count();
}

tracepoint:udp:udp_recvmsg
{
    @udp_packets_recv[comm] = count();
    @udp_bytes_recv[comm] = sum(args->size);
}

tracepoint:udp:udp_sendmsg
{
    @udp_packets_sent[comm] = count();
    @udp_bytes_sent[comm] = sum(args->size);
}

// VFS (Virtual File System) operations
tracepoint:vfs:read
{
    @vfs_reads[comm] = count();
    @vfs_read_bytes[comm] = sum(args->count);
}

tracepoint:vfs:write
{
    @vfs_writes[comm] = count();
    @vfs_write_bytes[comm] = sum(args->count);
}

tracepoint:vfs:open
{
    @vfs_opens[comm] = count();
}

tracepoint:vfs:close
{
    @vfs_closes[comm] = count();
}

// Network errors and drops
tracepoint:net:netif_rx
{
    @network_packets_dropped = count();
}

tracepoint:net:net_dev_xmit
/args->rc != 0/
{
    @network_xmit_errors[args->name] = count();
}

// Periodic aggregation every 60 seconds
interval:s:60
{
    time("%H:%M:%S");
    printf("=== 60-second System Activity Snapshot ===\n");

    printf("Active Processes: %d\n", nprocs);
    printf("CPU Load: %.2f%%\n", (100 * (1 - @cpu_idle_rate / 100.0)));

    if (@syscalls_total) {
        printf("Top System Call Processes:\n");
        print(@syscalls_total, 5);
    }

    if (@disk_io_requests) {
        printf("Disk I/O by Process:\n");
        print(@disk_io_requests, 5);
        printf("Disk Read/Write Ratio: ");
        print(@disk_reads, 5);
        printf("/");
        print(@disk_writes, 5);
        printf("\n");
    }

    if (@network_packets_out) {
        printf("Network Activity: %d packets out, %d packets in\n",
               @network_packets_out, @network_packets_in);
    }

    if (@vfs_reads) {
        printf("File System Operations: ");
        print(@vfs_reads, 3);
        printf(" reads, ");
        print(@vfs_writes, 3);
        printf(" writes\n");
    }

    clear(@syscalls_total);
    clear(@disk_io_requests);
    clear(@disk_reads);
    clear(@disk_writes);
    clear(@network_packets_out);
    clear(@network_packets_in);
    clear(@vfs_reads);
    clear(@vfs_writes);
    clear(@cpu_switches);
}

// Background process detection
tracepoint:sched:sched_process_fork
/!tty/
{
    @background_processes[comm] = count();
}

END
{
    printf("\n=== Final Research Data Summary ===\n");

    printf("Process Lifecycle:\n");
    printf("- Process starts: ");
    print(@process_starts);
    printf("- Process exits: ");
    print(@process_exits);

    printf("\nSystem Calls:\n");
    printf("- By process: ");
    print(@syscalls_total);
    printf("- By category: ");
    print(@syscalls_category);
    printf("- By syscall ID: ");
    print(@syscalls_by_type, 10);

    printf("\nResource Usage:\n");
    printf("- CPU switches: ");
    print(@cpu_switches);
    printf("- Memory pages alloc/free: %d/%d\n", @memory_pages_alloc, @memory_pages_free);

    printf("\nI/O Activity:\n");

    printf("Disk I/O:\n");
    printf("- Total requests: ");
    print(@disk_io_requests);
    printf("- Total bytes: ");
    print(@disk_io_bytes);
    printf("- Read operations: ");
    print(@disk_reads);
    printf("- Read bytes: ");
    print(@disk_read_bytes);
    printf("- Write operations: ");
    print(@disk_writes);
    printf("- Write bytes: ");
    print(@disk_write_bytes);
    printf("- I/O size distribution: ");
    print(@disk_io_sizes);
    printf("- Per-device requests: ");
    print(@disk_io_per_device);
    printf("- Per-device bytes: ");
    print(@disk_bytes_per_device);
    printf("- I/O latency (avg): ");
    print(@disk_io_latency);

    printf("\nNetwork I/O:\n");
    printf("- Packets in/out: %d/%d\n", @network_packets_in, @network_packets_out);
    printf("- Bytes in/out: %d/%d\n", @network_bytes_in, @network_bytes_out);
    printf("- Packet sizes in: ");
    print(@network_packet_sizes_in);
    printf("- Packet sizes out: ");
    print(@network_packet_sizes_out);
    printf("- Per-interface in: ");
    print(@network_in_per_interface);
    printf("- Per-interface out: ");
    print(@network_out_per_interface);

    printf("\nProtocol-specific:\n");
    printf("- TCP retransmits: ");
    print(@tcp_retransmits);
    printf("- UDP packets recv: ");
    print(@udp_packets_recv);
    printf("- UDP bytes recv: ");
    print(@udp_bytes_recv);
    printf("- UDP packets sent: ");
    print(@udp_packets_sent);
    printf("- UDP bytes sent: ");
    print(@udp_bytes_sent);

    printf("\nFile System (VFS):\n");
    printf("- Read operations: ");
    print(@vfs_reads);
    printf("- Read bytes: ");
    print(@vfs_read_bytes);
    printf("- Write operations: ");
    print(@vfs_writes);
    printf("- Write bytes: ");
    print(@vfs_write_bytes);
    printf("- File opens: ");
    print(@vfs_opens);
    printf("- File closes: ");
    print(@vfs_closes);

    printf("\nNetwork Errors:\n");
    printf("- Packets dropped: %d\n", @network_packets_dropped);
    printf("- Transmit errors: ");
    print(@network_xmit_errors);

    printf("\nBackground Processes Detected:\n");
    print(@background_processes);

    // Output in JSON format for research analysis
    printf("\n=== JSON Export for Analysis ===\n");
    printf("{\n");
    printf("  \"timestamp\": \"%s\",\n", strftime("%Y-%m-%d %H:%M:%S", nsecs / 1e9));
    printf("  \"process_starts\": ");
    print(@process_starts, 0, 1);
    printf(",\n  \"process_exits\": ");
    print(@process_exits, 0, 1);
    printf(",\n  \"syscalls_total\": ");
    print(@syscalls_total, 0, 1);
    printf(",\n  \"syscalls_category\": ");
    print(@syscalls_category, 0, 1);
    printf(",\n  \"background_processes\": ");
    print(@background_processes, 0, 1);
    printf(",\n  \"disk_io\": {\n");
    printf("    \"total_requests\": ");
    print(@disk_io_requests, 0, 1);
    printf(",\n    \"total_bytes\": ");
    print(@disk_io_bytes, 0, 1);
    printf(",\n    \"reads\": ");
    print(@disk_reads, 0, 1);
    printf(",\n    \"read_bytes\": ");
    print(@disk_read_bytes, 0, 1);
    printf(",\n    \"writes\": ");
    print(@disk_writes, 0, 1);
    printf(",\n    \"write_bytes\": ");
    print(@disk_write_bytes, 0, 1);
    printf(",\n    \"size_distribution\": ");
    print(@disk_io_sizes, 0, 1);
    printf(",\n    \"per_device_requests\": ");
    print(@disk_io_per_device, 0, 1);
    printf(",\n    \"per_device_bytes\": ");
    print(@disk_bytes_per_device, 0, 1);
    printf(",\n    \"latency_avg\": ");
    print(@disk_io_latency, 0, 1);
    printf("\n  }");
    printf(",\n  \"network_io\": {\n");
    printf("    \"packets_in\": %d,\n", @network_packets_in);
    printf("    \"packets_out\": %d,\n", @network_packets_out);
    printf("    \"bytes_in\": %d,\n", @network_bytes_in);
    printf("    \"bytes_out\": %d,\n", @network_bytes_out);
    printf("    \"packet_sizes_in\": ");
    print(@network_packet_sizes_in, 0, 1);
    printf(",\n    \"packet_sizes_out\": ");
    print(@network_packet_sizes_out, 0, 1);
    printf(",\n    \"per_interface_in\": ");
    print(@network_in_per_interface, 0, 1);
    printf(",\n    \"per_interface_out\": ");
    print(@network_out_per_interface, 0, 1);
    printf("\n  }");
    printf(",\n  \"protocols\": {\n");
    printf("    \"tcp_retransmits\": ");
    print(@tcp_retransmits, 0, 1);
    printf(",\n    \"udp_packets_recv\": ");
    print(@udp_packets_recv, 0, 1);
    printf(",\n    \"udp_bytes_recv\": ");
    print(@udp_bytes_recv, 0, 1);
    printf(",\n    \"udp_packets_sent\": ");
    print(@udp_packets_sent, 0, 1);
    printf(",\n    \"udp_bytes_sent\": ");
    print(@udp_bytes_sent, 0, 1);
    printf("\n  }");
    printf(",\n  \"filesystem\": {\n");
    printf("    \"vfs_reads\": ");
    print(@vfs_reads, 0, 1);
    printf(",\n    \"vfs_read_bytes\": ");
    print(@vfs_read_bytes, 0, 1);
    printf(",\n    \"vfs_writes\": ");
    print(@vfs_writes, 0, 1);
    printf(",\n    \"vfs_write_bytes\": ");
    print(@vfs_write_bytes, 0, 1);
    printf(",\n    \"vfs_opens\": ");
    print(@vfs_opens, 0, 1);
    printf(",\n    \"vfs_closes\": ");
    print(@vfs_closes, 0, 1);
    printf("\n  }");
    printf(",\n  \"network_errors\": {\n");
    printf("    \"packets_dropped\": %d,\n", @network_packets_dropped);
    printf("    \"xmit_errors\": ");
    print(@network_xmit_errors, 0, 1);
    printf("\n  }");
    printf("\n}\n");
}
