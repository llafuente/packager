#!bin/sh

set -exuo pipefail

cd /tmp
git clone git@github.com:libuv/libuv.git
cd libuv
sh autogen.sh
./configure
make
# make check
sudo make install
