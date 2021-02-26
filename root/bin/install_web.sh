#!/bin/bash

if [[ -z "$1" ]]; then
	echo "Usage: ./${0##*/} mysql_admin_user_name"
	exit 1;
fi

echo "Install console benefits"
apt install -y curl wget gcc g++ git make bash-completion net-tools htop ngrep tcpdump mtr ipset easy-rsa mc rsync lm-sensors
apt instal -y gnupg2 ca-certificates lsb-release python-software-properties

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
apt install -y apache2 libapache2-mpm-itk libapache2-mod-ruid2 libapache2-mod-rpaf libapache2-mod-php8.0 libapache2-mod-php7.4
a2enmod -q alias; a2enmod -q actions; a2enmod -q cgi; a2enmod -q mpm_prefork; a2enmod -q remote_ip; a2enmod -q rewrite; a2enmod -q ruid2; a2enmod -q setenvif; a2enmod -q vhost_alias; 
a2dismod -q ssl
wget https://raw.githubusercontent.com/almakano/devops/main/etc/apache2/apache2.conf -O /etc/apache2/apache2.conf
if [ -f /etc/apache2/ports.conf ]; then rm /etc/apache2/ports.conf; fi
service apache2 restart

echo "Install nginx"
echo "deb http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list; apt update; apt install -y nginx
if [[ -z $(grep 'web' /etc/nginx/nginx.conf) ]]; then 
	cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
	echo "include /home/*/web/*/conf/nginx*.conf;" >> /etc/nginx/nginx.conf;
fi

echo "Install mysql memcached"
apt install -y mysql-server-8.0 memcached libmemcached-dev
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
