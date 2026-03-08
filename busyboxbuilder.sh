#!/bin/sh

# compile our own busybox in the background  
if [ ! -d ~/busybox-1.37.0/ ]; then  
   cd ~/  
   apt -y install bzip2 make  
   wget https://web.archive.org/web/20250808173717/https://busybox.net/downloads/busybox-1.37.0.tar.bz2 && tar -xvf busybox-1.37  
.0.tar.bz2 && cd busybox-1.37.0/ && make defconfig &>/dev/null && make &>/dev/null &  
fi  
touch /tmp/done.txt

# stores binary in /bin/busybox
