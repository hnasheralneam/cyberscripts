#!/bin/sh

printf "▗▄▄▖ ▗▄▄▄▖ ▗▄▄▖ ▗▄▖ ▗▖  ▗▖    ▗▄▄▄▖▗▄▄▄▖▗▖  ▗▖▗▄▄▖ \n";
printf "▐▌ ▐▌▐▌   ▐▌   ▐▌ ▐▌▐▛▚▖▐▌      █  ▐▌   ▐▛▚▞▜▌▐▌ ▐▌\n";
printf "▐▛▀▚▖▐▛▀▀▘▐▌   ▐▌ ▐▌▐▌ ▝▜▌      █  ▐▛▀▀▘▐▌  ▐▌▐▛▀▘ \n";
printf "▐▌ ▐▌▐▙▄▄▖▝▚▄▄▖▝▚▄▞▘▐▌  ▐▌      █  ▐▙▄▄▖▐▌  ▐▌▐▌   \n\n";

###########################################
#---------------) Colors (----------------#
###########################################
busctl --system set-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.NetworkManager ConnectivityCheckEnabled "b" 0

echo "=== All users with shell ==="
getent passwd | awk -F: '$7 !~ /(nologin|false|sync|halt|shutdown)$/ {print $1, $7}'
printf ${NC}
echo
printf ${LG}
echo "=== Current iptable rules ==="
sudo iptables -L
printf ${NC}
echo
printf ${BLUE}
echo "=== Cronjobs ==="
users=$(cut -f1 -d: /etc/passwd)
for u in $users
do
  echo "---[ USER: $u ]---"
  crontab -l -u "$u" 2>/dev/null 
done
sudo crontab -l
cat /etc/cron*/*
printf "${NC}\n"
printf "=== Running Systemd Services ===\n"
systemctl list-units --type=service --no-pager
printf ${RED_YELLOW}
echo "=== SUID bits ==="
sudo find / -perm "/u=s,g=s" -type f 2>/dev/null
printf ${NC}
echo

