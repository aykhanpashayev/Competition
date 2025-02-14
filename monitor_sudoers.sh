#!/bin/bash
# Script Name: monitor_sudoers.sh
# Description: Monitors /etc/sudoers for modifications using inotifywait.
# Requirements: inotify-tools (Install with: sudo apt update && sudo apt install inotify-tools -y)

# Making sure the script is run as root.
if [[ $EUID -ne 0 ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Please run as root!"
    exit 1
fi

# Verifying that inotifywait is installed.
if ! command -v inotifywait &> /dev/null; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - inotifywait is not installed. Please install inotify-tools."
    exit 1
fi

# File to monitor and log file.
sudoers_file="/etc/sudoers"
log_file="/var/log/sudoers_watch.log"

# Checking if the log directory exists if not error message.
log_dir=$(dirname "$log_file")
if [ ! -d "$log_dir" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: Log directory $log_dir does not exist."
    exit 1
fi

# Checking if the log file is writable (or can be created).
if ! touch "$log_file" 2>/dev/null; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: Unable to write to log file $log_file. Please check permissions."
    exit 1
fi

# Function to generate the current timestamp.
timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Function to print a separator line (100 dashes).
print_separator() {
    printf -- '-%.0s' {1..100}
    echo
}

# Print initial separator and monitoring message.
print_separator
echo "$(timestamp) - Monitoring changes to sudoers file: $sudoers_file..."
print_separator

# Monitor the sudoers file for modifications.
inotifywait -m -e modify "$sudoers_file" |
while read -r path action file; do
    log_message="$(timestamp) - SUDOERS MODIFIED: $file"
    echo "$log_message" | tee -a "$log_file"
    echo "ALERT: UNATHORIZED MODIFICATION DETECTED IN: $sudoers_file!"
    print_separator
done
