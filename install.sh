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

echo "Making '$SCRIPT_FILE' an executable..."
chmod +x "$SCRIPT_FILE"

echo "Creating a soft link in '$INSTALL_DIRECTORY'..."
sudo rm -f "$INSTALL_DIRECTORY/$NEW_COMMAND"
sudo ln -s "$CURRENT_DIRECTORY/$SCRIPT_FILE" "$INSTALL_DIRECTORY/$NEW_COMMAND"

echo "Making command '$NEW_COMMAND' accesible in this terminal session..."
hash -r

echo "Done! Now you can run '$NEW_COMMAND'"
