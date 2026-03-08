#!/bin/sh
printf "▗▄▄▖  ▗▄▖  ▗▄▄▖▗▄▄▄▖▗▖   ▗▄▄▄▖▗▖  ▗▖▗▄▄▄▖     ▗▄▄▖▗▄▄▄▖▗▄▖ ▗▖  ▗▖▗▄▄▄  ▗▄▖ ▗▄▄▖ ▗▄▄▄ \n";
printf "▐▌ ▐▌▐▌ ▐▌▐▌   ▐▌   ▐▌     █  ▐▛▚▖▐▌▐▌       ▐▌     █ ▐▌ ▐▌▐▛▚▖▐▌▐▌  █▐▌ ▐▌▐▌ ▐▌▐▌  █\n";
printf "▐▛▀▚▖▐▛▀▜▌ ▝▀▚▖▐▛▀▀▘▐▌     █  ▐▌ ▝▜▌▐▛▀▀▘     ▝▀▚▖  █ ▐▛▀▜▌▐▌ ▝▜▌▐▌  █▐▛▀▜▌▐▛▀▚▖▐▌  █\n";
printf "▐▙▄▞▘▐▌ ▐▌▗▄▄▞▘▐▙▄▄▖▐▙▄▄▖▗▄█▄▖▐▌  ▐▌▐▙▄▄▖    ▗▄▄▞▘  █ ▐▌ ▐▌▐▌  ▐▌▐▙▄▄▀▐▌ ▐▌▐▌ ▐▌▐▙▄▄▀\n\n";
printf " ====================================================================== v0.0.1 ===== \n\n";

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo -e "\e[31mThis script must be run as root\e[0m" 1>&2
    exit 1
fi

# Colors
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

printf "${LG}GENERAL SYSTEM INFO${NC}\n"
cat /etc/os-release

printf "${BLUE}Checking for preloaded libraries${NC}\n"
printf "$LD_PRELOAD\n"

printf "${YELLOW}Is this system time correct?${NC}\n"
timedatectl

printf "${BLUE}Checking open ports${NC}\n"
ss -tulpn
printf "${BLUE}Show processes running on ports${NC}\n"
sudo lsof -i -P -n

printf "${BLUE}Checking iptable rules${NC}\n"
iptables -L

printf "${BLUE}Checking for preloaded libraries${NC}\n"
if [ -n "$LD_PRELOAD" ]; then
   printf "${RED}LD_PRELOAD is set${NC}\n$LD_PRELOAD\n"
fi

printf "${BLUE}Checking only root has id ${NC}\n"
#awk -F: '($3 == "0") {print}' /etc/passwd
if [ $(awk -F: '($3 == 0 && $1 != "root")' /etc/passwd | wc -l) -gt 0 ]; then
    printf "${RED}Multiple UID 0 accounts found!${NC}\n"
fi

printf "${BLUE}Checking for nopasswd in sudoers files${NC}\n"
sudo grep "NOPASSWD" /etc/sudoers
sudo grep -R "NOPASSWD" /etc/sudoers.d/

printf "${YELLOW}Listing priviledged users${NC}\n"
grep -Po '^sudo.+:\K.*$' /etc/group
grep -Po '^wheel.+:\K.*$' /etc/group
printf "${YELLOW}CHECK /etc/sudoers FILE FOR OTHER USERS WITH ROOT ACCESS${NC}\n"

printf "${BLUE}Listing users without passwords${NC}\n"
if [ $(awk -F: '($2 == "") {print}' /etc/shadow | wc -l) -gt 0 ]; then
    printf "${RED}Users without password set!\n$(awk -F: '($2 == "") {print $1}' /etc/shadow)${NC}\n"
fi

printf "${BLUE}Showing authorized SSH keys (concerning only systems with key-based auth enabled)${NC}\n"
printf "=== Root ===\n"
sudo cat /root/.ssh/authorized_keys
for user_dir in /home/*; do
   auth_file="$user_dir/.ssh/authorized_keys"
   if [ -f "$auth_file" ]; then
      printf "=== User: ${user_dir##*/} ===\n"
      cat "$auth_file"
   fi
done

printf "${YELLOW}Checking for scripts in the /etc/init.d directory${NC}\n"
ls /etc/init.d

printf "${BLUE}Searching for suspicious processes${NC}\n"
ps aux | grep -E 'nc|netcat|bash|python|perl|sh'

printf "${YELLOW}Listing all crontabs${NC}\n"
users=$(cut -f1 -d: /etc/passwd)
for u in $users
do
  echo "USER: $u"
  crontab -l -u "$u" 2>/dev/null 
done
sudo crontab -l
cat /etc/cron*/*
printf "${YELLOW}Also check anacron${NC}\n"

printf "${BLUE}Showing at jobs${NC}\n"
atq

printf "${BLUE}Showing systemd timers${NC}\n"
systemctl list-timers --all

printf "${BLUE}Showing files at root of /etc/ dir that are world writable${NC}\n"
find /etc -maxdepth 1 -perm -o+w -ls

printf "${BLUE}Checking Docker/Podman containers${NC}\n"
if command -v docker >/dev/null 2>&1; then
   sudo docker ps -a
elif command -v podman >/dev/null 2>&1; then
   sudo podman ps -a
fi

printf "${BLUE}Checking package checksums${NC}\n"
if command -v dpkg &> /dev/null; then
   dpkg -V | grep -v missing
else if command -v apk &> /dev/null; then
   apk verify
else if command -v rpm &> /dev/null; then
   rpm -Va | grep -v missing
fi

printf "${BLUE}Checking for pwnkit vulnerability${NC}\n"
polkitVersion=$(systemctl status polkit.service 2>/dev/null | grep version | cut -d " " -f 9)
if [ "$(apt list --installed 2>/dev/null | grep polkit | grep -c 0.105-26)" -ge 1 ] || [ "$(rpm -qa | grep -i polkit | grep -ic "0.11[3-9]")" -ge 1 ]; then
   printf "${RED}SYSTEM VULNERABLE TO PWNKIT\n"
   printf "RUN ${NC}`sudo chmod -s $(which pkexec)` ${RED}to mitigate${NC}\n"
fi

printf "${BLUE}Starting lynis, redirecting output to /tmp/lynis${NC}\n"
if command -v dnf &> /dev/null; then
   sudo dnf install lynis
else if command -v apt &> /dev/null; then
   sudo apt install lynis
else if command -v apk &> /dev/null; then
   sudo apk install lynis
if
nohup lynis audit system > /tmp/lynis 2>&1 &

printf "${BLUE}Starting linpeas, redircting output to /tmp/linpeas${NC}\n"
curl -o https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh /tmp/lp.sh
chmod +x /tmp/lp.sh
nohup lp.sh > /tmp/linpeas 2>&1 &

printf "${LC}Done. Look through the output carefully and check the tool output files${NC}\n"


# TO-DO
# chkrootkit, rkhunter, clamav
