#!/bin/sh

# from http://www.unixmen.com/postgresql-9-4-released-install-centos-7/

sudo rpm -Uvh http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-1.noarch.rpm

#sudo yum update

sudo yum install -y postgresql94-server postgresql94-contrib postgresql94-libs

service postgresql-9.4 initdb
service postgresql-9.4 start
chkconfig postgresql-9.4 on

# systemctl enable postgresql-9.4
# systemctl start postgresql-9.4

# this should be part of the PATH?
# /usr/pgsql-9.4/bin

# postgres install under postgres use, so 'sudo - postgres'
