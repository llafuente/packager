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

# Optional

# sudo -u postgres psql
# \password postgres;
  # or
# ALTER USER postgres with encrypted password 'your_password';

# create databse jsonb_test;
# grant all privileges on database jsonb_test to postgres;


#cat >/var/lib/pgsql/9.4/data/pg_hba.conf <<DELIM
#
#local   all             all                                     peer
#host    all             all             0.0.0.0/0               md5
#host    all             all             ::1/128                 md5
#
#DELIM
