# CPU Contention Analysis with DTrace

A project for analyzing CPU contention using DTrace/SystemTap on Linux systems.

## Prerequisites

- Linux system (Ubuntu 22.04 recommended)
- SystemTap installed
- Python 3.x
- Git

## Setup on Linux

### Install SystemTap

```bash
sudo apt-get update
sudo apt-get install -y systemtap systemtap-runtime
```

### Clone and Run

```bash
# Clone the repository
git clone https://github.com/khangpt2k6/SimpleDTrace SimpleDTrace
cd SimpleDTrace

# Install python and virtual environment for Python
sudo apt install python3-venv -y

# Create the virtual environment 
python3 -m venv venv

# Activate the virtual environment 
source venv/bin/activate

# Install Python dependencies
pip install -r requirements.txt

# Start the applications
python3 app.py & python3 noise_generator.py &

# Run SystemTap tracing
sudo stap -v dtrace_scripts/syscalls.d
```

## CPU and Memory Limits (Optional)

To simulate resource constraints, you can use cgroups or Docker:

```bash
# Using Docker with resource limits
docker run -it --privileged --cpus=0.5 -m 512m ubuntu:22.04 /bin/bash
```

## Monitoring Commands

```bash
# View running processes
ps aux | grep python3

# Monitor CPU usage
top -p $(pgrep -d',' -f 'python3')

# Kill background processes
pkill -f app.py
pkill -f noise_generator.py

# View SystemTap output
sudo stap -v dtrace_scripts/syscalls.d
```

## Troubleshooting

If SystemTap fails to run:

```bash
# Install kernel debug symbols
sudo apt-get install -y linux-headers-$(uname -r)

# Verify SystemTap installation
stap -V
```
