#!/bin/sh

set -exuo pipefail

# centos 7 don't have firewalld service in minimal distro
sudo yum install -y firewalld

# disable by config
sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config

# check if it's running
ENABLED=$(sudo systemctl status firewalld | grep "Active: active" | wc -l)

if [ "$ENABLED" -eq "1" ]
then
  echo "Disabling selinux"
  sudo systemctl disable firewalld
  sudo systemctl stop firewalld
else
  echo "Selinux already disabled"
fi

# this fix nginx - php-fpm
sudo setenforce 0

echo "OK"
