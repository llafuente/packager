#!/bin/sh

mkdir /tmp/node/
cd /tmp/node/

# legacy node
# wget https://nodejs.org/dist/v0.10.40/node-v0.10.40-linux-x64.tar.gz
wget https://nodejs.org/dist/v4.1.1/node-v4.1.1-linux-x64.tar.gz
tar xsfv node-*-linux-*.tar.gz
cd node-*-linux-*

# io.js
#wget https://iojs.org/dist/v3.3.0/iojs-v3.3.0-linux-x64.tar.xz
#tar xsfv iojs-*-linux-*.tar.xz
#cd iojs-*-linux-*

rm -f ChangeLog
rm -f LICENSE
rm -f README.mkdir
sudo cp -rf * /usr/local/

sudo /usr/local/bin/npm install -g yo grunt-cli browserify uglify-js bower
# angular-fullstack

echo "OK"
