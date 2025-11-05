# CPU Contention Analysis with DTrace - Quick Command Guide

## DTrace/SystemTap Commands (Linux/macOS Only)
#### Using Raw Ubuntu Container

```bash
# Start Ubuntu container with privileged access
docker run -it --privileged --cpus=0.5 -m 512m ubuntu:22.04 /bin/bash

# Inside container: install tools
apt update && apt install -y python3 python3-pip systemtap curl git

# Copy project
git clone https://github.com/khangpt2k6/SimpleDTrace /app
cd /app

# Install Python deps
pip install -r requirements.txt

# Start both apps in background
python3 app.py & python3 noise_generator.py &

# Run tracing
stap -v dtrace_scripts/syscalls.d
```
## Useful Docker Commands

```bash
# View container logs
docker logs -f <container_name>

# Execute command in container
docker exec -it <container_name> bash

# List running containers
docker ps

# Stop container
docker stop <container_name>

# Remove container
docker rm <container_name>

# Remove image
docker rmi dtrace-cpu-contention
```
