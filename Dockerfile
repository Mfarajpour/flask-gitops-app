# ============================================
# Stage 1: Builder - Build Dependencies
# ============================================
FROM python:3.11-alpine AS builder

WORKDIR /build

# Install build dependencies (temporary)
RUN apk add --no-cache \
    gcc \
    musl-dev \
    linux-headers

# Copy requirements file
COPY app/requirements.txt .

# Install Python packages to isolated location
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt 
    

# ============================================
# Stage 2: Runtime - Minimal Production Image
# ============================================
FROM python:3.11-alpine

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=5000

# Set working directory
WORKDIR /app

# Copy installed packages from builder stage
COPY --from=builder /install /usr/local

# Copy application code
COPY app/ .

# Create non-root user for security
RUN adduser -D -u 1000 appuser && \
    chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 5000

# Run application with Gunicorn
CMD ["gunicorn", "--config", "gunicorn_config.py", "app:app"]
