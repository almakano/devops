#!/bin/bash

if [ ! -f "/usr/share/mc/skins/blue.ini" ]; then
  wget https://raw.githubusercontent.com/almakano/devops/main/usr/share/mc/skins/blue.ini -O /usr/share/mc/skins/blue.ini
fi 
sed -i 's/skin=default/skin=blue/' ~/.config/mc/ini

exit 0;
