#!/bin/bash
# Script Name: monitor_services.sh
# Description: Checks critical services and restarts them if necessary, then verifies network connections.
#
# How to use:
#   sudo ./monitor_services.sh

# Making sure the script is running as root.
if [[ $EUID -ne 0 ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Please run as root!"
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

# Print initial separator and starting message.
print_separator
echo "$(timestamp) - Starting service check..."
print_separator

# Define services to check (base names; the script appends .service).
services=("named" "vsftpd" "apache2" "nginx" "slapd" "krb5kdc" "xrdp" "smbd" "ssh")

# Check each service and restart if necessary.
for service in "${services[@]}"; do
    unit="${service}.service"
    if systemctl is-active --quiet "$unit"; then
        echo "$(timestamp) - [✓] $unit is running"
    else
        echo "$(timestamp) - [!] $unit is DOWN. Restarting..."
        restart_output=$(sudo systemctl restart "$unit" 2>&1)
        # Verify if restart was successful.
        if systemctl is-active --quiet "$unit"; then
            echo "$(timestamp) - [✓] $unit successfully restarted"
        else
            echo "$(timestamp) - [X] Failed to restart $unit"
            echo "$(timestamp) - Error: $restart_output"
        fi
    fi
done

# Print separator before checking network connections.
print_separator
echo "$(timestamp) - Checking network connections..."
print_separator

# Verify network connections.
sudo netstat -tulnp | grep LISTEN

# Final separator and completion message.
print_separator
echo "$(timestamp) - Service check and network verification completed."
print_separator
