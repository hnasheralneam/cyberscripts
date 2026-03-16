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
- Add backup for sql, mongodb, and docker
- Migrate splunk deploy and time sync deploy from ansible
- Fix specific baseline script
- Write fake shell to replace /bin/false (discord ping when used)
- Test test test test test
- In-place deploy
- Upload busybox binary
- Toggle outgoing on and off for package installs in activate
- Investigate https://github.com/MZBCodes/NCAE-CyberGames/blob/main/Scripts/base_harden.sh
- Use inotifywait for watchdawg
- deploy auditd-notifier in activate
- migrate from iptables to nftables
- in standard baseline run linpeas as non-root
- pipe baseline specifc out to a file, and through less
