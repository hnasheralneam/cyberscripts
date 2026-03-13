# Dependencies
Only for the host system  
parallel, sshpass  

# Order of operations
-> YOU NEED TO CREATE A `hostname` FILE  
  -> must be in this format:  
  -> `<ip> <system-name> <new-password-hash>`  
  -> one line per host
  -> pregenerate all password hashes with the script in funcs  
-> execute `deploy.sh <current-username> <current-password>`, which runs  
  -> harden.sh (sets /bin/false shells, add bluey, sets bluey password)  
  -> autofirewall.sh (sets iptable rules)  
  -> uploads baseline and other scripts to /tmp
-> execute `activate.sh <system-name>`
  -> runs backup.sh
  -> deploys auditd rules
  -> deploys watchdawg
