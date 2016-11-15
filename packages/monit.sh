#!/bin/sh

set -x
set -e

# TODO this may check what is installed in the machine, and add only what's needed

sudo yum install -y monit

sudo cp -rf "${INSTALLER_PATH}/monit/mariadb" /etc/monit.d/mariadb
sudo cp -rf "${INSTALLER_PATH}/monit/nginx" /etc/monit.d/nginx
sudo cp -rf "${INSTALLER_PATH}/monit/php-fpm" /etc/monit.d/php-fpm


cat <<DELIM | sudo tee /etc/yum.repos.d/MariaDB.repo
set daemon  60
set logfile syslog

set logfile /var/log/monit.log

set httpd port 2812 and
    use address 0.0.0.0    # listen any IP
    allow 0.0.0.0/0.0.0.0  # allow localhost to connect to the server and
    allow admin:monit      # require user 'admin' with password 'monit'

include /etc/monit.d/*

DELIM

sudo systemctl enable monit
sudo systemctl start monit

echo "OK"
