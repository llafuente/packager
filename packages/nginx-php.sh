#!/bin/sh

# PHP 7.0.11 + FPM

set -x
set -e

#sudo yum install -y php php-mysql php-fpm

sudo yum install -y --nogpgcheck epel-release
sudo rpm -qa | grep -q remi-release || sudo rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

sudo yum --enablerepo=remi,remi-php70 install -y --nogpgcheck php php-mysql php-fpm php-apc
# other packages:
# php-opcache php-devel pcre-devel php-pear php-pecl-xdebug php-pecl-memcached php-xml php-gd php-mbstring php-mcrypt php-soap php-json php-curl


sudo sed -i "s/;cgi\.fix_pathinfo\=1/cgi.fix_pathinfo=0/g" /etc/php.ini


sudo sed -i "s@listen \= 127\.0\.0\.1:9000@listen = /var/run/php-fpm/php-fpm.sock@g" /etc/php-fpm.d/www.conf
sudo sed -i "s/;listen\.owner \= nobody/listen.owner = nobody/g" /etc/php-fpm.d/www.conf
sudo sed -i "s/;listen\.group \= nobody/listen.group = nobody/g" /etc/php-fpm.d/www.conf
sudo sed -i "s/user \= apache/user = nginx/g" /etc/php-fpm.d/www.conf
sudo sed -i "s/group \= apache/group = nginx/g" /etc/php-fpm.d/www.conf

# fix failed (13: Permission denied) while connecting to upstream...
# change user to listen.owner/group to nginx/nginx don't solve anything...
sudo usermod -G nobody nginx

cd /tmp
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

sudo systemctl start php-fpm
sudo systemctl enable php-fpm

#sudo /sbin/restorecon -R /var/www/.

php --version

echo "OK"