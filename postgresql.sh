#!/bin/sh

# from http://www.unixmen.com/postgresql-9-4-released-install-centos-7/

sudo rpm -Uvh http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-1.noarch.rpm

#sudo yum update

sudo yum install -y postgresql94-server postgresql94-contrib postgresql94-libs

# CENTOS 6
# sudo service postgresql-9.4 initdb
# sudo service postgresql-9.4 start
# sudo chkconfig postgresql-9.4 on

# CENTOS 7
sudo /usr/pgsql-9.4/bin/postgresql94-setup initdb
sudo systemctl enable postgresql-9.4
sudo systemctl start postgresql-9.4

# Optional

# sudo -u postgres psql
# \password postgres;
  # or

sudo -u postgres psql -e "ALTER USER postgres with encrypted password 'postgres';"

# create databse jsonb_test;
# grant all privileges on database jsonb_test to postgres;


cat <<DELIM | sudo tee /var/lib/pgsql/9.4/data/pg_hba.conf

local   all             all                                     peer
host    all             all             0.0.0.0/0               md5
host    all             all             ::1/128                 md5

DELIM

sudo systemctl restart postgresql-9.4
