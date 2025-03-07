#!/bin/bash

# Set variables
SOURCE="/var/lib/docker/volumes/minecraft_server_data/_data/aboba"
REPO_DIR="/home/timmy/minecraft_map"
DEST="$REPO_DIR/map_backup"

# Log start time
echo "Starting world backup at $(date)"

# Check if source exists
if [ ! -d "$SOURCE" ]; then
    echo "Error: Source directory $SOURCE not found"
    echo "Checking for other potential locations..."

    # Look for other possible locations
    FOUND=false
    for DIR in /var/lib/docker/volumes/*/; do
        if ls "$DIR/_data" 2>/dev/null | grep -q "world\|server.properties"; then
            echo "Potential Minecraft data found in: $DIR"
            POSSIBLE_WORLDS=$(find "$DIR/_data" -type d -name "world" -o -name "aboba" -o -name "*world*")
            if [ -n "$POSSIBLE_WORLDS" ]; then
                echo "Possible world directories:"
                echo "$POSSIBLE_WORLDS"
                FOUND=true
            fi
        fi
    done

    if [ "$FOUND" = false ]; then
        echo "No potential Minecraft worlds found in Docker volumes."
        echo "Please specify the correct path by editing the SOURCE variable in this script."
    fi

    exit 1
fi

# Navigate to repo directory
echo "Navigating to repository directory..."
cd $REPO_DIR || { echo "Error: Cannot cd to $REPO_DIR"; exit 1; }

# Pull latest changes using timmy user
echo "Pulling latest changes from GitHub..."
if [ "$(id -u)" = "0" ]; then
    # If running as root, use sudo to run git commands as timmy
    sudo -u timmy git pull origin main
else
    # If running as timmy already, just run git directly
    git pull origin main
fi

# Empty the destination directory
echo "Preparing destination directory..."
if [ -d "$DEST" ]; then
    rm -rf "$DEST"/*
else
    mkdir -p "$DEST"
fi

# Copy the world and set ownership/permissions
echo "Copying Minecraft world files..."
cp -r "$SOURCE"/* "$DEST"
if [ $? -eq 0 ]; then
    # Set ownership to timmy
    chown -R timmy:timmy "$DEST"
    chmod -R u+rwX "$DEST"
    echo "World copied successfully at $(date)"
else
    echo "World copy failed at $(date)"
    exit 1
fi

# Optional: Remove unnecessary files to reduce size
echo "Removing unnecessary files to reduce size..."
find "$DEST" -name "*.lock" -type f -delete
find "$DEST" -name "session.lock" -type f -delete
find "$DEST" -path "*/stats/*" -type f -delete
find "$DEST" -path "*/advancements/*" -type f -delete

# Push changes to GitHub using timmy user
echo "Committing changes..."
if [ "$(id -u)" = "0" ]; then
    # If running as root, use sudo to run git commands as timmy
    sudo -u timmy git add map_backup
    sudo -u timmy git commit -m "Daily map backup $(date)"

    echo "Pushing to GitHub..."
    sudo -u timmy git push origin main
else
    # If running as timmy already, just run git directly
    git add map_backup
    git commit -m "Daily map backup $(date)"

    echo "Pushing to GitHub..."
    git push origin main
fi

if [ $? -eq 0 ]; then
    echo "Map pushed to GitHub successfully at $(date)"
else
    echo "GitHub push failed at $(date)"
    echo "This could be due to authentication issues or network problems."
    exit 1
fi
