#!/bin/bash

current_directory=$(pwd)
INSTALL_DIR="/usr/local/bin"
SCRIPT_FILE="sound-timer.sh"
NEW_COMMAND="stimer"

echo "Making '$SCRIPT_FILE' an executable..."
chmod +x "$SCRIPT_FILE"

echo "Creating a soft link in '$INSTALL_DIR'..."
sudo rm -f "$INSTALL_DIR/$NEW_COMMAND"
sudo ln -s "$current_directory/$SCRIPT_FILE" "$INSTALL_DIR/$NEW_COMMAND"

echo "Making command '$NEW_COMMAND' accesible in this terminal session..."
hash -r

echo "Done! Now you can run '$NEW_COMMAND'"
