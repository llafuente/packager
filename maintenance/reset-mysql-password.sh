#!/bin/sh

set -exuo pipefail

sudo service mysqld stop
# sometimes do not stop... use the force!!!
sudo pgrep mysql | sudo xargs kill -9

mysqld_safe --skip-grant-tables &

cat <<SQL | mysql -uroot -h 127.0.0.1
use mysql;
update user set password=PASSWORD("root") where User='root';
flush privileges;

SQL

service mysqld stop
service mysqld start

mysql -h 127.0.0.1 -u root -p

