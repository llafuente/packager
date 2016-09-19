#!/bin/sh

set -x
set -e

for i in "$@"
do
case $i in
  --mysql-password=*)
  ROOT_MYSQL_PASSWORD="${i#*=}"
  shift # past argument=value
  ;;
esac
done

if [ -z $ROOT_MYSQL_PASSWORD ]
then
  #ROOT_MYSQL_PASSWORD=`pwgen -s 40 1`
  ROOT_MYSQL_PASSWORD=`dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev`
fi

echo "Using password: $ROOT_MYSQL_PASSWORD"

# leave it somewhere known, because can be random
echo "Root MySQL Password: $ROOT_MYSQL_PASSWORD" | sudo tee -a /root/passwords.txt
echo -ne "$ROOT_MYSQL_PASSWORD" | sudo tee /root/mysql.txt

# just to be sure...
sudo yum remove -y mysql mysql-server mysql-devel mysql-libs.

# centos-7 & mariadb 10.1 configuration
# other centos ?
# https://downloads.mariadb.org/mariadb/repositories/

cat <<DELIM | sudo tee /etc/yum.repos.d/MariaDB.repo
# MariaDB 10.1 CentOS repository list - created 2016-09-16 08:41 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1

DELIM


sudo yum install -y MariaDB-server MariaDB-client

sudo systemctl start mariadb

sudo mysqladmin -u root -h localhost password $ROOT_MYSQL_PASSWORD
# interactive version
# sudo mysql_secure_installation

sudo systemctl enable mariadb

mysql -uroot -p$ROOT_MYSQL_PASSWORD <<MYSQL_SCRIPT
SHOW VARIABLES LIKE "%version%";
MYSQL_SCRIPT

mysql --version

echo "OK"
