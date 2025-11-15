"""Gunicorn configuration file"""

# Server Socket
bind = "0.0.0.0:5000"

# Worker Processes
workers = 2
threads = 4
worker_class = "gthread"

# Timeouts
timeout = 60
keepalive = 5

# Logging
accesslog = "-"
errorlog = "-"
loglevel = "info"

# Performance
max_requests = 1000
max_requests_jitter = 50

# Process Naming
proc_name = "flask-gitops-app"
