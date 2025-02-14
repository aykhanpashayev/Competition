# Linux Administration and Security Scripts

Repository contains Bash scripts which will help automate linux administrator and security tasks.

Repository provides tools for:
- **Monitoring modifications** to the `/etc/sudoers` file.
- **Auditing and securing sudo access** by verifying allowed users.
- **Monitoring sudo activity** via system authentication logs.
- **Ensuring critical services** are running and restarting them if they are down.
- **Verifying active network connections.**

## Prerequisites

Before using these scripts, make sure you have:

- A Linux distribution with systemd.
- **Root privileges** (all scripts must be run as root).
- [**inotify-tools**](https://github.com/inotify-tools/inotify-tools) for monitoring file changes.  
  Install with:
  sudo apt update && sudo apt install inotify-tools -y
- netstat (provided by the net-tools package) for network verification.
  Install with:
  sudo apt update && sudo apt install net-tools -y

## How to use the repository
1. Clone the repository git clone https://github.com/aykhanpashayev/Linux_Administration_Scripts/
2. Move to directory: cd Linux_Administration_Scripts/
3. Make everything executable inside of directory: sudo chmod +x ./
4. Check Scripts in order to see how to run them

## Scripts

1. monitor_sudoers.sh
   Description:
   Monitors the /etc/sudoers file for modifications using inotifywait. When a change is detected, it logs the event (with a timestamp) to /var/log/sudoers_watch.log and displays an alert.

   Requirements:
   inotify-tools

   How to use:
   sudo ./monitor_sudoers.sh
   
   Output:
   The script outputs a series of timestamped log entries each time a when change is detected.
   
2. secure_sudo.sh
   Description:
   Checks for unauthorized users in the sudo group and removes them. You can define the list of allowed sudo users by modifying the allowed_users array in the script.

   How to use:
   sudo ./secure_sudo.sh
   
   Output:
   The script logs actions with timestamps and prints to clearly show when and which user is removed from the sudo group.

3. sudo_guard.sh
   Description:
   Provides two functionalities:

   Monitor sudo usage in authentication logs (from /var/log/auth.log or /var/log/secure).
   Secure permissions on the /etc/sudoers file by ensuring it has the correct permissions and ownership.
   
   How to use:
   To monitor sudo access:
   sudo ./sudo_guard.sh --monitor
   
   To secure the sudoers file:
   sudo ./sudo_guard.sh --secure
   
   Output:
   Each operation is logged with a timestamp for clarity and accuracy.

4. monitor_services.sh
   Description:
   Checks the status of critical services and attempts to restart them if they are not running. After checking the services, it also displays a list of active network connections.

   Defined Services:
   The default list includes: named, vsftpd, apache2, nginx, slapd, krb5kdc, xrdp, smbd, and ssh.
   ATTENTION!: Modify the services array as needed for your environment.

   How to use:
   sudo ./monitor_services.sh
   
   Output:
   The script logs the status of each service with timestamps, prints a success or failure message (including error output if a restart fails), and then shows the active network connections.


