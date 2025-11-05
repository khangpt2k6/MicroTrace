import time
import os
from datetime import datetime

def generate_noise():
    iteration = 0
    
    while True:
        iteration += 1
        start_time = time.time()
        
        # CPU-intensive computation
        result = 0
        for i in range(1000000):
            result += i
        
        elapsed = time.time() - start_time
        
        # Log activity
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        print(f"[{timestamp}] Noise Generator (PID: {os.getpid()}) - "
              f"Iteration: {iteration}, Computed sum: {result}, "
              f"Elapsed: {elapsed:.4f}s")
        
        # Sleep for 10 seconds before next iteration
        time.sleep(10)

if __name__ == '__main__':
    print(f"[Noise Generator] Starting on PID: {os.getpid()}")
    print(f"[Noise Generator] This process creates CPU contention")
    print(f"[Noise Generator] Will count 0-1,000,000 every iteration with 10s sleep between")
    try:
        generate_noise()
    except KeyboardInterrupt:
        print(f"\n[Noise Generator] Shutting down gracefully")