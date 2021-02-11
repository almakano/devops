#!/bin/bash

iptables-save | grep '/32 -j REJECT' | awk '{print $4}' | sort | uniq >> /etc/ipset/blacklist_auth.txt
iptables-restore < /etc/iptables/rules
cat /etc/ipset/blacklist_auth.txt | sort | uniq > /etc/ipset/blacklist_auth2.txt
rm /etc/ipset/blacklist_auth.txt
mv /etc/ipset/blacklist_auth2.txt /etc/ipset/blacklist_auth.txt

echo "create whitelist_ip4 hash:net family inet hashsize 4096 maxelem 800000" > /etc/ipset/rules
sed 's/^/add whitelist_ip4 /' /etc/ipset/whitelist*.txt >> /etc/ipset/rules
echo "create blacklist_ip4 hash:net family inet hashsize 4096 maxelem 800000" >> /etc/ipset/rules
sed 's/^/add blacklist_ip4 /' /etc/ipset/blacklist*.txt >> /etc/ipset/rules

ipset restore -! < /etc/ipset/rules

exit 0
