FROM python:3.9-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    python3-imaging \
    python3-numpy \
    python3-pillow \
    nginx \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Minecraft Overviewer
RUN git clone https://github.com/overviewer/Minecraft-Overviewer.git /tmp/overviewer \
    && cd /tmp/overviewer \
    && python3 setup.py build \
    && python3 setup.py install \
    && cd / \
    && rm -rf /tmp/overviewer

# Set working directory
WORKDIR /app

# Copy repository contents
COPY . /app/

# Configure Nginx to serve static files
RUN rm /etc/nginx/sites-enabled/default
COPY nginx.conf /etc/nginx/sites-enabled/

# Make the generate script executable
RUN chmod +x /app/generate_map.sh

# Run map generation during build
RUN /app/generate_map.sh --build-mode

# Start nginx when container runs
CMD ["nginx", "-g", "daemon off;"]
