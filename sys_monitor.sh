#!/bin/bash

# Configuration
CONFIG_DIR="$HOME/.system-monitor"
LOG_FILE="$CONFIG_DIR/monitor.log"
ALERT_FILE="$CONFIG_DIR/alerts.log"
THRESHOLD_FILE="$CONFIG_DIR/thresholds.conf"

# Create directories and files
mkdir -p "$CONFIG_DIR"
touch "$LOG_FILE" "$ALERT_FILE"

# Set default thresholds if not exists
if [ ! -f "$THRESHOLD_FILE" ]; then
    cat > "$THRESHOLD_FILE" << EOF
CPU_THRESHOLD=80
MEMORY_THRESHOLD=90
DISK_THRESHOLD=85
EOF
fi

source "$THRESHOLD_FILE"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get system metrics
get_cpu_usage() {
    cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}')
    cpu_usage=$(echo "100 - $cpu_idle" | bc)
    echo "${cpu_usage%.*}"
}

get_memory_usage() {
    free -m | awk '/Mem:/ {print int(($3/$2) * 100)}'
}
get_memory_usage() {
    free -m | awk '/Mem:/ {print int(($3/$2) * 100)}'
}

get_disk_usage() {
    df -h / | awk 'NR==2 {print int($5)}'
}

# Logging functions
log_alert() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local message="$1"
    echo "[$timestamp] $message" >> "$ALERT_FILE"
    echo -e "${RED}ALERT: $message${NC}"
}

log_metrics() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local cpu="$1"
    local mem="$2"
    local disk="$3"
    echo "[$timestamp] CPU: ${cpu}% | Memory: ${mem}% | Disk: ${disk}%" >> "$LOG_FILE"
}

# Main monitoring function
monitor() {
    while true; do
        cpu_usage=$(get_cpu_usage)
        memory_usage=$(get_memory_usage)
        disk_usage=$(get_disk_usage)

        # Log metrics
        log_metrics "$cpu_usage" "$memory_usage" "$disk_usage"

        # Display current status
        echo -e "\n${YELLOW}System Status at $(date '+%H:%M:%S')${NC}"
        echo "----------------------------------------"
        echo -e "CPU Usage:    ${cpu_usage}%    [Threshold: ${CPU_THRESHOLD}%]"
        echo -e "Memory Usage: ${memory_usage}%    [Threshold: ${MEMORY_THRESHOLD}%]"
        echo -e "Disk Usage:   ${disk_usage}%    [Threshold: ${DISK_THRESHOLD}%]"

        # Check thresholds
        if [ "$cpu_usage" -gt "$CPU_THRESHOLD" ]; then
            log_alert "High CPU usage: ${cpu_usage}%"
        fi
        if [ "$memory_usage" -gt "$MEMORY_THRESHOLD" ]; then
            log_alert "High memory usage: ${memory_usage}%"
        fi
        if [ "$disk_usage" -gt "$DISK_THRESHOLD" ]; then
            log_alert "High disk usage: ${disk_usage}%"
        fi

        sleep 5
    done
}

# View functions
show_alerts() {
    echo -e "\n${YELLOW}Recent Alerts${NC}"
    echo "----------------------------------------"
    tail -n 10 "$ALERT_FILE"
}

show_metrics() {
    echo -e "\n${YELLOW}Recent Metrics${NC}"
    echo "----------------------------------------"
    tail -n 10 "$LOG_FILE"
}

# Update thresholds
update_thresholds() {
    if [ -n "$1" ] && [ -n "$2" ]; then
        case "$1" in
            "cpu") sed -i "s/CPU_THRESHOLD=.*/CPU_THRESHOLD=$2/" "$THRESHOLD_FILE" ;;
            "memory") sed -i "s/MEMORY_THRESHOLD=.*/MEMORY_THRESHOLD=$2/" "$THRESHOLD_FILE" ;;
            "disk") sed -i "s/DISK_THRESHOLD=.*/DISK_THRESHOLD=$2/" "$THRESHOLD_FILE" ;;
            *) echo "Invalid resource type. Use: cpu, memory, or disk" ;;
        esac
        source "$THRESHOLD_FILE"
        echo -e "${GREEN}Thresholds updated successfully${NC}"
    else
        echo "Usage: $0 set-threshold <resource> <value>"
        echo "Example: $0 set-threshold cpu 85"
    fi
}


# Command handling
case "$1" in
    "monitor")
        monitor
        ;;
    "alerts")
        show_alerts
        ;;
    "metrics")
        show_metrics
        ;;
    "set-threshold")
        update_thresholds "$2" "$3"
        ;;
    *)
        echo "Usage: $0 {monitor|alerts|metrics|set-threshold}"
        echo "Commands:"
        echo "  monitor         - Start monitoring system resources"
        echo "  alerts          - Show recent alerts"
        echo "  metrics         - Show recent metrics"
        echo "  set-threshold   - Update resource thresholds"
        exit 1
        ;;
esac
