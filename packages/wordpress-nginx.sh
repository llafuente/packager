#!/bin/sh
# sh wordpress-nginx.sh --target-dir=/var/www/html/wp0 --domain=example.com

set -exuo pipefail

SSL=0

for i in "$@"
do
case $i in
  --domain=*)
    DOMAIN="${i#*=}"
    shift # past argument=value
  ;;
  --target-dir=*)
    TARGET_DIR="${i#*=}"
    shift # past argument=value
  ;;
  --ssl)
    SSL=1
    shift # past argument=value
  ;;
  *)
    # unknown option
  ;;
esac
done

if [ -z ${DOMAIN} ]; then
  echo "--domain is required"
  echo "KO"
  exit 1
fi

if [ -z ${TARGET_DIR} ]; then
  echo "--target-dir is required"
  echo "KO"
  exit 1
fi

WP_NAME=$(basename ${TARGET_DIR})

echo $INSTALLER_PATH

sudo cp -rf "${INSTALLER_PATH}/nginx/global" /etc/nginx/sites-available/global

if [ $SSL -eq 1 ]; then
  SOURCE_FILE="${INSTALLER_PATH}/nginx/wordpress-site-ssl.conf"
else
  SOURCE_FILE="${INSTALLER_PATH}/nginx/wordpress-site.conf"
fi

DST_FILE="/etc/nginx/sites-available/${WP_NAME}-wordpress-site.conf"

sudo cp -rf ${SOURCE_FILE} ${DST_FILE}

sudo sed -i "s@root /var/www/html/;@root ${TARGET_DIR};@g" ${DST_FILE}
sudo sed -i "s@example.com@${DOMAIN}@g" ${DST_FILE}

echo ${DST_FILE}

sudo systemctl restart nginx

echo "OK"
