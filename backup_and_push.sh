#!/bin/bash

# Set variables
SOURCE="/var/lib/docker/volumes/minecraft_server_data/_data/aboba"
REPO_DIR="/home/timmy/minecraft_map"
DEST="$REPO_DIR/map_backup"
LOG_FILE="/home/timmy/copy_world.log"

# Log start time
echo "Starting world backup at $(date)" >> $LOG_FILE

# Check if source exists
if [ ! -d "$SOURCE" ]; then
    echo "Error: Source directory $SOURCE not found" >> $LOG_FILE
    exit 1
fi

# Navigate to repo directory
cd $REPO_DIR || { echo "Error: Cannot cd to $REPO_DIR" >> $LOG_FILE; exit 1; }

# Pull latest changes
git pull origin main >> $LOG_FILE 2>&1

# Empty the destination directory
if [ -d "$DEST" ]; then
    rm -rf "$DEST"/*
else
    mkdir -p "$DEST"
fi

# Copy the world and set ownership/permissions
cp -r "$SOURCE"/* "$DEST" >> $LOG_FILE 2>&1
if [ $? -eq 0 ]; then
    chown -R timmy:timmy "$DEST" >> $LOG_FILE 2>&1
    chmod -R u+rwX "$DEST" >> $LOG_FILE 2>&1
    echo "World copied successfully at $(date)" >> $LOG_FILE
else
    echo "World copy failed at $(date)" >> $LOG_FILE
    exit 1
fi

# Optional: Remove unnecessary files to reduce size (adjust as needed)
find "$DEST" -name "*.lock" -type f -delete
find "$DEST" -name "session.lock" -type f -delete
find "$DEST" -path "*/stats/*" -type f -delete
find "$DEST" -path "*/advancements/*" -type f -delete

# Push changes to GitHub
git add map_backup
git commit -m "Daily map backup $(date)" >> $LOG_FILE 2>&1
git push origin main >> $LOG_FILE 2>&1
if [ $? -eq 0 ]; then
    echo "Map pushed to GitHub successfully at $(date)" >> $LOG_FILE
else
    echo "GitHub push failed at $(date)" >> $LOG_FILE
fi
