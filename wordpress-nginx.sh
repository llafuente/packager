#!/bin/sh

set -x
set -e

SSL=0
for i in "$@"
do
case $i in
  --ssl)
    SSL=1
    shift # past argument=value
  ;;
  *)
    # unknown option
  ;;
esac
done

LOCAL_FILE_PATH=./ # local
LOCAL_FILE_PATH=~/vagrant/ #aws

sudo cp -rf ${LOCAL_FILE_PATH}nginx/global /etc/nginx/sites-available/global

if [ $SSL -eq 1 ]; then
  sudo cp -rf ${LOCAL_FILE_PATH}nginx/wordpress-site-ssl.conf /etc/nginx/sites-available/wordpress-site-ssl.conf
else
  sudo cp -rf ${LOCAL_FILE_PATH}nginx/wordpress-site.conf /etc/nginx/sites-available/wordpress-site.conf
fi
