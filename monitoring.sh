#!/bin/bash

# Function to display top 10 CPU & Memory consuming Applications

function show_top_processes() {
  echo "1) Top 10 Most Used Applications:-"
    echo "Top 10 Applications by CPU Usage:"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 11
    echo ""
    echo "Top 10 Applications by Memory Usage:"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 11
    echo ""
}

# Function to Monitor Network usage

function network() {
    echo "2) Network Monitoring :-"
    which netstat
    status=$?
    # echo $status
    if [[ $status == 0 ]]; then
        echo ""
    else
        sudo apt-get update
        sudo apt-get install net-tools -y
    fi

    echo "Number of Current Connections to the Server:"
    ss -s | grep 'estab' | awk '{print $4}'
    echo ""

    echo "Packets Dropped on All Interfaces:"
    netstat -i | awk '{print $1, $4, $5}' | column -t
    echo ""

    echo "Network Usage (MB In/Out):"

    # Using ip command
    ip -s link | awk '/^[0-9]/ { iface=$2 } /RX:/{getline; rx=$1} /TX:/{getline; tx=$1; print iface, "RX:", rx/(1024*1024), "MB, TX:", tx/(1024*1024), "MB"}'

    echo ""
}

# Function to Monitor Disk Usage

function disk_usage() {
    echo "3) Disk Usage :- "
    echo "Disk Space Usage by Mounted Partitions:"
    echo "Partitions using < 80% disk space are highlighted."

    df -h --output=source,fstype,size,used,avail,pcent,target | while read -r line; do
        if [[ $(echo $line | awk '{print $5}' | tr -d '%') -lt 80 ]]; then
            echo -e "\e[1;31m$line\e[0m"
        else
            echo "$line"
        fi
    done
    echo ""
}


# Function to show the current load average & CPU usage breakdown

function system_lode() {
    echo "4) System Load :- "
    echo "Current Load Average:"
    uptime | awk -F'load average:' '{ print $2 }'
    echo ""

    echo "CPU Usage Breakdown:"
    mpstat 1 1 | awk '/Average:/ {print "  User: " $3 "%, System: " $5 "%, Idle: " $12 "%"}'
    echo ""
}


# Function to display memory usage

function memory_usage() {
    echo "5) memory Usage:-" 
    echo "Memory Usage:"
    free -h | awk '/^Mem:/ {print "  Total: "$2", Used: "$3", Free: "$4}'
    echo ""

    echo "Swap Memory Usage:"
    free -h | awk '/^Swap:/ {print "  Total: "$2", Used: "$3", Free: "$4}'
    echo ""
}



# Function to display number of active processes $ top 5 processes in term of CPU $ memory usage
function processes_monitoring() {
    echo "6) processes_monitoring:-"
    echo "Number of Active Processes:"
    ps aux | wc -l
    echo ""

    echo "Top 5 Processes by CPU Usage:"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
    echo ""

    echo "Top 5 Processes by Memory Usage:"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6
    echo ""
}

# Function to check if a service is active
function check_service_status() {
    local service_name=$1
    if systemctl is-active --quiet "$service_name"; then
        echo "$service_name is running"
    else
        echo "$service_name is not running"
    fi
}

# Function to display the status of essential services
function show_service_status() {
    echo "Service Monitoring:"
    check_service_status "sshd"
    check_service_status "nginx"
    check_service_status "iptables"
    read -p "Enter service Name to check status:-" service
    check_service_status "$service"

}
# Function to display the full dashboard
function show_dashboard() {
    clear
    echo "System Monitoring Dashboard"
    echo "============================="
    show_top_processes
    network
    disk_usage
    system_lode
    memory_usage
    processes_monitoring
    show_service_status
}

# Parse command-line options
while getopts ":pmdnltsha" opt; do
  case $opt in
    p)
      show_top_processes
      exit 0
      ;;
    m)
      memory_usage
      exit 0
      ;;
    d)
      disk_usage
      exit 0
      ;;
    n)
      network
      exit 0
      ;;
    l)
      system_lode
      exit 0
      ;;
    t)
      processes_monitoring
      exit 0
      ;;
    s)
      show_service_status
      exit 0
      ;;
    a)
      show_dashboard
      exit 0
      ;;

    h)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  -p   show top processes"
      echo "  -m   Show Memory usage"
      echo "  -d   Show Disk usage"
      echo "  -n   Show Network usage"
      echo "  -l   Show system lode"
      echo "  -t   Show processes"
      echo "  -a   Show All (Full Dashboard)"
      echo "  -h   Show this help message"
      exit 0
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Default to showing the full dashboard if no options are passed
while true; do
    show_dashboard
    sleep 5
done
