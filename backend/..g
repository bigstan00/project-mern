#!/bin/bash

set -e  # Exit on any error
set -x  # Enable debug mode to trace commands

# Configuration
SERVICE_NAME="backend"
COMPOSE_FILE="/home/ubuntu/project-mern/docker-compose.yaml"
MAX_INSTANCES=5
MIN_INSTANCES=1
CPU_THRESHOLD_UP=75
CPU_THRESHOLD_DOWN=30
LOG_FILE="/home/ubuntu/project-mern/backend/scale.log"
LOG_INTERVAL=300  # Log every 5 minutes (300 seconds)

# EC2 Instance Configuration
EC2_INSTANCE_ID="i-09f84bf49182b318d"  # Replace with your EC2 instance ID
EC2_MAX_LOAD=80  # CPU percentage at which to scale up the instance
EC2_MIN_LOAD=20  # CPU percentage at which to scale down the instance

# Function to get CPU usage
get_cpu_usage() {
    container_ids=$(docker compose -f "$COMPOSE_FILE" ps -q "$SERVICE_NAME")

    if [ -z "$container_ids" ]; then
        echo 0
        return
    fi

    total_cpu=0
    for id in $container_ids; do
        cpu_usage=$(docker stats --no-stream --format "{{.CPUPerc}}" "$id" | tr -d '%' | awk '{print int($1)}')
        total_cpu=$((total_cpu + cpu_usage))
    done

    num_containers=$(echo "$container_ids" | wc -w)
    average_cpu=$((total_cpu / num_containers))

    echo "$average_cpu"
}

# Function to scale the service
scale_service() {
    local count="$1"
    echo "Scaling $SERVICE_NAME to $count instances." | tee -a "$LOG_FILE"
    docker compose -f "$COMPOSE_FILE" up --scale "$SERVICE_NAME=$count" -d
}

# Function to scale EC2 instance
scale_ec2_instance() {
    local action="$1"  # "up" or "down"
    if [[ "$action" == "up" ]]; then
        echo "Scaling EC2 instance up." | tee -a "$LOG_FILE"
        # Start EC2 instance if it's stopped
        aws ec2 start-instances --instance-ids "$EC2_INSTANCE_ID" | tee -a "$LOG_FILE"
    elif [[ "$action" == "down" ]]; then
        echo "Scaling EC2 instance down." | tee -a "$LOG_FILE"
        # Stop EC2 instance if it's running
        aws ec2 stop-instances --instance-ids "$EC2_INSTANCE_ID" | tee -a "$LOG_FILE"
    fi
}

# Main loop
last_log_time=0

while true; do
    current_instances=$(docker compose -f "$COMPOSE_FILE" ps | grep "$SERVICE_NAME" | wc -l)
    cpu_usage=$(get_cpu_usage)

    current_time=$(date +%s)
    if (( current_time - last_log_time >= LOG_INTERVAL )); then
        echo "Service: $SERVICE_NAME, Instances: $current_instances, CPU: $cpu_usage%" | tee -a "$LOG_FILE"
        last_log_time=$current_time
    fi

    # Scale Docker containers
    if [ "$cpu_usage" -gt "$CPU_THRESHOLD_UP" ] && [ "$current_instances" -lt "$MAX_INSTANCES" ]; then
        new_instances=$((current_instances + 1))
        scale_service "$new_instances"
    elif [ "$cpu_usage" -lt "$CPU_THRESHOLD_DOWN" ] && [ "$current_instances" -gt "$MIN_INSTANCES" ]; then
        new_instances=$((current_instances - 1))
        scale_service "$new_instances"
    else
        echo "No scaling action needed for $SERVICE_NAME" | tee -a "$LOG_FILE"
    fi

    # Scale EC2 instance based on CPU load
    if [ "$cpu_usage" -gt "$EC2_MAX_LOAD" ]; then
        scale_ec2_instance "up"
    elif [ "$cpu_usage" -lt "$EC2_MIN_LOAD" ]; then
        scale_ec2_instance "down"
    fi

    sleep 120  # Adjust the interval as needed
done