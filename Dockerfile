FROM python:3.9-slim

# Install dependencies for Overviewer
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    python3-numpy \
    python3-pillow \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy repository contents
COPY . /app/

# Ensure scripts and executables are executable
RUN chmod +x /app/*.sh && \
    chmod +x /app/overviwer/overviewer

# Configure Nginx to serve static files
RUN rm /etc/nginx/sites-enabled/default
COPY nginx.conf /etc/nginx/sites-enabled/

# Set environment variables for Overviewer
ENV PYTHONUNBUFFERED=1
ENV OVERVIEWER_PROCESSES=1
ENV OVERVIEWER_MAX_MEMORY=2048

# Create a fallback index.html in case map generation fails
RUN mkdir -p /app/map && \
    echo '<!DOCTYPE html><html><head><title>Minecraft Map</title><style>body{font-family:Arial,sans-serif;text-align:center;margin-top:50px;}</style></head><body><h1>Minecraft Map</h1><p>Map generation is in progress. Please check back later.</p></body></html>' > /app/map/index.html

# Run map generation during build using local Overviewer
RUN /app/generate_map.sh --build-mode || true

# Start nginx when container runs
CMD ["nginx", "-g", "daemon off;"]
