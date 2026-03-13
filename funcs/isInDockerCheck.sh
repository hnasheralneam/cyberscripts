# Check if running in Docker
awk -F/ '$2 == "docker"' /proc/self/cgroup | read
