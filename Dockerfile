FROM python:3.11-slim

WORKDIR /app

# Install system dependencies including DTrace utilities
RUN apt-get update && apt-get install -y \
    systemtap \
    systemtap-sdt-dev \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY app.py .
COPY noise_generator.py .
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Expose Flask port
EXPOSE 5000

# Run both apps using the entrypoint script
ENTRYPOINT ["./entrypoint.sh"]