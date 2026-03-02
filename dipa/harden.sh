#!/bin/sh
if ! [ $(id -u) = 0 ]; then
   echo "Rerun with sudo"
   exit 1
fi

printf "Backing up passwd and shadow"
cp /etc/passwd /etc/passwd-o
cp /etc/shadow /etc/shadow-o
printf " [DONE]\n"

# Sets all users to login
sed -ri 's@(:[^:]*$)@:/bin/false@' /etc/passwd
# Add blueteam user
useradd bluey -m
printf "Added bluey\n"
if getent group wheel >/dev/null; then 
   usermod -aG wheel bluey
else
   usermod -aG sudo bluey
fi
printf "added to sudo\n"
#usermod -s /bin/sh bluey
#printf "changed shell\n"
chpasswd < /tmp/.pwd
shred /tmp/.pwd
shred /tmp/pass
