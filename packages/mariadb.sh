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
  ROOT_MYSQL_PASSWORD=$(</dev/urandom tr -dc 'a-zA-Z0-9' | head -c 64 | sed -e 's/[\/&]/\\&/g')
fi

echo "Using password: $ROOT_MYSQL_PASSWORD"

# leave it somewhere known, because can be random
echo "Root MySQL Password: $ROOT_MYSQL_PASSWORD" | sudo tee -a /root/passwords.txt
echo -ne "$ROOT_MYSQL_PASSWORD" | sudo tee /root/mysql.txt

# just to be sure..
ALREADY=$( (mysql --version | grep "MariaDB") || echo)
if [ $? != 0 ] || [ -z "${ALREADY}" ]; then
  sudo yum remove -y mysql mysql-server mysql-devel mysql-libs.
fi

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

sudo mkdir -p /var/log/mysql/
sudo chown mysql:mysql /var/log/mysql/

ALREADY=$(grep '# mariadb.sh' /etc/my.cnf || echo)

if [ -z "${ALREADY}" ]; then
  cat <<DELIM | sudo tee -a /etc/my.cnf
# mariadb.sh
[mysqld]
general-log
general-log-file=/var/log/mysql/mysqld.log
log-output=file

slow_query_log = 1
long_query_time = 1
slow_query_log_file = /var/log/mysql/slow-queries.log

log-error=/var/log/mysql/mysql-error.log

#open-files-limit
#innodb_open_files
DELIM
fi

# rotate logs, daily with date, compressed, delayed...
cat <<DELIM | sudo tee /etc/logrotate.d/mysql
/var/log/mysql/*log {
    #missingok
    create 0644 mysql mysql
    daily
    rotate 14
    notifempty
    sharedscripts
    dateext
    dateformat .%Y-%m-%d
    compress
    compresscmd /usr/bin/xz
    compressoptions -9
    compressext .xz
    delaycompress
    postrotate
      # just if mysqld is really running
      if test -x /usr/bin/mysqladmin && \
         /usr/bin/mysqladmin ping &>/dev/null
      then
         /usr/bin/mysqladmin flush-logs
      fi
    endscript
}
DELIM


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
