#!/bin/sh

set -ex

echo "downloading flex"
cd /tmp
wget -O flex.tar.gz https://github.com/westes/flex/releases/download/v2.6.1/flex-2.6.1.tar.gz
tar -xzf flex.tar.gz
cd flex-*
./configure --prefix=/usr
make
sudo make install
