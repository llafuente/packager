#!/bin/sh

set -exuo pipefail

cd /tmp
wget -O bison.tar.gz http://ftp.gnu.org/gnu/bison/bison-3.0.4.tar.gz
tar xvf bison.tar.gz
cd bison-*
./configure --prefix=/usr
make
sudo make install
