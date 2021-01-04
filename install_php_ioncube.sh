#!/bin/bash

wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar xvfz ioncube_loaders_lin_x86-64.tar.gz
rm -rf /var/lib/ioncube/
mv ioncube /var/lib/
rm ioncube_loaders_lin_x86-64.tar.gz

phpver=$(php -i | grep 'PHP Version' | head -n 1 | awk '{print $4}')
phpver=${phpver%.*}

if [ ! -f "/var/lib/ioncube/ioncube_loader_lin_${phpver}.so" ]; then
  echo "Requested version not found"
  exit 1;
fi

echo 'zend_extension=/var/lib/ioncube/ioncube_loader_lin_${phpver}.so' > /etc/php/$phpver/mods-available/ioncube.ini
echo 'zend_extension_ts=/var/lib/ioncube/ioncube_loader_lin_${phpver}_ts.so >> /etc/php/$phpver/mods-available/ioncube.ini

ln -s ../mods-available/ioncube.ini /etc/php/$phpver/fpm/00-ioncube.ini
ln -s ../mods-available/ioncube.ini /etc/php/$phpver/cli/00-ioncube.ini
ln -s ../mods-available/ioncube.ini /etc/php/$phpver/apache2/00-ioncube.ini

echo "Installed"
exit 0;
