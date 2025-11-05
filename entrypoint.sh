#!/bin/bash
# Entrypoint script to run both applications

echo "==========================================="
echo "CPU Contention Analysis Container"
echo "==========================================="

# Start the noise generator in the background
echo "Starting Noise Generator..."
python /app/noise_generator.py &
NOISE_PID=$!
echo "Noise Generator PID: $NOISE_PID"

# Start the Flask web server in the foreground
echo "Starting Flask Web Server..."
python /app/app.py

# Trap signals to clean up
trap "kill $NOISE_PID" EXIT