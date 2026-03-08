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

printf "Running data collection script on this compromised system\n"
chmod +x data-collection.sh
./data-collection.sh

printf "Decompressing files\n"
tar -xpzf * ../$SYSTEM/baseline.tar.gz ../$SYSTEM-clean
tar -xpzf * /tmp/baseline.tar.gz ../$SYSTEM-dirty


