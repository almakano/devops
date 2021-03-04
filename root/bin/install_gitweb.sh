#!/bin/sh

git clone git://git.kernel.org/pub/scm/git/git.git
cd git/
make GITWEB_PROJECTROOT="/opt/git" prefix=/usr gitweb
mv gitweb /var/www/
cd ../
rm -rf git/

mkdir -p /var/www/gitweb/conf
wget https://raw.githubusercontent.com/almakano/devops/main/var/www/gitweb/conf/apache.conf -O /var/www/gitweb/conf/apache.conf
wget https://raw.githubusercontent.com/almakano/devops/main/var/www/gitweb/conf/nginx.conf -O /var/www/gitweb/conf/nginx.conf

service nginx configtest && service nginx restart
apachectl configtest && service apache2 restart
