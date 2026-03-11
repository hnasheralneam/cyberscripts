#!/bin/sh

# will not work, because outbound is blocked
printf "**** Deploying auditd ****\n"
if command -v dnf &> /dev/null; then
   sudo dnf install auditd
else if command -v apt &> /dev/null; then
   sudo apt install audit
else if command -v zypper &> /dev/null; then
   sudo zypper install auditd
else if command -v apk &> /dev/null; then
   sudo apk add auditd
fi
