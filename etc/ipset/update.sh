#!/bin/bash

iptables-save | grep '/32 -j REJECT' | awk '{print $4}' | sort | uniq >> /etc/ipset/blacklist_auth.txt
iptables-restore < /etc/iptables/rules
cat /etc/ipset/blacklist_auth.txt | sort | uniq > /etc/ipset/blacklist_auth2.txt
rm /etc/ipset/blacklist_auth.txt; mv /etc/ipset/blacklist_auth2.txt /etc/ipset/blacklist_auth.txt

searchpattern="(0x%5B%5D=|wp-admin|wp-config|wp-login|wp-content|wp-includes|wp-json|archive.zip|\.env|\.svn|\.git|phpinfo\.php|config\.inc\.php)"

zcat /home/*/w*/*/logs/*nginx*.log*.gz | grep -E "$searchpattern" | grep -vE '" (200|301|302) ' | awk '{print $2}' | grep -vE '([a-zа-я]|127.0.0.1)' | sort | uniq >> /etc/ipset/blacklist_web.txt;
cat /home/*/w*/*/logs/*nginx*.log | grep -E "$searchpattern" | grep -vE '" (200|301|302) ' | awk '{print $2}' | grep -vE '([a-zа-я]|127.0.0.1)' | sort | uniq >> /etc/ipset/blacklist_web.txt;
cat /etc/ipset/blacklist_web.txt | sort | uniq >> /etc/ipset/blacklist_web2.txt
rm /etc/ipset/blacklist_web.txt; mv /etc/ipset/blacklist_web2.txt /etc/ipset/blacklist_web.txt

echo "create whitelist_ip4 hash:net family inet hashsize 4096 maxelem 800000" > /etc/ipset/rules
sed 's/^/add whitelist_ip4 /' /etc/ipset/whitelist*.txt >> /etc/ipset/rules
echo "create blacklist_ip4 hash:net family inet hashsize 4096 maxelem 800000" >> /etc/ipset/rules
sed 's/^/add blacklist_ip4 /' /etc/ipset/blacklist*.txt >> /etc/ipset/rules

ipset restore -! < /etc/ipset/rules

exit 0
