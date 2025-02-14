#!/bin/bash
# Script Name: sudo_guard.sh
# Description: Provides two functionalities:
#    1. Monitor sudo usage in authentication logs.
#    2. Secure permissions on the sudoers file.
#
# How to use:
#   sudo ./sudo_guard.sh --monitor   # To monitor sudo access logs
#   sudo ./sudo_guard.sh --secure    # To secure the sudoers file

# Function to generate the current timestamp.
timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Function to print a separator line (100 dashes).
print_separator() {
    printf -- '-%.0s' {1..100}
    echo
}

# Function to print usage instructions.
print_usage() {
    echo "$(timestamp) - Usage: $0 --monitor | --secure"
    echo "$(timestamp) -    --monitor : Monitor sudo access in authentication logs"
    echo "$(timestamp) -    --secure  : Secure permissions on the /etc/sudoers file"
    exit 1
}

# Making sure the script is running as root.
if [[ $EUID -ne 0 ]]; then
    echo "$(timestamp) - Please run as root!"
    exit 1
fi

# Validate that exactly one argument is provided.
if [[ $# -ne 1 ]]; then
    print_usage
fi

case "$1" in
    --monitor)
        # Define possible log file locations.
        logFile=""
        if [[ -f "/var/log/auth.log" ]]; then
            logFile="/var/log/auth.log"
        elif [[ -f "/var/log/secure" ]]; then
            logFile="/var/log/secure"
        else
            echo "$(timestamp) - ERROR!: No authentication log file found!"
            exit 1
        fi

        print_separator
        echo "$(timestamp) - Monitoring sudo access in $logFile... Press Ctrl+C to stop."
        print_separator
        # Live monitoring of sudo usage.
        sudo tail -fn0 "$logFile" | grep --line-buffered "sudo"
        ;;
    --secure)
        print_separator
        echo "$(timestamp) - Setting secure permissions on sudoers file..."
        print_separator
        if [[ -f "/etc/sudoers" ]]; then
            sudo chmod 440 /etc/sudoers && sudo chown root:root /etc/sudoers
            echo "$(timestamp) - Sudoers file secured!"
            print_separator
        else
            echo "$(timestamp) - ERROR!: /etc/sudoers file not found!"
            exit 1
        fi
        ;;
    *)
        print_usage
        ;;
esac
