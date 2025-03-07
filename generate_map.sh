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

# Generate the Minecraft map using local Overviewer
echo "Starting map generation..."
python "$OVERVIEWER_PATH/overviewer.py" --config="$CONFIG_PATH"

# Check if generation was successful
if [ $? -ne 0 ]; then
    echo "Error: Map generation failed."
    if [ "$BUILD_MODE" = true ]; then
        exit 1
    fi
else
    echo "Map generation complete."

    # If this is not build mode, we're done and nginx will be started by CMD
    if [ "$BUILD_MODE" = false ]; then
        echo "Exiting generate script, nginx will be started by CMD."
    fi
fi
