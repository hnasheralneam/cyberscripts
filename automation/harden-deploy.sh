#!/bin/sh

#run with sudo
while IFS= read -r line; do

  IP=$(echo "$line" | cut -d' ' -f1)
  USER=$(echo "$line" | cut -d' ' -f2) 
  PASS=$(echo "$line" | cut -d' ' -f3)

  printf "On system $IP with user $USER\n"

  sshpass -p "$PASS" scp harden.sh $IP:/tmp/harden.sh
  sshpass -p "$PASS" scp pass $IP:/tmp/pass
  sshpass -p "$PASS" scp .pwd $IP:/tmp/.pwd

  printf "Running harden.sh\n"
  sshpass -p "$PASS" ssh $USER@$IP 'SUDO_ASKPASS="/tmp/pass" sudo -A /tmp/harden.sh'

done < "hostfile"

printf "Done\n"
