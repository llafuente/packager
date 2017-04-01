#!/bin/sh

set -x

WEB_PATH="/var/www/html/XXX"
WEB_TARGZ="/var/www/html/XXX.wordpress.tar.gz"
DB_NAME="wordpress"
DB_TARGZ="/var/www/html/XXX.database.tar.gz"
CFG_FILES="/etc/nginx/sites-available/XXX-wordpress-site.conf /etc/nginx/sites-available/global/restrictions.conf /etc/nginx/sites-available/global/wordpress.conf"
CFG_TARGZ="/var/www/html/XXX.config.tar.gz"




cat <<SCRIPT | ssh -i ~/.ssh/${AWS_CLIENT_PEM}.pem ec2-user@${INSTANCE_IP} "bash -s" --

set -x

sudo rm ${WEB_TARGZ}
sudo rm ${DB_TARGZ}
sudo rm ${CFG_TARGZ}

cd /tmp
ROOT_MYSQL_PASSWORD=\$(sudo cat /root/mysql.txt)
mysqldump -uroot -p\$ROOT_MYSQL_PASSWORD --databases ${DB_NAME} > /tmp/database.sql
sudo tar -zcvf ${DB_TARGZ} database.sql

sudo tar -zcf ${WEB_TARGZ} ${WEB_PATH}

sudo tar -zcf ${CFG_TARGZ} ${CFG_FILES}

sudo tar -tf ${DB_TARGZ}
sudo tar -tf ${CFG_TARGZ}

SCRIPT
