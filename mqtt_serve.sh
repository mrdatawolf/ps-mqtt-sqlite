#!/bin/bash

# Common variables
mqtt_broker="127.0.0.1"
ip_to_check="127.0.0.1"
interval_test=1
interval_test2=2
interval_test3=3
date_today=$(date +"%m-%d-%Y")
file1="/tmp/Stm_01 Daily Export ${date_today}.csv"
file2="/tmp/Stm_01 Daily Report ${date_today}.xlsx"

# Function to send a message to a given topic
send_message() {
    local topic="$1"
    local message="$2"
    mosquitto_pub -h "$mqtt_broker" -t "$topic" -m "$message"
}

# Function to check if an IP is alive
check_ip_alive() {
    local ip="$1"
    if ping -c 1 "$ip" &> /dev/null; then
        echo "true"
    else
        echo "false"
    fi
}

# Function to check if files exist
check_file_exists() {
    local file="$1"
    if [[ -f "$file" ]]; then
        echo "true"
    else
        echo "false"
    fi
}

# Ensure mosquitto is installed
if ! command -v mosquitto_pub &> /dev/null; then
    echo "mosquitto is not installed. Installing..."
    sudo apt update
    sudo apt install -y mosquitto mosquitto-clients
else
    echo "mosquitto is already installed."
fi

while true; do
    # Check if IP is alive
    ip_alive=$(check_ip_alive "$ip_to_check")
    send_message "ip_alive" "$ip_alive"
    sleep "$interval_test"

    # Check if the first file exists
    file1_exists=$(check_file_exists "$file1")
    send_message "export_file_exists" "$file1_exists"
    sleep "$interval_test2"

    # Check if the second file exists
    file2_exists=$(check_file_exists "$file2")
    send_message "report_file_exists" "$file2_exists"
    sleep "$interval_test3"
done