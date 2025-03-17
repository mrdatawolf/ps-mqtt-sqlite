#!/bin/bash

# Function to handle incoming MQTT messages
handle_message() {
    local topic="$1"
    local message="$2"

    if [[ "$message" == "true" ]]; then
        echo -e "\e[32m${topic}: ${message}\e[0m"  # Green for true
    elif [[ "$message" == "false" ]]; then
        echo -e "\e[31m${topic}: ${message}\e[0m"  # Red for false
    else
        echo "${topic}: ${message}"
    fi
}

# Check if mosquitto is installed, and install it if not
if ! command -v mosquitto_sub &> /dev/null; then
    echo "mosquitto is not installed. Installing..."
    sudo apt update
    sudo apt install -y mosquitto mosquitto-clients
else
    echo "mosquitto is already installed."
fi

# MQTT broker details
mqtt_broker="127.0.0.1"
topics=("ip_alive" "file_exists")

# Subscribe to the MQTT topics with verbose output to include the topic
mosquitto_sub -h "$mqtt_broker" -t "${topics[0]}" -t "${topics[1]}" -v | while read -r line; do
    topic=$(echo "$line" | awk '{print $1}')
    message=$(echo "$line" | awk '{print $2}')
    handle_message "$topic" "$message"
done