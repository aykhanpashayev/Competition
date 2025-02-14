#!/bin/bash 
# Script Name: secure_sudo.sh
# Description: Checks for unauthorized sudo users and removes them modify the code define your own allowed users!.

# Make sure the script is run as root.
if [[ $EUID -ne 0 ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Please run as root!"
    exit 1
fi

# Function to generate the current timestamp.
timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Function to print a log message with timestamp.
log() {
    echo "$(timestamp) - $1"
}

# Print separator line.
log "----------------------------------------------------------------------------"

# Define allowed sudo users.
allowed_users=("kali")

# Get the current sudo users (comma-separated).
sudo_users=$(getent group sudo | cut -d: -f4)

# If no users are found in the sudo group, exit.
if [ -z "$sudo_users" ]; then
    log "No users found in the sudo group."
    log "----------------------------------------------------------------------------"
    exit 0
fi

# Convert the comma-separated list into an array.
IFS=',' read -ra current_users <<< "$sudo_users"

# Checking each current sudo user.
for user in "${current_users[@]}"; do
    # Trim whitespace.
    user=$(echo "$user" | xargs)
    allowed=false
    # Checking if the user is in the allowed list.
    for allowed_user in "${allowed_users[@]}"; do
        if [ "$user" == "$allowed_user" ]; then
            allowed=true
            break
        fi
    done
    # If the user is not allowed, remove them from the sudo group.
    if [ "$allowed" = false ]; then
        log "Unauthorized sudo user detected: $user"
        if command -v deluser >/dev/null 2>&1; then
            deluser "$user" sudo
        else
            gpasswd -d "$user" sudo
        fi
        log "$user removed from sudo group"
        log "----------------------------------------------------------------------------"
    fi
done

log "Sudo users checked and secured"
log "----------------------------------------------------------------------------"

