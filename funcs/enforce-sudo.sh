if [ "$(id -u)" -ne 0 ]; then
  echo "Rerun with sudo"
  exit 1
fi
