#!bin/sh

set -x
set -e

for i in "$@"
do
case $i in
  --device=*)
    DEVICE="${i#*=}"
    shift # past argument=value
  ;;
  *)
    # unknown option
  ;;
esac
done

MOUNT=ebs_volume

if [ -z $DEVICE ]; then
  echo "--device required"
  echo "KO"
  exit 1
fi

sudo mkdir -p /media/${MOUNT}

FSTYPE=$(lsblk --output NAME,FSTYPE | grep ${DEVICE} | awk '{print $2}')

if [ "${FSTYPE}" -neq "xfs" ]; then
  sudo mkfs.xfs -f /dev/${DEVICE}
fi

sudo mount /dev/${DEVICE} /media/${MOUNT}


if [ ! -z $(which mysql) ]; then
  echo "moving mysql data to ebs"

  sudo systemctl stop mariadb
  
  sudo cp -R -p /var/lib/mysql /media/${MOUNT}/mysql
  sudo mv /var/lib/mysql /var/lib/mysql.back
  sudo ln -sf /media/${MOUNT}/mysql /var/lib/mysql

  sudo systemctl start mariadb
fi

if [ -d /var/www ] && [ ! -h /var/www ]; then
  echo "moving www data to ebs"

  sudo cp -R -p /var/www /media/${MOUNT}/www
  sudo mv /var/www /var/www.back
  sudo ln -sf /media/${MOUNT}/www /var/www
fi

sudo mkdir -p /media/${MOUNT}/log
for LOG_FOLDER in "nginx" "mysql" "php-fpm";
do
  if [ ! -h /var/log/${LOG_FOLDER} ]; then
    sudo mv /var/log/${LOG_FOLDER} /media/${MOUNT}/log/${LOG_FOLDER}
    sudo ln -sf /media/${MOUNT}/log/${LOG_FOLDER} /var/log/${LOG_FOLDER}
  fi
done
