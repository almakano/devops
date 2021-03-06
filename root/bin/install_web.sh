#!/bin/bash

if [[ -z "$1" ]]; then
	echo "Usage: ./${0##*/} mysql_admin_user_name"
	exit 1;
fi

echo "Install console benefits"
apt install -y curl wget gcc g++ git make bash-completion net-tools htop ngrep tcpdump mtr ipset easy-rsa mc rsync lm-sensors
apt install -y gnupg2 ca-certificates lsb-release software-properties-common python-software-properties zip language-pack-ru screen

dpkg-reconfigure tzdata
dpkg-reconfigure locales

echo "Set console colors"
sed -i '/PS1/d' /root/.bash_profile
if [[ -z $(grep 'EDITOR=mcedit' /root/.bash_profile) ]]; then 
	echo "export PS1='\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\H \[\033[01;33m\]\w \[\033[01;35m\]\$ \[\033[00m\]'" >> /root/.bash_profile
	echo "eval \"`dircolors`\"" >> /root/.bash_profile
	echo "export EDITOR=mcedit" >> /root/.bash_profile
	echo "export LS_OPTIONS='--color=auto -h'" >> /root/.bash_profile
fi

echo "Install php7.4"
add-apt-repository ppa:ondrej/php; apt update;
apt install -y php7.4 php7.4-fpm php7.4-mbstring php7.4-curl php7.4-mysql php7.4-opcache php7.4-gd php7.4-imagick php7.4-xml php7.4-zip

echo "Install apache"
apt install -y apache2 libapache2-mpm-itk libapache2-mod-ruid2 libapache2-mod-rpaf libapache2-mod-php7.4
a2enmod -q alias; a2enmod -q actions; a2enmod -q cgi; a2enmod -q mpm_prefork; a2enmod -q remote_ip; a2enmod -q rewrite; a2enmod -q setenvif; a2enmod -q vhost_alias; 
a2dismod -q ssl
wget https://raw.githubusercontent.com/almakano/devops/main/etc/apache2/apache2.conf -O /etc/apache2/apache2.conf
if [ -f /etc/apache2/ports.conf ]; then rm /etc/apache2/ports.conf; fi
service apache2 restart

echo "Install nginx"
echo "deb http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list; apt update; apt install -y nginx
curl -o /etc/apt/trusted.gpg.d/nginx_signing.asc https://nginx.org/keys/nginx_signing.key

if [[ -z $(grep 'web' /etc/nginx/nginx.conf) ]]; then 
	cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
	echo "include /home/*/web/*/conf/nginx*.conf;" >> /etc/nginx/nginx.conf;
fi

echo "Install mysql memcached"
apt install -y mysql-server-8.0 memcached libmemcached-dev
echo "Add mysql user $1"
echo "CREATE USER '$1'@'%' IDENTIFIED BY '$1'; GRANT ALL PRIVILEGES ON *.* TO '$1'@'%' WITH GRANT OPTION; flush privileges;" | mysql 

echo "Install exim4"
apt install -y exim4 bsd-mailx
mkdir -p /etc/exim4/dkim/
openssl genrsa -out /etc/exim4/dkim/default.key 2048
openssl rsa -in /etc/exim4/dkim/default.key -pubout > /etc/exim4/dkim/default.pem
echo "DKIM_KEY_FILE = /etc/exim4/dkim/default.key
DKIM_PRIVATE_KEY = ${if exists{DKIM_KEY_FILE}{DKIM_KEY_FILE}{0}}
DKIM_SELECTOR = mail" > /etc/exim4/exim4.conf.template2
cat /etc/exim4/exim4.conf.template >> /etc/exim4/exim4.conf.template2
rm /etc/exim4/exim4.conf.template
mv /etc/exim4/exim4.conf.template2 /etc/exim4/exim4.conf.template

dpkg-reconfigure exim4-config

echo "Install nodejs npm"
curl -sL https://deb.nodesource.com/setup_12.x | bash -
apt install -y npm

echo "Install certbot"
add-apt-repository ppa:certbot/certbot; apt update
apt install -y certbot
(crontab -l 2>/dev/null; echo "0 0 * * * /usr/bin/certbot renew") | crontab -

echo "Install composer"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer

exit 0;
