#!/bin/sh

if command -v dnf &> /dev/null; then
   echo "rhel"
else if command -v apt &> /dev/null; then
   echo "debian"
else if command -v zypper &> /dev/null; then
   echo "opensuse"
else if command -v apk &> /dev/null; then
   echo "alpine"
else if command -v pacman &> /dev/null; then
   echo "arch"
else
   echo "What are you using, Solaris?"
fi
