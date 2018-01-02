#!/bin/sh

set -exuo pipefail

cat <<DELIM | sudo tee -a /etc/yum.repos.d/mongodb.repo
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

# if it fails to star with
#
# sudo cat /var/log/mongodb/mongod.log
#
#** WARNING: Readahead for /var/lib/mongo is set to 4096KB
#**          We suggest setting it to 256KB (512 sectors) or less
#**          http://dochub.mongodb.org/core/readahead
#journal dir=/var/lib/mongo/journal
#recover : no journal files present, no recovery needed
#
#ERROR: Insufficient free space for journal files
#Please make at least 3379MB available in /var/lib/mongo/journal or use --smallfiles
#
# exception in initAndListen: 15926 Insufficient free space for journals, terminating
#
# run the mongodb part of: aws/mount-ebs.sh

#mongod -v

sudo service mongod status

echo "OK"
