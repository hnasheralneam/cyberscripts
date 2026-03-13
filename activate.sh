#!/bin/sh
# UNTESTED

printf "Starting activation script...\n"
printf "==> Extracting resources\n"
# backup.sh c2scanner.sh watchdawg.sh watchdawg-sources auditd-rules
cd /tmp
tar -xvf minzero.tar

printf "==> Deploying backup\n"
chmod +x backup.sh
./backup.sh | tee backup.out

printf "==> Deploying auditd\n"
printf "====> Installing auditd\n"
if command -v auditd &> /dev/null; then
   printf "Already installed\n"
if command -v dnf &> /dev/null; then
   sudo dnf install audit -y
elif command -v apt &> /dev/null; then
   sudo apt install auditd -y
elif command -v apk &> /dev/null; then
   sudo apk add audit
fi

printf "====> Applying rules\n"
sudo cp auditd-rules /etc/audit/rules.d/standard.rules
sudo chmod 0600 /etc/audit/rules.d/standard.rules

printf "====> Restarting service\n"
if command -v systemctl &> /dev/null; then
   sudo systemctl restart auditd
elif
   doas rc-service auditd restart
fi

printf "==> Deploying watchdawg\n"
# ACTUALLY DO THIS
