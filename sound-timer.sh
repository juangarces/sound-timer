#!/bin/bash

# Load configuration file
CONFIG_FILE="./config.sh"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Error: Configuration file not found!"
    exit 1
fi

start_script() {
    # Check if already running
    if [ -f "$PID_FILE" ]; then
        echo "Sound Timer is already running! Use './sound-timer.sh stop' to stop it."
        exit 1
    fi

    echo "Sound timer running..."

	# No hang up to keep running after closing terminal
    nohup bash -c '
		sleep_until_next_minute() {
			# Wait until the next full minute (X:XX:00)
			current_second=$(date +%S)
			sleep $((60 - current_second))		
		}
		# first time wait to start from second 0 
		sleep_until_next_minute

        while true; do
			# Uncomment to Log every iteration
			current_time=$(date)
            
			MINUTE=$(date +%M)
            if (( MINUTE % 15 == 0 )); then
				echo "15 minute: $current_time" >> "'"$LOG_FILE"'"
                paplay "'"$SOUND_15MIN"'"
            elif (( MINUTE % 5 == 0 )); then
				echo "5 minute: $current_time" >> "'"$LOG_FILE"'"
                paplay "'"$SOUND_5MIN"'"
            else
				echo "1 minute: $current_time" >> "'"$LOG_FILE"'"
                paplay "'"$SOUND_1MIN"'"
            fi

            sleep_until_next_minute
        done
	' >> "$LOG_FILE" 2>&1 & echo $! > "$PID_FILE"
    
	# echo "Script started with PID $(cat $PID_FILE)."
}

stop_script() {
    # Stop the script if running
    if [ -f "$PID_FILE" ]; then
        kill "$(cat $PID_FILE)" 2>/dev/null
        rm -f "$PID_FILE"
        echo "Sound Timer stopped."
    else
        echo "Sound Timer is not running!"
    fi
}

status_script() {
    if [ -f "$PID_FILE" ] && ps -p "$(cat $PID_FILE)" > /dev/null 2>&1; then
        echo "Sound Timer is running with PID $(cat $PID_FILE)."
    else
        echo "Sound Timer is not running."
    fi
}

case "$1" in
    start)
        start_script
        ;;
    stop)
        stop_script
        ;;
    status)
        status_script
        ;;
    *)
        echo "Usage: $0 {start|stop|status}"
        exit 1
        ;;
esac
