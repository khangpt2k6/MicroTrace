from flask import Flask, jsonify
import time
import os

app = Flask(__name__)

# Configuration from environment variables
FLASK_PORT = int(os.getenv('FLASK_PORT', 5000))
FLASK_HOST = os.getenv('FLASK_HOST', '0.0.0.0')

@app.route('/', methods=['GET'])
def home():
    return jsonify({
        'status': 'ok',
        'message': 'Web server is running',
        'pid': os.getpid(),
        'timestamp': time.time()
    }), 200

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        'healthy': True,
        'pid': os.getpid(),
        'timestamp': time.time()
    }), 200

@app.route('/compute', methods=['GET'])
def compute():
    start = time.time()
    result = sum(i for i in range(100000))
    elapsed = time.time() - start
    return jsonify({
        'result': result,
        'processing_time_ms': elapsed * 1000,
        'pid': os.getpid(),
        'timestamp': time.time()
    }), 200

@app.route('/info', methods=['GET'])
def info():
    return jsonify({
        'app': 'Flask Web Server',
        'version': '1.0',
        'purpose': 'CPU Contention Analysis',
        'pid': os.getpid(),
        'timestamp': time.time()
    }), 200

if __name__ == '__main__':
    print(f"[Flask Server] Starting on PID: {os.getpid()}")
    print(f"[Flask Server] Listening on {FLASK_HOST}:{FLASK_PORT}")
    app.run(host=FLASK_HOST, port=FLASK_PORT, debug=False, threaded=True)