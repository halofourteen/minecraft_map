#!/bin/bash

# Set variables - Change these for different server backups
VOLUME_NAME="minecraft_server_universal_data"
WORLD_NAME="aboba"
SOURCE="/var/lib/docker/volumes/${VOLUME_NAME}/_data/${WORLD_NAME}"
REPO_DIR="$HOME/minecraft_map"
DEST="$REPO_DIR/map_backup"

# Log start time
echo "Starting world backup at $(date)"
echo "Backing up world from: ${SOURCE}"

# Make sure the script is executable
chmod +x "$0"

# Navigate to repo directory
echo "Navigating to repository directory..."
cd "$REPO_DIR" || { echo "Error: Cannot cd to $REPO_DIR"; exit 1; }

# Handle Git more safely - stash any changes first
echo "Handling local Git changes..."
git stash
git pull origin main
git stash pop || true # Don't fail if there's nothing to pop

# Prepare destination directory
echo "Preparing destination directory..."
mkdir -p "$DEST"
rm -rf "$DEST"/*

# Copy directly from the volume (most reliable method)
echo "Copying Minecraft world files from volume..."
if [ -d "$SOURCE" ] && [ "$(ls -A "$SOURCE" 2>/dev/null)" ]; then
    sudo cp -r "$SOURCE"/* "$DEST"/
    sudo chown -R $(whoami):$(whoami) "$DEST"
    echo "World copied successfully from volume at $(date)"
else
    echo "Error: Cannot access Minecraft world data at ${SOURCE}. Please check the path and permissions."
    exit 1
fi

# Verify that files were actually copied
if [ ! "$(ls -A "$DEST" 2>/dev/null)" ]; then
    echo "Error: No files were copied to the destination directory. Backup failed."
    exit 1
fi

echo "Files in backup directory:"
ls -la "$DEST"

# Check for important dimension directories
echo "Checking for dimension directories..."
if [ -d "$DEST/DIM-1" ]; then
    echo "Found Nether dimension (DIM-1)"
    ls -la "$DEST/DIM-1"
else
    echo "Warning: Nether dimension (DIM-1) not found"
fi

if [ -d "$DEST/DIM1" ]; then
    echo "Found End dimension (DIM1)"
    ls -la "$DEST/DIM1"
else
    echo "Warning: End dimension (DIM1) not found"
fi

# Commit and push changes to GitHub
echo "Committing changes..."
git add map_backup
git add "*.sh"
git commit -m "Automated map backup $(date)"

# Only push if there were changes to commit
if [ $? -eq 0 ]; then
    echo "Pushing to GitHub..."
    git push origin main
    
    if [ $? -eq 0 ]; then
        echo "Map pushed to GitHub successfully at $(date)"
    else
        echo "GitHub push failed at $(date)"
        exit 1
    fi
else
    echo "No changes to commit. Skipping push."
fi