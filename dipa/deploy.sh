#!/bin/sh

#run with sudo
while IFS= read -r line; do

  IP=$(echo "$line" | cut -d' ' -f1)
  USER=$(echo "$line" | cut -d' ' -f2) 
  PASS=$(echo "$line" | cut -d' ' -f3)

  printf "On system $IP with user $USER\n"

  sshpass -p "$PASS" scp harden.sh "$USER"@"$IP":/tmp/harden.sh
  sshpass -p "$PASS" scp pass "$USER"@"$IP":/tmp/pass
  sshpass -p "$PASS" scp .pwd "$USER"@"$IP":/tmp/.pwd
  sshpass -p "$PASS" scp autofirewall.sh "$USER"@"$IP":/tmp/autofirewall.sh
  
  printf "Running harden.sh\n"
  sshpass -p "$PASS" ssh $USER@$IP 'SUDO_ASKPASS="/tmp/pass" sudo -A /tmp/harden.sh' < /dev/null
  printf "harden.sh [DONE]\nRuning autofirewall.sh\n"
  sshpass -p "$PASS" ssh $USER@$IP 'SUDO_ASKPASS="/tmp/pass" sudo -A /tmp/autofirewall.sh' < /dev/null
  printf "autofirewall.sh [DONE]\n"

done < "hostfile"

printf "Done\n"
