#!/bin/sh
if [ "$#" -eq 0 ]; then
  printf "Pass password in first arg\n"
  exit 1
fi

#run with sudo
while IFS= read -r line; do

  IP=$(echo "$line" | cut -d' ' -f1)
  USER=$(echo "$line" | cut -d' ' -f2) 
  PASS=$(echo "$line" | cut -d' ' -f3)

  printf "On system $IP with user $USER\n"

  sshpass -p "$PASS" scp harden.sh "$USER"@"$IP":/tmp/harden.sh
  sshpass -p "$PASS" scp pass "$USER"@"$IP":/tmp/pass
  sshpass -p "$PASS" scp autofirewall.sh "$USER"@"$IP":/tmp/autofirewall.sh
  
  printf "Running harden.sh\n"
  salt=$(openssl rand -hex 16)
  hashed_password=$(openssl passwd -6 -salt "$salt" "$1")
  printf "$hashed_password\n"
  escaped_hash=${hashed_password//$/\\$}
  sshpass -p "$PASS" ssh "$USER"@"$IP" "SUDO_ASKPASS=/tmp/pass sudo -A /tmp/harden.sh '$hashed_password'" < /dev/null
  printf "harden.sh [DONE]\nRuning autofirewall.sh\n"
  sshpass -p "$PASS" ssh "$USER"@"$IP" 'SUDO_ASKPASS="/tmp/pass" sudo -A /tmp/autofirewall.sh' < /dev/null
  printf "autofirewall.sh [DONE]\n"

done < "hostfile"

printf "Done\n"
