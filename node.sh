#!/bin/sh

mkdir /tmp/node/
cd /tmp/node/

# legacy node
# wget https://nodejs.org/dist/v0.10.40/node-v0.10.40-linux-x64.tar.gz
wget https://nodejs.org/dist/v4.3.1/node-v4.3.1-linux-x64.tar.gz
tar xsfv node-*-linux-*.tar.gz
cd node-*-linux-*

rm -f CHANGELOG.md
rm -f LICENSE
rm -f README.md
sudo cp -rf * /usr/local/

sudo /usr/local/bin/npm install -g yo grunt-cli browserify uglify-js bower
# angular-fullstack

echo "OK"
