#!/bin/sh

set -x
set -e

# TODO this may check what is installed in the machine, and add only what's needed

sudo yum install -y monit

sudo cp -rf "${INSTALLER_PATH}/monit/mariadb" /etc/monit.d/mariadb
sudo cp -rf "${INSTALLER_PATH}/monit/nginx" /etc/monit.d/nginx
sudo cp -rf "${INSTALLER_PATH}/monit/php-fpm" /etc/monit.d/php-fpm


echo "OK"
