#!/bin/sh

set -exuo pipefail

sudo yum install -y fontconfig freetype libfreetype.so.6 libfontconfig.so.1 libstdc++.so.6
yum install urw-fonts

cd /tmp
wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.7-linux-x86_64.tar.bz2
tar xsfv phantomjs-*-linux-x86_64.tar.bz2*
cd phantomjs-*-linux-x86_64
sudo mv bin/phantomjs /usr/local/bin/phantomjs
