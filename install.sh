#!/bin/bash

# Load configuration file
CONFIG_FILE="./config.sh"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Error: Configuration file not found!"
    exit 1
fi

current_directory=$(pwd)
INSTALL_DIR="/usr/local/bin"

echo "Making '$SCRIPT_FILE' an executable..."
chmod +x "$SCRIPT_FILE"

echo "Creating a soft link in '$INSTALL_DIR'..."
sudo rm -f "$INSTALL_DIR/$NEW_COMMAND"
sudo ln -s "$current_directory/$SCRIPT_FILE" "$INSTALL_DIR/$NEW_COMMAND"

echo "Making command '$NEW_COMMAND' accesible in this terminal session..."
hash -r

echo "Done! Now you can run '$NEW_COMMAND'"
