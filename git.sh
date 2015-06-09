#!/bin/sh

sudo yum -y install zlib-devel perl-ExtUtils-MakeMaker asciidoc xmlto openssl-devel

cd /tmp
# https://github.com/git/git/releases
wget -O git.zip 'https://github.com/git/git/archive/v1.9.5.zip'

unzip git.zip
cd git-1.9.5

make configure
./configure --prefix=/usr
make all doc
sudo make install install-doc install-html


git config --global user.name "llafuente"
git config --global user.email "llafuente@noboxout.com"
