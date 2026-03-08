#!/bin/bash
# Script to capture snapshot of initial compitition state

# kernel modules -> lsmod
# cron, anacron -> check ALL dirs
# systemd timers -> run command
# service configs -> /etc
# installed packages -> distro dependant
# suid bits -> run command
# repos -> check location, copy over
# pam directories -> probably /etc
# open ports -> ss -tulpn
# environment variables -> save env
# systemd services -> run command
# systemd service files -> probably /etc
# binary sizes -> diff ls -R

# Ensure running as root
if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] This script must be run as root or with sudo."
    exit 1
fi

BACKUP_DIR=/var/bk

mkdir -p $BACKUP_DIR/filesystem
mkdir -p $BACKUP_DIR/filesystem/etc
mkdir -p $BACKUP_DIR/filesystem/home

## Criticial files and directories
cp -pr /etc/*       $BACKUP_DIR/filesystem/etc/
cp -pr /home/*      $BACKUP_DIR/filesystem/home/

## Processes and services
ps aux    > $BACKUP_DIR/processes-ps_aux.txt
pstree -p > $BACKUP_DIR/processes-pstree.txt

if [ -d /run/systemd/system ]; then
    # Systemd stuff
    systemctl list-units      --type=service --state=running --no-pager > $BACKUP_DIR/services-active_running.txt
    systemctl list-unit-files --type=service --state=enabled --no-pager > $BACKUP_DIR/services-enabled_autostart.txt
    systemctl list-units                               --all --no-pager > $BACKUP_DIR/services all_units.txt
else
    # Openrc stuff
    rc-status --started --manual > $BACKUP_DIR/services-active_running.txt
    rc-update -v show            > $BACKUP_DIR/services-enabled_autostart.txt
    rc-update show               > $BACKUP_DIR/services all_units.txt
fi

## Packages
# Alpine
if [ -x "$(command -v apk)" ];
then
    apk info > $BACKUP_DIR/packages-alpine.txt
# Debian
elif [ -x "$(command -v apt)" ];
then
    dpkg -l > $BACKUP_DIR/packages-debian.txt
# RHEL
elif [ -x "$(command -v dnf)" ];
then
    rpm -qa > $BACKUP_DIR/packages-rhel.txt
else
    printf "== Unknown package manager ==\n"
fi

## Ports and firewall
ss -tulpn      > $BACKUP_DIR/listeningports.txt
iptables -L > $BACKUP_DIR/iptablerules.txt

## Kernel modules
lsmod > $BACKUP_DIR/kernelmodules.txt

printf "== Archiving directory... ==\n"
tar -cpzf ~/bk.tar.gz $BACKUP_DIR
