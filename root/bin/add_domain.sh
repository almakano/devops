#!/bin/bash

if [[ -z "$1" || -z "$2" ]]; then
	echo "Usage: ${0##*/}" user domain
	exit 1;
fi

user="$1"
domain="$2"

echo "Creating user homedir"
if [[ "$(id -gn $user)" != "$user" ]]; then useradd $user; fi

mkdir -p "/home/$user/web/$domain/public_html"
mkdir -p "/home/$user/web/$domain/conf/ssl"
mkdir -p "/home/$user/web/$domain/logs"
mkdir -p "/home/$user/web/$domain/tmp"
mkdir -p "/home/$user/web/$domain/backup"

echo "Copying nginx apache config files"
cp /etc/nginx/defaults/server.conf "/home/$user/web/$domain/conf/nginx.conf"
cp /etc/apache2/defaults/server.conf "/home/$user/web/$domain/conf/apache.conf"
sed -i "s/DOMAINNAME/$domain/g" "/home/$user/web/$domain/conf/nginx.conf"
sed -i "s/USERNAME/$user/g" "/home/$user/web/$domain/conf/nginx.conf"
sed -i "s/DOMAINNAME/$domain/g" "/home/$user/web/$domain/conf/apache.conf"
sed -i "s/USERNAME/$user/g" "/home/$user/web/$domain/conf/apache.conf"

echo "Creating ssl certificate"
certbot certonly --agree-tos --webroot -w /var/www/html -d $domain
ln -s /etc/letsencrypt/live/$domain/privkey.pem "/home/$user/web/$domain/conf/ssl/${domain}.key"
ln -s /etc/letsencrypt/live/$domain/fullchain.pem "/home/$user/web/$domain/conf/ssl/${domain}.pem"

sed -i "s/#	ssl/	ssl/g" "/home/$user/web/$domain/conf/nginx.conf"
sed -i "s/#	listen/	listen/g" "/home/$user/web/$domain/conf/nginx.conf"

echo "Restarting nginx"
service nginx restart
echo "Restarting apache"
service apache2 restart

echo "<?php echo '$domain' ?>" > "/home/$user/web/$domain/public_html/index.php"

chown -R $user:$user "/home/$user"

echo "Creating git commit"
su -c "cd ~/web/$domain/public_html/; git init; git add .; git commit -m 'Init'" $user
