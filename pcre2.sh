#!/bin/sh

cd /tmp
rm -rf pcre2
svn co svn://vcs.exim.org/pcre2/code/trunk pcre2
cd pcre2i
sh autogen.sh
CFLAGS='-O2 -Wall' ./configure --prefix=/usr
make
make install
