# CyberDawgs Automation Suite
Courtesy of Dipa and Hamza  

## Vagrant
We're using Vagrant for spinning up test environments to quickly test scripts across multiple distros; there are more setup details in the `testing` directory.  

## Documentation
For information on what the scripts do/how they work/when to use them, visit the docs:
```
https://docs.dawgsec.com
User: team
Password: cyberdawgs4eva
```
And check out the README in the `minzero` directory.  

## To-do
- Offline auditd installation
- Revise audit-rules file
- Dynamic auditd rule installtion script for watching binaries based on specific paths on different distros
- In-place deploy (try localhost on deploy)
- deploy auditd-notifier in activate
- pipe baseline specific out to a file, and through less
- deploy runs backup and sends back to system executed from
- move suid bits to baseline specific

- jumpstart script curled into shell that installs packages and pulls repo + runs deploy
- Toggle outgoing on and off for package installs in activate
- Investigate https://github.com/MZBCodes/NCAE-CyberGames/blob/main/Scripts/base_harden.sh
- Use inotifywait for watchdawg
- in standard baseline run linpeas as non-root
- Write fake shell to replace /bin/false (discord ping when used) or rbash
- Windows scripting :(

# To-done  
- add busybox binary to repo
- apply busybox on systems
- add readme for baselines
- add linpeas to binaries folder
- move oldpass and olduser from deploy params to hostfile
- deploy stops logging success messages if it fails to connect to system
- add internet check to active and skip blocking install commands if disconnected
- fix blocking syntax error in baseline/standard.sh
- use binaries/linpeas.sh instead of pulling from internet
