#!/bin/bash
set -e

echo "[*] Applying hardened firewall rules..."

#precaution
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT

# Flush existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t mangle -F

# Loopback
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established / related
iptables -A INPUT  -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# --------------------------------------------------
# Allow inbound traffic ONLY to listening TCP ports
# --------------------------------------------------
echo "[*] Detecting listening TCP ports..."

LISTEN_PORTS=$(ss -ltnH | awk '{print $4}' | sed 's/.*://' | sort -n | uniq)

for PORT in $LISTEN_PORTS; do
    echo "    [+] Allow inbound TCP port $PORT"
    iptables -A INPUT -p tcp --dport "$PORT" -m conntrack --ctstate NEW -j ACCEPT
done

# --------------------------------------------------
# Essential outbound services
# --------------------------------------------------

# DNS
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# ICMP
iptables -A INPUT -p icmp -j ACCEPT

# HTTP / HTTPS (apt, certs, mirrors)
iptables -A OUTPUT -p tcp --dport 80  -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

#ISTS Only
iptables -A OUTPUT -p tcp --dport 514  -j ACCEPT

# --------------------------------------------------
# DHCP (only if interface is using it)
# --------------------------------------------------
if ss -lunH | grep -q ':68'; then
    echo "    [+] DHCP detected — allowing lease renewal"
    iptables -A OUTPUT -p udp --sport 68 --dport 67 -j ACCEPT
    iptables -A INPUT  -p udp --sport 67 --dport 68 -j ACCEPT
fi

# --------------------------------------------------
# Optional logging (rate limited)
# --------------------------------------------------
iptables -A INPUT  -m limit --limit 5/min -j LOG --log-prefix "DROP_INPUT "
iptables -A OUTPUT -m limit --limit 5/min -j LOG --log-prefix "DROP_OUTPUT "

# Default deny
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Drop invalid early
iptables -A INPUT  -m conntrack --ctstate INVALID -j DROP
iptables -A OUTPUT -m conntrack --ctstate INVALID -j DROP

#v6
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1

ip6tables -P INPUT DROP
ip6tables -P OUTPUT DROP
ip6tables -P FORWARD DROP

echo "[*] Saving iptable rules across reboot..."

iptables-save -f /etc/iptables/iptables.rules
ip6tables-save -f /etc/iptables/ip6tables.rules

echo "[✓] Firewall locked down successfully."
