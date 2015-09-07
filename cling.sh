#!/bin/sh

cd /tmp
# wget https://ecsft.cern.ch/dist/cling/current/cling-Fedora20-x86_64-4b08f20793.tar.bz2
wget https://ecsft.cern.ch/dist/cling/current/cling-Fedora20-x86_64-13218860da.tar.bz2
tar xjvf cling-Fedora20-x86_64-*.tar.bz2
cd cling-Fedora20-x86_64-*
rm -rf ./docs
rm -rf ./include/clang
rm -rf ./include/clang-c
rm -rf ./include/llvm
rm -rf ./include/llvm-c
rm -rf ./share/llvm
rm -rf ./lib/clang/
rm -f ./bin/llvm*
rm -f ./bin/clang*
rm -rf ./bin/opt
rm -rf ./bin/lli-child-target
rm -rf ./bin/lli
rm -rf ./bin/llc
rm -rf ./lib/libLLVM*
rm -rf ./lib/libclang*

sudo cp -rf * /usr/local/
