#!/bin/sh
# Harden automatic v0.0.1

# Enforce root
if ! [ $(id -u) = 0 ]; then
   echo "Rerun with sudo"
   exit 1
fi

# Backup important files before modification
printf "Backing up passwd and shadow"
cp /etc/passwd /etc/.passwd
cp /etc/shadow /etc/.shadow
printf " [DONE]\n"

# Set all user shells to /bin/false, preventing login
sed -ri 's@(:[^:]*$)@:/bin/false@' /etc/passwd

# Add blueteam user
useradd bluey -m
printf "Added bluey\n"

if getent group wheel >/dev/null; then 
   usermod -aG wheel bluey
else
   usermod -aG sudo bluey
fi

printf "Added to sudoers group\n"

printf "Setting password for root & bluey user\n"
hashed="$1"

printf "Received: %s\n" "$hashed"

sudo sed -i "s|^bluey:[^:]*|bluey:$hashed|" /etc/shadow
#printf "Received: $hashed\n"
#sudo sed -i "s|^bluey:[^:]*|bluey:${hashed//\$/\\\$}|" /etc/shadow
shred /tmp/pass
