#!/bin/sh

set -exuo pipefail

WP_LANG_ES=

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
  --db-password=*)
    DB_PASSWORD="${i#*=}"
    shift # past argument=value
  ;;
  --target-dir=*)
    TARGET_DIR="${i#*=}"
    shift # past argument=value
  ;;
  --lang-es)
    WP_LANG_ES="1"
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

if [ -z $DB_PASSWORD ]
then
  DB_PASSWORD=$(</dev/urandom tr -dc 'a-zA-Z0-9' | head -c 64 | sed -e 's/[\/&]/\\&/g')
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

echo "Using password: ${DB_PASSWORD}"
echo "Target directory: ${TARGET_DIR}"
echo "Wordpress (${TARGET_DIR}): ${DB_PASSWORD}" | sudo tee -a /root/passwords.txt

ROOT_MYSQL_PASSWORD=$(sudo cat /root/mysql.txt)

mysql -uroot -p$ROOT_MYSQL_PASSWORD <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_USER}.* TO '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
FLUSH PRIVILEGES;
MYSQL_SCRIPT


cd /tmp/
rm -rf wordpress
wget --quiet https://wordpress.org/latest.zip -O wordpress.zip
unzip wordpress.zip
cp wordpress/wp-config-sample.php wordpress/wp-config.php

sed -i "s/'database_name_here'/'${DB_NAME}'/g"       /tmp/wordpress/wp-config.php
sed -i "s/'username_here'/'${DB_USER}'/g"            /tmp/wordpress/wp-config.php
sed -i "s/'password_here'/'${DB_PASSWORD}'/g" /tmp/wordpress/wp-config.php
for i in $(seq 1 8); do
  wp_salt=$(</dev/urandom tr -dc 'a-zA-Z0-9!@#$%^&*()\-_ []{}<>~`+=,.;:/?|' | head -c 64 | sed -e 's/[\/&]/\\&/g')
  sed -i "s/put your unique phrase here/$wp_salt/g" /tmp/wordpress/wp-config.php
done

mkdir -p /var/www/html/
sudo mv /tmp/wordpress ${TARGET_DIR}
sudo chown -Rf ec2-user:ec2-user ${TARGET_DIR}
# go-rx,u-rwx
sudo chmod 755 -R ${TARGET_DIR}
sudo mkdir -p ${TARGET_DIR}/wp-content/uploads/
sudo chmod 777 -R ${TARGET_DIR}/wp-content/uploads/
sudo chmod 755 ${TARGET_DIR}/wp-content/uploads/
#sudo chmod 400 -R ${TARGET_DIR}/wp-config.php

# spanish translation
if [ ! -z ${LANG_ES} ]; then
  rm -rf wordpress
  cd /tmp/
  wget --quiet zip https://es.wordpress.org/wordpress-4.6.1-es_ES.zip -O wordpress-es_ES.zip
  unzip wordpress-es_ES.zip
  mkdir -p ${TARGET_DIR}/wp-content/languages/
  cp -rf /tmp/wordpress/wp-content/languages/* ${TARGET_DIR}/wp-content/languages/
  rm -rf wordpress
fi


echo "OK"
