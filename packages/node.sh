#!/bin/sh

set -exuo pipefail

MODE="legacy"
for i in "$@"
do
case $i in
  --legacy=*)
    MODE="legacy"
    shift # past argument=value
  ;;
  --lts=*)
    MODE="lts"
    shift # past argument=value
  ;;
  --latest=*)
    MODE="latest"
    shift # past argument=value
  ;;
  *)
    # unknown option
  ;;
esac
done

sudo yum install -y wget

sudo rm -rf /tmp/node/
mkdir -p /tmp/node/
cd /tmp/node/

if [ "${MODE}" -eq "legacy" ]; then
  curl -o node.tar.gz https://nodejs.org/dist/v0.10.40/node-v0.10.40-linux-x64.tar.gz
elif [ "${MODE}" -eq "lts" ]; then
  #curl -o node.tar.gz https://nodejs.org/dist/v4.4.5/node-v4.4.5-linux-x64.tar.gz
  curl -o node.tar.gz https://nodejs.org/dist/v6.11.4/node-v6.11.4-linux-x64.tar.gz
else
  curl -o node.tar.gz https://nodejs.org/dist/v8.7.0/node-v8.7.0-linux-x64.tar.gz
fi

tar xsfv node.tar.gz > /dev/null
cd node-*

rm -f CHANGELOG.md
rm -f LICENSE
rm -f README.md
sudo cp -rf * /usr/local/

# sudo /usr/local/bin/npm update npm

echo "OK"
