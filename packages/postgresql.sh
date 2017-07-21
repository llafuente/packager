#!/bin/sh

set -exuo pipefail

# from http://www.unixmen.com/postgresql-9-4-released-install-centos-7/

sudo rpm -Uvh http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-1.noarch.rpm

sudo yum install -y postgresql94-server postgresql94-contrib postgresql94-libs

# CENTOS 6
# sudo service postgresql-9.4 initdb
# sudo service postgresql-9.4 start
# sudo chkconfig postgresql-9.4 on

# CENTOS 7
sudo /usr/pgsql-9.4/bin/postgresql94-setup initdb
sudo systemctl enable postgresql-9.4
sudo systemctl start postgresql-9.4

# set password for postgres user
sudo -u postgres psql -c "ALTER USER postgres with encrypted password 'postgres';"

cat <<DELIM | sudo tee /var/lib/pgsql/9.4/data/pg_hba.conf

local   all             all                                     peer
host    all             all             0.0.0.0/0               md5
host    all             all             ::1/128                 md5

DELIM

sudo systemctl restart postgresql-9.4


#sudo -u postgres psql -c "create database portal_test;"
#sudo -u postgres psql -c "grant all privileges on database portal_test to postgres;"
