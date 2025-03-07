#!/bin/bash

# Check if the script is running in build mode
BUILD_MODE=false
if [[ "$1" == "--build-mode" ]]; then
    BUILD_MODE=true
fi

# Set paths
OVERVIEWER_PATH="/app/overviwer"
CONFIG_PATH="/app/overviewer.conf"
MAP_BACKUP_PATH="/app/map_backup"
MAP_OUTPUT_PATH="/app/map"

# Check if the map_backup directory has files
if [ -z "$(ls -A $MAP_BACKUP_PATH 2>/dev/null)" ]; then
    echo "Error: No world files found in map_backup directory."
    if [ "$BUILD_MODE" = true ]; then
        echo "This is build mode, exiting with error."
        exit 1
    else
        echo "Will retry later."
        sleep 60
        exit 0
    fi
fi

# Add Overviewer to Python path
export PYTHONPATH="$OVERVIEWER_PATH:$PYTHONPATH"

# Set the number of processes to use (default to 1 if not set)
PROCESSES=${OVERVIEWER_PROCESSES:-1}

# Set the maximum memory to use (default to 2048 if not set)
MAX_MEMORY=${OVERVIEWER_MAX_MEMORY:-2048}

# Create the map directory if it doesn't exist
mkdir -p "$MAP_OUTPUT_PATH"

# Generate the Minecraft map using local Overviewer
echo "Starting map generation with $PROCESSES processes and ${MAX_MEMORY}MB memory limit..."
echo "Using world files from: $MAP_BACKUP_PATH"
echo "Output directory: $MAP_OUTPUT_PATH"

# Use the executable directly with process and memory limits
"$OVERVIEWER_PATH/overviewer" --config="$CONFIG_PATH" --processes=$PROCESSES

# Check if generation was successful
if [ $? -ne 0 ]; then
    echo "Error: Map generation failed."
    
    # Create a simple index.html if map generation failed but we're in build mode
    if [ "$BUILD_MODE" = true ]; then
        echo "Creating a placeholder index.html..."
        mkdir -p "$MAP_OUTPUT_PATH"
        cat > "$MAP_OUTPUT_PATH/index.html" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Minecraft Map</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
    </style>
</head>
<body>
    <h1>Minecraft Map</h1>
    <p>Map generation is in progress. Please check back later.</p>
</body>
</html>
EOF
        echo "Created placeholder index.html"
        # Exit with success so the build can continue
        exit 0
    else
        exit 1
    fi
else
    echo "Map generation complete."

    # If this is not build mode, we're done and nginx will be started by CMD
    if [ "$BUILD_MODE" = false ]; then
        echo "Exiting generate script, nginx will be started by CMD."
    fi
fi
