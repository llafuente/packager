#!/bin/sh

set -exuo pipefail

sh pip.sh

sudo pip install awscli


echo "OK"
