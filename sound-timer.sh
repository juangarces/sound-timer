#!/bin/bash

# Resolve symlinks and get the directory of the original script
COMMAND_LINK_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIRECTORY="$(dirname "$COMMAND_LINK_PATH")"

import_file() {
    file=$1
    if [ -f "$file" ]; then
        source "$file"
    else
        echo "Error: $file file not found!"
        exit 1
    fi
}

CONFIG_FILE="$SCRIPT_DIRECTORY/config.sh"
import_file $CONFIG_FILE

show_help() {
    echo "Usage: $NEW_COMMAND {start|stop|status} [-l] [-h]"
    echo
    echo "Options:"
    echo "  -l          Enable logging to $LOG_FILE"
    echo "  -h, --help  Show this help message and exit"
    echo
    echo "Commands:"
    echo "  start       Start the sound timer"
    echo "  stop        Stop the sound timer"
    echo "  status      Check if the timer is running"
    exit 0
}

parse_options() {
    local command=$1
    shift

    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -l)
                if [[ $command != "start" ]]; then
                    echo "Error: -l is only valid for 'start' command." >&2
                    show_help
                    exit 1
                fi

                LOGGING_ENABLED="true"
                echo "Logging enabled."
                ;;
            -h|--help)
                show_help
                exit 1
                ;;
            *)
                echo "Unknown option for '$command': $1" >&2
                show_help
                exit 1
                ;;
        esac
        shift
    done
}

check_script_running() {
    if [ -f "$PID_FILE" ]; then
        echo "Sound Timer is already running! Use '$NEW_COMMAND stop' to stop it."
        exit 1
    fi
}

sleep_until_next_minute() {
    # Wait until the next full minute (X:XX:00)
    current_second=$(date +%S)
    sleep $((60 - current_second))		
}

log_time() {
    if [[ "$LOGGING_ENABLED" == "true" ]]; then
        tag=$1
        CURRENT_TIME=$2
        echo "$tag: $CURRENT_TIME" >> "$LOG_FILE"
    fi
}

play_sound() {
    FILE_NAME=$1
    paplay "$SCRIPT_DIRECTORY/sounds/$FILE_NAME.wav"
}

start_script() {
    check_script_running
    echo "Sound timer running..."

    run_timer() {
        sleep_until_next_minute

        while true; do
            CURRENT_TIME=$(date)
            MINUTE=$(date +%M)

            if (( MINUTE % 15 == 0 )); then
                log_time "15 minutes" "$CURRENT_TIME"
                play_sound 15
            elif (( MINUTE % 5 == 0 )); then
                log_time "5 minutes" "$CURRENT_TIME"
                play_sound 5
            else
                log_time "1 minute" "$CURRENT_TIME"
                play_sound 1
            fi

            sleep_until_next_minute
        done
    }

    # Run the timer in the background
    run_timer >> "$LOG_FILE" 2>&1 &

    # Get the PID of the background process
    TIMER_PID=$!

    # Disown the process so it continues running after the terminal is closed
    disown

    echo "$TIMER_PID" > "$PID_FILE"

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
        echo "Sound Timer is not running. Run '$NEW_COMMAND start'"
    fi
}

# Main script logic
if [[ $# -lt 1 ]]; then
    show_help
    exit 1
fi

case $1 in
    start)
        shift # Remove 'start' from arguments
        parse_options "start" "$@"
        start_script
        ;;
    stop)
        shift # Remove 'stop' from arguments
        parse_options "stop" "$@"
        stop_script
        ;;
    status)
        shift # Remove 'status' from arguments
        parse_options "status" "$@"
        status_script
        ;;
    -h|--help)
        show_help
        ;;
    *)
        echo "Unknown command: $1" >&2
        show_help
        exit 1
        ;;
esac