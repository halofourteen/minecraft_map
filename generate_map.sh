#!/bin/bash

# Check if the script is running in build mode
BUILD_MODE=false
if [[ "$1" == "--build-mode" ]]; then
    BUILD_MODE=true
fi

# Check if the map_backup directory has files
if [ -z "$(ls -A /app/map_backup 2>/dev/null)" ]; then
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

# Generate the Minecraft map using Overviewer
echo "Starting map generation..."
overviewer.py --config=/app/overviewer.conf

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
