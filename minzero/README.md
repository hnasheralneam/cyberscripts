# Dependencies:
GNU Parallel: `sudo apt install parallel`  

# Order of operations:  
-> YOU NEED TO CREATE A `hostname` FILE  
  -> `hostname` should be in this format:  
  -> `<ip> <dir> <new-password-hash>`  
  -> Pregenerate all password hashes with the script in funcs  
-> execute `deploy.sh <username> <password>`, which runs  
  -> harden.sh (sets /bin/false shells, add bluey, sets bluey password)  
  -> autofirewall.sh (sets iptable rules)  
  -> uploads recon.sh to /tmp
