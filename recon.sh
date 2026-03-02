#!/bin/sh
if [ "$(id -u)" -ne 0 ]; then
  echo "Rerun with sudo"
  exit 1
fi

echo "=== OS Version ==="
uname -a
echo
echo "=== Open Ports ==="
sudo ss -tulpn
echo
echo "=== Sudoers ==="
grep -Po '^sudo.+:\K.*$' /etc/group
grep -Po '^wheel.+:\K.*$' /etc/group
echo
echo "=== All users with shell ==="
getent passwd | awk -F: '$7 !~ /(nologin|false|sync|halt|shutdown)$/ {print $1, $7}'
echo
echo "=== Current iptable rules ==="
sudo iptables -L
echo
echo "=== SUID bits ==="
sudo find / -perm "/u=s,g=s" -type f 2>/dev/null
echo
echo "=== Cronjobs ==="
users=$(cut -f1 -d: /etc/passwd)
for u in $users
do
  echo "---[ USER: $u ]---"
  crontab -l -u "$u" 2>/dev/null
done
sudo crontab -l
cat /etc/cron*/*
