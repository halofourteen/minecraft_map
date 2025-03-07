#!/bin/bash

# Set variables
SOURCE="/var/lib/docker/volumes/minecraft_server_data/_data/aboba"
REPO_DIR="/home/timmy/minecraft_map"
DEST="$REPO_DIR/map_backup"

# Log start time
echo "Starting world backup at $(date)"

# Check if running as root and switch to timmy if needed
if [ "$(id -u)" = "0" ]; then
    echo "This script should be run as timmy, not root."
    echo "Please run: sudo chown -R timmy:timmy ~/minecraft_map"
    echo "Then run: chmod +x ~/minecraft_map/*.sh"
    echo "Then try again without sudo."
    exit 1
fi

# Check if source exists
if [ ! -d "$SOURCE" ]; then
    echo "Error: Source directory $SOURCE not found"
    echo "Checking for other potential locations..."

    # Look for other possible locations
    FOUND=false

    # Check common locations first
    COMMON_PATHS=(
        "/var/lib/docker/volumes/minecraft_data/_data"
        "/var/lib/docker/volumes/minecraft/_data"
        "/var/lib/docker/volumes/minecraft_server/_data"
        "/var/lib/docker/volumes/mc_server_data/_data"
    )

    for PATH in "${COMMON_PATHS[@]}"; do
        if [ -d "$PATH" ]; then
            echo "Found potential Minecraft data at: $PATH"
            if ls "$PATH" | grep -q "world\|level.dat"; then
                echo "This looks like a Minecraft server directory!"
                echo "Update your script to use: SOURCE=\"$PATH\""
                FOUND=true
            fi
        fi
    done

    if [ "$FOUND" = false ]; then
        echo "Searching all Docker volumes (this may take a moment)..."
        for DIR in /var/lib/docker/volumes/*/; do
            if [ -d "$DIR/_data" ] && sudo ls "$DIR/_data" 2>/dev/null | grep -q "world\|server.properties"; then
                echo "Potential Minecraft data found in: $DIR"
                POSSIBLE_WORLDS=$(sudo find "$DIR/_data" -type d -name "world" -o -name "aboba" -o -name "*world*" 2>/dev/null)
                if [ -n "$POSSIBLE_WORLDS" ]; then
                    echo "Possible world directories:"
                    echo "$POSSIBLE_WORLDS"
                    FOUND=true
                fi
            fi
        done
    fi

    echo ""
    echo "Please edit this script and update the SOURCE variable at the top"
    echo "with the correct path to your Minecraft world."
    exit 1
fi

# Navigate to repo directory
echo "Navigating to repository directory..."
cd $REPO_DIR || { echo "Error: Cannot cd to $REPO_DIR"; exit 1; }

# Pull latest changes
echo "Pulling latest changes from GitHub..."
git pull origin main

# Empty the destination directory
echo "Preparing destination directory..."
if [ -d "$DEST" ]; then
    rm -rf "$DEST"/*
else
    mkdir -p "$DEST"
fi

# Copy the world - we might need sudo for this since it's in Docker volume dir
echo "Copying Minecraft world files..."
sudo cp -r "$SOURCE"/* "$DEST"
if [ $? -eq 0 ]; then
    # Set ownership to timmy
    sudo chown -R timmy:timmy "$DEST"
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

# Push changes to GitHub
echo "Committing changes..."
git add map_backup
git commit -m "Daily map backup $(date)"

echo "Pushing to GitHub..."
git push origin main

if [ $? -eq 0 ]; then
    echo "Map pushed to GitHub successfully at $(date)"
else
    echo "GitHub push failed at $(date)"
    echo "This could be due to authentication issues or network problems."
    exit 1
fi
