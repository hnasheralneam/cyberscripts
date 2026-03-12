#!/bin/sh
printf "▗▄▄▖  ▗▄▖  ▗▄▄▖▗▄▄▄▖▗▖   ▗▄▄▄▖▗▖  ▗▖▗▄▄▄▖     ▗▄▄▖▗▄▄▖ ▗▄▄▄▖ ▗▄▄▖▗▄▄▄▖▗▄▄▄▖▗▄▄▄▖ ▗▄▄▖\n";
printf "▐▌ ▐▌▐▌ ▐▌▐▌   ▐▌   ▐▌     █  ▐▛▚▖▐▌▐▌       ▐▌   ▐▌ ▐▌▐▌   ▐▌     █  ▐▌     █  ▐▌   \n";
printf "▐▛▀▚▖▐▛▀▜▌ ▝▀▚▖▐▛▀▀▘▐▌     █  ▐▌ ▝▜▌▐▛▀▀▘     ▝▀▚▖▐▛▀▘ ▐▛▀▀▘▐▌     █  ▐▛▀▀▘  █  ▐▌   \n";
printf "▐▙▄▞▘▐▌ ▐▌▗▄▄▞▘▐▙▄▄▖▐▙▄▄▖▗▄█▄▖▐▌  ▐▌▐▙▄▄▖    ▗▄▄▞▘▐▌   ▐▙▄▄▖▝▚▄▄▖▗▄█▄▖▐▌   ▗▄█▄▖▝▚▄▄▖\n\n";



# TO-DO
# kernel modules: show difference
# service configs, their permissions: show diff
# installed packages: show diff
# suid bits: show extra
# repositories: show extra
# pam directory: all diffs
# open ports: show diff
# environment variables: show diff
# systemd services: show extra
# systemd service files: show diff
# ensure binary sizes roughly similar: show non compliant
#
# make sure to run diff on ALL pam files!

# require input in form of system name

RED="${C}[1;31m"
GREEN="${C}[1;32m"
YELLOW="${C}[1;33m"
BLUE="${C}[1;34m"
LG="${C}[1;37m"
NC="${C}[0m"

interact() {
   printf "%s " "${LG}Press enter to continue${NC}\n"
   read ans
}

printf "${BLUE}==> Running data collection script on this compromised system${NC}\n"
chmod +x data-collection.sh
./data-collection.sh

printf "${BLUE}==> Decompressing files${NC}\n"
tar -xpzf * ../$SYSTEM/baseline.tar.gz ../$SYSTEM-clean
tar -xpzf * /tmp/baseline.tar.gz ../$SYSTEM-dirty

CLEAN=$(realpath ../$SYSTEM-clean)
DIRTY=$(realpath ../$SYSTEM-dirty)

interact

printf "${BLUE}Showing kernel modules${NC}\n"
diff -y $CLEAN/kernelModules $DIRTY/kernelModules

interact

printf "${BLUE}Showing active services${NC}\n"
diff -y $CLEAN/servicesActiveRunning $DIRTY/servicesActiveRunning
printf "${BLUE}Showing startup services${NC}\n"
diff -y $CLEAN/servicesEnabledAutostart $DIRTY/servicesEnabledAutostart

interact
