#!/bin/sh

printf "run with sudo\n"

SUS_IP="10.67.2.26"

{

while true; do
   A=$(ss -plant | grep "$SUS_IP" | grep ESTAB)
   if [ -n "$A" ]; then
      printf "$A\n"
      break
   fi
   sleep .2
done

} | tee -a "beaconfinder.log"
