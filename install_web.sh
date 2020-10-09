#!/bin/bash

if [[ -z "$1" ]]; then
	echo "Usage: ./${0##*/} mysql_admin_user_name"
	exit 1;
fi

echo "Install console benefits"
apt install -y curl wget gcc g++ make bash-completion net-tools htop ngrep tcpdump mtr ipset easy-rsa git mc rsync lm-sensors libmemcached-dev gnupg2 ca-certificates lsb-release python-software-properties

echo "Install nginx"
echo "deb http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list; apt update; apt install -y nginx

echo "Install apache"
apt install -y apache2

echo "Install php7.4"
add-apt-repository ppa:ondrej/php; apt update; apt install -y php7.4 php7.4-fpm php7.4-mbstring php7.4-curl composer

echo "Install mysql memcached"
apt install -y mysql-server-5.7 memcached
echo "Add mysql user $1"
echo "GRANT ALL PRIVILEGES ON *.* TO '$1'@'%' IDENTIFIED BY '$1' WITH GRANT OPTION; flush privileges;" | mysql 

echo "Install exim4"
apt install -y exim4 bsd-mailx

echo "Install nodejs npm"
curl -sL https://deb.nodesource.com/setup_12.x | bash -
apt install -y npm

echo "Install certbot"
add-apt-repository ppa:certbot/certbot; apt update
apt install -y certbot python-certbot-nginx

exit 0;
