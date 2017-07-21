#!/bin/sh

set -exuo pipefail

cat <<DELIM | sudo tee /etc/sysconfig/clock
ZONE="GMT"
UTC=false
ARC=false
DELIM

sudo rm -f /etc/localtime
sudo cp -f /usr/share/zoneinfo/Greenwich /etc/localtime

sudo yum -y install ntp

cat <<DELIM | sudo tee /etc/cron.hourly/ntp_sync.cron
#!/bin/bash

/usr/sbin/ntpdate hora.rediris.es >/dev/null 2>&1
DELIM

sudo chmod 755 /etc/cron.hourly/ntp_sync.cron
sudo /usr/sbin/ntpdate hora.rediris.es

RESULT=`date | grep GMT | wc -l`

#result
if [ "${RESULT}" == "1" ]
then
  echo "OK"
else
  echo "ERROR"
fi