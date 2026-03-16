#!/bin/bash
if [ "$1" != "" ] && [ "$2" != "" ] && [ "$3" != "" ]; then
   USER="$1"
   OLDPASS="$2"
   HOST="$3"
else
   printf "No arguments. \nYou must include <username>, <password> and <system-name>\n"
   exit
fi

LOGFILE="deploy-local.log"
{

printf '#!/bin/sh\nprintf '\""$OLDPASS\\\n"\" > pass
chmod +x pass
chmod +x harden.sh
chmod +x autofirewall.sh

printf "=== Compressing scripts ===\n"
tar -cvf ../minzero.tar.gz ../c2scanner.sh ../sshd_config ../backup.sh ../watchdawg.sh ../watchdawg-sources ../auditd-rules

deploy_host() {
  line="$1"
  IP=$(echo "$line" | cut -d' ' -f1)
  DIR=$(echo "$line" | cut -d' ' -f2) 
  HASH=$(echo "$line" | cut -d' ' -f3)

  if [ "$HASH" = "$HOST" ]; then
    printf "[$DIR]\nBegin hardening system...\n"
    AbsPath=$(realpath ../systems/)

    cp harden.sh pass autofirewall.sh $(realpath ../activate.sh) $(realpath ../minzero.tar.gz) "$AbsPath/$DIR/port-sources" /tmp/

    printf "Starting autofirewall.sh\n"
    sshpass -p "$OLDPASS" ssh "$USER"@"$IP" 'SUDO_ASKPASS="/tmp/pass" sudo -A /tmp/autofirewall.sh' < /dev/null \
      2>&1 | sed "s/^/[$DIR] /"
    printf "Done autofirewall.sh\n"
    printf "Starting harden.sh\n"
    #printf "$HASH\n"
    sshpass -p "$OLDPASS" ssh "$USER"@"$IP" "SUDO_ASKPASS=/tmp/pass sudo -A /tmp/harden.sh '$HASH'" < /dev/null \
      2>&1 | sed "s/^/[$DIR] /"
    printf "Done harden.sh\n"

  fi
}

while IFS= read -r host_line || [ -n "$host_line" ]; do
    deploy_host "$host_line"
done < hostfile

printf "Finished\n"

} 2>&1 | tee -a "$LOGFILE"
