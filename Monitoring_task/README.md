
# System Monitoring Script

This script provides a real-time dashboard for monitoring various system resources like CPU usage, memory usage, disk space, network activity, and active processes. You can also use specific command-line switches to access individual parts of the dashboard.


Requirements

- sysstat: For monitoring CPU usage.
- net-tools: For network monitoring.  


Before running the script, ensure that the required packages are installed:

## Installation:
- sysstat
```bash
  sudo apt update
  sudo apt install sysstat
```
- net-tools
```bash
  sudo apt update
  sudo apt install net-tools
```
## Usage

You can run the script in different modes based on the command-line switches you use. Here’s how to use it:

### Full Dashboard
To display the full monitoring dashboard that refreshes every 5 seconds:
```bash
  ./monitoring.sh -a
```

### Individual Sections
You can monitor specific sections by using the following switches:

#### Top Processes by CPU and Memory Usage:
```bash
  ./monitoring.sh -p
```  
#### Memory Usage:
```bash
  ./monitoring.sh -m
```  
### Disk Usage:
```bash
  ./monitoring.sh -d
```
### Network Usage:
```bash
  ./monitoring.sh -n
```
### System Load and CPU Breakdown:
```bash
  ./monitoring.sh -l
```
### Process Monitoring:
```bash
  ./monitoring.sh -t
```
### memory usage:
```bash
  ./monitoring.sh -m
```
### To monitor Services:
```bash
  ./monitoring.sh -s
```
### Help
For help or to see all available options:
```bash
  ./monitoring.sh -h
```