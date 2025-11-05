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

# Configuration environment variables
ENV FLASK_PORT=5000
ENV FLASK_HOST=0.0.0.0

# Expose Flask port
EXPOSE 5000

# Health check to monitor container status
HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Run both apps using the entrypoint script
ENTRYPOINT ["./entrypoint.sh"]