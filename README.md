# System Monitor Script
System Monitor is a simple shell script to monitor CPU, memory, and disk usage and generate alerts when thresholds are exceeded.

Features
Monitor CPU, memory, and disk usage in real-time.
Log metrics and alerts to files.
Update resource thresholds dynamically.

Usage:

Start Monitoring: ./system-monitor.sh monitor

View Alerts: ./system-monitor.sh alerts

View Metrics: ./system-monitor.sh metrics

Update Thresholds: ./system-monitor.sh set-threshold "cpu|memory|disk" "value"
