#!/bin/sh
# Harden automatic v0.0.1

# Enforce root
if ! [ "$(id -u)" = 0 ]; then
   echo "Rerun with sudo"
   exit 1
fi

# Backup important files before modification
printf "Backing up passwd and shadow"
cp /etc/passwd /etc/.passwd
cp /etc/shadow /etc/.shadow
printf " [DONE]\n"
chattr -i /etc/passwd
chattr -i /etc/shadow

# Set all user shells to /bin/false, preventing login
sed -ri 's@(:[^:]*$)@:/bin/false@' /etc/passwd

# Add blueteam user
useradd bluey -m
printf "Added bluey\n"
rm -rf /home/bluey/*
rm -rf /home/bluey/.*
printf "Cleaned up home directory\n"

if getent group wheel >/dev/null; then 
   usermod -aG wheel bluey
else
   usermod -aG sudo bluey
fi

printf "Set bluey shell\n"
usermod -s /bin/sh bluey

printf "Added to sudoers group\n"

printf "Setting password for root & bluey user\n"
hashed="$1"

printf "Received: %s\n" "$hashed"

sudo sed -i "s|^bluey:[^:]*|bluey:$hashed|" /etc/shadow
sudo chmod 644 /etc/passwd
sudo chmod 600 /etc/shadow 

# List of users to keep unlocked
ALLOWED_USERS="nobody bluey"

# Function to check if a user is in the allowed list
is_allowed() {
    for allowed_user in $ALLOWED_USERS; do
        if [ "$allowed_user" = "$1" ]; then
            return 0
        fi
    done
    return 1
}

# Lock all users except the allowed ones
for user in $(cut -f1 -d: /etc/passwd); do
    if ! is_allowed "$user"; then
        passwd -l "$user"
    fi
done


chattr +i /etc/passwd
chattr +i /etc/shadow
shred /tmp/pass
