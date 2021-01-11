#!/bin/bash

if [ -z "$(dpkg -l | grep 'ipset')" ]; then 
    apt install ipset iptables-persistent
fi

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

iptables-save | grep '/32 -j REJECT' | awk '{print $4}' | sort >> /etc/ipset/blacklist_auth.txt

echo "create whitelist_ip4 hash:net family inet hashsize 4096 maxelem 800000" > /etc/ipset/rules
sed 's/^/add whitelist_ip4 /' /etc/ipset/whitelist*.txt >> /etc/ipset/rules
echo "create blacklist_ip4 hash:net family inet hashsize 4096 maxelem 800000" >> /etc/ipset/rules
sed 's/^/add blacklist_ip4 /' /etc/ipset/blacklist*.txt >> /etc/ipset/rules

ipset restore -! < /etc/ipset/rules
iptables-restore < /etc/iptables/rules

if [ -z "$(grep -iRI 'whitelist_ip4' /etc/iptables/rules)" ]; then 
    iptables -A INPUT -m set --match-set whitelist_ip4 src -j ACCEPT
fi

if [ -z "$(grep -iRI 'blacklist_ip4' /etc/iptables/rules)" ]; then 
    iptables -A INPUT -m set --match-set blacklist_ip4 src -j LOG --log-prefix "Iptables: DROP ip4 "
    iptables -A INPUT -m set --match-set blacklist_ip4 src -j DROP
fi

iptables-save > /etc/iptables/rules

exit 0
