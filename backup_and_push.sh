#!/bin/bash

# Set variables - this is the exact Docker volume path
SOURCE="/var/lib/docker/volumes/minecraft_server_data/_data/aboba"
REPO_DIR="/home/timmy/minecraft_map"
DEST="$REPO_DIR/map_backup"

# Log start time
echo "Starting world backup at $(date)"

# Make sure the script is executable
chmod +x "$0"

# Navigate to repo directory
echo "Navigating to repository directory..."
cd $REPO_DIR || { echo "Error: Cannot cd to $REPO_DIR"; exit 1; }

# Pull latest changes from GitHub preserving file permissions
echo "Pulling latest changes from GitHub..."
git config core.fileMode false  # Ignore permission changes
git pull origin main

# Make scripts executable again
chmod +x *.sh

# Prepare destination directory
echo "Preparing destination directory..."
if [ -d "$DEST" ]; then
    rm -rf "$DEST"/*
else
    mkdir -p "$DEST"
fi

# Copy the world files using sudo (required to access Docker volumes)
echo "Copying Minecraft world files using sudo..."
if sudo test -d "$SOURCE"; then
    sudo cp -r "$SOURCE"/* "$DEST"/

    # Change ownership to timmy
    sudo chown -R timmy:timmy "$DEST"
    chmod -R u+rwX "$DEST"
    echo "World copied successfully at $(date)"
else
    echo "Error: Source directory $SOURCE not accessible or doesn't exist."
    echo "Please make sure the path is correct and you have sudo rights."
    exit 1
fi

# Remove unnecessary files to reduce size
echo "Removing unnecessary files to reduce size..."
find "$DEST" -name "*.lock" -type f -delete
find "$DEST" -name "session.lock" -type f -delete
find "$DEST" -path "*/stats/*" -type f -delete
find "$DEST" -path "*/advancements/*" -type f -delete

# Commit and push changes to GitHub
echo "Committing changes..."
git add map_backup
git add "*.sh"  # Make sure our scripts are added with executable permission
git commit -m "Daily map backup $(date)"

echo "Pushing to GitHub..."
git push origin main

if [ $? -eq 0 ]; then
    echo "Map pushed to GitHub successfully at $(date)"
else
    echo "GitHub push failed at $(date)"
    exit 1
fi
