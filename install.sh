#!/bin/bash

# Load configuration file
CONFIG_FILE="./config.sh"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Error: Configuration file not found!"
    exit 1
fi

CURRENT_DIRECTORY=$(pwd)

install_pulseaudio() {
    echo "Installing dependency 'pulseaudio-utils'..."
    
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y pulseaudio-utils
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y pulseaudio-utils
    elif command -v pacman &> /dev/null; then
        sudo pacman -Sy --noconfirm pulseaudio
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y pulseaudio-utils
    else
        echo "Error: Could not detect package manager. Please install 'pulseaudio-utils' manually."
        exit 1
    fi

    # Verify if installation was successful
    if ! command -v paplay &> /dev/null; then
        echo "Error: Failed to install 'pulseaudio-utils'. Please install it manually."
        exit 1
    fi

    echo "'pulseaudio-utils' installed successfully!"
}

# Check if pulseaudio is installed, install it if missing
if ! command -v paplay &> /dev/null; then
    install_pulseaudio
fi

echo "Making '$SCRIPT_FILE' an executable..."
chmod +x "$SCRIPT_FILE"

echo "Creating a soft link in '$INSTALL_DIRECTORY'..."
sudo rm -f "$INSTALL_DIRECTORY/$NEW_COMMAND"
sudo ln -s "$CURRENT_DIRECTORY/$SCRIPT_FILE" "$INSTALL_DIRECTORY/$NEW_COMMAND"

echo "Making command '$NEW_COMMAND' accesible in this terminal session..."
hash -r

echo "Done! Now you can run '$NEW_COMMAND'"
