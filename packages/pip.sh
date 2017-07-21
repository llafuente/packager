#!/bin/sh

set -exuo pipefail

sudo yum install -y python

curl -s "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
sudo python get-pip.py
pip -V

echo "OK"
