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

# this fix another nginx error with reverse-proxy
# 2017/08/02 11:19:11 [crit] 25186#0: *26 connect() to [::1]:8080 failed (13: Permission denied) while connecting to upstream, client: ***, server: , request: "GET / HTTP/1.1", upstream: "http://[::1]:8080/", host: "***"
sudo setsebool -P httpd_can_network_connect 1

# under normal circunstances to really stop the selinux need a reboot
# this get info about the running selinux config, should be: SELinux status:                 disabled
/usr/sbin/sestatus

echo "OK"
