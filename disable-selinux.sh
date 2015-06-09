#!/bin/sh

sed -i 's/enforcing/disabled/g' /etc/selinux/config

sudo systemctl disable firewalld
sudo systemctl stop firewalld
