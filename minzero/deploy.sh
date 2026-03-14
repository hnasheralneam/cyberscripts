#!/bin/bash
if [ "$1" != "" ] && [ "$2" != "" ]; then
   USER="$1"
   OLDPASS="$2"
else
   printf "No arguments. \nYou must include <username> and <password>\n"
   exit
fi

LOGFILE="deploy.log"
{

printf '#!/bin/sh\nprintf '\""$OLDPASS\\\n"\" > pass
chmod +x pass
chmod +x harden.sh
chmod +x autofirewall.sh

printf "=== Compressing scripts ===\n"
tar -cvf ../minzero.tar ../backup.sh ../c2scanner.sh ../watchdawg.sh ../watchdawg-sources ../auditd-rules

deploy_host() {
  line="$1"
  IP=$(echo "$line" | cut -d' ' -f1)
  DIR=$(echo "$line" | cut -d' ' -f2) 
  HASH=$(echo "$line" | cut -d' ' -f3)

  printf "[$DIR] Begin system $IP with user $USER\n"
  AbsPath=$(realpath ../systems/)


  sshpass -p "$OLDPASS" scp -o StrictHostKeyChecking=no harden.sh pass autofirewall.sh $(realpath ../activate.sh) $(realpath ../minzero.tar) "$AbsPath/$DIR/port-sources" "$USER@$IP:/tmp/"

  printf "[$DIR] starting autofirewall.sh\n"
  sshpass -p "$OLDPASS" ssh "$USER"@"$IP" 'SUDO_ASKPASS="/tmp/pass" sudo -A /tmp/autofirewall.sh' < /dev/null \
    2>&1 | sed "s/^/[$DIR] /"
  printf "[$DIR] done autofirewall.sh\n"
  printf "[$DIR] starting harden.sh\n"
  #printf "$HASH\n"
  sshpass -p "$OLDPASS" ssh "$USER"@"$IP" "SUDO_ASKPASS=/tmp/pass sudo -A /tmp/harden.sh '$HASH'" < /dev/null \
    2>&1 | sed "s/^/[$DIR] /"
  printf "[$DIR] done harden.sh\n"

  printf "[$DIR] All done\n"
}
export -f deploy_host
export USER OLDPASS

parallel -j 10 --line-buffer deploy_host :::: hostfile

printf "Finished\n"

} 2>&1 | tee -a "$LOGFILE"
