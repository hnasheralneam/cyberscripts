#!/bin/sh
#Run this to prep for deploy
#./gen.sh <user> <pass>
printf '#!/bin/sh\nprintf '\""$2\\\n"\" > pass

while IFS= read -r line; do
  printf "%s %s %s\n" "$line" "$1" "$2" >> hostfile
done < "ips" 

