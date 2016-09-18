#!/bin/sh

sudo yum install -y firewalld

sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config

ENABLED=$(sudo systemctl status firewalld | grep "Active: active" | wc -l)

if [ "$ENABLED" -eq "1" ]
then
  echo "Disabling selinux"
  sudo systemctl disable firewalld
  sudo systemctl stop firewalld
else
	echo "Selinux already disabled"
fi

sudo setenforce 0


echo "OK"