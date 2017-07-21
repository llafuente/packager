{{< highlight bash >}}
### for a single command
your-failure-command || echo


### for multiline / zones

set +e
your-failure-command
your-failure-command2
set -e
{{< /highlight >}}#!bin/sh

set -exuo pipefail

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

FSTYPE=$(lsblk --output NAME,FSTYPE | (grep "${DEVICE}" || echo) | awk '{print $2}')

if [ "${FSTYPE}" != "xfs" ]; then
  sudo mkfs.xfs -f "/dev/${DEVICE}"
  # perf: write all 16Kb blocks of the EBS
  # sudo dd if="/dev/${DEVICE}" of=/dev/null bs=16384
fi

sudo mount /dev/${DEVICE} /media/${MOUNT}


if [ -x "$(command -v mysql)" ] && [ ! -h /var/lib/mysql ]; then
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
  echo "moving log data to ebs"
  if [ -d "/var/log/${LOG_FOLDER}" ] && [ ! -h "/var/log/${LOG_FOLDER}" ]; then
    sudo mv /var/log/${LOG_FOLDER} /media/${MOUNT}/log/${LOG_FOLDER}
    sudo ln -sf /media/${MOUNT}/log/${LOG_FOLDER} /var/log/${LOG_FOLDER}
  fi
done

if [ -x "$(command -v mongo)" ] && [ ! -h /var/lib/mongo ]; then
  echo "moving mongo data to ebs"

  sudo systemctl stop mongod

  sudo cp -R -p /var/lib/mongo /media/${MOUNT}/mongo
  sudo mv /var/lib/mongo /var/lib/mongo.back
  sudo ln -sf /media/${MOUNT}/mongo /var/lib/mongo

  sudo systemctl start mongod
fi



echo "OK"
