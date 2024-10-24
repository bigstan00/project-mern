# # #!/bin/bash

# # # Function to check if a command exists
# # command_exists() {
# #     command -v "$1" >/dev/null 2>&1
# # }

# # # Function to install Docker and Docker Compose
# # install_docker() {
# #     echo "Checking for Docker installation..."
# #     if command_exists docker; then
# #         echo "Docker is already installed."
# #     else
# #         echo "Installing Docker..."
# #         sudo apt-get update
# #         sudo apt-get install -y docker.io
# #         sudo systemctl start docker
# #         sudo systemctl enable docker
# #     fi

# #     echo "Checking for Docker Compose installation..."
# #     if command_exists docker-compose; then
# #         echo "Docker Compose is already installed."
# #     else
# #         echo "Installing Docker Compose..."
# #         sudo apt-get install -y docker-compose
# #     fi
# # }

# # # Install Docker and Docker Compose
# # install_docker

# # # Configuration
# # SERVICE_NAME="backend"  # Set this to your actual service name
# # COMPOSE_FILE="/home/bigstan/mern-redo/docker-compose.yaml"
# # MAX_INSTANCES=5
# # MIN_INSTANCES=1
# # CPU_THRESHOLD_UP=75
# # CPU_THRESHOLD_DOWN=30

# # # Function to get the CPU usage percentage of the containers for the service
# # get_cpu_usage() {
# #     container_ids=$(docker compose -f "$COMPOSE_FILE" ps -q "$SERVICE_NAME")

# #     if [ -z "$container_ids" ]; then
# #         echo 0
# #         return
# #     fi

# #     total_cpu=0
# #     for id in $container_ids; do
# #         cpu_usage=$(docker stats --no-stream --format "{{.CPUPerc}}" "$id" | tr -d '%' | awk '{print int($1)}')
# #         total_cpu=$((total_cpu + cpu_usage))
# #     done

# #     num_containers=$(echo "$container_ids" | wc -w)
# #     average_cpu=$((total_cpu / num_containers))

# #     echo $average_cpu
# # }

# # # Function to scale the service
# # scale_service() {
# #     local count=$1
# #     echo "Scaling $SERVICE_NAME to $count instances."
# #     docker compose -f "$COMPOSE_FILE" up --scale "$SERVICE_NAME=$count" -d
# # }

# # # Main loop
# # while true; do
# #     current_instances=$(docker compose -f "$COMPOSE_FILE" ps | grep "$SERVICE_NAME" | wc -l)
# #     cpu_usage=$(get_cpu_usage)

# #     echo "Current Instances: $current_instances, CPU Usage: $cpu_usage%"

# #     if [[ $cpu_usage -gt $CPU_THRESHOLD_UP && $current_instances -lt $MAX_INSTANCES ]]; then
# #         new_instances=$((current_instances + 1))
# #         scale_service $new_instances
# #     elif [[ $cpu_usage -lt $CPU_THRESHOLD_DOWN && $current_instances -gt $MIN_INSTANCES ]]; then
# #         new_instances=$((current_instances - 1))
# #         scale_service $new_instances
# #     else
# #         echo "No scaling action needed. Current instances: $current_instances, CPU Usage: $cpu_usage%"
# #     fi

# #     # Wait for a specified interval before checking again
# #     sleep 30  # Adjust the interval as needed
# # done

# # echo "Scale script executed" >> /home/bigstan/mern-redo/scale.log



# #---------------------------

# export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# set -x  # Debug mode to print commands


# #!/bin/bash

# # Function to check if a command exists
# command_exists() {
#     command -v "$1" >/dev/null 2>&1
# }

# # Install Docker and Docker Compose if necessary
# install_docker() {
#     echo "Checking for Docker installation..."
#     if command_exists docker; then
#         echo "Docker is already installed."
#     else
#         echo "Installing Docker..."
#         sudo apt-get update
#         sudo apt-get install -y docker.io
#         sudo systemctl start docker
#         sudo systemctl enable docker
#     fi

#     echo "Checking for Docker Compose installation..."
#     if command_exists docker-compose; then
#         echo "Docker Compose is already installed."
#     else
#         echo "Installing Docker Compose..."
#         sudo apt-get install -y docker-compose
#     fi
# }

# install_docker  # Install Docker if necessary

# # Configuration
# SERVICE_NAMES="backend"  # Array of service names
# COMPOSE_FILE="/home/bigstan/mern-redo/docker-compose.yaml"
# MAX_INSTANCES=5
# MIN_INSTANCES=1
# CPU_THRESHOLD_UP=75
# CPU_THRESHOLD_DOWN=30
# LOG_FILE="/home/bigstan/mern-redo/backend/scale.log"

# # Function to log messages
# log_message() {
#     echo "$(date) - $1" | tee -a "$LOG_FILE"
# }

# # Get CPU usage of containers for a specific service
# get_cpu_usage() {
#     local service_name=$1
#     container_ids=$(docker compose -f "$COMPOSE_FILE" ps -q "$service_name")

#     if [ -z "$container_ids" ]; then
#         echo 0  # No containers running
#         return
#     fi

#     total_cpu=0
#     for id in $container_ids; do
#         cpu_usage=$(docker stats --no-stream --format "{{.CPUPerc}}" "$id" | tr -d '%' | awk '{print int($1)}')
#         total_cpu=$((total_cpu + cpu_usage))
#     done

#     num_containers=$(echo "$container_ids" | wc -w)
#     average_cpu=$((total_cpu / num_containers))

#     echo $average_cpu
# }

# # Scale a service to the specified number of instances
# scale_service() {
#     local service_name=$1
#     local count=$2
#     log_message "Scaling $service_name to $count instances."
#     docker compose -f "$COMPOSE_FILE" up --scale "$service_name=$count" -d
# }

# # Ensure minimum instances are running
# check_and_recover() {
#     local service_name=$1
#     current_instances=$(docker compose -f "$COMPOSE_FILE" ps | grep "$service_name" | wc -l)

#     if [[ $current_instances -lt $MIN_INSTANCES ]]; then
#         log_message "Service $service_name has fewer than $MIN_INSTANCES instances. Scaling up..."
#         scale_service "$service_name" "$MIN_INSTANCES"
#     fi
# }

# # Main monitoring loop
# while true; do
#     for service in "${SERVICE_NAMES[@]}"; do
#         # Check and recover from failures
#         check_and_recover "$service"

#         # Get current instance count and CPU usage
#         current_instances=$(docker compose -f "$COMPOSE_FILE" ps | grep "$service" | wc -l)
#         cpu_usage=$(get_cpu_usage "$service")

#         log_message "Service: $service | Instances: $current_instances | CPU Usage: $cpu_usage%"

#         # CPU-based scaling logic
#         if [[ $cpu_usage -gt $CPU_THRESHOLD_UP && $current_instances -lt $MAX_INSTANCES ]]; then
#             new_instances=$((current_instances + 1))
#             scale_service "$service" "$new_instances"
#         elif [[ $cpu_usage -lt $CPU_THRESHOLD_DOWN && $current_instances -gt $MIN_INSTANCES ]]; then
#             new_instances=$((current_instances - 1))
#             scale_service "$service" "$new_instances"
#         else
#             log_message "No scaling needed for $service."
#         fi
#     done

#     # Wait for a specified interval before checking again
#     sleep 30
# done







# #---------------------

# # #!/bin/bash

# # # Function to check if a command exists
# # command_exists() {
# #     command -v "$1" >/dev/null 2>&1
# # }

# # # Install Docker and Docker Compose if necessary
# # install_docker() {
# #     echo "Checking for Docker installation..."
# #     if command_exists docker; then
# #         echo "Docker is already installed."
# #     else
# #         echo "Installing Docker..."
# #         sudo apt-get update
# #         sudo apt-get install -y docker.io
# #         sudo systemctl start docker
# #         sudo systemctl enable docker
# #     fi

# #     echo "Checking for Docker Compose installation..."
# #     if command_exists docker-compose; then
# #         echo "Docker Compose is already installed."
# #     else
# #         echo "Installing Docker Compose..."
# #         sudo apt-get install -y docker-compose
# #     fi
# # }

# # install_docker  # Install Docker if necessary

# # # Configuration
# # SERVICE_NAMES=("backend" "backend1")  # Array of service names
# # COMPOSE_FILE="/home/bigstan/mern-redo/docker-compose.yaml"
# # MAX_INSTANCES=5
# # MIN_INSTANCES=1
# # CPU_THRESHOLD_UP=75
# # CPU_THRESHOLD_DOWN=30
# # LOG_FILE="/home/bigstan/mern-redo/backend/scale.log"

# # # Function to log messages
# # log_message() {
# #     echo "$(date) - $1" | tee -a "$LOG_FILE"
# # }

# # # Get CPU usage of containers for a specific service
# # get_cpu_usage() {
# #     local service_name=$1
# #     container_ids=$(docker compose -f "$COMPOSE_FILE" ps -q "$service_name")

# #     if [ -z "$container_ids" ]; then
# #         echo 0  # No containers running
# #         return
# #     fi

# #     total_cpu=0
# #     for id in $container_ids; do
# #         cpu_usage=$(docker stats --no-stream --format "{{.CPUPerc}}" "$id" | tr -d '%' | awk '{print int($1)}')
# #         total_cpu=$((total_cpu + cpu_usage))
# #     done

# #     num_containers=$(echo "$container_ids" | wc -w)
# #     average_cpu=$((total_cpu / num_containers))

# #     echo $average_cpu
# # }

# # # Scale a service to the specified number of instances
# # scale_service() {
# #     local service_name=$1
# #     local count=$2
# #     log_message "Scaling $service_name to $count instances."
# #     docker compose -f "$COMPOSE_FILE" up --scale "$service_name=$count" -d
# # }

# # # Ensure minimum instances are running or scale down after recovery
# # check_and_recover() {
# #     local service_name=$1
# #     current_instances=$(docker compose -f "$COMPOSE_FILE" ps | grep "$service_name" | wc -l)

# #     if [[ $current_instances -lt $MIN_INSTANCES ]]; then
# #         log_message "Service $service_name has fewer than $MIN_INSTANCES instances. Scaling up..."
# #         scale_service "$service_name" "$MIN_INSTANCES"
# #     elif [[ $current_instances -gt $MIN_INSTANCES ]]; then
# #         log_message "More than the minimum instances of $service_name are running. Checking if scale-down is needed..."
# #         cpu_usage=$(get_cpu_usage "$service_name")

# #         if [[ $cpu_usage -lt $CPU_THRESHOLD_DOWN ]]; then
# #             new_instances=$((current_instances - 1))
# #             log_message "CPU usage is low. Scaling down $service_name to $new_instances instances."
# #             scale_service "$service_name" "$new_instances"
# #         else
# #             log_message "CPU usage is still high. No scale-down for $service_name."
# #         fi
# #     fi
# # }

# # # Main monitoring loop
# # while true; do
# #     for service in "${SERVICE_NAMES[@]}"; do
# #         # Check and recover from failures, and scale down if possible
# #         check_and_recover "$service"

# #         # Get current instance count and CPU usage
# #         current_instances=$(docker compose -f "$COMPOSE_FILE" ps | grep "$service" | wc -l)
# #         cpu_usage=$(get_cpu_usage "$service")

# #         log_message "Service: $service | Instances: $current_instances | CPU Usage: $cpu_usage%"

# #         # CPU-based scaling logic
# #         if [[ $cpu_usage -gt $CPU_THRESHOLD_UP && $current_instances -lt $MAX_INSTANCES ]]; then
# #             new_instances=$((current_instances + 1))
# #             scale_service "$service" "$new_instances"
# #         elif [[ $cpu_usage -lt $CPU_THRESHOLD_DOWN && $current_instances -gt $MIN_INSTANCES ]]; then
# #             new_instances=$((current_instances - 1))
# #             scale_service "$service" "$new_instances"
# #         else
# #             log_message "No scaling needed for $service."
# #         fi
# #     done

# #     # Wait for a specified interval before checking again
# #     sleep 30
# # done

#--------------------use
# #!/bin/bash

# set -e  # Exit on any error
# set -x  # Enable debug mode to trace commands

# # Configuration
# SERVICE_NAME="backend"
# COMPOSE_FILE="/home/bigstan/mern-redo/docker-compose.yaml"
# MAX_INSTANCES=5
# MIN_INSTANCES=1
# CPU_THRESHOLD_UP=75
# CPU_THRESHOLD_DOWN=30
# #LOG_FILE="/home/bigstan/mern-redo/backend/scale.log"

# # Function to get CPU usage
# get_cpu_usage() {
#     container_ids=$(docker compose -f "$COMPOSE_FILE" ps -q "$SERVICE_NAME")

#     if [ -z "$container_ids" ]; then
#         echo 0
#         return
#     fi

#     total_cpu=0
#     for id in $container_ids; do
#         cpu_usage=$(docker stats --no-stream --format "{{.CPUPerc}}" "$id" | tr -d '%' | awk '{print int($1)}')
#         total_cpu=$((total_cpu + cpu_usage))
#     done

#     num_containers=$(echo "$container_ids" | wc -w)
#     average_cpu=$((total_cpu / num_containers))

#     echo "$average_cpu"
# }

# # Function to scale the service
# scale_service() {
#     local count="$1"
#     echo "Scaling $SERVICE_NAME to $count instances." | tee -a "$LOG_FILE"
#     docker compose -f "$COMPOSE_FILE" up --scale "$SERVICE_NAME=$count" -d
# }

# # Main loop
# while true; do
#     current_instances=$(docker compose -f "$COMPOSE_FILE" ps | grep "$SERVICE_NAME" | wc -l)
#     cpu_usage=$(get_cpu_usage)

#     echo "Service: $SERVICE_NAME, Instances: $current_instances, CPU: $cpu_usage%" | tee -a "$LOG_FILE"

#     if [ "$cpu_usage" -gt "$CPU_THRESHOLD_UP" ] && [ "$current_instances" -lt "$MAX_INSTANCES" ]; then
#         new_instances=$((current_instances + 1))
#         scale_service "$new_instances"
#     elif [ "$cpu_usage" -lt "$CPU_THRESHOLD_DOWN" ] && [ "$current_instances" -gt "$MIN_INSTANCES" ]; then
#         new_instances=$((current_instances - 1))
#         scale_service "$new_instances"
#     else
#         echo "No scaling action needed for $SERVICE_NAME" | tee -a "$LOG_FILE"
#     fi

#     sleep 120  # Adjust the interval as needed
# done

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
