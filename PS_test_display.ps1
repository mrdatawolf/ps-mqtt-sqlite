# Ensure the PSMQTT module is installed and import it
if (-not (Get-Module -ListAvailable -Name PSMQTT)) {
    Install-Module -Name PSMQTT -Scope CurrentUser -Force
}
Import-Module PSMQTT

# Function to handle incoming MQTT messages
function OnMessageReceived {
    param (
        [string]$topic,
        [string]$message
    )

    Write-Host "Received message: $topic - $message"

    if ($message -eq "true") {
        Write-Host "${topic}: ${message}" -ForegroundColor Green
    } elseif ($message -eq "false") {
        Write-Host "${topic}: ${message}" -ForegroundColor Red
    } else {
        Write-Host "${topic}: ${message}"
    }
}

# Function to connect to MQTT broker and subscribe to multiple topics
function Connect-MQTTBrokerAndSubscribe {
    param (
        [string]$broker,
        [array]$topics
    )

    Write-Host "Connecting to MQTT broker at $broker"
    try {
        $session = Connect-MQTTBroker -HostName $broker
        Write-Host "Connected to MQTT broker. Subscribing to topics ${topics}"
        $topicString = $topics -join ","
        Watch-MQTTTopic -Session $session -Topic $topicString | ForEach-Object {
            $messageParts = $_ -split ";"
            $receivedTopic = $messageParts[0]
            $receivedMessage = $messageParts[1]
            OnMessageReceived -topic $receivedTopic -message $receivedMessage
        }
    } catch {
        Write-Host "Error subscribing to topics ${topics}: $_" -ForegroundColor Red
    }
}

# Main script
$mqttBroker = "127.0.0.1"
$topics = @("ip_alive", "file_exists")

Write-Host "Starting script. MQTT broker: $mqttBroker, Topics: $topics"

# Connect to MQTT broker and subscribe to the topics
Connect-MQTTBrokerAndSubscribe -broker $mqttBroker -topics $topics