#!/bin/sh

sudo cat > /etc/yum.repos.d/mongodb.repo <<DELIM
[mongodb]
name=MongoDB Repository
baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/
gpgcheck=0
enabled=1
DELIM

sudo yum install -y mongodb-org

#TODO logs

sudo service mongod start
sudo chkconfig mongod on
