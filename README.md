System Monitoring Script
This script provides a real-time dashboard for monitoring various system resources like CPU usage, memory usage, disk space, network activity, and active processes. You can also use specific command-line switches to access individual parts of the dashboard.

Requirements
bash: The script is written in Bash.
sysstat: For monitoring CPU usage.
net-tools: For network monitoring.
ps: For process monitoring.
df: For disk usage monitoring.
free: For memory usage monitoring.
Installation
Before running the script, ensure that the required packages are installed:

bash
Copy code
sudo apt-get update
sudo apt-get install sysstat net-tools -y
Usage
You can run the script in different modes based on the command-line switches you use. Here’s how to use it:

Full Dashboard
To display the full monitoring dashboard that refreshes every 5 seconds:

bash
Copy code
./second.sh -a
Individual Sections
You can monitor specific sections by using the following switches:

Top Processes by CPU and Memory Usage:

bash
Copy code
./second.sh -p
Memory Usage:

bash
Copy code
./second.sh -m
Disk Usage:

bash
Copy code
./second.sh -d
Network Usage:

bash
Copy code
./second.sh -n
System Load and CPU Breakdown:

bash
Copy code
./second.sh -l
Process Monitoring:

bash
Copy code
./second.sh -t

To monitor memory usage:
bash
Copy code
./second.sh -m
To check disk usage:
bash
Copy code
./second.sh -d

Help
For help or to see all available options:

bash
Copy code
./second.sh -h
