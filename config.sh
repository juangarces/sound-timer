# ------------------------------------------
# This file is imported inside a few files
# ------------------------------------------

# Run install.sh if you change name of command
NEW_COMMAND="stimer"
INSTALL_DIRECTORY="/usr/local/bin"
SCRIPT_FILE="sound-timer.sh"

# Define the process ID file
PID_FILE="/tmp/sound-timer.pid"
LOG_FILE="/tmp/sound-timer.log"

logging_enabled="false"
advance_seconds=0
