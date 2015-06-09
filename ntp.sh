#!/bin/sh
echo 'ZONE="GMT"' > /etc/sysconfig/clock
echo 'UTC=false' >> /etc/sysconfig/clock
echo 'ARC=false' >> /etc/sysconfig/clock
rm /etc/localtime
cp -f /usr/share/zoneinfo/Greenwich /etc/localtime

yum -y install ntp

echo '#!/bin/bash' > /etc/cron.hourly/ntp_sync.cron
echo '/usr/sbin/ntpdate hora.rediris.es >/dev/null 2>&1' >> /etc/cron.hourly/ntp_sync.cron
chmod 755 /etc/cron.hourly/ntp_sync.cron
/usr/sbin/ntpdate hora.rediris.es

RESULT=`date | grep GMT | wc -l`

#result
if [ "${RESULT}" == "1" ]
then
  echo "OK"
else
  echo "ERROR"
fi