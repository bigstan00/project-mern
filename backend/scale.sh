#!/bin/bash

set -e  # Exit on any error
set -x  # Enable debug mode to trace commands

# Configuration
SERVICE_NAME="backend"
COMPOSE_FILE="/home/bigstan/mern-redo/docker-compose.yaml"
MAX_INSTANCES=5
MIN_INSTANCES=1
CPU_THRESHOLD_UP=75
CPU_THRESHOLD_DOWN=30
LOG_FILE="/home/bigstan/mern-redo/backend/scale.log"
LOG_INTERVAL=300  # Log every 5 minutes (300 seconds)

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

    if [ "$cpu_usage" -gt "$CPU_THRESHOLD_UP" ] && [ "$current_instances" -lt "$MAX_INSTANCES" ]; then
        new_instances=$((current_instances + 1))
        scale_service "$new_instances"
    elif [ "$cpu_usage" -lt "$CPU_THRESHOLD_DOWN" ] && [ "$current_instances" -gt "$MIN_INSTANCES" ]; then
        new_instances=$((current_instances - 1))
        scale_service "$new_instances"
    else
        echo "No scaling action needed for $SERVICE_NAME" | tee -a "$LOG_FILE"
    fi

    sleep 120  # Adjust the interval as needed
done


