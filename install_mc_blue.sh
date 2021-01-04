#!/bin/bash

cp /usr/share/mc/skins
wget https://raw.githubusercontent.com/almakano/devops/main/usr/share/mc/skins/blue.ini
sed -i 's/skin=default/skin=blue/' ~/.config/mc/ini

exit 0;
