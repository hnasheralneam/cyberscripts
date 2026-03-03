#!/bin/sh

while IFS= read -r line; do
   IP=$(echo "$line" | cut -d' ' -f1)
   USER=$(echo "$line" | cut -d' ' -f2) 
   PASS=$(echo "$line" | cut -d' ' -f3)

   printf "On system $IP with user $USER"

   sshpass -p "$PASS" scp /home/hna/cyber/Scripts/watchdawg.sh $IP:/tmp/watchdawg
   sshpass -p "$PASS" scp /home/hna/cyber/Automation/watchdawg-start.sh $IP:/tmp/wd-start
   sshpass -p "$PASS" scp /home/hna/cyber/Scripts/watchdawg-sources $IP:/tmp/sources

   sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no $USER@$IP << EOF
      echo "$PASS" | sudo -S chmod 700 /tmp/wd-start
      echo "$PASS" | sudo /tmp/wd-start
EOF

done < "hostfile"

printf "Done\n"
