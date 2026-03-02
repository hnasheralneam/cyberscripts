#!/bin/bash
# Harden interactive v0.0.1

echo "Starting Harden interactive, v0.0.1"

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo -e "\e[31mThis script must be run as root\e[0m" 1>&2
    exit 1
fi

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
