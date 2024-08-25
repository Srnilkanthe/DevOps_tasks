# Security Audit Script

This script performs a comprehensive security audit on a Linux server. It checks for various security aspects, including user and group management, file permissions, running services, firewall status, IP configurations, and more.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)



## Features

- Lists all users and groups on the system.
- Checks for users with UID 0 (root privileges) and identifies non-standard users.
- Scans for world-writable files and directories.
- Detects files with SUID/SGID bits set.
- Ensures `.ssh` directories have secure permissions.
- Lists all running services and checks for unauthorized or unnecessary services.
- Verifies that critical services are running.
- Checks for services listening on non-standard or insecure ports.
- Verifies the status of the firewall (firewalld, UFW, iptables).
- Reports open ports and their associated services.
- Checks for IP forwarding and lists all IP addresses assigned to the server.
- Identifies whether the server's IP addresses are public or private.
- Checks for available security updates and ensures automatic security updates are configured.

## Requirements

- **Operating System**: Linux (Debian-based distributions such as Ubuntu)
- **Permissions**: Root or sudo privileges are required to run this script.
- **Utilities**: The script relies on standard Linux utilities such as `awk`, `grep`, `find`, `ss`, `systemctl`, `ufw`, `firewall-cmd`, and `iptables`.

## Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Srnilkanthe/DevOps_tasks/tree/main/Automation_task
   cd DevOps_tasks
   ```
2. **Make the Script Executable**:
   ```bash
   chmod +x Automation.sh
   ```
3. **Usage**:
 To perform a security audit, run the script with root or sudo privileges:
   ```bash
   sudo ./security_audit.sh
   ```
## Configuration
The script can be customized by modifying the following sections:
- Critical Services: Add or remove services from the critical_services array to customize which services are considered critical.
- Authorized Services: Modify the authorized_services array to specify which services should be allowed to run.
- Standard Ports: The standard_ports array contains the list of ports considered standard. Modify this array to include additional standard ports.
