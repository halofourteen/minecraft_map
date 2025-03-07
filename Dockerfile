FROM python:3.9-slim

# Install dependencies for Overviewer
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    python3-imaging \
    python3-numpy \
    python3-pillow \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy repository contents
COPY . /app/

# Ensure scripts are executable
RUN chmod +x /app/*.sh

# Configure Nginx to serve static files
RUN rm /etc/nginx/sites-enabled/default
COPY nginx.conf /etc/nginx/sites-enabled/

# Run map generation during build using local Overviewer
RUN /app/generate_map.sh --build-mode

# Start nginx when container runs
CMD ["nginx", "-g", "daemon off;"]
