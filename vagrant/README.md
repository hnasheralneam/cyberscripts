# Vagrant

Useful for quickly spinning up test environments  

First, install vagrant and run `vagrant plugin install vagrant-libvirt` to install native virtualization support  
With the current setup, run `vagrant up` to set up the boxes, with user vagrant and password vagrant  
SSH in using the provided ip, or use `vagrant ssh <box>` to use the embedded key  
To make snapshots, use `vagrant snapshot save <box> <snapshot>` and restore with `vagrant snapshot restore <box> <snapshot>`  

Current setup includes Ubuntu, Fedora, and Alpine
