#!/bin/sh

set -x
set -e

sudo yum install -y epel-release
sudo yum install -y nginx

mkdir -p /etc/nginx/sites-available
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
cp -f nginx/nginx.conf /etc/nginx/nginx.conf

sudo systemctl start nginx
sudo systemctl enable nginx

curl localhost | grep 'Welcome'

nginx -v


echo "OK"
