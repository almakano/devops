#!/bin/bash

if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
	echo "Usage: ${0##*/} user database domain"
	exit 1;
fi

user="$1"
database="$2"
domain="$3"
backupdir="/home/$user/backups/domain/"

mkdir -p "$backupdir"
mysqldump --routines --triggers --events --skip-comments --skip-disable-keys --no-create-db -u $user -p $database | gzip > "$backupdir/$domain.sql.gz"
cd /home/$user/web/$domain; zip --symlinks -r "$backupdir/$domain.zip" .
