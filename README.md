# Minecraft Map Generator

This repository contains scripts and configuration for automatically backing up a Minecraft world and generating an interactive map using the Overviewer tool.

## System Overview

This project involves two servers:

1. **Minecraft Server**: Runs the Minecraft server and periodically backs up the world data to this repository.
2. **Map Server**: Pulls the world data from this repository and generates an interactive map using Overviewer.

## Setup Instructions

### Minecraft Server Setup

1. Clone this repository:

    ```bash
    git clone https://github.com/halofourteen/minecraft_map.git
    cd minecraft_map
    ```

2. Configure Git credentials (for automated pushing):

    ```bash
    git config --global user.name "Your Name"
    git config --global user.email "your.email@example.com"
    ```

3. Set up SSH keys for passwordless GitHub access:

    ```bash
    ssh-keygen -t ed25519 -C "your.email@example.com"
    cat ~/.ssh/id_ed25519.pub
    ```

    Add this key to your GitHub account settings.

4. Test SSH connection:

    ```bash
    ssh -T git@github.com
    ```

5. Configure the backup script for your Minecraft server:

    First, identify the correct path to your Minecraft world data:

    ```bash
    # Find your Minecraft container ID
    docker ps

    # Inspect the container to find the volume mount points
    docker inspect YOUR_CONTAINER_ID | grep -A 10 "Mounts"

    # Check the world directory inside the container
    docker exec YOUR_CONTAINER_ID ls -la /minecraft
    ```

    Then edit the `backup_and_push.sh` script if needed to update the paths:

    ```bash
    # Open the script in your favorite editor
    nano backup_and_push.sh

    # Update the SOURCE variable if your volume path is different
    # Update the WORLD_PATH variable if your world is in a different location
    ```

6. Make the backup script executable:

    ```bash
    chmod +x backup_and_push.sh
    ```

7. Set up a cron job to run the backup script periodically:
    ```bash
    crontab -e
    ```
    Add the following line to run the backup daily at 3 AM:
    ```
    0 3 * * * /path/to/minecraft_map/backup_and_push.sh >> /path/to/minecraft_map/backup.log 2>&1
    ```

### Map Server Setup

1. Clone this repository:

    ```bash
    git clone https://github.com/halofourteen/minecraft_map.git
    cd minecraft_map
    ```

2. Install Docker and Docker Compose:

    ```bash
    # For Ubuntu/Debian
    sudo apt update
    sudo apt install docker.io docker-compose
    ```

3. Set up a webhook or cron job to pull changes and rebuild the map:

    Option 1: Using a cron job:

    ```bash
    crontab -e
    ```

    Add the following line to check for updates every hour:

    ```
    0 * * * * cd /path/to/minecraft_map && git pull && docker-compose up -d --build
    ```

    Option 2: Using a webhook (more efficient):
    Install a webhook service like [webhook](https://github.com/adnanh/webhook) and configure it to pull and rebuild when GitHub sends a push notification.

4. Start the map server:
    ```bash
    docker-compose up -d
    ```

## How It Works

### Backup Process (Minecraft Server)

1. The `backup_and_push.sh` script runs on the Minecraft server.
2. It copies the world data from the Minecraft server's Docker volume.
3. It removes unnecessary files to reduce size.
4. It commits and pushes the changes to this GitHub repository.

### Map Generation Process (Map Server)

1. The Map Server detects changes to the repository.
2. It pulls the latest world data.
3. It runs the Overviewer tool to generate an interactive map.
4. It serves the map via a web server.

## Troubleshooting

### Backup Issues

-   **Permission denied**: Make sure the user running the script has access to the Docker volume or container.
-   **Git push fails**: Verify SSH keys are set up correctly and the user has write access to the repository.
-   **No files copied**: Check if the world path in the script matches your Minecraft server's configuration. Run the script with `bash -x backup_and_push.sh` to see detailed debugging information.
-   **Container path issues**: Different Minecraft server images use different paths for the world data. Common paths include:
    -   `/minecraft/world`
    -   `/minecraft/server/world`
    -   `/data/world`
    -   `/minecraft`

### Map Generation Issues

-   **Map not updating**: Check if the Docker container is running and if the webhook/cron job is working.
-   **Missing textures**: Ensure the Minecraft assets are correctly mounted in the container.

## Customization

-   Edit `overviewer.conf` to customize map rendering options.
-   Modify `nginx.conf` to change web server settings.
-   Adjust `backup_and_push.sh` if your Minecraft server uses a different volume path.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
