#!/bin/sh
# sh wordpress.sh --db-name=wordpress --db-user=wordpress --target-dir=/var/www/html/wp0
set -x
set -e

for i in "$@"
do
case $i in
  --db-name=*)
    DB_NAME="${i#*=}"
    shift # past argument=value
  ;;
  --db-user=*)
    DB_USER="${i#*=}"
    shift # past argument=value
  ;;
  --wp-password=*)
    WP_PASSWORD="${i#*=}"
    shift # past argument=value
  ;;
  --target-dir=*)
    TARGET_DIR="${i#*=}"
    shift # past argument=value
  ;;
  *)
    # unknown option
  ;;
esac
done



if [ -z $TARGET_DIR ]
then
  TARGET_DIR="/var/www/html/wordpress"
fi

if [ -z $WP_PASSWORD ]
then
  WP_PASSWORD=`dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev`
fi

if [ -z $DB_NAME ]
then
  echo "--db-name is required"
  echo "KO"
  exit 1
fi

if [ -z $DB_USER ]
then
  echo "--db-user is required"
  echo "KO"
  exit 1
fi

echo "Using password: $WP_PASSWORD"
echo "Target directory: $TARGET_DIR"
echo "Wordpress: $WP_PASSWORD" | sudo tee -a /root/passwords.txt

ROOT_MYSQL_PASSWORD=$(sudo cat /root/mysql.txt)

mysql -uroot -p$ROOT_MYSQL_PASSWORD <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$PASSWORD';
GRANT ALL PRIVILEGES ON $DB_USER.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$PASSWORD';
FLUSH PRIVILEGES;
MYSQL_SCRIPT


cd /tmp/
rm -rf wordpress
wget --quiet https://wordpress.org/latest.zip -O wordpress.zip
unzip wordpress.zip
cp wordpress/wp-config-sample.php wordpress/wp-config.php

sed -i "s/'database_name_here'/'DB_NAME/g"       /tmp/wordpress/wp-config.php
sed -i "s/'username_here'/'$DATABASE_USER'/g"            /tmp/wordpress/wp-config.php
sed -i "s/'password_here'/'$WORDPRESS_MYSQL_PASSWORD'/g" /tmp/wordpress/wp-config.php
for i in $(seq 1 8); do
  wp_salt=$(</dev/urandom tr -dc 'a-zA-Z0-9!@#$%^&*()\-_ []{}<>~`+=,.;:/?|' | head -c 64 | sed -e 's/[\/&]/\\&/g')
  sed -i "s/put your unique phrase here/$wp_salt/g" /tmp/wordpress/wp-config.php
done

mkdir -p /var/www/html/
sudo mv /tmp/wordpress $TARGET_DIR
sudo chown -Rf nginx:nginx /var/www/html
