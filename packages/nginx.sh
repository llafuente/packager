#!/bin/sh

LOCAL_FILE_PATH=~/vagrant #aws
LOCAL_FILE_PATH=.. # local

set -x
set -e

sudo yum install -y epel-release
sudo yum install -y nginx

sudo mkdir -p /etc/nginx/sites-available
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

# curl 'https://raw.githubusercontent.com/llafuente/vagrant/master/nginx/nginx.conf'

sudo cp -f ${LOCAL_FILE_PATH}/nginx/nginx.conf /etc/nginx/nginx.conf

sudo systemctl start nginx
sudo systemctl enable nginx

nginx -v

#result
RESULT=$(systemctl status nginx.service | grep 'Active: active (running)' | wc -l)
if [ "${RESULT}" == "1" ]
then
  echo "OK"
else
  echo "ERROR"
fi
