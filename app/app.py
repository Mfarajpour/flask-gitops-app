"""
Flask GitOps Demo Application
A simple REST API to demonstrate GitOps workflow
"""

from flask import Flask, jsonify, request
import os
import socket
from datetime import datetime

app = Flask(__name__)

# Configuration from environment variables
APP_VERSION = os.getenv('APP_VERSION', '1.0.0')
ENVIRONMENT = os.getenv('ENVIRONMENT', 'development')

@app.route('/')
def home():
    """
    Home endpoint - returns basic app info
    """
    return jsonify({
        'message': 'Welcome to Flask GitOps App!',
        'version': APP_VERSION,
        'environment': ENVIRONMENT,
        'status': 'running'
    })

@app.route('/health')
def health():
    """
    Health check endpoint for Kubernetes probes
    Returns 200 if app is healthy
    """
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'version': APP_VERSION
    }), 200

@app.route('/ready')
def ready():
    """
    Readiness probe endpoint for Kubernetes
    Returns 200 when app is ready to serve traffic
    """
    return jsonify({
        'status': 'ready',
        'timestamp': datetime.now().isoformat()
    }), 200

@app.route('/info')
def info():
    """
    Returns detailed information about the application
    """
    return jsonify({
        'app_name': 'Flask GitOps Demo',
        'version': APP_VERSION,
        'environment': ENVIRONMENT,
        'hostname': socket.gethostname(),
        'timestamp': datetime.now().isoformat(),
        'endpoints': [
            '/',
            '/health',
            '/ready',
            '/info',
            '/api/data'
        ]
    })

@app.route('/api/data', methods=['GET', 'POST'])
def api_data():
    """
    Sample API endpoint
    GET: returns sample data
    POST: accepts and echoes back JSON data
    """
    if request.method == 'POST':
        data = request.get_json()
        return jsonify({
            'message': 'Data received successfully',
            'received_data': data,
            'timestamp': datetime.now().isoformat()
        }), 201
    else:
        return jsonify({
            'message': 'Sample data endpoint',
            'data': [
                {'id': 1, 'name': 'Item 1'},
                {'id': 2, 'name': 'Item 2'},
                {'id': 3, 'name': 'Item 3'}
            ],
            'count': 3
        })

@app.errorhandler(404)
def not_found(error):
    """
    Custom 404 error handler
    """
    return jsonify({
        'error': 'Not Found',
        'message': 'The requested endpoint does not exist',
        'status': 404
    }), 404

@app.errorhandler(500)
def internal_error(error):
    """
    Custom 500 error handler
    """
    return jsonify({
        'error': 'Internal Server Error',
        'message': 'Something went wrong',
        'status': 500
    }), 500

if __name__ == '__main__':
    # Run the Flask app
    # In production, use gunicorn or uwsgi
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
