FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ .

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PORT=5000

# Expose port
EXPOSE 5000

# Run the application
CMD ["python3", "app.py"]
