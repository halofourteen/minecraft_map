#!/bin/bash

# Set variables
SOURCE="/var/lib/docker/volumes/minecraft_server_data/_data/aboba"
REPO_DIR="$HOME/minecraft_map"
DEST="$REPO_DIR/map_backup"

# Log start time
echo "Starting world backup at $(date)"

# Make sure the script is executable
chmod +x "$0"

# Navigate to repo directory
echo "Navigating to repository directory..."
cd "$REPO_DIR" || { echo "Error: Cannot cd to $REPO_DIR"; exit 1; }

# Pull latest changes from GitHub
echo "Pulling latest changes from GitHub..."
git pull origin main

# Prepare destination directory
echo "Preparing destination directory..."
mkdir -p "$DEST"
rm -rf "$DEST"/*

# Copy the world files using docker cp instead of direct volume access
# This is more secure and avoids permission issues
echo "Copying Minecraft world files..."
CONTAINER_ID=$(docker ps -qf "volume=minecraft_server_data")

if [ -n "$CONTAINER_ID" ]; then
    # If container is running, use docker cp
    docker cp "$CONTAINER_ID:/data/aboba/." "$DEST/"
    echo "World copied successfully using docker cp at $(date)"
elif [ -d "$SOURCE" ]; then
    # Fallback to direct volume access if needed
    sudo cp -r "$SOURCE"/* "$DEST"/
    sudo chown -R $(whoami):$(whoami) "$DEST"
    echo "World copied successfully using direct volume access at $(date)"
else
    echo "Error: Cannot access Minecraft world data. Container not found and source directory not accessible."
    exit 1
fi

# Remove unnecessary files to reduce size
echo "Removing unnecessary files to reduce size..."
find "$DEST" -name "*.lock" -type f -delete
find "$DEST" -name "session.lock" -type f -delete
find "$DEST" -path "*/stats/*" -type f -delete
find "$DEST" -path "*/advancements/*" -type f -delete
find "$DEST" -path "*/playerdata/*" -type f -delete

# Commit and push changes to GitHub
echo "Committing changes..."
git add map_backup
git add "*.sh"
git commit -m "Automated map backup $(date)"

echo "Pushing to GitHub..."
git push origin main

if [ $? -eq 0 ]; then
    echo "Map pushed to GitHub successfully at $(date)"
else
    echo "GitHub push failed at $(date)"
    exit 1
fi
