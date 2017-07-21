#!/bin/sh

set -exuo pipefail

# git install is long, check before...
GIT_VERSION=$(git --version || echo "git not found")
if [ "${GIT_VERSION}" == "git version 1.9.5" ]; then
  echo "OK"
  exit 0
fi

sudo yum -y groupinstall "Development Tools"
sudo yum -y install zlib-devel perl-ExtUtils-MakeMaker asciidoc xmlto openssl-devel unzip

cd /tmp
# https://github.com/git/git/releases
wget -O git.zip 'https://github.com/git/git/archive/v1.9.5.zip'

unzip -o git.zip
cd git-1.9.5

make configure
./configure --prefix=/usr
make all doc
sudo make install install-doc install-html


git config --global user.name "llafuente"
git config --global user.email "llafuente@noboxout.com"

sudo yum -y install gitflow


echo "OK"
