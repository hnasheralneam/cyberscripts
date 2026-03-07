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

printf "${BLUE}Checking for preloaded libraries${NC}\n"
cat /etc/os-release

printf "$BLUE}Checking open ports${NC}\n"
ss -tulpn

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

printf "${YELLOW}Listing priviledged users${NC}\n"
grep -Po '^sudo.+:\K.*$' /etc/group
grep -Po '^wheel.+:\K.*$' /etc/group
printf "${YELLOW}CHECK /etc/sudoers FILE FOR OTHER USERS WITH ROOT ACCESS${NC}\n"

printf "${BLUE}Listing users without passwords${NC}\n"
if [ $(awk -F: '($2 == "") {print}' /etc/shadow | wc -l) -gt 0]; then
   printf "${RED}Users without password set!\n$(awk -F: '($2 == "") {print}' /etc/shadow)${NC}\n"
fi

printf "${BLUE}Searching for suspicious processes${NC}\n"
ps aux | grep -E 'nc|netcat|bash|python|perl|sh'


# /etc/passwd
ONE=$(ls -l /etc/passwd)
TWO="-rw-r--r--. 1 root root 3734 Dec 15 13:17 /etc/passwd"
printf "Permissions on /etc/passwd:\n(current) $ONE\n"
printf "(default) $TWO\n"
read -p "Override existing permissions (y/n): " CHOICE
if [ "$CHOICE" == "y" ]; then
   sudo chmod 666 /etc/passwd
else
   echo "Nothing changed."
fi
# chattr +i /etc/passwd
printf "Locked file.\n"

# printf "If there is an i, the file is immutable: "
# lsattr /etc/passwd

# also ask to override if the suid bit is set 
# show a diff of the files; if different, ask y/n to open the file for editing


# may be useful to upload a zipped version of the baseline from a vm of the system, including only critical files/dirs, up here for comparison
# like `cp /etc/ssh/* ~/baseline/etc/ssh/` then `zip ~/baseline` then `sftp vm` then `get baseline` then `sftp compsys` then `put baseline` then `unzip baseline` then run this script
#
#
# use mapfile to read in array of files to montitor
