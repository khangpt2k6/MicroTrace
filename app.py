from flask import Flask, jsonify
import time
import os

app = Flask(__name__)

@app.route('/', methods=['GET'])
def home():
    """Simple health check endpoint"""
    return jsonify({
        'status': 'ok',
        'message': 'Web server is running',
        'pid': os.getpid(),
        'timestamp': time.time()
    }), 200

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        'healthy': True,
        'pid': os.getpid(),
        'timestamp': time.time()
    }), 200

@app.route('/compute', methods=['GET'])
def compute():
    """Lightweight computation endpoint"""
    result = sum(i for i in range(100000))
    return jsonify({
        'result': result,
        'pid': os.getpid(),
        'timestamp': time.time()
    }), 200

@app.route('/info', methods=['GET'])
def info():
    """Returns server info"""
    return jsonify({
        'app': 'Flask Web Server',
        'version': '1.0',
        'purpose': 'CPU Contention Analysis',
        'pid': os.getpid(),
        'timestamp': time.time()
    }), 200

if __name__ == '__main__':
    print(f"[Flask Server] Starting on PID: {os.getpid()}")
    app.run(host='0.0.0.0', port=5000, debug=False, threaded=True)