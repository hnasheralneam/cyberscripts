#!/bin/sh
# _        __    _       _         _                     
#\ \  /\  / /___| |_ ___| |__   __| | __ ___      ____ _ 
# \ \/  \/ / _` | __/ __| '_ \ / _` |/ _` \ \ /\ / / _` |
#  \  /\  / (_| | || (__| | | | (_| | (_| |\ V  V / (_| |
#   \/  \/ \__,_|\__\___|_| |_|\__,_|\__,_| \_/\_/ \__, |
#                                                  |___/ 
#                                         Version 1.1.1  

printf "▗▖ ▗▖ ▗▄▖▗▄▄▄▖▗▄▄▖▗▖ ▗▖▗▄▄▄  ▗▄▖ ▗▖ ▗▖ ▗▄▄▖\n";
printf "▐▌ ▐▌▐▌ ▐▌ █ ▐▌   ▐▌ ▐▌▐▌  █▐▌ ▐▌▐▌ ▐▌▐▌   \n";
printf "▐▌ ▐▌▐▛▀▜▌ █ ▐▌   ▐▛▀▜▌▐▌  █▐▛▀▜▌▐▌ ▐▌▐▌▝▜▌\n";
printf "▐▙█▟▌▐▌ ▐▌ █ ▝▚▄▄▖▐▌ ▐▌▐▙▄▄▀▐▌ ▐▌▐▙█▟▌▝▚▄▞▘\n\n";

echo "Starting watchdawg v1.1.1"
if [ "$1" != "" ] && [ "$2" != "" ]; then
   # directory to backup copies of files
   BACKUP_DIR=$1
   # input file which contains dirs and files to watch
   INPUT=$2
else
   printf "no arguments. \ninput backup directory and input file"
   exit
fi



mkdir -p "$BACKUP_DIR"
echo "Backup dir created"
LOG_DIR="/var/log/.wd/"
mkdir -p "$LOG_DIR"
chattr +a /var/log/.wd/


# Read files and to watch
while IFS= read -r line; do
   if [ -d "$line" ]; then

   #LAST_CHAR="${ROW: -1}"
   #if [[ "$LAST_CHAR" == "/" ]]; then
      # handle folders
      for filename in "$line"/*; do
         #if [ -f "$filename" ]; then
            # ADD THE THNIGLY
         #else if [ -d "$filename" ]; then
            # ADD THE THINGY
            echo "$filename" >> "$INPUT"
         #fi
      done
   elif [ -f "$line" ]; then

      # handle files
      #if [ -e "$filename"
      printf "adding file to watchlist: %s\n" "$line"
      cp -p --parents "$line" "$BACKUP_DIR"
   else
      printf "file or folder %s doesn't exist\n" "$line"
   fi
done < "$INPUT"


while true; do
   while IFS= read -r line; do
      [ -f "$line" ] || continue
      diff -q "$line" "$BACKUP_DIR$line"
      DIFF_EXIT_CODE=$?


      if [ "$DIFF_EXIT_CODE" -eq 1 ]; then
         echo "============" >> "$LOG_DIR/wd.log"
         echo "Woof! File change detected on file $line"
         echo "CHANGE on file $line at $(date)" >> "$LOG_DIR/wd.log"
         diff "$line" "$BACKUP_DIR$line" >> "$LOG_DIR/wd.log"
         cp -p "$line" "$BACKUP_DIR$line"
      fi
   done < "$INPUT"

   sleep 3
done


# v1.0.0 -> watch files and output changes to log
# v1.1.0 -> add support for watching directories
# v1.1.1 -> mark only .wd dir as append only instead of /var/log
