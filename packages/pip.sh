#!/bin/sh

set -x
set -e

sudo yum install -y python

curl -s "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
sudo python get-pip.py
pip -V

echo "OK"
