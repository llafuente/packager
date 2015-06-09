#!/bin/sh

mkdir /tmp/node/
cd /tmp/node/
#wget http://nodejs.org/dist/v0.10.36/node-v0.10.36-linux-x64.tar.gz
#tar xsfv node-*-linux-*.tar.gz
#cd node-*-linux-*

wget https://iojs.org/dist/v2.1.0/iojs-v2.1.0-linux-x64.tar.xz
tar xsfv iojs-*-linux-*.tar.xz
cd iojs-*-linux-*

rm -f ChangeLog
rm -f LICENSE
rm -f README.mkdir
sudo cp -rf * /usr/local/

sudo /usr/local/bin/npm install -g yo grunt-cli browserify uglify-js bower
# angular-fullstack

echo "OK"
