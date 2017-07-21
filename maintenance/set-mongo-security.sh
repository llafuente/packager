#!/bin/sh

set -exuo pipefail

sudo service mongod status

sudo service mongod stop

# sudo sed -i -e 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' /etc/mongod.conf
sudo sed -i -e 's/#security:/security:\n   authorization: enabled/g' /etc/mongod.conf


sudo service mongod start

sudo service mongod status

echo "OK"

security:
    authorization: enabled
storage:
   smallFiles: true