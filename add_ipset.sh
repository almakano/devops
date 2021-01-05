#!/bin/bash

apt install ipset iptables-persistent

if [ ! -d /etc/ipset ]; then mkdir /etc/ipset; fi
if [ ! -d /etc/iptables ]; then mkdir /etc/iptables; fi
if [ ! -f /etc/rc.local ]; then 
    echo "#!/bin/sh -e" > /etc/rc.local
    chmod 755 /etc/rc.local
fi

if [ -z "$(grep -iRI 'ipset restore' /etc/rc.local)" ]; then 
    echo "ipset restore -! < /etc/ipset/rules" >> /etc/rc.local
fi
if [ -z "$(grep -iRI 'iptables-restore' /etc/rc.local)" ]; then 
    echo "iptables-restore < /etc/iptables/rules" >> /etc/rc.local
fi
if [ -z "$(grep -iRI 'exit 0' /etc/rc.local)" ]; then 
    echo "exit 0" >> /etc/rc.local
fi

echo "create whitelist_ip4 hash:net family inet hashsize 4096 maxelem 800000" > /etc/ipset/rules
sed 's/^/add whitelist_ip4 /' /etc/ipset/whitelist*.txt >> /etc/ipset/rules
echo "create blacklist_ip4 hash:net family inet hashsize 4096 maxelem 800000" >> /etc/ipset/rules
sed 's/^/add blacklist_ip4 /' /etc/ipset/blacklist*.txt >> /etc/ipset/rules

ipset restore -! < /etc/ipset/rules

iptables -A INPUT -m set --match-set whitelist_ip4 src -j ACCEPT
iptables -A INPUT -m set --match-set blacklist_ip4 src -j LOG --log-prefix "Iptables: DROP ip4 "
iptables -A INPUT -m set --match-set blacklist_ip4 src -j DROP

iptables-save > /etc/iptables/rules

exit 0
