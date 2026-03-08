#!/bin/sh
if [ "$1" != "" ] && [ "$2" != "" ]; then
   USER="$1"
   OLDPASS="$2"
else
   printf "No arguments. \nYou must include <username> and <password>\n"
   exit
fi



printf '#!/bin/sh\nprintf '\""$OLDPASS\\\n"\" > pass
chmod +x pass
chmod +x harden.sh
chmod +x autofirewall.sh

#run with sudo
while IFS= read -r line; do
  IP=$(echo "$line" | cut -d' ' -f1)
  DIR=$(echo "$line" | cut -d' ' -f2) 
  HASH=$(echo "$line" | cut -d' ' -f3)

  printf "[$DIR] Begin system $IP with user $USER\n"
  AbsPath=$(realpath ../systems/)

  sshpass -p "$OLDPASS" scp -o StrictHostKeyChecking=no harden.sh "$USER"@"$IP":/tmp/harden.sh
  sshpass -p "$OLDPASS" scp pass "$USER"@"$IP":/tmp/pass
  sshpass -p "$OLDPASS" scp autofirewall.sh "$USER"@"$IP":/tmp/autofirewall.sh
  sshpass -p "$OLDPASS" scp "$AbsPath/$DIR/port-sources" "$USER"@"$IP":/tmp/port-sources

  printf "[$DIR] starting autofirewall.sh\n"
  sshpass -p "$OLDPASS" ssh "$USER"@"$IP" 'SUDO_ASKPASS="/tmp/pass" sudo -A /tmp/autofirewall.sh' < /dev/null
  printf "[$DIR] done autofirewall.sh\n"
  printf "[$DIR] starting harden.sh\n"
  #printf "$HASH\n"
  sshpass -p "$OLDPASS" ssh "$USER"@"$IP" "SUDO_ASKPASS=/tmp/pass sudo -A /tmp/harden.sh '$HASH'" < /dev/null
  printf "[$DIR] done harden.sh\n"
  printf "[$DIR] All done\n"

done < "hostfile"

printf "Finished\n"
