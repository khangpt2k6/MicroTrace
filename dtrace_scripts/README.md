# DTrace Scripts for CPU Contention Analysis

This directory contains DTrace scripts for monitoring system behavior during CPU contention analysis.

## Prerequisites

- **Linux with SystemTap** or **macOS with DTrace**
- Elevated privileges (sudo)
- Target Docker container must be running

## Available Scripts

### 1. syscalls.d - System Call Monitoring

Tracks all system calls made by Python processes (Flask and Noise Generator)

**Shows:**

- Count of each system call
- Execution time per system call
- Which process is making which calls

**Usage:**

```bash
sudo dtrace -s syscalls.d 2>/dev/null
```

**Expected Output:**

```
=== System Calls Summary ===
Process: Function Count
python  epoll_wait  156
python  futex       284
python  write       42

=== Average Execution Time (ns) ===
python  epoll_wait  1234567
python  futex       567890
```

### 2. cpu_usage.d - CPU Scheduling Analysis

Monitors when processes go on and off CPU, tracking scheduling events

**Shows:**

- When processes are scheduled on CPU
- How long they run before being descheduled
- Wake-up events and preemptions

**Usage:**

```bash
sudo dtrace -s cpu_usage.d 2>/dev/null
```

**Expected Output:**

```
[2024-01-15 10:30:45] python (PID:42) on CPU
[2024-01-15 10:30:45] python (PID:42) off CPU after 123456789 nanoseconds
[2024-01-15 10:30:46] python (PID:43) on CPU
```

### 3. process_info.d - Process Activity Tracking

Monitors process and thread lifecycle events

**Shows:**

- New processes spawned
- Thread creation
- System call counts per process
- Process exit codes

**Usage:**

```bash
sudo dtrace -s process_info.d 2>/dev/null
```

**Expected Output:**

```
[2024-01-15 10:30:44] New process: python (PID:42, PPID:1)
[2024-01-15 10:30:44] New thread created in python (PID:42, TID:1)

=== Process Activity Summary ===
python  12458
```

### 4. io_analysis.d - I/O Operations Monitoring

Tracks file I/O, open/close operations, read/write patterns

**Shows:**

- File operations (open, close, read, write)
- Number of bytes read/written
- I/O frequency per process

**Usage:**

```bash
sudo dtrace -s io_analysis.d 2>/dev/null
```

**Expected Output:**

```
[2024-01-15 10:30:45] python (PID:42) -> write()
       Result: 256 bytes
[2024-01-15 10:30:45] python (PID:43) -> read()
       Result: 512 bytes

=== I/O Operations Summary ===
python  write  284
python  read   156
```

## How to Use with Docker Container

### Step 1: Start the Container

```bash
docker run --name dtrace-app --cpus=0.5 -m 512m -p 5000:5000 dtrace-cpu-contention
```

### Step 2: Get Container's Root Process

```bash
# Find the container's main process PID
CONTAINER_PID=$(docker inspect -f '{{.State.Pid}}' dtrace-app)
echo "Container PID: $CONTAINER_PID"
```

### Step 3: Run DTrace Script with Elevated Privileges

```bash
# For Linux with SystemTap
sudo dtrace -s syscalls.d 2>/dev/null

# Or filter by process name
sudo dtrace -p $CONTAINER_PID -s syscalls.d 2>/dev/null
```

### Step 4: In Another Terminal, Generate Load

```bash
# Create some activity for DTrace to observe
for i in {1..20}; do
  curl http://localhost:5000/compute > /dev/null 2>&1 &
  sleep 0.5
done
```

## Analyzing Results

### What indicates CPU Contention?

1. **High context switch frequency** (from cpu_usage.d)

   - Processes switching on/off CPU constantly
   - Small run times before preemption

2. **Long system call times** (from syscalls.d)

   - Mutex/semaphore wait times increase
   - Scheduler-related calls take longer

3. **Unequal CPU distribution** (from cpu_usage.d)

   - One process gets more CPU time
   - Fairness is compromised

4. **Increased I/O wait** (from io_analysis.d)
   - Processes block waiting for I/O
   - Lock contention on file descriptors

### Comparison: Contention vs No Contention

| Metric               | No Contention | With Contention |
| -------------------- | ------------- | --------------- |
| Context switches/sec | < 100         | > 1000          |
| Avg syscall time     | 1-10 µs       | 100+ µs         |
| Process run time     | 100-1000 µs   | 10-100 µs       |
| CPU fairness         | ~50-50%       | Imbalanced      |

## Creating Custom DTrace Scripts

### Basic Template

```d
syscall:::entry
/execname == "python"/
{
    printf("[%Y] %s syscall: %s\n", walltimestamp, execname, probefunc);
}
```

### Useful Predicates

```d
/pid != 0/              # Filter out system processes
/execname == "python"/  # Filter by process name
/arg0 > 1000/           # Filter by argument value
```

### Common Probes

```d
syscall:::entry         # Entry to system call
syscall:::return        # Return from system call
sched:::on-cpu          # Process scheduled on CPU
sched:::off-cpu         # Process preempted from CPU
proc:::exec             # Process execution
thread:::create         # New thread creation
```

## Troubleshooting DTrace

### "Permission Denied"

```bash
# Run with sudo
sudo dtrace -s syscalls.d
```

### "DTrace: unknown provider"

- Ensure DTrace/SystemTap is installed
- On Linux: `apt-get install systemtap systemtap-sdt-dev`
- On macOS: Should be built-in

### "Can't open specified probe"

- Process might have exited
- Ensure Docker container is still running
- Check process name with `ps aux`

### No Output Produced

- Script might be running but no matching probes
- Try simpler script first
- Check if processes are actually running
- Increase output verbosity

## Performance Impact of DTrace

⚠️ **Warning**: DTrace itself adds overhead!

- CPU usage increases by 5-20%
- Response times may change when DTrace is active
- For accurate measurements, disable DTrace and use Docker stats

## References

- [DTrace Tutorials](http://www.solarisinternals.com/si/dtrace/)
- [SystemTap Documentation](https://sourceware.org/systemtap/)
- [Linux Kernel Scheduler](https://www.kernel.org/doc/html/latest/scheduler/)
- [Flask Performance Tuning](https://flask.palletsprojects.com/en/latest/quickstart/)

## Next Steps

1. Run each script individually and observe output
2. Modify scripts to track specific metrics
3. Compare outputs with and without CPU contention
4. Create custom scripts for specific analysis needs
