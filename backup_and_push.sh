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
    # First, check if the world directory exists in the container
    WORLD_PATH="/minecraft/aboba"
    
    # Check if the world directory exists in the container
    if docker exec "$CONTAINER_ID" test -d "$WORLD_PATH"; then
        echo "Found world at $WORLD_PATH in container $CONTAINER_ID"
        docker cp "$CONTAINER_ID:$WORLD_PATH/." "$DEST/"
        
        # Verify the copy was successful
        if [ $? -eq 0 ] && [ "$(ls -A "$DEST" 2>/dev/null)" ]; then
            echo "World copied successfully using docker cp at $(date)"
        else
            echo "Error: Docker cp command failed or no files were copied."
            echo "Trying direct volume access as fallback..."
            if [ -d "$SOURCE" ] && [ "$(ls -A "$SOURCE" 2>/dev/null)" ]; then
                sudo cp -r "$SOURCE"/* "$DEST"/
                sudo chown -R $(whoami):$(whoami) "$DEST"
                echo "World copied successfully using direct volume access at $(date)"
            else
                echo "Error: Both docker cp and direct volume access failed. Cannot access world data."
                exit 1
            fi
        fi
    else
        echo "World directory not found at $WORLD_PATH in container. Checking other common paths..."
        
        # Try to find the world directory by listing common Minecraft server paths
        POSSIBLE_PATHS=("/minecraft" "/minecraft/world" "/minecraft/server/world" "/data/world" "/data")
        FOUND=false
        
        for PATH_TO_CHECK in "${POSSIBLE_PATHS[@]}"; do
            echo "Checking $PATH_TO_CHECK..."
            if docker exec "$CONTAINER_ID" test -d "$PATH_TO_CHECK"; then
                echo "Found potential world directory at $PATH_TO_CHECK"
                # List contents to help identify the world directory
                docker exec "$CONTAINER_ID" ls -la "$PATH_TO_CHECK"
                FOUND=true
            fi
        done
        
        if [ "$FOUND" = false ]; then
            echo "Could not find world directory in container. Trying direct volume access..."
        fi
        
        # Try direct volume access as fallback
        if [ -d "$SOURCE" ] && [ "$(ls -A "$SOURCE" 2>/dev/null)" ]; then
            sudo cp -r "$SOURCE"/* "$DEST"/
            sudo chown -R $(whoami):$(whoami) "$DEST"
            echo "World copied successfully using direct volume access at $(date)"
        else
            echo "Error: Cannot access Minecraft world data. Please check the paths and permissions."
            exit 1
        fi
    fi
elif [ -d "$SOURCE" ] && [ "$(ls -A "$SOURCE" 2>/dev/null)" ]; then
    # Fallback to direct volume access if needed
    sudo cp -r "$SOURCE"/* "$DEST"/
    sudo chown -R $(whoami):$(whoami) "$DEST"
    echo "World copied successfully using direct volume access at $(date)"
else
    echo "Error: Cannot access Minecraft world data. Container not found and source directory not accessible."
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

# Remove only unnecessary files to reduce size
# DO NOT remove any dimension directories or their contents
echo "Removing only unnecessary files to reduce size..."
find "$DEST" -name "*.lock" -type f -delete
find "$DEST" -name "session.lock" -type f -delete

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
