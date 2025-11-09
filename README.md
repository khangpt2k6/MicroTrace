# CPU Contention Analysis with DTrace

A project for analyzing CPU contention using DTrace/SystemTap on Linux systems.

## Prerequisites

- Linux system (Ubuntu 22.04 recommended)
- SystemTap installed
- Python 3.x
- Git

## Setup on Linux


### Install bpftrace
```bash
sudo apt update
sudo apt install -y bpftrace linux-headers-$(uname -r)
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

# Start both apps in background
python3 app.py & python3 noise_generator.py &

# Run SystemTap tracing
sudo bpftrace dtrace_scripts/syscalls.d
```
<img width="1087" height="569" alt="image" src="https://github.com/user-attachments/assets/bc9b3125-f079-4e3e-a027-59ed1feeae78" />

<img width="1189" height="615" alt="image" src="https://github.com/user-attachments/assets/bf121510-50f0-4c52-9f23-5897e879ded7" />


## CPU and Memory Limits (Optional)

To simulate resource constraints, you can use cgroups or Docker:

```bash
# Using Docker with resource limits
docker run -it --privileged --cpus=0.5 -m 512m ubuntu:22.04 /bin/bash
```

## Running Tests

```bash
# Run all tests
pytest

# Run tests with coverage report
pytest --cov=. --cov-report=html

# Run specific test file
pytest tests/test_app.py

# Run with verbose output
pytest -v
```

### Suggest solution for kernel

**Try running one script first. If it works, you can run the others:**

```bash
sudo bpftrace dtrace_scripts/io_analysis.d
sudo bpftrace dtrace_scripts/process_info.d
sudo bpftrace dtrace_scripts/cpu_usage.d
```
