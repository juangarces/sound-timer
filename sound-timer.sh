#!/bin/bash
# set -x

# Resolve symlinks and get the directory of the original script
COMMAND_LINK_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIRECTORY="$(dirname "$COMMAND_LINK_PATH")"

FILES_TO_LOAD=("config.sh" "time-zones.sh")

for file in "${FILES_TO_LOAD[@]}"; do

	if [ -f "$SCRIPT_DIRECTORY/$file" ]; then
		source "$SCRIPT_DIRECTORY/$file"
	else
		echo "Error: $SCRIPT_DIRECTORY/$file file not found!"
		exit 1
	fi

done

show_help() {
    echo "Usage: $NEW_COMMAND {start|stop|status} [-h] [1|5|15|30|60|4h...] [-a=<seconds>] [-tz=<city>] [-l]"
    echo
    echo "Options:"
    echo "    -a, --advance   Specify seconds to advance notification"
    echo "    -l              Enable logging each interval to $LOG_FILE"
    echo "    -h, --help      Show this help message and exit"
	echo "    -tz             Choose a valid city time zone"
    echo
    echo "Commands:"
    echo "    start    Start the Sound Timer with 1, 5, 15, 30, 60 minute and 4 hour intervals"
    echo "    stop     Stop the Sound Timer"
    echo "    status   Check if the timer is running"
    echo
    echo "Example usage:"
    echo "    $NEW_COMMAND start 5 15                Start the Sound Timer with 5- and 15-minute intervals"
    echo "    $NEW_COMMAND start 4h -tz=newyork      Start the Sound Timer with a 4-hour interval using the New York timezone"
    exit 0
}

# Initialize all time intervals to false (0)
declare -A intervals_selected=( [1]=0 [5]=0 [15]=0 [30]=0 [60]=0 [4h]=0 )
found_interval=0

log_message() {
	if [[ "$logging_enabled" == "true" ]]; then
		local message=$1
		echo "$message" >> "$LOG_FILE"
	fi
}

log_value() {
	if [[ "$logging_enabled" == "true" ]]; then
		local tag=$1
		local value=$2
		echo "$tag: $value" >> "$LOG_FILE"
	fi
}

validate_start_option() {
	local command=$1
	local arg=$2

	if [[ $command != "start" ]]; then
		echo "Error: $arg is only valid for 'start' command." >&2
		show_help
		exit 1
	fi
}

list_timezones() {
	for city in $(printf "%s\n" "${!timezones[@]}" | sort); do # Sorted alphabetically
		echo "    $city"
	done
}

parse_options() {
	local command=$1
	shift

	# Loop through command-line arguments
	for arg in "$@"; do
		case $arg in
			-h|--help)
				show_help
				exit 1
				;;
			1|5|15|30|60|4h)
				validate_start_option "$command" "$arg"
				intervals_selected[$arg]=1
				found_interval=1
				;;
			-a|--advance)
				echo "Error: $arg requires a value. Usage: $arg=<number_below_60>" >&2
				show_help
				exit 1
				;;
			-a=*|--advance=*)
				validate_start_option "$command" "$arg"
				advance_seconds="${arg#*=}"

				# Validate advance_seconds is a number below 60
				if ! [[ "$advance_seconds" =~ ^[0-9]+$ ]] || (( advance_seconds >= 60 )); then
					echo "Error: Invalid value for $arg. Expected a number below 60 seconds, got '$advance_seconds'." >&2
					show_help
					exit 1
				fi

				echo "Notifications will play $advance_seconds seconds before each time interval"
				;;
			-tz)
				echo "Error: $arg requires a valid city name in lowercase without spaces. Example: $arg=newyork" >&2
				echo "Choose between these valid cities:"
				list_timezones
				exit 1
				;;
			-tz=*)
				validate_start_option "$command" "$arg"
				city="${arg#*=}"

				# Validate city name
				if [[ -v timezones["$city"] ]]; then
					echo "${timezones[$city]} timezone"
				else
					echo "City name is not valid. Please choose between one of these:"
					list_timezones
					exit 1
				fi
				;;
			-l)
				validate_start_option "$command" "$arg"
				logging_enabled="true"
				echo "Logging enabled."
				;;
			*)
				echo "Unknown option for '$command': $arg" >&2
				show_help
				exit 1
				;;
		esac
	done

	# if no interval in arguments, then select all
	if (( found_interval == 0 )); then
		intervals_selected[1]=1
		intervals_selected[5]=1
		intervals_selected[15]=1
		intervals_selected[30]=1
		intervals_selected[60]=1
		intervals_selected[4h]=1
	fi
}

check_script_running() {
	if [ -f "$PID_FILE" ]; then
		echo "Sound Timer is already running! Use '$NEW_COMMAND stop' to stop it."
		exit 1
	fi
}

sleep_until_next_minute() {
	local advance_seconds=$1

	# Wait until the next full minute (X:XX:00)
	local current_second=$(date +%S)
	current_second=$((10#$current_second)) # converts to decimal

	# Calculate the remaining time until the next minute and adjust by advance_seconds
	local seconds_to_sleep=$(( (60 - current_second - advance_seconds + 60) % 60 ))

	# if remaining time is 0 sleep a minute
	if (( seconds_to_sleep == 0)); then
		seconds_to_sleep=60
	fi

	log_message "Current second is $current_second so is going to sleep $seconds_to_sleep seconds"	 
	sleep $((seconds_to_sleep))
}

play_sound() {
	local file_name=$1
	paplay "$SCRIPT_DIRECTORY/sounds/$file_name.wav"
}

get_hour() {
	# city variable comes from -tz start command option
	local timezone="$city"
	
	if [[ -z "$timezone" ]]; then
		hour=$(date +%H)
	else
		hour=$(TZ=${timezones[$timezone]} date +%H)
	fi

	echo "$hour"
}

start_script() {
	local advance_seconds=$1

	check_script_running
	echo "Sound timer running..."

	run_timer() {
		sleep_until_next_minute $advance_seconds

		while true; do
			local current_time=$(date)
			minute=$(date +%M)
			minute=$((10#$minute)) # Converts to decimal
			hour=$(get_hour)
			hour=$((10#$hour)) # Converts to decimal

			# if there are seconds decrease still round minute to next interval
			# so when minute is XX:14:50 notification would be 15 minutes
			if (( advance_seconds > 0 )); then
				minute=$((minute + 1))
			fi 

			if [[ -n "${intervals_selected[4h]}" && $(( hour % 4 == 0 && minute % 60 == 0 )) -eq 1 ]]; then
				log_value "4 hours" "$current_time"
				play_sound 4h
			elif (( intervals_selected[60] && minute % 60 == 0 )); then
				log_value "60 minutes" "$current_time"
				play_sound 60
			elif (( intervals_selected[30] && minute % 30 == 0 )); then
				log_value "30 minutes" "$current_time"
				play_sound 30
			elif (( intervals_selected[15] && minute % 15 == 0 )); then
				log_value "15 minutes" "$current_time"
				play_sound 15
			elif (( intervals_selected[5] && minute % 5 == 0 )); then
				log_value "5 minutes" "$current_time"
				play_sound 5
			elif (( intervals_selected[1] )); then
				log_value "1 minute" "$current_time"
				play_sound 1
			fi

			sleep_until_next_minute $advance_seconds
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
		start_script $advance_seconds
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
	-l|-a|--advance|-tz)
		echo "$1 only works with subcommand 'start'"
		show_help
		;;
	*)
		echo "Unknown command: $1" >&2
		show_help
		exit 1
		;;
esac