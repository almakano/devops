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

wget https://raw.githubusercontent.com/almakano/devops/main/etc/ipset/update.sh -O /etc/ipset/update.sh
chmod 0755 /etc/ipset/update.sh
/etc/ipset/update.sh

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
