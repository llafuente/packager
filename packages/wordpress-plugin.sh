#!/bin/sh
#ssh -i ~/.ssh/${AWS_CLIENT_PEM}.pem ec2-user@${INSTANCE_IP} "bash -s" -- < \
# ./wordpress-plugin.sh --url=https://downloads.wordpress.org/plugin/social-pug.zip \
# -- target-dir=/var/www/html/e-scenario/

set -exuo pipefail

for i in "$@"
do
case $i in
  --url=*)
    URL="${i#*=}"
    shift # past argument=value
  ;;
  --target-dir=*)
    TARGET_DIR="${i#*=}"
    shift # past argument=value
  ;;
  *)
    # unknown option
  ;;
esac
done

if [ -z ${TARGET_DIR} ]; then
  echo "--target-dir is required"
  echo "KO"
  exit 1
fi

cd ${TARGET_DIR}/wp-content/plugins
sudo wget ${URL} -O plugin.zip
sudo unzip plugin.zip
sudo rm plugin.zip

echo "OK"
