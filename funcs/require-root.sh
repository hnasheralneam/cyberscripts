if [ "$(id -u)" -ne 0 ]; then
  printf "This script requires root privileges. Exiting\n"
  exit 1
fi
