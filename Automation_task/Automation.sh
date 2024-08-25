#!/bin/bash


LOGFILE="/tmp/security_audit.log"


# User and group audit
echo "$(date +'%Y-%m-%d %H:%M:%S') Listing all users and groups"
echo "List of all Users:"
cut -d: -f1 /etc/passwd
echo ""
echo "List of all Groups:"
cut -d: -f1 /etc/group
echo ""

# Check for users with UID 0 and non-standard users
echo "$(date +'%Y-%m-%d %H:%M:%S') Checking for users with UID 0 & non-standard users"
echo "Users with UID 0:"
awk -F: '($3 == 0) {print $1}' /etc/passwd
echo ""
echo "Listing non-standard users (UID 0 but not root):"
awk -F: '($3 == 0 && $1 != "root") {print $1}' /etc/passwd
echo ""

# Check users without or weak passwords
echo "$(date +'%Y-%m-%d %H:%M:%S') Checking for users without or weak passwords"
sudo awk -F: '($2 == "" || $2 == "*" || $2 == "!" || $2 == "!!") {print $1}' /etc/shadow
echo ""

# Scan for world-writable files and directories
echo "$(date +'%Y-%m-%d %H:%M:%S') Scanning for world-writable files and directories"
world_writable=$(find / -xdev -type f -perm -0002 -o -type d -perm -0002 2>/dev/null)
if [ -n "$world_writable" ]; then
    echo "World-writable files and directories found:"
    echo "$world_writable" | tee -a $LOGFILE
else
    echo "No world-writable files or directories found."
fi

# Scan for SUID/SGID files
echo "$(date +'%Y-%m-%d %H:%M:%S') Scanning for files with SUID or SGID bits set"
suid_sgid_files=$(find / -xdev \( -perm -4000 -o -perm -2000 \) -type f 2>/dev/null)
if [ -n "$suid_sgid_files" ]; then
    echo "Files with SUID/SGID bits set found:"
    echo "$suid_sgid_files" | tee -a $LOGFILE
else
    echo "No files with SUID/SGID bits set found."
fi

# Check for .ssh directories with insecure permissions
echo "$(date +'%Y-%m-%d %H:%M:%S') Checking for .ssh directories with insecure permissions"
ssh_dirs=$(find /home /root -type d -name ".ssh" 2>/dev/null)
for dir in $ssh_dirs; do
    permissions=$(stat -c "%a" "$dir")
    if [ "$permissions" != "700" ]; then
        echo "Insecure .ssh directory permissions found: $dir (Permissions: $permissions)"
    else
        echo "No insecure .ssh directories found."
    fi
done

# List all running services
echo "$(date +'%Y-%m-%d %H:%M:%S') Listing all running services"
if command -v systemctl &> /dev/null; then
    running_services=$(systemctl list-units --type=service --state=running | grep ".service" | awk '{print $1}')
else 
    running_services=$(service --status-all 2>/dev/null | grep '+' | awk '{print $4}')
fi
echo "Running services:"
echo "$running_services" | tee -a $LOGFILE

# Check critical services
echo "$(date +'%Y-%m-%d %H:%M:%S') Checking if critical services are running"
critical_services=("sshd" "iptables" "firewalld" "cron")
for service in "${critical_services[@]}"; do
    if systemctl is-active --quiet "$service"; then
        echo "$service is running."
    else
        echo "Critical service $service is NOT running!"
    fi
done

# Check for services listening on non-standard or insecure ports
echo "$(date +'%Y-%m-%d %H:%M:%S') Checking for services listening on non-standard or insecure ports"
listening_ports=$(ss -tuln | grep LISTEN)
echo "Listening ports and associated services:"
echo "$listening_ports" | tee -a $LOGFILE

standard_ports=("22" "80" "443" "53")
while read -r line; do
    port=$(echo $line | awk '{print $5}' | cut -d':' -f2)
    if [[ ! " ${standard_ports[@]} " =~ " ${port} " ]]; then
        echo "Service listening on non-standard or insecure port: $port"
    fi
done <<< "$listening_ports"

# Firewall checks
echo "$(date +'%Y-%m-%d %H:%M:%S') Checking firewall status and configuration"
if command -v firewall-cmd &> /dev/null; then
    if firewall-cmd --state &> /dev/null; then
        echo "Firewalld is active."
        firewall-cmd --list-all | tee -a $LOGFILE
    else
        echo "WARNING: Firewalld is not active!"
    fi
fi

if command -v ufw &> /dev/null; then
    if ufw status | grep -q "Status: active"; then
        echo "UFW is active."
        ufw status verbose | tee -a $LOGFILE
    else
        echo "WARNING: UFW is not active!"
    fi
fi

if command -v iptables &> /dev/null; then
    if iptables -L | grep -q "Chain"; then
        echo "Iptables is active."
        iptables -L -v -n | tee -a $LOGFILE
    else
        echo "WARNING: Iptables does not have any active rules!"
    fi
fi

# Report open ports
echo "$(date +'%Y-%m-%d %H:%M:%S') Reporting open ports and their associated services"
open_ports=$(ss -tuln | grep LISTEN)
echo "Open ports and associated services:"
echo "$open_ports" | tee -a $LOGFILE

# IP forwarding check
echo "$(date +'%Y-%m-%d %H:%M:%S') Checking for IP forwarding"
ip_forwarding=$(sysctl net.ipv4.ip_forward | awk '{print $3}')
if [ "$ip_forwarding" -eq "1" ]; then
    echo "WARNING: IP forwarding is enabled!"
else
    echo "IP forwarding is disabled."
fi

# IP address checks
echo "$(date +'%Y-%m-%d %H:%M:%S') Identifying all IP addresses assigned to the server"
ip_addresses=$(hostname -I | tr ' ' '\n')

public_ips=()
private_ips=()

for ip in $ip_addresses; do
    if [[ $ip =~ ^10\. ]] || [[ $ip =~ ^192\.168\. ]] || [[ $ip =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\. ]]; then
        private_ips+=($ip)
    else
        public_ips+=($ip)
    fi
done

echo "IP Address Summary:"
echo "Private IPs: ${private_ips[*]}"
echo "Public IPs: ${public_ips[*]}"

# Check for security updates and configure automatic updates
echo "$(date +'%Y-%m-%d %H:%M:%S') Checking for available security updates and ensuring automatic security updates are configured"
if command -v apt-get &> /dev/null; then
    updates=$(apt-get -s dist-upgrade | grep "^Inst" | grep -i security)
    if [ -n "$updates" ]; then
        echo "Security updates available:"
        echo "$updates"
        echo "Automatic security updates are NOT configured. Installing unattended-upgrades."
        apt-get install -y unattended-upgrades
        dpkg-reconfigure --priority=low unattended-upgrades
    else
        echo "No security updates available."
    fi
fi

echo "$(date +'%Y-%m-%d %H:%M:%S') Security audit completed."
