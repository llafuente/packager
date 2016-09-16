#!/bin/sh

set -x
set -e


sudo cp -rf nginx/global /etc/nginx/sites-available/global
sudo cp -rf nginx/wordpress-site.conf /etc/nginx/sites-available/wordpress-site.conf
#cp -rf nginx/wordpress-site-ssl.conf /etc/nginx/sites-available/wordpress-site-ssl.conf
